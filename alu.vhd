library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
--use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity alu is
-- generic and port declration here
port(	clk			: 	in std_logic;
		reset		: 	in std_logic;
		data_A		:	in std_logic_vector(15 downto 0);
		data_B		:	in std_logic_vector(15 downto 0);
		carry_in	:	in std_logic;
		s_0			:	in std_logic;
		s_1 		:	in std_logic;
		s_2			:	in std_logic;

		data_out	:	out std_logic_vector(15 downto 0);
		carry_out	:	out std_logic
		);
end entity alu;

---------------------------------------------------------------------------------------------------
architecture behaviour of alu is
signal t_data_out : std_logic_vector(15 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declaration here


---------------------------------------------------------------------------------------------------
begin
-- component wiring here


---------------------------------------------------------------------------------------------------
alu_proc:	process(clk, reset)
variable v_opcode : std_logic_vector(3 downto 0);
begin
	if( reset = '1') then
		t_data_out <= (others => '0');
	elsif (rising_edge(clk)) then
		v_opcode := s_2 & s_1 & s_0 & carry_in;
		case v_opcode is
			when "0000" => t_data_out <= data_A;
			when "0001" => t_data_out <= data_A + '1';
			when "0010" => t_data_out <= data_A + data_B;
			when "0011" => t_data_out <= data_A + data_B + 1;
			when "0100" => t_data_out <= data_A + (NOT data_B);
			when "0101" => t_data_out <= data_A + (NOT data_B) + '1'; --subtraction
			when "0110" => t_data_out <= data_A - '1';
			when "0111" => t_data_out <= data_B;
			when "1000" => t_data_out <= data_A AND data_B;
			when "1100" => t_data_out <= data_A AND data_B;
			when "1001" => t_data_out <= data_A OR data_B;
			when "1101" => t_data_out <= data_A OR data_B;
			when "1010" => t_data_out <= data_A XOR data_B;
			when "1110" => t_data_out <= NOT data_A;
			when "1111" => t_data_out <= NOT data_B;
			when others => t_data_out <= "X";
		end case;
	end if;
end process alu_proc;


data_out <= t_data_out;

---------------------------------------------------------------------------------------------------
end architecture;