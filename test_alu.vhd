library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_alu is
end test_alu;

architecture behaviour of test_alu is

	component alu
		port(
			clk			: 	in std_logic;
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
	end component;



	
	signal t_clk, t_reset, t_carry_in, t_s_0, t_s_1, t_s_2, t_carry_out : std_logic := '0';
	signal t_data_A, t_data_B, t_data_out : std_logic_vector(15 downto 0) := (others => '0');
	constant t_clk_period : time := 20 ns;

begin

	t_alu : alu
		port map(
				clk 		=> 	t_clk,
				reset		=> 	t_reset,
				data_A		=> 	t_data_A,
				data_B 		=> 	t_data_B,
				carry_in	=> 	t_carry_in,
				s_0			=>	t_s_0,
				s_1			=>	t_s_1,
				s_2			=> 	t_s_2,

				data_out	=>	t_data_out,
				carry_out	=>	t_carry_out

			);

	


	t_clk_process : process
	begin
		t_clk <= '1';
		wait for t_clk_period/2;
		t_clk <= '0';
		wait for t_clk_period/2;
	end process;




	t_reset_process : process
	begin
		t_reset <= '0';
		wait for t_clk_period * 3;
		t_reset <= '1';
		wait for t_clk_period;
		t_reset <= '0';
		wait;
	end process;

	

	t_alu_proc	:	process
	begin

		wait for t_clk_period * 6;
		-- data_out <= data_A
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_s_2 <= '0';
		t_s_1 <= '0';
		t_s_0 <= '0';
		t_carry_in <= '0';
		wait for t_clk_period * 4;

		-- data_out <= data_A + 1
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_s_2		 <= '0';
		t_s_1		 <= '0';
		t_s_0		 <= '0';
		t_carry_in	 <= '1';
		wait for t_clk_period * 4;

		-- data_out <= data_A + data_B
		t_data_A <= x"0002"; 
		t_data_B <= x"0003";
		t_s_2		 <= '0';
		t_s_1		 <= '0';
		t_s_0		 <= '1';
		t_carry_in	 <= '0';
		wait for t_clk_period * 4;

		-- data_out <= data_A + data_B + 1
		t_data_A <= x"0002"; 
		t_data_B <= x"0003";
		t_s_2		<= '0';
		t_s_1 		<= '0';
		t_s_0 		<= '1';
		t_carry_in 	<= '1';
		wait for t_clk_period * 4;

		-- data_out <= data_A + (NOT data_B)
		t_data_A <= x"0001"; 
		t_data_B <= x"FFF0";
		t_s_2 		<= '0';
		t_s_1 		<= '1';
		t_s_0 		<= '0';
		t_carry_in 	<= '0';
		wait for t_clk_period * 4;
		-- data_out <= data_A + (NOT data_B) + '1'
		t_data_A <= x"0006"; 
		t_data_B <= x"0002";
		t_s_2 <= '0';
		t_s_1 <= '1';
		t_s_0 <= '0';
		t_carry_in <= '1';
		wait for t_clk_period * 4;
		-- data_out <= data_A - 1
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_s_2 <= '0';
		t_s_1 <= '1';
		t_s_0 <= '1';
		t_carry_in <= '0';
		wait for t_clk_period * 4;

		-- data_out <= data_B
		t_data_A <= x"0000"; 
		t_data_B <= x"00F0";
		t_s_2 <= '0';
		t_s_1 <= '1';
		t_s_0 <= '1';
		t_carry_in <= '1';
		wait for t_clk_period * 4;

		-- data_out <= data_A AND data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"00F4";
		t_s_2 <= '1';
		t_s_1 <= '0';
		t_s_0 <= '0';
		t_carry_in <= '0';
		wait for t_clk_period * 4;

		-- data_out <= data_A OR data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_s_2 <= '1';
		t_s_1 <= '0';
		t_s_0 <= '0';
		t_carry_in <= '1';
		wait for t_clk_period * 4;

		-- data_out <= data_A XOR data_B
		t_data_A <= x"002F"; 
		t_data_B <= x"0064";
		t_s_2 <= '1';
		t_s_1 <= '0';
		t_s_0 <= '1';
		t_carry_in <= '0';
		wait for t_clk_period * 4;

		-- data_out <= not data_A
		t_data_A <= x"F00F"; 
		t_data_B <= x"0000";
		t_s_2 <= '1';
		t_s_1 <= '1';
		t_s_0 <= '1';
		t_carry_in <= '0';
		wait for t_clk_period * 4;

		-- data_out <= not data_B
		t_data_A <= x"000F"; 
		t_data_B <= x"0000";
		t_s_2 <= '1';
		t_s_1 <= '1';
		t_s_0 <= '1';
		t_carry_in <= '1';
		wait for t_clk_period * 4;

		




	end process;



end architecture;