library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.all;
use work.mux_pkg.all;

---------------------------------------------------------------------------------------------------
entity test_mux is
end test_mux;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_mux is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_port_num : positive := 4;

signal t_clk : std_logic := '0';
signal t_inputs_4_bit : mux_4_bit_arr(t_port_num - 1 downto 0) := (0 => "0000", 1 => "0001", 2 => "0010", 3=> "0011");
signal t_inputs_16_bit : mux_16_bit_arr(t_port_num - 1 downto 0) := (0 => x"0001", 1=> x"0011", 2=> x"0021", 3=> x"0031");
signal t_sel_4_bit,t_sel_16_bit : std_logic_vector(integer(ceil(log2(real(t_port_num)))) - 1 downto 0) := (others => '0');
signal t_output_4_bit : std_logic_vector(3 downto 0) := (others => '0');
signal t_output_16_bit : std_logic_vector(15 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component mux_4_bit
	generic(
		constant port_num			: positive := 4
	);
	port(
		inputs 	: in mux_4_bit_arr(port_num - 1 downto 0);
		sel		: in std_logic_vector(integer(ceil(log2(real(port_num)))) - 1 downto 0);
		
		output	: out std_logic_vector(3 downto 0)
	);
	end component;


component mux_16_bit
	generic(
		constant port_num			: positive := 4
	);
	port(
		inputs 	: in mux_16_bit_arr(port_num - 1 downto 0);
		sel		: in std_logic_vector(integer(ceil(log2(real(port_num)))) - 1 downto 0);
		
		output	: out std_logic_vector(15 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_mux_4_bit : mux_4_bit
	generic map(
		port_num => t_port_num
	)
	port map(
		inputs 	=> t_inputs_4_bit,
		sel		=>	t_sel_4_bit,

		output	=>	t_output_4_bit

	);

t_mux_16_bit : mux_16_bit
	generic map(
		port_num => t_port_num
	)
	port map(
		inputs 	=> t_inputs_16_bit,
		sel		=>	t_sel_16_bit,

		output	=>	t_output_16_bit

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
t_mux_proc_4_bit : process
begin
	wait for t_clk_period * 6;

	sel_loop : for i in 0 to t_port_num -1 loop
		t_sel_4_bit <= std_logic_vector(to_unsigned(i,t_sel_4_bit'length));
		wait for t_clk_period * 2;
	end loop ; -- sel_loop

	wait;

end process;
---------------------------------------------------------------------------------------------------
t_mux_proc_16_bit : process
begin
	wait for t_clk_period * 6;

	sel_loop : for i in 0 to t_port_num -1 loop
		t_sel_16_bit <= std_logic_vector(to_unsigned(i,t_sel_16_bit'length));
		wait for t_clk_period * 2;
	end loop ; -- sel_loop

	wait;

end process;

---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;