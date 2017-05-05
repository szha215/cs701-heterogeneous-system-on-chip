library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
--use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity alu is
-- generic and port declration here
port(	
		data_A		:	in std_logic_vector(15 downto 0);
		data_B		:	in std_logic_vector(15 downto 0);
		alu_op		:	in std_logic_vector(2 downto 0);

		data_out		:	out std_logic_vector(15 downto 0);
		zero			:	out std_logic;
		overflow		:	out std_logic
		);
end entity alu;

---------------------------------------------------------------------------------------------------
architecture behaviour of alu is

signal s_data_out : std_logic_vector(16 downto 0) := (others => '0');
signal s_max		: std_logic_vector(15 downto 0) := (others => '0');
---------------------------------------------------------------------------------------------------
begin

process(data_A,data_B)
begin
	if(data_A > data_B) then
		s_max <= data_A;
	else
		s_max <= data_B;
	end if;
end process;



with alu_op select s_data_out <=
	('0' & data_a) + ('0' & data_b)					when "000",  -- a + b
	('0' & data_a) + (not ('0' & data_b)) + '1'  when "001",  -- a - b
	'0' & (data_a and data_b)							when "010",  -- a & b
	'0' & (data_a or data_b)	 						when "011",  -- a | b
	'0' & s_max	 											when "100",
	"XXXXXXXXXXXXXXXXX"									when others;
	
--with alu_op select s_data_out <=
--	'0' & data_A 											when "0000",  -- A
--	'0' & (data_A + '1') 								when "0001",  
--	('0' & data_A) + ('0' & data_B)					when "0010",  -- A + B
--	'0' & (data_A + data_B + 1) 						when "0011",
--	'0' & (data_A + (NOT data_B))		 				when "0100",
--	(('0' & data_A) + (NOT ('0' & data_B)) + '1')when "0101",  -- A - B
--	'0' & (data_A - '1')									when "0110",
--	'0' & data_B											when "0111",
--	'0' & (data_A AND data_B)							when "1000",
--	'0' & (data_A AND data_B) 							when "1001",
--	'0' & (data_A OR data_B)							when "1010",
--	'0' & (data_A OR data_B)							when "1011",
--	'0' & (data_A XOR data_B)							when "1100",
--	'0' & (NOT data_A)									when "1110",
--	'0' & (NOT data_B)									when "1111",
--	"XXXXXXXXXXXXXXXXX"									when others;

overflow <= s_data_out(16);
data_out <= s_data_out(15 downto 0);

zero <= '1' when data_A + (NOT data_B) + '1' = "0000000000000000" else
		  '0';

---------------------------------------------------------------------------------------------------
end architecture;