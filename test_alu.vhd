library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_alu is
end test_alu;

architecture behaviour of test_alu is

	component alu
		port(
			data_A		:	in std_logic_vector(15 downto 0);
			data_B		:	in std_logic_vector(15 downto 0);
			opcode		:	in std_logic_vector(3 downto 0);

			data_out		:	out std_logic_vector(15 downto 0);
			zero			:	out std_logic;
			overflow		:	out std_logic
		);
	end component;



	
	signal t_clk, t_reset, t_carry_in, t_overflow, t_zero : std_logic := '0';
	signal t_data_A, t_data_B, t_data_out : std_logic_vector(15 downto 0) := (others => '0');
	signal t_opcode : std_logic_vector(3 downto 0) := (others => '0');
	constant t_clk_period : time := 20 ns;

begin

	t_alu : alu
		port map(
				data_A	=> 	t_data_A,
				data_B 	=> 	t_data_B,
				opcode	=>		t_opcode,


				data_out		=>	t_data_out,
				zero 	=>	t_zero,
				overflow	=>	t_overflow

			);

	


	t_clk_process : process
	begin
		t_clk <= '1';
		wait for t_clk_period/2;
		t_clk <= '0';
		wait for t_clk_period/2;
	end process;

	

	t_alu_proc	:	process
	begin

		wait for t_clk_period * 6;
		-- data_out <= data_A
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_opcode <= "0000";
		wait for t_clk_period * 4;

		-- data_out <= data_A + 1
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_opcode <= "0001";
		wait for t_clk_period * 4;

		-- data_out <= data_A + data_B
		t_data_A <= x"0002"; 
		t_data_B <= x"0003";
		t_opcode <= "0010";
		wait for t_clk_period * 4;

		-- data_out <= data_A + data_B + 1
		t_data_A <= x"0002"; 
		t_data_B <= x"0003";
		t_opcode <= "0011";
		wait for t_clk_period * 4;

		-- data_out <= data_A + (NOT data_B)
		t_data_A <= x"0001"; 
		t_data_B <= x"FFF0";
		t_opcode <= "0100";
		wait for t_clk_period * 4;
		-- data_out <= data_A + (NOT data_B) + '1'
		t_data_A <= x"0006"; 
		t_data_B <= x"0002";
		t_opcode <= "0101";
		wait for t_clk_period * 4;
		-- data_out <= data_A - 1
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_opcode <= "0110";
		wait for t_clk_period * 4;

		-- data_out <= data_B
		t_data_A <= x"0000"; 
		t_data_B <= x"00F0";
		t_opcode <= "0111";
		wait for t_clk_period * 4;

		-- data_out <= data_A AND data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"00F4";
		t_opcode <= "1000";
		wait for t_clk_period * 4;

		-- data_out <= data_A OR data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_opcode <= "1010";
		wait for t_clk_period * 4;

		-- data_out <= data_A XOR data_B
		t_data_A <= x"002F"; 
		t_data_B <= x"0064";
		t_opcode <= "1100";
		wait for t_clk_period * 4;

		-- data_out <= not data_A
		t_data_A <= x"F00F"; 
		t_data_B <= x"0000";
		t_opcode <= "1110";
		wait for t_clk_period * 4;

		-- data_out <= not data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_opcode <= "1111";
		wait for t_clk_period * 4;

		-- data_out <= data_A + data _B ; test overflow
		t_data_A <= x"FFFF"; 
		t_data_B <= x"FFFF";
		t_opcode <= "0010";
		wait for t_clk_period * 4;

		-- data_out <= data_A - data_B; test zero bit
		t_data_A <= x"00FF"; 
		t_data_B <= x"00FF";
		t_opcode <= "0101";
		wait for t_clk_period * 4;

		-- data_out <= data_A - data_B; test underflow
		t_data_A <= x"000E"; 
		t_data_B <= x"000F";
		t_opcode <= "0101";
		wait for t_clk_period * 4;



		




	end process;



end architecture;