--
--  Copyright 2012 Rasmus Bo Soerensen <rasmus@rbscloud.dk>,
--                 Technical University of Denmark, DTU Informatics. 
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
--
--                

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;

entity MeshNetwork is
	generic(
			number_of_nodes	: integer := 8;
			buffer_depth		: integer := 1;
			WIDTH 				: integer := 32;
			PERIOD_P 			: integer := 5
		);
		port(
			clk_noc		: in std_logic;
			clk_core		: in std_logic;
			reset			: in std_logic;
			in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
			out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
			ifrd_req		: in std_logic_vector(0 to number_of_nodes-1);
			ifrd_addr	: in FIFO_ADDR_ARRAY_TYPE(0 to number_of_nodes-1)
		);
end entity MeshNetwork;

architecture struct of MeshNetwork is

  constant N : natural := sqrt(TOTAL_NI_NUM);

	component router
		generic (
			NI_NUM		: natural
		);
		port (
			clk			: in std_logic;
			reset			: in std_logic;

			north_in		: in network_link_forward;
			south_in		: in network_link_forward;
			east_in		: in network_link_forward;
			west_in		: in network_link_forward;
			local_in		: in network_link_forward;

			north_out	: out network_link_forward;
			south_out	: out network_link_forward;
			east_out		: out network_link_forward;
			west_out		: out network_link_forward;
			local_out	: out network_link_forward
		);
	end component;
	
	component ni_ram_single is
		generic (
			NI_NUM	: natural
		);
		port (
			clk           : in  std_logic;
			reset         : in  std_logic;
			-- Signals to/from the router
			tile_tx_f     : out network_link_forward;
			tile_rx_f     : in  network_link_forward;
			-- Signals to/from the tile
			processor_out : in  io_out_type;
			processor_in  : out io_in_type
		);
	end component;
	
	component ni_ram is
		generic (
			NI_NUM	: natural
		);
		port (
			router_clk    : in  std_logic;
			processor_clk : in  std_logic;
			reset         : in  std_logic;
			-- Signals to/from the router
			tile_tx_f     : out network_link_forward;
			tile_rx_f     : in  network_link_forward;
			-- Signals to/from the tile
			processor_out : in  io_out_type;
			processor_in  : out io_in_type
		);
	end component;
	

	type link_n is array(0 to (N - 1)) of network_link_forward;
	type link_m is array(0 to (N - 1)) of link_n;
	type link_l_out is array(0 to (number_of_nodes-1)) of io_out_type;
	type link_l_in is array(0 to (number_of_nodes-1)) of io_in_type;

	signal north_in	: link_m;
	signal east_in		: link_m;
	signal south_in	: link_m;
	signal west_in		: link_m;
	signal local_in	: link_m;
	signal north_out	: link_m;
	signal east_out	: link_m;
	signal south_out	: link_m;
	signal west_out	: link_m;
	signal local_out	: link_m;

	signal processor_out	: link_l_out;
	signal processor_in 	: link_l_in;
			
	signal open_vector : network_link_forward;
	
begin
	
	-----------------
	--   Routers   --
	-----------------
	nodes_m : for i in N-1 downto 0 generate
		nodes_n : for j in N-1 downto 0 generate
			node : router
				generic map (
					NI_NUM => i*N+j
				)
				port map (
					clk			=> clk_noc,
					reset			=> reset,
					north_in		=> north_in(i)(j),
					south_in		=> south_in(i)(j),
					east_in		=> east_in(i)(j),
					west_in		=> west_in(i)(j),
					local_in		=> local_in(i)(j),
					north_out	=> north_out(i)(j),
					south_out	=> south_out(i)(j),
					east_out		=> east_out(i)(j),
					west_out		=> west_out(i)(j),
					local_out	=> local_out(i)(j)
				);
		end generate nodes_n;
	end generate nodes_m;


	----------------
	--   Wires   ---
	----------------
	open_vector.data <= (others => '0');
	open_vector.data_valid <= '0';
	links_m : for i in 0 to N-1 generate
		links_n : for j in 0 to N-1 generate

			link_north_south : if (i = 0) generate
				north_in(i)(j)		<= south_out(N-1)(j);
				south_in(N-1)(j)	<= north_out(i)(j);
			end generate link_north_south;
			
			link_west_east : if (j = 0) generate
				west_in(i)(j)		<= east_out(i)(N-1);
				east_in(i)(N-1)	<= west_out(i)(j);
			end generate link_west_east;

			bottom : if (i = (N-1) and j < (N-1)) generate
				west_in(i)(j+1)	<= east_out(i)(j);
				east_in(i)(j)		<= west_out(i)(j+1);
			end generate bottom;
			
			right : if (i < (N-1) and j = (N-1)) generate
				north_in(i+1)(j)	<= south_out(i)(j);
				south_in(i)(j)		<= north_out(i+1)(j);
			end generate right;
			
			center : if (i < (N-1) and j < (N-1)) generate
				north_in(i+1)(j)	<= south_out(i)(j);
				south_in(i)(j)		<= north_out(i+1)(j);
				west_in(i)(j+1)	<= east_out(i)(j);
				east_in(i)(j)		<= west_out(i)(j+1);
			end generate center;
			
--			link_local : if i*N+j < number_of_nodes generate
--				local_in(i)(j)		<= local_in(i)(j);
--				local_out(i)(j)	<= local_out(i)(j);
--			end generate link_local;
			
			link_dummy : if i*N+j >= number_of_nodes generate
				local_in(i)(j)		<= open_vector;
			end generate link_dummy;
      
		end generate links_n;
	end generate links_m;

	--------------------
	--   Interfaces   --
	--------------------
	interface_m : for i in 0 to N-1 generate
		interface_n : for j in 0 to N-1 generate
			dualclkni : if DUAL_CLOCK_NOC = true and i*N+j < number_of_nodes generate
				ni : ni_ram
					generic map (
						NI_NUM => i*N+j
						)
					port map (
						router_clk		=> clk_noc,
						processor_clk	=> clk_core,
						reset				=> reset,
						tile_tx_f		=> local_in(i)(j),
						tile_rx_f		=> local_out(i)(j),
						processor_out	=> processor_out(i*N+j),
						processor_in	=> processor_in(i*N+j)
					);
				
				processor_out(i*N+j).wrdata	<= in_port(i*N+j) when in_port(i*N+j)(31) = '1'
																else (others => '0');
				processor_out(i*N+j).wraddr	<= in_port(i*N+j)(30 downto 24) when in_port(i*N+j)(31) = '1'
																else std_logic_vector(to_unsigned(i*N+j, 7));
				processor_out(i*N+j).wr			<= in_port(i*N+j)(31);
				processor_out(i*N+j).rdaddr	<= ifrd_addr(i*N+j);
				processor_out(i*N+j).rd			<= '0' when in_port(i*N+j)(31) = '1'
																else '1';
				out_port(i*N+j)					<= processor_in(i*N+j).rddata;
			end generate dualclkni;

			singleclkni : if DUAL_CLOCK_NOC = false and i*N+j < number_of_nodes generate
				ni : ni_ram_single
					generic map (
						NI_NUM => i*N+j
					)
					port map (
						clk				=> clk_noc,
						reset				=> reset,
						tile_tx_f		=> local_in(i)(j),
						tile_rx_f		=> local_out(i)(j),
						processor_out	=> processor_out(i*N+j),
						processor_in	=> processor_in(i*N+j)
					);
					
				processor_out(i*N+j).wrdata	<= in_port(i*N+j) when in_port(i*N+j)(31) = '1'
																else (others => '0');
				processor_out(i*N+j).wraddr	<= in_port(i*N+j)(30 downto 24) when in_port(i*N+j)(31) = '1'
																else std_logic_vector(to_unsigned(i*N+j, 7));
				processor_out(i*N+j).wr			<= in_port(i*N+j)(31);
				processor_out(i*N+j).rdaddr	<= ifrd_addr(i*N+j);
				processor_out(i*N+j).rd			<= '0' when in_port(i*N+j)(31) = '1'
																else '1';
				out_port(i*N+j)					<= processor_in(i*N+j).rddata;
			end generate singleclkni;

		end generate interface_n;
	end generate interface_m;
	
end architecture struct;

