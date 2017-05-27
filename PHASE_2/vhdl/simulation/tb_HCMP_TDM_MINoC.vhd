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
use work.min_ports_pkg.all;
use work.HMPSoC_config.all;


entity tb_HCMP_TDM_MINoC is
	generic (
		SIMULATION		: std_logic := '0';
		MULTICLK			: std_logic := '0';	-- currently not available in MIN architecture
		buffer_depth	: integer := 128;		-- fifo_depth in network nodes
		--
		-- JOP generics
		--
		jop_cnt			: integer := num_jop;
		jop_ram_cnt		: integer := 3;		-- clock cycles for external ram
		--jop_rom_cnt	: integer := 3;		-- clock cycles for external rom OK for 20 MHz
		jop_rom_cnt		: integer := 15;		-- clock cycles for external rom for 100 MHz
		jop_jpc_width	: integer := 12;		-- address bits of java bytecode pc = cache size
		jop_block_bits	: integer := 5;		-- 2*block_bits is number of cache blocks
		jop_spm_width	: integer := 0;		-- size of scratchpad RAM (in number of address bits for 32-bit words)
		--
		-- ReCOP generics
		--
		recop_cnt		: integer := num_recop
	);
	port(
		--
		-- System wide ports
		--clk0_in			: in std_logic;
		--clk1_in			: in std_logic;
		oLEDR				: out std_logic_vector(17 downto 0);
		oLEDG				: out std_logic_vector(8 downto 0);
		iSW				: in std_logic_vector(17 downto 0);
		iKEY				: in std_logic_vector(3 downto 0);		-- (x, x, x, reset)
--
-- Seven Segment Displays
--
		oHEX0      : out std_logic_vector(6 downto 0);
		oHEX1      : out std_logic_vector(6 downto 0);
		oHEX2      : out std_logic_vector(6 downto 0);
		oHEX3      : out std_logic_vector(6 downto 0);
		oHEX4      : out std_logic_vector(6 downto 0);
		oHEX5      : out std_logic_vector(6 downto 0);
		oHEX6      : out std_logic_vector(6 downto 0);
		oHEX7      : out std_logic_vector(6 downto 0);

		ser_txd			: out std_logic;
		ser_rxd			: in std_logic;
		
--
-- GPIO
--
   	GP_IN : in std_logic_vector(15 downto 0);
   	GP_OUT : out std_logic_vector(15 downto 0); -- for mechatronics
		
		-- 
		-- JOP ports
		oUART_CTS		: in std_logic;
		iUART_RTS		: out std_logic;
		wd					: out std_logic
		--
		-- ReCOP ports
		-- sip			: in std_logic_vector(15 downto 0);
		-- sop			: out std_logic_vector(15 downto 0)
	);
end entity tb_HCMP_TDM_MINoC;


architecture rtl of tb_HCMP_TDM_MINoC is

	constant number_of_nodes	: integer := jop_cnt + recop_cnt;
	constant	number_of_stages	: integer := integer(ceil(log2(real(number_of_nodes))));
	constant	max_nodes			: integer := integer(2 ** (number_of_stages));
	constant clk_period : time := 12.5 ns;

	signal clk0_in			: std_logic := '0';
	signal clk1_in			: std_logic := '0';
	
	signal clk_jop			: std_logic;								-- drive jop
	signal clk_jop_inv	: std_logic;								-- clk_jop shifted by 180deg
	signal clk_recop		: std_logic;								-- drive ReCOP
	signal clk_noc			: std_logic;								-- drive interconnects
	signal clk_system		: std_logic;								-- system wide clock if single clock design
	signal clk_system_inv: std_logic;								-- clk_system shifted by 180deg
	
	signal reset			: std_logic;
	signal int_res			: std_logic;
	
	signal tdm_slot		: std_logic_vector(integer(ceil(log2(real(number_of_nodes))))-1 downto 0);
	
	signal min_in_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1) := (others => (others => '0'));
	signal min_out_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);
	signal ifrd_req			: std_logic_vector(0 to max_nodes-1);
	signal ifrd_addr			: FIFO_ADDR_ARRAY_TYPE(0 to max_nodes-1);
	
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
	
	signal debugWireI		: std_logic_vector(15 downto 0) := x"0000";
	signal debugWireII	: std_logic_vector(15 downto 0) := x"0000";
	signal debugWireIII	: std_logic_vector(15 downto 0) := x"0000";
	signal componentDebugI: std_logic_vector(15 downto 0);
	signal componentDebugII: std_logic_vector(15 downto 0);
	signal componentDebugIII: std_logic_vector(15 downto 0);
	

	
	signal debug			: std_logic;
	signal step_through	: std_logic;
	signal sip				: std_logic_vector(15 downto 0);
	signal sop				: std_logic_vector(15 downto 0);
	signal eot				: std_logic_vector(recop_cnt-1 downto 0);
	signal er_btn			: std_logic;
	signal er_sw			: std_logic;
	signal z_flag			: std_logic_vector(recop_cnt-1 downto 0);
	signal sop_array		: BIT16_SIGNAL_ARRAY_TYPE(recop_cnt-1 downto 0);

	signal oLEDR_int		: std_logic_vector(9 downto 0);

	signal data_call_valid : std_logic_vector(max_nodes-1 downto 0) := ( others => '0' );
	signal clear_jop_status : std_logic_vector(max_nodes-1 downto 0) := ( others => '0' );
	signal dispatched : std_logic_vector(recop_cnt-1 downto 0);
	signal dispatched_io : std_logic_vector(recop_cnt-1 downto 0);
	signal jop_free         : std_logic_vector(recop_cnt-1 downto 0);
	
	component combined_pll IS
		port(
			inclk0	: IN STD_LOGIC  := '0';
			c0			: OUT STD_LOGIC ;
			c1			: OUT STD_LOGIC ;
			locked	: OUT STD_LOGIC 
		);
	end component;
	
	component sys_pll is
		port(
			inclk0			: IN STD_LOGIC := '0';
			c0					: OUT STD_LOGIC;
			c1					: OUT STD_LOGIC
		);
	end component;
	
	component pll is
		generic (
			multiply_by	: natural;
			divide_by	: natural
			);
		port (
			inclk0		: in std_logic;
			c0				: out std_logic;
			c1				: out std_logic;
			locked		: out std_logic
		);
	end component;

	component ReCOPv2 is
		generic(
			recop_id			: integer
		);
		port(
			inclk0			: in std_logic;
			reset				: in std_logic;
			button			: in std_logic;
			debug				: in std_logic;
			dpcr				: out std_logic_vector(31 downto 0);
			dprr				: in std_logic_vector(31 downto 0);
			dprr_ack			: out std_logic;
			sip				: in std_logic_vector(15 downto 0);
			er_btn			: in std_logic;
			er_sw				: in std_logic;
			eot				: out std_logic;
			z_flag			: out std_logic;
			sop				: out std_logic_vector(15 downto 0);
            dispatched      : in std_logic;
            dispatched_io   : in std_logic;
            jop_free        : in std_logic
		);
	end component;
	
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
			data_call_valid : in std_logic_vector((2 ** number_of_stages)-1 downto 0);
			clear_jop_status : in std_logic_vector((2 ** number_of_stages)-1 downto 0);
			jop_free : out std_logic_vector(num_recop-1 downto 0);
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
			jop_free : in std_logic_vector(num_recop-1 downto 0); 
			dispatched : out std_logic_vector(recop_cnt-1 downto 0);
			dispatched_io : out std_logic_vector(recop_cnt-1 downto 0);
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
	
	component signal_holder is
		port(
			clk	: in std_logic;
			reset	: in std_logic;
			iSigI	: in std_logic_vector(15 downto 0);
			isigII : in std_logic_vector(15 downto 0);
			iSigIII : in std_logic_vector(15 downto 0);
			oSig	: out std_logic_vector(15 downto 0)
		);
	end component;

	component jop_cmp is
		generic (
		cpu_cnt			: integer;
		ram_cnt			: integer;	
		--rom_cnt		: integer;	
		rom_cnt			: integer;	
		jpc_width		: integer;	
		block_bits		: integer;
		spm_width		: integer		
	);
		port (
			 clk_in			  : in std_logic;
			 clk_in_inv		: in std_logic;
			 reset				: in std_logic;
			 oLEDR		    : out std_logic_vector(17 downto 0);
			 oLEDG				: out std_logic_vector(8 downto 0);
			 iSW				  : in std_logic_vector(17 downto 0);
			 oHEX0        : out std_logic_vector(6 downto 0);
			 oHEX1        : out std_logic_vector(6 downto 0);
			 oHEX2        : out std_logic_vector(6 downto 0);
			 oHEX3        : out std_logic_vector(6 downto 0);
			 oHEX4        : out std_logic_vector(6 downto 0);
			 oHEX5        : out std_logic_vector(6 downto 0);
			 oHEX6        : out std_logic_vector(6 downto 0);
			 oHEX7        : out std_logic_vector(6 downto 0);

			 ser_txd			: out std_logic;
			 ser_rxd			: in std_logic;
			 oUART_CTS		: in std_logic;
			 iUART_RTS		: out std_logic;
			 GP_IN : in std_logic_vector(15 downto 0);
			 GP_OUT : out std_logic_vector(15 downto 0); -- for mechatronics
			 wd				: out std_logic;
			 DATACALL_ARRAY	: in NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
			 dc_ack			: out std_logic_vector(cpu_cnt-1 downto 0);
			 RESULT_ARRAY	: out NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
			 debug			 : out std_logic_vector(15 downto 0)
				 );
	end component;
	

begin
	tb_reset : process
	begin
		reset <= '1';
		wait for 1 ms;
		reset <= '0';
		wait;
	end process;

	er_sw <= '1';

	debug <= '0';

	--reset 					<= not iKEY(0);
	--debug						<= iSW(9);
	--er_sw						<= iSW(8);								--DEBUG function to constantly force ER signal
	sip(7 downto 0)						<= iSW(7 downto 0);
--	others => '0');
--	oLEDR(recop_cnt-1 downto 0)	<= eot;
--	oLEDR(8)					<= z_flag(0);
	
--	oLEDR <= GP_IN(9 downto 0);
	
--	oLEDR_int				<= "00" & x"abcd";
--	datacall_jop_array(0) <= x"80000002";
--	datacall_jop_array(1) <= x"00000000";
--	datacall_jop_array(2) <= x"00000000";
	
	------------------------
	--   CLOCK MAPPINGS   --
	------------------------
	--comb_pll: if SIMULATION = '0' and MULTICLK = '0' generate
	--combined_pll_inst : combined_pll
		--port map(
			--inclk0 	=> clk0_in,
			--c0			=> clk_system,
			--c1			=> clk_system_inv,
			--locked	=> open
		--);
	--clk_recop		<= clk_system;
	--clk_noc			<= clk_system;
	--clk_jop			<= clk_system;
	--clk_jop_inv		<= clk_system_inv;
	--end generate;
	clk_recop <= clk0_in;
	clk_noc <= clk0_in;
	clk_jop <= clk0_in;
	clk_jop_inv <= not clk0_in;
	
	plls : if SIMULATION = '0' and MULTICLK = '1' generate
	sys_pll_inst : sys_pll
		port map(
			inclk0	=> clk0_in,
			c0			=> clk_noc,
			c1			=> clk_recop
		);
	pll_inst : pll 
		generic map(
			multiply_by	=> pll_mult,
			divide_by	=> pll_div
		)
		port map (
			inclk0	=> clk1_in,
			c0			=> clk_jop,
			c1			=> clk_jop_inv,
			locked 	=> open
		);
	end generate;
	
	pll_bypass : if SIMULATION = '1' generate
		clk_recop	<= clk0_in;
		clk_noc		<= clk0_in;
		clk_jop		<= clk1_in;
		clk_jop_inv	<= not clk1_in;
	end generate;

	
	-------------
	--   JOP   --
	-------------
	jop_container : jop_cmp
	generic map(
		cpu_cnt			=> jop_cnt,
		ram_cnt			=> jop_ram_cnt,
		rom_cnt			=> jop_rom_cnt,
		jpc_width		=> jop_jpc_width,
		block_bits		=> jop_block_bits,
		spm_width		=> jop_spm_width
	)
	port map(
		clk_in			=> clk_jop,
		clk_in_inv		=> clk_jop_inv,
		reset				=> int_res,
		oLEDR				=> oLEDR,					
		oLEDG				=> oLEDG,	
		iSW				=> iSW,
		oHEX0 => oHEX0,
		oHEX1 => oHEX1,
		oHEX2 => oHEX2,
		oHEX3 => oHEX3,
		oHEX4 => oHEX4,
		oHEX5 => oHEX5,
		oHEX6 => oHEX6,
		oHEX7 => oHEX7,
		GP_IN => GP_IN,
		GP_OUT => GP_OUT,
		ser_txd			=> ser_txd,
		ser_rxd			=> ser_rxd,
		oUART_CTS		=> oUART_CTS,
		iUART_RTS		=> iUART_RTS,
		wd					=> wd,
		DATACALL_ARRAY	=> DATACALL_JOP_ARRAY,
		dc_ack			=> datacall_jop_ack,
		RESULT_ARRAY	=> result_jop_array,
		debug				=> componentDebugI
--		debug				=> open
	);
	
	
	---------------
	--   ReCOP   --
	---------------
	gen_recop: for i in 0 to recop_cnt-1 generate
		recop_inst: ReCOPv2
		generic map(
			recop_id			=> i
		)
		port map(
			inclk0			=> clk_recop,
			reset				=> int_res,
			button			=> step_through,
			debug				=> debug,
			dpcr				=> datacall_recop_array(i),
			dprr				=> result_recop_array(i),
			dprr_ack			=> result_recop_ack(i),
			sip				=> sip,
			er_btn			=> er_btn,
			er_sw				=> er_sw,
			eot				=> eot(i),
			z_flag			=> z_flag(i),
			sop				=> sop_array(i),
			dispatched		=> dispatched(i),
			dispatched_io   => dispatched_io(i),
			jop_free        => jop_free(i)
		);
		
		end generate;
	
	sop <= sop_array(0);


	-----------------------------------------------------------
	--   TDMA Mesh Network for constant transmission times   --
	-----------------------------------------------------------
	noc : TDMA_MINoC
	generic map(
		number_of_nodes	=> max_nodes,
		buffer_depth		=> buffer_depth
	)
	port map(
		clk		=> clk_noc,
		reset		=> int_res,
		tdm_slot	=> tdm_slot,
		in_port	=> min_in_port,
		out_port	=> min_out_port
	);
	
	global_counter : tdm_slot_counter
	generic map(
		number_of_stages	=> number_of_stages
	)
	port map(
		clk			=> clk_noc,
		reset			=> int_res,
		data_call_valid 	 => data_call_valid,
		clear_jop_status	 => clear_jop_status,
		jop_free 	=> jop_free,
		q				=> tdm_slot
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
			jop_free => jop_free,
			dispatched => dispatched,
			dispatched_io => dispatched_io,
			tdm_slot	=> tdm_slot,
			dpcr_in	=> datacall_recop_array,
			dpcr_out	=> datacall_recop_if_array,
			dprr_in	=> result_recop_if_array,
			dprr_ack	=> result_recop_ack,
			dprr_out	=> result_recop_array
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
--	datacall_jop_if_array(0) <= datacall_recop_if_array(0);
--	result_recop_if_array(0) <= result_jop_if_array(0);
	
	------------------------------------------------------
	--  physical wire connections between IF and cores  --
	------------------------------------------------------
	port_mapping: for j in 0 to max_nodes-1 generate
		recop_lookup: for i in 0 to recop_cnt-1 generate
			recop_link: if j = get_recop_mapping(i, number_of_nodes, recop_cnt) generate
				min_in_port(j)					<= datacall_recop_if_array(i);
				data_call_valid(j)              <= min_in_port(j)(31);
				ifrd_req(j)						<= result_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				result_recop_if_array(i)	<= min_out_port(j);
			end generate;
		end generate;
		jop_lookup: for i in 0 to jop_cnt-1 generate
			jop_link: if j = get_jop_mapping(i, number_of_nodes, recop_cnt) generate
				min_in_port(j)					<= result_jop_if_array(i);
				clear_jop_status(j)             <= min_in_port(j)(31);
				ifrd_req(j)						<= datacall_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				datacall_jop_if_array(i)	<= min_out_port(j);
			end generate;
--			jop_linka: if j = 1 and i = 2 generate
--				noc_in_port(j)					<= result_jop_if_array(i);
--				ifrd_req(j)						<= datacall_interf_rdreq(i);
--				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
--				datacall_jop_if_array(i)	<= noc_out_port(j);
--			end generate;
--			jop_linkb: if j = 2 and i = 1 generate
--				noc_in_port(j)					<= result_jop_if_array(i);
--				ifrd_req(j)						<= datacall_interf_rdreq(i);
--				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
--				datacall_jop_if_array(i)	<= noc_out_port(j);
--			end generate;
--			jop_linkc: if j = 3 and i = 0 generate
--				noc_in_port(j)					<= result_jop_if_array(i);
--				ifrd_req(j)						<= datacall_interf_rdreq(i);
--				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
--				datacall_jop_if_array(i)	<= noc_out_port(j);
--			end generate;
		end generate;
	end generate;
	
	-----------------------------
	--   ReCOP steper button   --
	-----------------------------
	stepper_inst : recop_stepper
	port map(
		clk		=> clk_recop,
		iBtn		=> iKEY(1),
		step		=> step_through
	);
	
	
	------------------------------------------
	--   ReCOP environment ready bypasses   --
	------------------------------------------
	erbypass_inst : recop_stepper
	port map(
		clk		=> clk_recop,
		iBtn		=> iKEY(3),
		step		=> er_btn
	);
	
	------------------------
	--   Reset Counter   ---
	------------------------
	rescnt_inst : reset_counter
	port map(
		clk			=> clk_noc,
		reset			=> reset,
		reset_int	=> int_res
	);
	
	---------------------------------------
	--   Sample and Hold Debug Signals   --
	---------------------------------------
	debugger_inst : signal_holder
	port map(
--		clk	=> clk_jop,
--		clk	=> clk_recop,
		clk	=> clk_noc,
		reset	=> int_res,
		iSigI	=> debugWireI,
		iSigII => debugWireII,
		iSigIII => debugWireIII,
		oSig	=> open--oLEDR_int(9 downto 0)
	);
--	debugWireI	<= componentDebugI;
--	debugWireII <= componentDebugII;

--	debugWireI <=	datacall_jop_if_array(2)(31 downto 16);
--	debugWireII <= result_jop_if_array(2)(15 downto 0);
	debugWireI <=	datacall_recop_array(0)(31 downto 16);
	debugWireII <= result_jop_array(0)(15 downto 0);
	debugWireIII <= datacall_recop_array(0)(15 downto 0);

	clk_process: process
	begin
			clk0_in <= not clk0_in after clk_period / 2;
			clk1_in <= not clk1_in after clk_period / 2;
			wait for clk_period / 2;
	end process;



--	debugWireI <=	datacall_recop_array(0)(31 downto 16);
--						datacall_recop_array(1)(31 downto 16);
--	debugWireII <= result_recop_array(0)(15 downto 0);
--						result_recop_array(0)(15 downto 0);
	
--	debugWireI(7 downto 0) <= DATACALL_ARRAY(0)(23 downto 16);
--	debugWireI(15 downto 8) <= DATACALL_ARRAY(1)(23 downto 16);
--	debugWireI <= datacall_array(0)(31 downto 16) or
--						datacall_array(1)(31 downto 16) or
--						datacall_array(2)(31 downto 16) or
--						datacall_array(3)(31 downto 16);
--	debugWireI <= datacall_recop_array(0)(31 downto 16) or
--						datacall_recop_array(1)(31 downto 16);
--	debugWireI	<= DATACALL_JOP_ARRAY(1)(31 downto 16);
--	debugWireI	<= datacall_recop_array(0)(31 downto 16);
--	debugWireI <= datacall_jop_array(0)(31 downto 16) or
--						datacall_jop_array(1)(31 downto 16) or
--						datacall_jop_array(2)(31 downto 16);				
--	debugWireII <= result_recop_array(0)(15 downto 0);
--	debugWireI <= result(15 downto 0);
--	debugWireI <= result_jop_if_array(0)(31 downto 16) or
--						result_jop_if_array(1)(31 downto 16) or
--						result_jop_if_array(2)(31 downto 16);
--	debugWireI <= result_array(0)(15 downto 0) or
--						result_array(1)(15 downto 0) or
--						result_array(2)(15 downto 0);
--						result_array(3)(15 downto 0);
--						result_array(4)(15 downto 0) or
--						result_array(5)(15 downto 0);
--	oLEDR_int(15 downto 0) <= result_array(0)(15 downto 0) or
--										result_array(1)(15 downto 0);
--	debugWireI <= "00000000000000" &
--						result_array(0)(1) & 
--						result_array(1)(1);
--						result_array(2)(1) &
--						result_array(3)(1) &
--						result_array(4)(1) &
--						result_array(5)(1);
	


end architecture rtl;
