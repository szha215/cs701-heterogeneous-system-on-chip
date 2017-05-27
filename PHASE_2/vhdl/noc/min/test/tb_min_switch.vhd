LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity tb_min_switch is
end tb_min_switch;

architecture test of tb_min_switch is

	component min_switch is
		generic(
			this_stage		: positive;
			buffer_depth	: positive
		);
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			in_portA		: in std_logic_vector(31 downto 0);
			in_portB		: in std_logic_vector(31 downto 0);
			out_portA	: out std_logic_vector(31 downto 0);
			out_portB	: out std_logic_vector(31 downto 0)
		);
	end component;

	signal tb_clk, tb_reset	: std_logic := '0';
	signal tb_inA, tb_inB	: std_logic_vector(31 downto 0) := x"00000000";
	signal tb_outA, tb_outB	: std_logic_vector(31 downto 0);
	
	
begin

	dut : min_switch
	generic map(
		this_stage		=> 1,
		buffer_depth	=> 4
	)
	port map(
		clk			=> tb_clk,
		reset			=> tb_reset,
		in_portA		=> tb_inA,
		in_portB		=> tb_inB,
		out_portA	=> tb_outA,
		out_portB	=> tb_outB
	);
	
	clk_gen: process
	begin
		wait for 1 ns;
		tb_clk <= not tb_clk;
	end process;
	
	initialize: process
	begin
		tb_reset <= '1', '0' after 10 ns;
		wait;
	end process;
	
	gen_ports: process
	begin
		wait for 16 ns;
		tb_inA <= x"80000000", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"B0000001", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"C0000002", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"F0000003";
		wait for 2 ns;
		tb_inA <= x"D0000004", x"00000000" after 2 ns;
		tb_inB <= x"80000000", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"90000005", x"00000000" after 2 ns;
		tb_inB <= x"D0000001", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"D0000006";
		tb_inB <= x"80000002";
		wait for 2 ns;
		tb_inA <= x"90000007", x"00000000" after 2 ns;
		tb_inB <= x"D0000003", x"00000000" after 2 ns;
		wait for 10 ns;
		tb_inA <= x"F0000008";
		tb_inB <= x"F0000004";
		wait for 2 ns;
		tb_inA <= x"F0000009";
		tb_inB <= x"F0000005";
		wait for 2 ns;
		tb_inA <= x"F000000A";
		tb_inB <= x"F0000006";
		wait for 2 ns;
		tb_inA <= x"8000000B";
		tb_inB <= x"80000007";
		wait for 2 ns;
		tb_inA <= x"F000000C", x"00000000" after 2 ns;
		tb_inB <= x"80000008", x"00000000" after 2 ns;
		wait for 20 ns;
	end process;

end architecture;