library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity test_gen_reg is
end test_gen_reg;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_gen_reg is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_reg_width : positive := 16;

signal t_clk, t_reset, t_wr_en : std_logic := '0';
signal t_data_in,t_data_out : std_logic_vector(t_reg_width -1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component gen_reg
	generic(
		constant reg_width		: positive := 16
	);
	port(
		-- control inputs
		clk			: 	in std_logic;
		reset			: 	in std_logic;
		wr_en			:	in std_logic; 
		data_in		:	in std_logic_vector(reg_width - 1 downto 0);
		data_out		:	out std_logic_vector(reg_width - 1 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_gen_reg : gen_reg
	generic map(
		reg_width 	=> t_reg_width
	)
	port map(
		clk		=> t_clk,
		reset		=> t_reset,
		wr_en		=>	t_wr_en,
		data_in	=>	t_data_in,
		data_out	=>	t_data_out
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
	wait for t_clk_period * 26;
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
	t_data_in <= x"FFFF";
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_data_in <= x"F00F";
	wait for t_clk_period * 4;

	t_wr_en <= '0';
	t_data_in <= x"0FF0"; --writing blocked
	wait for t_clk_period * 4;

	t_wr_en <= '1';
	t_data_in <= x"0FFF"; --writing enabled
	wait for t_clk_period * 4;

	t_wr_en <= '0';

	wait;

end process;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;