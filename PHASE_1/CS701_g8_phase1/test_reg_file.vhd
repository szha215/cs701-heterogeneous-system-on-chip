library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity test_reg_file is
end test_reg_file;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_reg_file is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_reg_width : positive := 16;
constant t_reg_num	: positive := 16;

signal t_clk, t_reset, t_wr_en : std_logic := '0';
signal t_rd_reg1,t_rd_reg2, t_wr_reg : std_logic_vector(integer(ceil(log2(real(t_reg_width)))) - 1 downto 0) := (others => '0');
signal t_wr_data,t_data_out_a,t_data_out_b : std_logic_vector(t_reg_width - 1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component reg_file
	generic(
		constant reg_num			: positive := 16;
		constant reg_width		: positive := 16
	);
	port(
		-- control inputs
		clk			: 	in std_logic;
		reset			: 	in std_logic;
		wr_en			:	in std_logic; 
		rd_reg1		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
		rd_reg2		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
		wr_reg		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
		wr_data		: 	in std_logic_vector(reg_width - 1 downto 0);

		data_out_a	:	out std_logic_vector(reg_width - 1 downto 0);
		data_out_b	:	out std_logic_vector(reg_width - 1 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_reg_file : reg_file
	generic map(
		reg_num 		=> t_reg_num,
		reg_width 	=> t_reg_width
	)
	port map(
		clk		=> t_clk,
		reset		=> t_reset,
		wr_en		=>	t_wr_en,
		rd_reg1	=>	t_rd_reg1,
		rd_reg2	=>	t_rd_reg2,
		wr_reg	=>	t_wr_reg,
		wr_data	=>	t_wr_data,

		data_out_a	=>	t_data_out_a,
		data_out_b	=>	t_data_out_b

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
t_reset_process : process
begin
	t_reset <= '0';
	wait for t_clk_period * 3;
	t_reset <= '1';
	wait for t_clk_period;
	t_reset <= '0';
	wait;
end process;
---------------------------------------------------------------------------------------------------
t_reg_file_proc : process
begin
	wait for t_clk_period * 6;

	t_wr_en <= '1';
	t_wr_data <= x"FFFF";
	t_wr_reg <= "0000";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"0FF0";
	t_wr_reg <= "0100";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"0FF0";
	t_wr_reg <= "0100";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"F00F";
	t_wr_reg <= "0110";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"000F";
	t_wr_reg <= "1000";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"00F0";
	t_wr_reg <= "1010";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_wr_data <= x"0F0F";
	t_wr_reg <= "1111";
	wait for t_clk_period * 4;

	wait for 1 ns;

	t_wr_en <= '0';
	t_rd_reg1 <= "0100";
	t_rd_reg2 <= "1000";
	wait for t_clk_period;

	t_wr_en <= '0';
	t_rd_reg1 <= "0110";
	t_rd_reg2 <= "1010";
	wait for t_clk_period;

	t_wr_en <= '0';
	t_rd_reg1 <= "0000";
	t_rd_reg2 <= "1111";
	wait for t_clk_period;

	wait;

end process;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;