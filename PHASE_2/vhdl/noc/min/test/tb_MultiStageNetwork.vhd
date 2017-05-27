library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.min_ports_pkg.all;

entity tb_MultiStageNetwork is
end tb_MultiStageNetwork;

architecture test of tb_MultiStageNetwork is

	constant number_of_nodes	: integer := 16;
	constant buffer_depth		: integer := 8;

	component MultiStageNetwork is
		generic(
			number_of_nodes	: integer := 8;
			buffer_depth		: integer := 1
		);
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			in_port		: in min_port(0 to number_of_nodes-1);
			out_port		: out min_port(0 to number_of_nodes-1)
		);
	end component;

	signal tb_clk, tb_reset	: std_logic := '0';
	signal tb_in				: min_port(0 to number_of_nodes-1);
	signal tb_out				: min_port(0 to number_of_nodes-1);
	
	
begin

	dut : MultiStageNetwork
	generic map(
		number_of_nodes	=> number_of_nodes,
		buffer_depth		=> buffer_depth
	)
	port map(
		clk		=> tb_clk,
		reset		=> tb_reset,
		in_port	=> tb_in,
		out_port	=> tb_out
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
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"00000000";
		end loop;
		wait for 16 ns;
		tb_in(0) <= x"80000000", x"00000000" after 2 ns;
		wait for 20 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000001" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000002" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000003" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000004" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000005" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000006" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000007" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"8000008" & conv_std_logic_vector(i, 4);
		end loop;
		wait for 2 ns;
		for i in 0 to number_of_nodes-1 loop
			tb_in(i) <= x"00000000";
		end loop;
		wait;
	end process;

end architecture;