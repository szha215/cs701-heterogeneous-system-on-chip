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
		opcode		:	in std_logic_vector(3 downto 0);

		data_out		:	out std_logic_vector(15 downto 0);
		zero			:	out std_logic;
		overflow		:	out std_logic
		);
end entity alu;

---------------------------------------------------------------------------------------------------
architecture behaviour of alu is
signal t_data_out : std_logic_vector(16 downto 0) := (others => '0');
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
begin

t_data_out <=  '0' & data_A 						when opcode = "0000" else
'0' & (data_A + '1') 								when opcode = "0001" else
('0' & data_A) + ('0' & data_B)					when opcode = "0010" else
'0' & (data_A + data_B + 1) 						when opcode = "0011" else
'0' & (data_A + (NOT data_B))		 				when opcode = "0100" else
(('0' & data_A) + (NOT ('0' & data_B)) + '1')when opcode = "0101" else
'0' & (data_A - '1')									when opcode = "0110" else
'0' & data_B											when opcode = "0111" else
'0' & (data_A AND data_B)							when opcode = "1000" else
'0' & (data_A AND data_B) 							when opcode = "1001" else
'0' & (data_A OR data_B)							when opcode = "1010" else
'0' & (data_A OR data_B)							when opcode = "1011" else
'0' & (data_A XOR data_B)							when opcode = "1100" else
'0' & (NOT data_A)									when opcode = "1110" else
'0' & (NOT data_B)									when opcode = "1111";

data_out <= t_data_out(15 downto 0);
overflow <= t_data_out(16);
zero <= '1' when data_A + (NOT data_B) + '1' = "0000000000000000" else '0';
---------------------------------------------------------------------------------------------------
end architecture;