library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;


---------------------------------------------------------------------------------------------------
entity gen_reg is
-- generic and port declration here
generic(
	
	constant reg_width : positive := 16
);
port(	clk			: 	in std_logic;
		reset			: 	in std_logic;
		wr_en			:	in std_logic; 
		
		data_in		:	in std_logic_vector(reg_width - 1 downto 0);


		data_out 	:	out std_logic_vector(reg_width - 1 downto 0)
		
		
		);
end entity gen_reg;

---------------------------------------------------------------------------------------------------
architecture behaviour of gen_reg is
signal s_data_out :	std_logic_vector(reg_width - 1 downto 0) := (others => '0');
---------------------------------------------------------------------------------------------------
-- component declaration here
begin


reg_file_proc : process( clk,reset )
begin
	if(reset = '1') then
		s_data_out <= (others => '0');
		
	elsif (rising_edge(clk)) then
		if(wr_en = '1') then
			s_data_out <= data_in;
		end if;

	end if;
end process ; -- reg_file_proc

data_out <= s_data_out;

---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
end architecture;