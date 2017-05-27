library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.noc_types.all;
use work.jop_config.all;

entity multiReCOP is
	generic (
		SIMULATION		: std_logic := '0';
		MULTICLK			: std_logic := '0';
		--
		-- JOP generics
		--
		jop_cnt			: integer := 3;
		jop_ram_cnt		: integer := 3;		-- clock cycles for external ram
		--jop_rom_cnt	: integer := 3;		-- clock cycles for external rom OK for 20 MHz
		jop_rom_cnt		: integer := 15;		-- clock cycles for external rom for 100 MHz
		jop_jpc_width	: integer := 12;		-- address bits of java bytecode pc = cache size
		jop_block_bits	: integer := 5;		-- 2*block_bits is number of cache blocks
		jop_spm_width	: integer := 0;			-- size of scratchpad RAM (in number of address bits for 32-bit words)
		--
		-- ReCOP generics
		--
		recop_cnt		: integer := 1
	);
	port(
		--
		-- System wide ports
		clk0_in			: in std_logic;
		clk1_in			: in std_logic;
		oLEDR				: out std_logic_vector(9 downto 0);
		--oLEDG				: out std_logic_vector(8 downto 0);
		--oHEX0_D			: out std_logic_vector(6 downto 0);
		--oHEX0_DP			: out std_logic;
		--oHEX1_D			: out std_logic_vector(6 downto 0);
		--oHEX1_DP			: out std_logic;
		iSW				: in std_logic_vector(17 downto 0);
		iKEY				: in std_logic_vector(3 downto 0);		-- (x, x, x, reset)
		ser_txd			: out std_logic;
		ser_rxd			: in std_logic;
		-- 
		-- JOP ports
		oUART_CTS		: in std_logic;
		iUART_RTS		: out std_logic;
		wd					: out std_logic;
		-- GPIO
		GP_IN : in std_logic_vector(15 downto 0);
		GP_OUT : out std_logic_vector(15 downto 0)

		--oSRAM_A			: out std_logic_vector(18 downto 0);		-- edit
		--SRAM_DQ			: inout std_logic_vector(31 downto 0);	-- edit
		--oSRAM_CE1_N		: out std_logic;
		--oSRAM_OE_N		: out std_logic;
		--oSRAM_BE_N		: out std_logic_vector(3 downto 0);
		--oSRAM_WE_N		: out std_logic;
		--oSRAM_GW_N  	: out std_logic;
		--oSRAM_CLK		: out std_logic;
		--oSRAM_ADSC_N	: out std_logic;
		--oSRAM_ADSP_N	: out std_logic;
		--oSRAM_ADV_N		: out std_logic;
		--oSRAM_CE2		: out std_logic;
		--oSRAM_CE3_N 	: out std_logic
		--
		-- ReCOP ports
		-- sip			: in std_logic_vector(15 downto 0);
		-- sop			: out std_logic_vector(15 downto 0)
	);
end multiReCOP;



architecture rtl of multiReCOP is

component combined_pll IS
	port(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
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
generic (multiply_by : natural; divide_by : natural);
port (
	inclk0		: in std_logic;
	c0			: out std_logic;
	c1			: out std_logic;
	locked		: out std_logic
);
end component;


component jop_cmp is
	generic (
		cpu_cnt			: integer;
		ram_cnt			: integer;		-- clock cycles for external ram
		--rom_cnt		: integer;		-- clock cycles for external rom OK for 20 MHz
		rom_cnt			: integer;		-- clock cycles for external rom for 100 MHz
		jpc_width		: integer;		-- address bits of java bytecode pc = cache size
		block_bits		: integer;		-- 2*block_bits is number of cache blocks
		spm_width		: integer			-- size of scratchpad RAM (in number of address bits for 32-bit words)
	);

	port (
		clk_in			: in std_logic;
		clk_in_inv		: in std_logic;
		reset				: in std_logic;
		oLEDR				: out std_logic_vector(9 downto 0);
		--oLEDG				: out std_logic_vector(7 downto 0);
		iSW				: in std_logic_vector(9 downto 0);
		--oHEX0_D			: out std_logic_vector(6 downto 0);
		--oHEX0_DP			: out std_logic;
		--oHEX1_D			: out std_logic_vector(6 downto 0);
		--oHEX1_DP			: out std_logic;
		ser_txd			: out std_logic;
		ser_rxd			: in std_logic;
		oUART_CTS		: in std_logic;
		iUART_RTS		: out std_logic;
		wd					: out std_logic;
		DATACALL_ARRAY	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dc_ack			: out std_logic_vector(jop_cnt-1 downto 0);
		RESULT_ARRAY	: out NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
		GP_IN : in std_logic_vector(15 downto 0);
		GP_OUT : out std_logic_vector(15 downto 0);
		--oSRAM_A			: out std_logic_vector(18 downto 0);	-- edit
		--SRAM_DQ			: inout std_logic_vector(31 downto 0);	-- edit
		--oSRAM_CE1_N		: out std_logic;
		--oSRAM_OE_N		: out std_logic;
		--oSRAM_BE_N		: out std_logic_vector(3 downto 0);
		--oSRAM_WE_N		: out std_logic;
		--oSRAM_GW_N  	: out std_logic;
		--oSRAM_CLK		: out std_logic;
		--oSRAM_ADSC_N	: out std_logic;
		--oSRAM_ADSP_N	: out std_logic;
		--oSRAM_ADV_N		: out std_logic;
		--oSRAM_CE2		: out std_logic;
		--oSRAM_CE3_N 	: out std_logic;
		debug				: out std_logic_vector(15 downto 0)
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
		sop				: out std_logic_vector(15 downto 0)
	);
end component;

--component dpcr_mux is
--	generic(
--		jop_cnt			: integer
--	);
--	port(
--		datacall_in		: in std_logic_vector(31 downto 0);
--		datacall_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
--	);
--end component;

component dpcr_bus is
	generic(
		MULTICLK			: std_logic;
		jop_cnt			: integer;
		recop_cnt		: integer
	);
	port(
		clk_recop		: in std_logic;
		clk_noc			: in std_logic;
		clk_jop			: in std_logic;
		reset				: in std_logic;
		datacall_in		: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		datacall_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		datacall_jop_ack : in std_logic_vector(jop_cnt-1 downto 0);
		debug				: out std_logic_vector(15 downto 0)
	);
end component;

component dprr_bus is
	generic(
		MULTICLK			: std_logic;
		jop_cnt			: integer;
		recop_cnt		: integer
	);
	port(
		clk_recop		: in std_logic;
		clk_noc			: in std_logic;
		clk_jop			: in std_logic;
		reset				: in std_logic;
		dprr_in			: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out			: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_recop_ack : in std_logic_vector(recop_cnt-1 downto 0);
		debug				: out std_logic_vector(15 downto 0)
	);
end component;

component dprr_mux is
	generic(
		jop_cnt			: integer
	);
	port(
		debug				: out std_logic_vector(15 downto 0);
		clk_read			: in std_logic;
		clk_write		: in std_logic;
		reset				: in std_logic;
		dprr_in_array	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out			: out std_logic_vector(31 downto 0);
		dprr_ack			: in std_logic
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
		oSig	: out std_logic_vector(15 downto 0)
	);
end component;

	signal clk_jop			: std_logic;								-- drive jop
	signal clk_jop_inv	: std_logic;								-- clk_jop shifted by 180deg
	signal clk_recop		: std_logic;								-- drive ReCOP
	signal clk_noc			: std_logic;								-- drive interconnects
	signal clk_system		: std_logic;								-- system wide clock if single clock design
	signal clk_system_inv: std_logic;								-- clk_system shifted by 180deg
	signal reset			: std_logic;
	signal int_res			: std_logic;
	signal debug			: std_logic;
	signal step_through	: std_logic;
	signal eot				: std_logic_vector(recop_cnt-1 downto 0);
	signal er_btn			: std_logic;
	signal er_sw			: std_logic;
	signal z_flag			: std_logic_vector(recop_cnt-1 downto 0);
	
	signal datacall_jop_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal datacall_recop_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal datacall_jop_ack			: std_logic_vector(jop_cnt-1 downto 0);
	
	signal result_jop_array			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_recop_array		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal result_recop_ack			: std_logic_vector(recop_cnt-1 downto 0);
	
	signal sip				: std_logic_vector(15 downto 0);
	signal sop				: std_logic_vector(15 downto 0);
	signal sop_array		: BIT16_SIGNAL_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal debugWireI		: std_logic_vector(15 downto 0) := x"0000";
	signal debugWireII	: std_logic_vector(15 downto 0) := x"0000";
	signal oLEDR_int		: std_logic_vector(17 downto 0);
	signal componentDebugI: std_logic_vector(15 downto 0);
	signal componentDebugII: std_logic_vector(15 downto 0);
	signal oLEDG_int : std_logic_vector(8 downto 0);
	
begin

	------------------------
	--   CLOCK MAPPINGS   --
	------------------------
	
	comb_pll: if SIMULATION = '0' and MULTICLK = '0' generate
	combined_pll_inst : combined_pll
		port map(
			inclk0 	=> clk0_in,
			c0			=> clk_system,
			c1			=> clk_system_inv,
			locked	=> open
		);
	clk_recop		<= clk_system;
	clk_noc			<= clk_system;
	clk_jop			<= clk_system;
	clk_jop_inv		<= clk_system_inv;
	end generate;
	
	
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
		--rom_cnt		=> jop_rom_cnt,
		rom_cnt			=> jop_rom_cnt,
		jpc_width		=> jop_jpc_width,
		block_bits		=> jop_block_bits,
		spm_width		=> jop_spm_width
	)
	port map(
		clk_in			=> clk_jop,
		clk_in_inv		=> clk_jop_inv,
		reset				=> int_res,
		oLEDR				=> open,					
		--oLEDG				=> open,
		iSW				=> iSW(9 downto 0),
		--oHEX0_D			=> oHEX0_D,
		--oHEX0_DP			=> oHEX0_DP,
		--oHEX1_D			=> oHEX1_D,
		--oHEX1_DP			=> oHEX1_DP,
		ser_txd			=> ser_txd,
		ser_rxd			=> ser_rxd,
		oUART_CTS		=> oUART_CTS,
		iUART_RTS		=> iUART_RTS,
		wd					=> wd,
		DATACALL_ARRAY	=> DATACALL_JOP_ARRAY,
		dc_ack			=> datacall_jop_ack,
		RESULT_ARRAY	=> result_jop_array,
		GP_IN     => GP_IN,
		GP_OUT    => GP_OUT,
		--oSRAM_A			=> oSRAM_A,
		--SRAM_DQ			=> SRAM_DQ,
		--oSRAM_CE1_N		=> oSRAM_CE1_N,
		--oSRAM_OE_N		=> oSRAM_OE_N,
		--oSRAM_BE_N		=> oSRAM_BE_N,
		--oSRAM_WE_N		=> oSRAM_WE_N,
		--oSRAM_GW_N  	=> oSRAM_GW_N,
		--oSRAM_CLK		=> oSRAM_CLK,
		--oSRAM_ADSC_N	=> oSRAM_ADSC_N,
		--oSRAM_ADSP_N	=> oSRAM_ADSP_N,
		--oSRAM_ADV_N		=> oSRAM_ADV_N,
		--oSRAM_CE2		=> oSRAM_CE2,
		--oSRAM_CE3_N 	=> oSRAM_CE3_N,
--		debug				=> componentDebugI
		debug				=> open
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
			sop				=> sop_array(i)
		);
		end generate;
	
	sop <= sop_array(0);
	
	------------------
	--   DPCR Bus   --
	------------------
	dpcr_bus_inst : dpcr_bus
	generic map(
		MULTICLK				=> MULTICLK,
		jop_cnt				=> jop_cnt,
		recop_cnt			=> recop_cnt
	)
	port map(
		clk_recop			=> clk_recop,
		clk_noc				=> clk_noc,
		clk_jop				=> clk_jop,
		reset					=> int_res,
		datacall_in			=> datacall_recop_array,
		datacall_out		=> datacall_jop_array,
		datacall_jop_ack	=> datacall_jop_ack,
		debug					=> componentDebugI
	);
	
	
	------------------
	--   DPRR Bus   --
	------------------
	dprr_bus_inst : dprr_bus
	generic map(
		MULTICLK			=> MULTICLK,
		jop_cnt			=> jop_cnt,
		recop_cnt		=> recop_cnt
	)
	port map(
		clk_recop		=> clk_recop,
		clk_noc			=> clk_noc,
		clk_jop			=> clk_jop,
		reset				=> int_res,
		dprr_in			=> result_jop_array,
		dprr_out			=> result_recop_array,
		dprr_recop_ack	=> result_recop_ack,
		debug				=> componentDebugII
	);

	reset 					<= not iKEY(0);
	debug						<= iSW(9);
	er_sw						<= iSW(8);								--DEBUG function to constantly force ER signal
	sip						<= X"00" & iSW(7 downto 0);
	oLEDG_int(recop_cnt-1 downto 0)	<= eot;
--	oLEDG(8)					<= or_reduce(z_flag);
	oLEDG_int(8)					<= z_flag(0);
--	oLEDR(15 downto 0)	<= oLEDR_int(15 downto 0) OR debugWireI;
	oLEDR(9 downto 0)	<= oLEDR_int(9 downto 0);



	---------------------------------------
	--   Sample and Hold Debug Signals   --
	---------------------------------------
	debugger_inst : signal_holder
	port map(
		clk	=> clk_jop,
--		clk	=> clk_recop,
--		clk	=> clk_noc,
		reset	=> int_res,
		iSigI	=> debugWireI,
		iSigII => debugWireII,
		oSig	=> oLEDR_int(15 downto 0)
--		oSig	=> open
	);
--	debugWireI <=	datacall_recop_array(0)(31 downto 16) or
--						datacall_recop_array(1)(31 downto 16);
--	debugWireII <= result_recop_array(0)(15 downto 0) or
--						result_recop_array(0)(15 downto 0);
	
--	debugWireI(7 downto 0) <= DATACALL_ARRAY(0)(23 downto 16);
--	debugWireI(15 downto 8) <= DATACALL_ARRAY(1)(23 downto 16);
--	debugWireI <= datacall_array(0)(31 downto 16) or
--						datacall_array(1)(31 downto 16) or
--						datacall_array(2)(31 downto 16) or
--						datacall_array(3)(31 downto 16);
--	debugWireI <= datacall_recop_array(0)(31 downto 16) or
--						datacall_recop_array(1)(31 downto 16);
--	debugWireI <= datacall_jop_array(0)(31 downto 16) or
--						datacall_jop_array(1)(31 downto 16) or
--						datacall_jop_array(2)(31 downto 16);				
	debugWireI <= componentDebugI;
	debugWireII <=componentDebugII;
--	debugWireII <= result_recop_array(0)(15 downto 0);
--	debugWireI <= result(15 downto 0);
--	debugWireI <= result_array(0)(15 downto 0) or
--						result_array(1)(15 downto 0) or
--						result_array(2)(15 downto 0) or
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

end architecture;
