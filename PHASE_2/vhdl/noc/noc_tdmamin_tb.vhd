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
use ieee.math_real.all;
use work.jop_config.all;
use work.noc_types.all;
use work.mesh_ports_pkg.all;

entity noc_tdmamin_tb is
end entity noc_tdmamin_tb;


architecture rtl of noc_tdmamin_tb is

	constant jop_cnt				: integer := 3;
	constant recop_cnt			: integer := 1;
	constant number_of_nodes	: integer := jop_cnt + recop_cnt;
	constant SIMULATION			: std_logic := '1';
	constant buffer_depth		: integer := 4;
	constant number_of_stages	: integer := integer(ceil(log2(real(number_of_nodes))));
	
	signal clk0_in			: std_logic	:= '0';
	signal clk1_in			: std_logic	:= '0';
	signal clk_jop			: std_logic;								-- drive jop
	signal clk_jop_inv	: std_logic;								-- clk_jop shifted by 180deg
	signal clk_recop		: std_logic;								-- drive ReCOP
	signal clk_noc			: std_logic;								-- drive interconnects
	signal clk_system		: std_logic;								-- system wide clock if single clock design
	signal clk_system_inv: std_logic;								-- clk_system shifted by 180deg
	
	signal reset			: std_logic;
	signal int_res			: std_logic;
	
	signal tdm_slot		: std_logic_vector(integer(ceil(log2(real(number_of_nodes))))-1 downto 0);
	
	signal noc_in_port		: NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
	signal noc_out_port		: NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
	signal ifrd_req			: std_logic_vector(0 to number_of_nodes-1);
	signal ifrd_addr			: FIFO_ADDR_ARRAY_TYPE(0 to number_of_nodes-1);
	
	signal datacall_jop_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal datacall_jop_if_array	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal datacall_recop_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal datacall_recop_if_array: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal datacall_jop_ack			: std_logic_vector(jop_cnt-1 downto 0);
	signal datacall_interf_rdreq	: std_logic_vector(jop_cnt-1 downto 0);
	
	signal result_jop_array			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_jop_if_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_recop_array		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal result_recop_if_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal result_recop_ack			: std_logic_vector(recop_cnt-1 downto 0);
	signal result_interf_rdreq		: std_logic_vector(recop_cnt-1 downto 0);
	
	signal debug			: std_logic;
	signal step_through	: std_logic;
	signal sip				: std_logic_vector(15 downto 0);
	signal sop				: std_logic_vector(15 downto 0);
	signal eot				: std_logic_vector(recop_cnt-1 downto 0);
	signal er_btn			: std_logic;
	signal er_sw			: std_logic;
	signal z_flag			: std_logic_vector(recop_cnt-1 downto 0);
	signal sop_array		: BIT16_SIGNAL_ARRAY_TYPE(recop_cnt-1 downto 0);

	signal oLEDR_int		: std_logic_vector(17 downto 0);
	
	
	component TDMA_MINoC is
		generic(
			number_of_nodes	: integer := 6;
			buffer_depth		: integer := 2
		);
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			tdm_slot		: in std_logic_vector(integer(ceil(log2(real(number_of_nodes))))-1 downto 0);
			in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
			out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1)
		);
	end component;
	
	                                                                      

	component tdm_slot_counter is
		generic(
			number_of_stages	: integer range 1 to 8
		);
		port(
			clk		: in std_logic;
			reset		: in std_logic;
			q			: out std_logic_vector(number_of_stages-1 downto 0)
		);
	end component;
	
	component jop_tdm_min_interface is
		generic(
			recop_cnt: integer;
			jop_cnt	: integer;
			fifo_depth	: integer
		);
		port(
			clk		: in std_logic;
			reset		: in std_logic;
			tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt))))-1 downto 0);
			dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
			dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
		);
	end component;
	
	component recop_tdm_min_interface is
		generic(
			recop_cnt: integer;
			jop_cnt	: integer;
			fifo_depth	: integer
		);
		port(
			clk		: in std_logic;
			reset		: in std_logic;
			tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt))))-1 downto 0);
			dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
			dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0)
		);
	end component;
	
	component recop_stepper is
	port(
		clk	: in std_logic;
		iBtn	: in std_logic;
		step	: out std_logic
	);
	end component;

	component reset_counter is
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			reset_int	: out std_logic
		);
	end component;

begin
	
	datacall_gen: process is
	begin
		for i in 0 to recop_cnt-1 loop
			datacall_recop_array(i) <= x"00000000";
		end loop;
		for i in 0 to jop_cnt-1 loop
			result_jop_array(i) <= x"00000000";
		end loop;
		
		wait for 30 ns;
		datacall_recop_array(0) <= x"80000000", x"00000000" after 2 ns;
		wait for 4 ns;
		datacall_recop_array(0) <= x"81000001";
		wait for 2 ns;
		datacall_recop_array(0) <= x"81000002", x"00000000" after 2 ns;
		wait for 4 ns;
		datacall_recop_array(0) <= x"82000003", x"00000000" after 2 ns;
		wait for 50 ns;
--		result_jop_array(0) <= x"00000002", x"00000000" after 2 ns;
--		wait for 6 ns;
--		result_jop_array(1) <= x"00000006", x"00000000" after 2 ns;
--		wait for 20 ns;
		result_jop_array(0) <= x"00000012", x"00000000" after 2 ns;
		result_jop_array(1) <= x"00000022", x"00000000" after 2 ns;
		wait;
	end process;
	
	datacall_ack_gen: process is
	begin
		for i in 0 to jop_cnt-1 loop
			datacall_jop_ack(i) <= '0';
		end loop;
		wait for 100 ns;
		datacall_jop_ack(2) <= '1', '0' after 2 ns;
		wait for 10 ns;
		datacall_jop_ack(1) <= '1', '0' after 2 ns;
		wait for 2 ns;
		datacall_jop_ack(1) <= '1', '0' after 2 ns;
		wait for 20 ns;
		datacall_jop_ack(0) <= '1', '0' after 2 ns;
		wait;
	end process;
	
	receive_pkg_gen: process is
	begin
		for i in 0 to number_of_nodes-1 loop
			ifrd_addr(i) <= (others => '0');
			wait;
		end loop;
	end process;
	
	ckl0_gen : process is
	begin
		wait for 1 ns;
		clk0_in <= not clk0_in;
	end process;
	ckl1_gen : process is
	begin
		wait for 1 ns;
		clk1_in <= not clk1_in;
	end process;
	
	initialize : process
	begin
		reset <= '1', '0' after 10 ns;
		wait;
	end process;

	pll_bypass : if SIMULATION = '1' generate
		clk_recop	<= clk0_in;
		clk_noc		<= clk0_in;
		clk_jop		<= clk1_in;
		clk_jop_inv	<= not clk1_in;
	end generate;

	
	-----------------------------------------------------------
	--   TDMA Mesh Network for constant transmission times   --
	-----------------------------------------------------------
	noc : TDMA_MINoC
	generic map(
		number_of_nodes	=> number_of_nodes,
		buffer_depth		=> buffer_depth
	)
	port map(
		clk		=> clk_noc,
		reset		=> int_res,
		tdm_slot	=> tdm_slot,
		in_port	=> noc_in_port,
		out_port	=> noc_out_port
	);
	
	
	-----------------------------------
	--  Network Interface for ReCOP  --
	-----------------------------------
	recop_min_if: recop_tdm_min_interface
		generic map(
			recop_cnt	=> recop_cnt,
			jop_cnt		=> jop_cnt,
			fifo_depth	=> buffer_depth
		)
		port map(
			clk		=> clk_recop,
			reset		=> int_res,
			tdm_slot	=> tdm_slot,
			dpcr_in	=> datacall_recop_array,
			dpcr_out	=> datacall_recop_if_array,
			dprr_in	=> result_recop_if_array,
			dprr_ack	=> result_recop_ack,
			dprr_out	=> result_recop_array
		);		
		
	global_counter : tdm_slot_counter
		generic map(
			number_of_stages	=> number_of_stages
		)
		port map(
			clk			=> clk_noc,
			reset			=> int_res,
			q				=> tdm_slot
	);
	
	
	---------------------------------
	--  Network Interface for JOP  --
	---------------------------------
	jop_min_if: jop_tdm_min_interface
		generic map(
			recop_cnt	=> recop_cnt,
			jop_cnt		=> jop_cnt,
			fifo_depth	=> buffer_depth
		)
		port map(
			clk		=> clk_jop,					
			reset		=> int_res,
			tdm_slot	=> tdm_slot,
			dpcr_in	=> datacall_jop_if_array,
			dpcr_ack	=> datacall_jop_ack,
			dpcr_out	=> datacall_jop_array,
			dprr_in	=> result_jop_array,
			dprr_out	=> result_jop_if_array
		);
	
	------------------------------------------------------
	--  physical wire connections between IF and cores  --
	------------------------------------------------------
	port_mapping: for j in 0 to number_of_nodes-1 generate
		recop_lookup: for i in 0 to recop_cnt-1 generate
			recop_link: if j = get_recop_mapping(i, number_of_nodes, recop_cnt) generate
				noc_in_port(j)					<= datacall_recop_if_array(i);
				ifrd_req(j)						<= result_interf_rdreq(i);
				result_recop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
		jop_lookup: for i in 0 to jop_cnt-1 generate
			jop_link: if j = get_jop_mapping(i, number_of_nodes, recop_cnt) generate
				noc_in_port(j)					<= result_jop_if_array(i);
				ifrd_req(j)						<= datacall_interf_rdreq(i);
				datacall_jop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
	end generate;
	
	
	------------------------
	--   Reset Counter   ---
	------------------------
	rescnt_inst : reset_counter
	port map(
		clk			=> clk_noc,
		reset			=> reset,
		reset_int	=> int_res
	);

end architecture rtl;
