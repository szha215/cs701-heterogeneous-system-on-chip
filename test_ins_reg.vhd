library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;


---------------------------------------------------------------------------------------------------
entity test_ins_reg is
end test_ins_reg;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_ins_reg is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_reg_width	:	positive := 16;

signal t_clk, t_reset : std_logic := '0';
signal t_ir_wr_en : std_logic_vector(1 downto 0) := (others => '0');
signal t_data_in,t_lower0 : std_logic_vector(t_reg_width - 1 downto 0) := (others => '0');
signal t_upper0 : std_logic_vector(7 downto 0) := (others => '0');
signal t_upper1, t_upper2 : std_logic_vector(3 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component ins_reg
	generic(
		constant reg_width			: positive := 16
	);
	port(
		clk	:	in std_logic;
		reset	:	in std_logic;
		data_in	:	in std_logic_vector(reg_width - 1 downto 0);
		ir_wr_en	:	in std_logic_vector(1 downto 0);

		upper_0	:	out std_logic_vector(7 downto 0);
		upper_1	:	out std_logic_vector(3 downto 0);
		upper_2	:	out std_logic_vector(3 downto 0);

		lower_0	:	out std_logic_vector(reg_width - 1 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_ins_reg : ins_reg
	generic map(
		reg_width	=>	t_reg_width
	)
	port map(
		clk		=>	t_clk,
		reset		=>	t_reset,
		data_in	=>	t_data_in,
		ir_wr_en	=>	t_ir_wr_en,

		upper_0	=>	t_upper0,
		upper_1	=>	t_upper1,
		upper_2	=>	t_upper2,

		lower_0	=>	t_lower0

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
	wait for t_clk_period;
	t_reset <= '1';
	wait for t_clk_period;
	t_reset <= '0';

	wait for t_clk_period * 16;
	t_reset <= '1';

	wait for t_clk_period;
	t_reset <= '0';

	wait;

end process;

t_ins_reg_process : process
begin
	
	wait for t_clk_period * 4;
	t_ir_wr_en <= "01";
	t_data_in <= x"EF23";
	wait for t_clk_period;
	t_ir_wr_en <= "00";


	wait for t_clk_period * 3;
	t_ir_wr_en <= "10";
	t_data_in <= x"FFFF";
	wait for t_clk_period;
	t_ir_wr_en <= "00";

	wait for t_clk_period * 3;
	t_ir_wr_en <= "11";
	t_data_in <= x"F0EF";
	wait for t_clk_period;
	t_ir_wr_en <= "00";

	wait;


end process;


end architecture;