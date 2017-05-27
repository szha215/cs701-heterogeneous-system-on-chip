library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_counter is
	port(
		clk			: in std_logic;
		reset			: in std_logic;
		reset_int	: out std_logic
	);
end reset_counter;

architecture beh of reset_counter is
	
	signal res_cnt	: unsigned(2 downto 0) := "000";
	attribute altera_attribute : string;
	attribute altera_attribute of res_cnt : signal is "POWER_UP_LEVEL=LOW";

begin
	process(clk, reset)
	begin
		if rising_edge(clk) then
			if (res_cnt/="111") then
				res_cnt <= res_cnt+1;
			end if;
			
			if reset = '1' then
				res_cnt <= "000";
				reset_int <= '1';
			else
				reset_int <= not res_cnt(0) or not res_cnt(1) or not res_cnt(2);
			end if;
		end if;
	end process;
end architecture;