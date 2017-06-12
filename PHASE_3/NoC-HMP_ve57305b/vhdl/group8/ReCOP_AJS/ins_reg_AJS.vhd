library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;


entity ins_reg_AJS is
generic(
	constant reg_width 	: 	positive := 16
);

port (
	clk		:	in std_logic;
	reset		:	in std_logic;
	data_in	:	in std_logic_vector(reg_width - 1 downto 0);
	ir_wr_en	:	in std_logic_vector(1 downto 0);
	

	upper_0	:	out std_logic_vector(7 downto 0);
	upper_1	:	out std_logic_vector(3 downto 0);
	upper_2	:	out std_logic_vector(3 downto 0);

	lower_0	:	out std_logic_vector(reg_width - 1 downto 0) 			
) ;
end entity ; -- ins_reg

architecture behaviour of ins_reg_AJS is
signal s_upper_out,s_lower_out 	: std_logic_vector(reg_width - 1 downto 0) := (others => '0');


component gen_reg_AJS
	generic(
		constant reg_width : positive := 16
	);
	port(
		clk		:	in std_logic;
		reset		:	in std_logic;
		wr_en		:	in std_logic;
		data_in	:	in	std_logic_vector(reg_width - 1 downto 0);
		
		data_out :	out std_logic_vector(reg_width - 1 downto 0) 

	);
end component;

begin

upper_reg : gen_reg_AJS
	generic map(
		reg_width => reg_width
	)
	port map(
		clk	=>	clk,
		reset => reset,
		wr_en => ir_wr_en(1),

		data_in => data_in,
		data_out => s_upper_out

	);

lower_reg : gen_reg_AJS
	generic map(
		reg_width => reg_width
	)
	port map(
		clk	=>	clk,
		reset => reset,
		wr_en => ir_wr_en(0),

		data_in => data_in,
		data_out => s_lower_out

	);

upper_0 <= s_lower_out(15 downto 8);
upper_1 <= s_lower_out(7 downto 4);
upper_2 <= s_lower_out(3 downto 0);

lower_0 <= s_upper_out;

end architecture;