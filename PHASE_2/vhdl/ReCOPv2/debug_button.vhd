library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.recop_types.all;
use work.various_constants.all;

-- this component generates a pulse (output pin continue) for one clock cycles when the button input is high for 100 undisrupted clock cycle

entity continue_button is
	port (
		clk: in bit_1;
		button: in bit_1;
		continue : out bit_1
		);
end continue_button;

architecture beh of continue_button is

begin
	process (clk)
		variable counter: integer range 0 to 127 :=0;
		variable state : bit_1 := '0';
	begin
		if rising_edge(clk) then
			-- idle state
			if state = '0' then
				if button = '1' then
					-- check for button press for 100 clk cycles
					if counter < 100 then
						counter := counter +1;
						continue <= '0';
					else
						-- if button is held for 100 cycles, assert output pin "continue"
						state := '1'; -- go to next state that will deassert the continue output in the next cycle
						counter := 0;
						continue <= '1';
					end if;
				else
					-- reset if button is released
					counter := 0;
					continue <= '0';
				end if;
			else
				-- pull continue pin low after ONE cycle
				continue <= '0';
				counter := 0;
				if button = '0' then
					-- reset to allow the next button press to be detected 
					state := '0';
				end if;
			end if;
		end if;
	end process;
end beh;
