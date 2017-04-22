library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity recop is
-- generic and port declration here

port(	clk		: in std_logic;
		reset		: in std_logic;
		valid		: in std_logic
		
		);
end entity recop;

---------------------------------------------------------------------------------------------------
architecture behaviour of recop is
-- type, signal, constant declarations here

type states is (idle, XXXXXX);	-- states

signal CS, NS	: states := idle;

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
state_transition_logic : process(CS, NS)
begin
	case CS is	-- must cover all states
		when idle =>
			null; -- some condition to set NS
			
		when XXXXXX =>
			null;
			
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	case CS is	-- must cover all states
		when idle =>
			null; -- output signals go here
			
		when XXXXXX =>
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