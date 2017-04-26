library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
--use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity asp is
-- generic and port declration here
generic(
	constant N : positive := 8;
	constant L : positive := 4
);
port(	clk		: in std_logic;
		reset		: in std_logic;
		valid		: in std_logic;
		d_in		: in std_logic_vector(31 downto 0);

		busy			: out std_logic;
		res_ready	: out std_logic;
		d_out			: out std_logic_vector(31 downto 0)
		);
end entity asp;

---------------------------------------------------------------------------------------------------
architecture behaviour of asp is
-- type, signal, constant declarations here

type states is (IDLE, STORE_INIT, STORE_WAIT, STORE_DATA, INVOKE, INVOKE_BUSY, SEND_DATA, SEND_PAUSE);	-- states
signal CS, NS	: states := IDLE;

signal d_in_copy	: std_logic_vector(31 downto 0) := (others => '0');

type data_vector is array (0 to N - 1) of std_logic_vector(15 downto 0);
signal s_A, s_B : data_vector := (others => (others =>'0'));

type output_vector is array (0 to 3) of std_logic_vector(31 downto 0);
signal s_output_buffer 							: output_vector := (others => (others =>'0'));
signal s_words_sent, s_words_to_send		: std_logic_vector(1 downto 0) := (others => '0');  -- max 4 packets
signal s_words_stored, s_words_to_store	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_mem_sel		: std_logic := '0';
signal s_store_addr	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_invoke_en, s_invoke_init, s_invoke_done	: std_logic := '0';
signal s_start_addr, s_end_addr		: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_op_code	: std_logic_vector(3 downto 0) := (others => '0');
signal s_pointer : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declaration here


---------------------------------------------------------------------------------------------------
begin
-- component wiring here


---------------------------------------------------------------------------------------------------
state_updater: process(clk, reset)
begin
	if (reset = '1') then
		CS <= IDLE;
	elsif (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(CS, valid)
begin
	case CS is	-- must cover all states
		when IDLE =>
			if (valid = '1') then
				case (d_in(25 downto 22)) is
					when "0000" =>
						NS <= INVOKE;

					when "0001" =>
						NS <= STORE_INIT;

					when "0010" =>
						NS <= INVOKE;

					when others =>
						NS <= INVOKE;
				end case;

			else
				NS <= IDLE;
			end if;

		when STORE_INIT =>
			NS <= STORE_WAIT;

		when STORE_WAIT =>
			if (valid = '1') then
				NS <= STORE_DATA;
			else
				NS <= STORE_WAIT;
			end if;

		when STORE_DATA =>
			if (s_words_stored = s_words_to_store) then
				NS <= SEND_DATA;
			else
				NS <= STORE_WAIT;
			end if;

		when INVOKE =>
			NS <= INVOKE_BUSY;

		when INVOKE_BUSY =>
			if (s_invoke_done = '1') then
				NS <= SEND_DATA;
			else
				NS <= INVOKE_BUSY;
			end if;

		when SEND_DATA =>
			if (s_words_sent = s_words_to_send) then
				NS <= IDLE;
			else
				NS <= SEND_PAUSE;
			end if;

		when SEND_PAUSE =>
			NS <= SEND_DATA;

		when others =>
			report "STATE TRANSITION: BAD STATE" severity error;
			NS <= IDLE;
			
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	case CS is
		when IDLE =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			s_words_stored <= (others => '0');
			s_words_sent <= (others => '0');

			busy <= '0';
			res_ready <= '0';
			d_out <= (others => '0');

		when STORE_INIT =>
			--s_A <= (others => (others =>'0'));
			--s_B <= (others => (others =>'0'));
			report "STORE INIT: words to store = " & integer'image(conv_integer(unsigned(d_in_copy(integer(ceil(log2(real(N)))) - 1  downto 0))));
			s_words_to_store <= d_in_copy(integer(ceil(log2(real(N)))) - 1  downto 0) - '1';
			s_mem_sel <= d_in_copy(17);

		when STORE_WAIT =>


		when STORE_DATA =>
			report "STORE ADDR = " & integer'image(conv_integer(unsigned(d_in_copy(24 downto 16))));
			report "STORE DATA = " & integer'image(conv_integer(unsigned(d_in_copy(15 downto 0))));
			if (s_mem_sel = '1') then  -- B
				s_B(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			else
				s_A(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			end if;

			s_words_stored <= s_words_stored + '1';

		when INVOKE =>
			s_invoke_en <= '1';
			s_invoke_init <= '1';

			s_op_code <= d_in_copy(25 downto 22);

			busy <= '1';
			res_ready <= '0';

		when INVOKE_BUSY =>
			report "OP CODE = " & integer'image(conv_integer(unsigned(s_op_code)));

			s_invoke_en <= '1';
			s_invoke_init <= '0';

			busy <= '1';
			res_ready <= '0';

		when SEND_DATA =>

			s_invoke_en <= '0';
			s_invoke_init <= '0';

			busy <= '1';
			res_ready <= '1';

		when SEND_PAUSE =>

			s_invoke_en <= '1';
			s_invoke_init <= '0';

			busy <= '1';
			res_ready <= '0';

		when others =>
			report "STATE OUTPUT: BAD STATE" severity error;
			null;
			
	end case;
end process output_logic;

---------------------------------------------------------------------------------------------------
-- other processes here
copy_d_in : process(clk)
begin
	if (rising_edge(clk)) then
		if (valid = '1') then
			d_in_copy <= d_in;
			--report "Coping d_in = " & integer'image(conv_integer(unsigned(d_in(30 downto 0))));
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
invoke_process : process(clk, s_invoke_en)
begin
	if (rising_edge(clk)) then
		if (s_invoke_en = '1') then

			if (s_invoke_init = '1') then
				s_pointer <= s_start_addr;
			else
				s_pointer <= s_pointer + '1';
			end if;

			case(s_op_code) is
			
				when "0010" =>	-- XOR A


				when "0011" => -- XOR B


				when "0100" => -- MAC


				when "0101" => -- AVE A


				when "0110" => -- AVE B
					
			
				when others =>
					report "INVOKE: bad OP" severity error;
			
			end case ;
		else
			s_output_buffer <= (others => (others => '0'));
			s_pointer <= (others => '0');
		end if;
	end if;

end process;

---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;


---------------------------------------------------------------------------------------------------
end architecture;