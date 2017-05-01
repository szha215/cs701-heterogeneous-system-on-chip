library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------------------------------------
entity test_multiplier is
end entity; -- test_multiplier

---------------------------------------------------------------------------------------------------
architecture behaviour of test_multiplier is

constant t_clk_period : time := 20 ns;

signal t_clk	: std_logic;
signal t_a, t_b: std_logic_vector(15 downto 0) := (others => '0');
signal t_res	: std_logic_vector(63 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
component multiplier is
	generic( 
	in_width	: positive;
	res_witdh	: positive;
	result_lowbit	: natural
	);
	port(
	a		: in std_logic_vector(in_width-1 downto 0);
	b		: in std_logic_vector(in_width-1 downto 0);
	res	: out std_logic_vector(res_witdh-1 downto 0)
	);
end component;

---------------------------------------------------------------------------------------------------
begin

mult : multiplier
generic map(
	in_width			=> 16,
	res_witdh		=> 64,
	result_lowbit	=> 0
)
port map(
	a		=> t_a,
	b		=> t_b,
	res	=> t_res
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
a_b_process : process
begin
	wait for t_clk_period;

	t_a <= x"0005";
	t_b <= x"0003";
	wait for t_clk_period * 2;

	t_a <= x"0009";
	t_b <= x"0008";
	wait for t_clk_period * 2;

	t_a <= x"0001";
	t_b <= x"0001";
	wait for t_clk_period * 2;


	t_a <= x"0005";
	t_b <= x"0000";
	wait for t_clk_period * 2;


	wait;
end process ; -- a_b_process

---------------------------------------------------------------------------------------------------
end architecture ; -- behaviour