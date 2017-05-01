library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------------------------------------
entity test_average_filter is
end entity; -- test_average_filter

---------------------------------------------------------------------------------------------------
architecture behaviour of test_average_filter is

constant t_clk_period : time := 20 ns;

signal t_clk, t_reset	: std_logic;
signal t_data	: std_logic_vector(15 downto 0) := (others => '0');
signal t_avg	: std_logic_vector(15 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
component average_filter is
	generic(
		window_size	: positive := 4;
		data_width	: positive := 16
	);
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		data	: in std_logic_vector(data_width - 1 downto 0);

		avg	: out std_logic_vector(data_width - 1 downto 0)
	);
end component; -- average_filter

---------------------------------------------------------------------------------------------------
begin

filter : average_filter
generic map(
	window_size	=> 4,
	data_width	=> 16
)
port map(
	clk	=> t_clk,
	reset => t_reset,
	data	=> t_data,

	avg	=> t_avg
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

	wait for t_clk_period * 20;
	t_reset <= '1';
	wait for t_clk_period;
	t_reset <= '0';
	wait;
end process;
---------------------------------------------------------------------------------------------------
data_process : process
begin
	wait for t_clk_period * 4;

	t_data <= x"0001";
	wait for t_clk_period;

	t_data <= x"0002";
	wait for t_clk_period;

	t_data <= x"0003";
	wait for t_clk_period;

	t_data <= x"0004";
	wait for t_clk_period;

	t_data <= x"0005";
	wait for t_clk_period * 6;

	t_data <= x"0003";
	wait for t_clk_period;

	t_data <= x"0003";
	wait for t_clk_period;

	t_data <= x"0002";
	wait for t_clk_period;

	t_data <= x"0001";
	wait for t_clk_period;

	wait;
end process ; -- a_b_process

---------------------------------------------------------------------------------------------------
end architecture ; -- behaviour