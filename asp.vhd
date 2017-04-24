library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
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

type states is (IDLE, STORE_CLEAR, STORE_WAIT, STORE_DATA, INVOKE, INVOKE_BUSY, SEND_DATA, SEND_PAUSE);	-- states
signal CS, NS	: states := IDLE;

signal d_in_copy	: std_logic_vector(31 downto 0) := (others => '0');

type data_vector is array (0 to N - 1) of std_logic_vector(15 downto 0);
signal s_A, s_B : data_vector := (others => (others =>'0'));

type output_vector is array (0 to 3) of std_logic_vector(31 downto 0);
signal s_output_buffer 							: output_vector := (others => (others =>'0'));
signal s_words_sent, s_words_to_send		: std_logic_vector(1 downto 0) := (others => '0');  -- max 4 packets
signal s_words_stored, s_words_to_store	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_invoke_en, s_invoke_done	: std_logic := '0';

signal s_op_code	: std_logic_vector(3 downto 0) := (others => '0');

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
						NS <= STORE_CLEAR;

					when "0001" =>
						NS <= STORE_WAIT;

					when "0010" =>
						NS <= INVOKE;

					when others =>
						report "STATE TRANSITION: BAD OP CODE";
						NS <= INVOKE;
				end case;
			else
				NS <= IDLE;
			end if;

		when STORE_CLEAR =>
			NS <= IDLE;

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
			report "STATE TRANSITION: BAD STATE";
			NS <= IDLE;
			
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	case CS is	-- must cover all states
		when IDLE =>
			s_invoke_en <= '0';

			busy <= '0';
			res_ready <= '0';
			d_out <= (others => '0');

		when STORE_CLEAR =>
			s_A <= (others => (others =>'0'));
			s_B <= (others => (others =>'0'));

		when STORE_WAIT =>


		when STORE_DATA =>


		when INVOKE =>


		when INVOKE_BUSY =>


		when SEND_DATA =>


		when SEND_PAUSE =>


		when others =>
			report "STATE OUTPUT: BAD STATE";
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
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;


---------------------------------------------------------------------------------------------------
end architecture;