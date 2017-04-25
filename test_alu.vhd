library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity test_alu is
end test_alu;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_alu is

constant t_clk_period : time := 20 ns;

signal t_clk, t_reset, t_carry_in, t_overflow, t_zero : std_logic := '0';
signal t_data_A, t_data_B, t_data_out : std_logic_vector(15 downto 0) := (others => '0');
signal t_alu_op : std_logic_vector(1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
component alu
	port(
		data_A		:	in std_logic_vector(15 downto 0);
		data_B		:	in std_logic_vector(15 downto 0);
		alu_op		:	in std_logic_vector(1 downto 0);

		data_out		:	out std_logic_vector(15 downto 0);
		zero			:	out std_logic;
		overflow		:	out std_logic
	);
end component;

---------------------------------------------------------------------------------------------------
begin

t_alu : alu
	port map(
			data_A	=> 	t_data_A,
			data_B 	=> 	t_data_B,
			alu_op	=>		t_alu_op,


			data_out		=>	t_data_out,
			zero 	=>	t_zero,
			overflow	=>	t_overflow

	);

---------------------------------------------------------------------------------------------------
t_clk_process : process
begin
	t_clk <= '1';
	wait for t_clk_period/2;
	t_clk <= '0';
	wait for t_clk_period/2;
end process;

---------------------------------------------------------------------------------------------------
t_alu_proc	:	process
begin

	wait for t_clk_period * 4;

	-- 0xF + 0x3 = 0x12
	t_data_A <= x"000F";
	t_data_B <= x"0003";
	t_alu_op <= "00";
	wait for t_clk_period * 2;

	-- 0xFFFE + 0x5 = 0x(1)0003 overflow
	t_data_A <= x"FFFE";
	t_data_B <= x"0005";
	t_alu_op <= "00";
	wait for t_clk_period * 2;

	-- 0xE - 0x5 = 0x9
	t_data_A <= x"000E";
	t_data_B <= x"0005";
	t_alu_op <= "01";
	wait for t_clk_period * 2;

	-- 0x5 - 0xE = 0x(1)FFF9 underflow
	t_data_A <= x"0005";
	t_data_B <= x"000E";
	t_alu_op <= "01";
	wait for t_clk_period * 2;

	-- 0x0ECE & 0x701 = 0x600
	t_data_A <= x"0ECE";
	t_data_B <= x"0701";
	t_alu_op <= "10";
	wait for t_clk_period * 2;

	-- 0xECE | 0x701 = 0xFCF
	t_data_A <= x"0ECE";
	t_data_B <= x"0701";
	t_alu_op <= "11";
	wait for t_clk_period * 2;

	wait;
	

end process;




end architecture;