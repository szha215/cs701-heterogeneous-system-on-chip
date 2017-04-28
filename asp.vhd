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

-- Control signals
signal words_stored_inc_en	: std_logic := '0';
signal op_ld, start_addr_ld, end_addr_ld, mem_sel_ld, src_port_ld, dest_port_ld, a_ld, b_ld	: std_logic := '0';
signal words_stored_res	: std_logic := '0';
signal d_out_sel, ab_d_sel	: std_logic_vector(1 downto 0) := (others => '0');

signal cmp_store : std_logic := '0';


-- Datapath

signal s_op_code	: std_logic_vector(3 downto 0) := (others => '0');
signal s_start_addr, s_end_addr		: std_logic_vector(8 downto 0) := (others => '0');
signal s_mem_sel		: std_logic := '0';




type output_vector is array (0 to 3) of std_logic_vector(31 downto 0);
signal s_output_buffer 							: output_vector := (others => (others =>'0'));
signal s_words_sent, s_words_to_send		: std_logic_vector(1 downto 0) := (others => '0');  -- max 4 packets
signal s_words_stored, s_words_to_store	: std_logic_vector(8 downto 0) := (others => '0');

signal s_store_addr	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_invoke_en, s_invoke_init, s_invoke_done	: std_logic := '0';
signal s_src_port, s_dest_port	: std_logic_vector(3 downto 0) := (others => '0');

signal s_pointer : std_logic_vector(8 downto 0) := (others => '0');

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
state_transition_logic : process(clk)
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
			if (cmp_store = '1') then
				NS <= SEND_DATA;
			elsif (valid = '1') then
				NS <= STORE_DATA;
			else
				NS <= STORE_WAIT;
			end if;

		when STORE_DATA =>
			NS <= STORE_WAIT;

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
	op_ld <= '0';
	start_addr_ld <= '0';
	mem_sel_ld <= '0';
	words_stored_res <= '0';
	words_stored_inc_en <= '0';
	src_port_ld <= '0';
	dest_port_ld <= '0';

	case CS is
		when IDLE =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			words_stored_res <= '1';
			s_words_sent <= (others => '0');

			busy <= '0';
			res_ready <= '0';
			d_out <= (others => '0');

		when STORE_INIT =>
			--s_A <= (others => (others =>'0'));
			--s_B <= (others => (others =>'0'));
			
			s_invoke_init <= '1';
			busy <= '0';
			
			report "STORE INIT: words to store = " & integer'image(conv_integer(unsigned(d_in_copy(integer(ceil(log2(real(N)))) - 1  downto 0))));
			start_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_ld <= '1';

		when STORE_WAIT =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			s_words_sent <= (others => '0');

			busy <= '0';
			res_ready <= '0';
			d_out <= (others => '0');

		when STORE_DATA =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			words_stored_inc_en <= '1';

			-- s_words_stored <= (others => '0');
			s_words_sent <= (others => '0');

			busy <= '1';
			res_ready <= '0';
			d_out <= (others => '0');
			
			--report "STORE ADDR = " & integer'image(conv_integer(unsigned(d_in_copy(24 downto 16))));
			--report "STORE DATA = " & integer'image(conv_integer(unsigned(d_in_copy(15 downto 0))));
			--if (s_mem_sel = '1') then  -- B
			--	s_B(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			--else
			--	s_A(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			--end if;


		when INVOKE =>
			s_invoke_en <= '1';
			s_invoke_init <= '1';

			op_ld <= '1';
			src_port_ld <= '1';

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
			if (s_mem_sel = '1') then  -- B
				d_out <= "11000100010010000000000000010001";
			else
				d_out <= "11000100010010000000000000000001";
			end if;

		when SEND_PAUSE =>

			s_invoke_en <= '1';
			s_invoke_init <= '0';

			busy <= '1';
			res_ready <= '0';

		when others =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			s_words_sent <= (others => '0');

			busy <= '0';
			res_ready <= '0';
			d_out <= (others => '0');
			
			report "STATE OUTPUT: BAD STATE" severity error;
			
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
	s_invoke_done <= '0';

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
op_code_process : process (clk, op_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (op_ld = '1') then
			s_op_code <= d_in_copy(25 downto 22);
		else
			s_op_code <= s_op_code;
		end if;
	end if;	
end process;

---------------------------------------------------------------------------------------------------
start_addr_process : process(clk, start_addr_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (start_addr_ld = '1') then
			s_start_addr <= d_in_copy(8 downto 0);
		else
			s_start_addr <= s_start_addr;
		end if;
	end if;

	s_words_to_store <= s_start_addr;

end process;

---------------------------------------------------------------------------------------------------
end_addr_process : process(clk, end_addr_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (end_addr_ld = '1') then
			s_end_addr <= d_in_copy(17 downto 9);
		else
			s_end_addr <= s_end_addr;
		end if;
	end if;
end process ; -- end_addr_process

---------------------------------------------------------------------------------------------------
mem_sel_process : process(clk, mem_sel_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (mem_sel_ld = '1') then
			s_mem_sel <= d_in_copy(17);
		else
			s_mem_sel <= s_mem_sel;
		end if;
	end if;
end process ; -- mem_sel_process

---------------------------------------------------------------------------------------------------
words_stored_process : process(clk, words_stored_inc_en, words_stored_res)
begin
	if (rising_edge(clk)) then
		if (words_stored_res = '1') then
			s_words_stored <= (others => '0');
		elsif (words_stored_inc_en = '1') then
			s_words_stored <= s_words_stored + '1';
		else
			s_words_stored <= s_words_stored;
		end if;
	end if;
end process ; -- words_stored_process

---------------------------------------------------------------------------------------------------
src_port_process : process(clk, src_port_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (src_port_ld = '1') then
			s_src_port <= d_in_copy(21 downto 18);
		else
			s_src_port <= s_src_port;
		end if;
	end if;
end process ; -- src_port_process

---------------------------------------------------------------------------------------------------
dest_port_process : process(clk, dest_port_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (dest_port_ld = '1') then
			s_dest_port <= d_in_copy(29 downto 26);
		else
			s_dest_port <= s_dest_port;
		end if;
	end if;
end process ; -- dest_port_process

---------------------------------------------------------------------------------------------------
store_complete : process(s_words_to_store, s_words_stored)
begin
	if (s_words_to_store = s_words_stored) then
		cmp_store <= '1';
	else
		cmp_store <= '0';
	end if;
end process ; -- store_complete

---------------------------------------------------------------------------------------------------
vector_a_store : process(clk, ab_d_sel, a_ld, d_in_copy)
begin
	
end process ; -- vector_a_store

---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;


---------------------------------------------------------------------------------------------------
end architecture;