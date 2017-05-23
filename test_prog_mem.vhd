library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity test_prog_mem is
end test_prog_mem;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_prog_mem is
-- type, signal declarations

constant t_clk_period : time := 20 ns;
constant t_ram_addr_width : positive := 16;
constant t_ram_data_width : positive := 16;

signal t_clk, t_reset : std_logic := '0';
signal t_addr : std_logic_vector(t_ram_addr_width - 1 downto 0) := (others => '0');
signal t_data_out : std_logic_vector(t_ram_data_width - 1 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declarations
component prog_mem
	generic(
		constant ram_addr_width		: positive := 16;
		constant ram_data_width		: positive := 16
	);
	port(
		clk			:	in std_logic;
		addr			:	in std_logic_vector(ram_addr_width - 1 downto 0); 
		data_out		:	out std_logic_vector(ram_data_width - 1 downto 0)
	);
	end component;

---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_prog_mem : prog_mem
	generic map(
		ram_addr_width => t_ram_addr_width,
		ram_data_width => t_ram_data_width
	)
	port map(
		clk			=>	t_clk,
		addr 			=>	t_addr,
		data_out		=>	t_data_out
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
t_data_mem_proc : process
begin
	wait for t_clk_period * 6;

	t_addr <= x"0001";
	wait for t_clk_period;
	wait for t_clk_period * 3;
	--wait for 5 ns;

	t_addr <= x"0003";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0005";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0007";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0009";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0001";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0005";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0003";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0009";
	wait for t_clk_period;
	wait for t_clk_period * 3;

	t_addr <= x"0007";
	wait for t_clk_period;
	wait for t_clk_period * 3;





	wait;

end process;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;