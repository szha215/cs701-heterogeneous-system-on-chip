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

type states is (idle, STORE_CLEAR, STORE_WAIT, STORE_DATA, INVOKE_XOR, SEND_DATA);	-- states
signal CS, NS	: states := idle;

type data_vectors is array (0 to N - 1) of std_logic_vector(15 downto 0);
signal A, B : data_vectors := ((others=> (others=>'0')));

signal s_words_stored, s_words_to_store	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);

---------------------------------------------------------------------------------------------------
-- component declaration here


---------------------------------------------------------------------------------------------------
begin
-- component wiring here


---------------------------------------------------------------------------------------------------
state_updater: process(clk, reset)
begin
	if (reset = '1') then
		CS <= idle;
	elsif (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(CS, valid)
begin
	case CS is	-- must cover all states
		when idle =>
			if (valid = '1') then
				case (d_in(25 downto 22)) is
					when "0000" =>
						NS <= STORE_CLEAR;

					when "0001" =>
						NS <= STORE_WAIT;

					when "0010" =>
						NS <= INVOKE_XOR;

					when others =>
						report "STATE TRANSITION: BAD OP CODE";
						NS <= idle;
				end case;
			else
				NS <= idle;
			end if;

		when STORE_CLEAR =>
			NS <= idle;

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

		when others =>
			report "STATE TRANSITION: BAD STATE";
			NS <= idle;
			
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	case CS is	-- must cover all states
		when idle =>
			null; -- output signals go here
			
		when others =>
			report "STATE OUTPUT: BAD STATE";
			null;
			
	end case;
end process output_logic;

---------------------------------------------------------------------------------------------------
-- other processes here



---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;


---------------------------------------------------------------------------------------------------
end architecture;