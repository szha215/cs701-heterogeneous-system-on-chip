library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;


---------------------------------------------------------------------------------------------------
entity reg_file is
-- generic and port declration here
generic(
	constant reg_num 	 : positive := 16;
	constant reg_width : positive := 16
);
port(	clk			: 	in std_logic;
		reset			: 	in std_logic;
		wr_en			:	in std_logic; 
		rd_reg1		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		rd_reg2		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		wr_reg		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		wr_data		: 	in std_logic_vector(reg_width - 1 downto 0);

		data_out_a	:	out std_logic_vector(reg_width - 1 downto 0);
		data_out_b	:	out std_logic_vector(reg_width - 1 downto 0)
		);
end entity reg_file;

---------------------------------------------------------------------------------------------------
architecture behaviour of reg_file is

type reg_arr is array (0 to reg_num - 1) of std_logic_vector(reg_width - 1 downto 0);
signal registers : reg_arr := ((others => (others => '0')));
signal s_data_out_a, s_data_out_b : std_logic_vector(reg_width - 1 downto 0) := (others => '0');
---------------------------------------------------------------------------------------------------
-- component declaration here
begin


reg_file_proc : process( clk,reset )
begin
	if(reset = '1') then
		--clean all the registers
		clean_registers : for i in 0 to reg_num - 1 loop
			registers(i) <= (others => '0');
		end loop ; -- clean_registers
	elsif (rising_edge(clk)) then
		if(wr_en = '1') then
			--write 
			registers(to_integer(unsigned(wr_reg))) <= wr_data;
			--output addr when write 
			s_data_out_a <= (reg_width - 1 downto rd_reg1'length => '0') & rd_reg1;
			s_data_out_b <= (reg_width - 1 downto rd_reg2'length => '0') & rd_reg2;
		else
			--read
			--s_data_out_a <= 
			s_data_out_b <= registers(to_integer(unsigned(rd_reg2)));
		end if;

	end if;
end process ; -- reg_file_proc

data_out_a <= registers(to_integer(unsigned(rd_reg1)));
data_out_b <= s_data_out_b;

---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
end architecture;