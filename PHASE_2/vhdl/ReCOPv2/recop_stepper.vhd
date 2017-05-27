library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity recop_stepper is
	port(
		clk	: in std_logic;
		iBtn	: in std_logic;
		step	: out std_logic
	);
end recop_stepper;

architecture beh of recop_stepper is
begin
	process(clk, iBtn)
		variable pressed : std_logic := '0';
	begin
		if rising_edge(clk) then
			step <= '0';
			
			if (iBtn = '0' and pressed = '0') then
				step <= '1';
				pressed := '1';
			end if;
			
			if iBtn = '1' then
				pressed := '0';
			end if;
		end if;	
	end process;
end architecture;