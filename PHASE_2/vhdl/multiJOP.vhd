library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;

entity multiJOP is
	generic (
		--
		-- JOP generics
		--
		jop_cnt			: integer := 2;
		jop_ram_cnt		: integer := 3;		-- clock cycles for external ram
		--jop_rom_cnt	: integer := 3;		-- clock cycles for external rom OK for 20 MHz
		jop_rom_cnt		: integer := 15;		-- clock cycles for external rom for 100 MHz
		jop_jpc_width	: integer := 12;		-- address bits of java bytecode pc = cache size
		jop_block_bits	: integer := 5;		-- 2*block_bits is number of cache blocks
		jop_spm_width	: integer := 0			-- size of scratchpad RAM (in number of address bits for 32-bit words)
	);
	port(
		--
		-- System wide ports
		clk0_in			: in std_logic;
		clk1_in			: in std_logic;
		oLEDR				: out std_logic_vector(17 downto 0);
		oLEDG				: out std_logic_vector(8 downto 0);
		oHEX0_D			: out std_logic_vector(6 downto 0);
		oHEX0_DP			: out std_logic;
		oHEX1_D			: out std_logic_vector(6 downto 0);
		oHEX1_DP			: out std_logic;
		iSW				: in std_logic_vector(17 downto 0);
		iKEY				: in std_logic_vector(3 downto 0);		-- (x, x, x, reset)
		ser_txd			: out std_logic;
		ser_rxd			: in std_logic;
		-- 
		-- JOP ports
		oUART_CTS		: in std_logic;
		iUART_RTS		: out std_logic;
		wd					: out std_logic;
		oSRAM_A			: out std_logic_vector(18 downto 0);		-- edit
		SRAM_DQ			: inout std_logic_vector(31 downto 0);	-- edit
		oSRAM_CE1_N		: out std_logic;
		oSRAM_OE_N		: out std_logic;
		oSRAM_BE_N		: out std_logic_vector(3 downto 0);
		oSRAM_WE_N		: out std_logic;
		oSRAM_GW_N  	: out std_logic;
		oSRAM_CLK		: out std_logic;
		oSRAM_ADSC_N	: out std_logic;
		oSRAM_ADSP_N	: out std_logic;
		oSRAM_ADV_N		: out std_logic;
		oSRAM_CE2		: out std_logic;
		oSRAM_CE3_N 	: out std_logic
		--
		-- ReCOP ports
		-- sip			: in std_logic_vector(15 downto 0);
		-- sop			: out std_logic_vector(15 downto 0)
	);
end multiJOP;



architecture rtl of multiJOP is

component sys_pll is
	port(
		inclk0			: IN STD_LOGIC := '0';
		c0					: OUT STD_LOGIC;
		c1					: OUT STD_LOGIC
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
		clk0_in			: in std_logic;
		clk_noc_in		: in std_logic;
		clk_jop_out		: out std_logic;
		reset				: in std_logic;
		oLEDR				: out std_logic_vector(17 downto 0);
		oLEDG				: out std_logic_vector(7 downto 0);
		iSW				: in std_logic_vector(17 downto 0);
		oHEX0_D			: out std_logic_vector(6 downto 0);
		oHEX0_DP			: out std_logic;
		oHEX1_D			: out std_logic_vector(6 downto 0);
		oHEX1_DP			: out std_logic;
		ser_txd			: out std_logic;
		ser_rxd			: in std_logic;
		oUART_CTS		: in std_logic;
		iUART_RTS		: out std_logic;
		wd					: out std_logic;
		DATACALL_ARRAY	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dc_ack			: out std_logic_vector(jop_cnt-1 downto 0);
		RESULT_ARRAY	: out NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
		oSRAM_A			: out std_logic_vector(18 downto 0);	-- edit
		SRAM_DQ			: inout std_logic_vector(31 downto 0);	-- edit
		oSRAM_CE1_N		: out std_logic;
		oSRAM_OE_N		: out std_logic;
		oSRAM_BE_N		: out std_logic_vector(3 downto 0);
		oSRAM_WE_N		: out std_logic;
		oSRAM_GW_N  	: out std_logic;
		oSRAM_CLK		: out std_logic;
		oSRAM_ADSC_N	: out std_logic;
		oSRAM_ADSP_N	: out std_logic;
		oSRAM_ADV_N		: out std_logic;
		oSRAM_CE2		: out std_logic;
		oSRAM_CE3_N 	: out std_logic;
		debug				: out std_logic_vector(15 downto 0)
	);
end component;

component ReCOPv2 is
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

component dpcr_mux is
	generic(
		jop_cnt			: integer
	);
	port(
		datacall_in		: in std_logic_vector(31 downto 0);
		datacall_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
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
		iSig	: in std_logic_vector(15 downto 0);
		oSig	: out std_logic_vector(15 downto 0)
	);
end component;

	signal clk_jop			: std_logic;								-- drive JOP-PLL
	signal clk_recop		: std_logic;								-- drive ReCOP
	signal clk_noc			: std_logic;								-- drive interconnects
	signal clk_jop_out	: std_logic;								-- generated by jop
	signal reset			: std_logic;
	signal int_res			: std_logic;
	signal debug			: std_logic;
	signal step_through	: std_logic;
	signal eot				: std_logic;
	signal er_btn			: std_logic;
	signal er_sw			: std_logic;
	signal z_flag			: std_logic;
	signal datacall		: std_logic_vector(31 downto 0);
	signal datacall_array: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal dpcr_fifo_put	: std_logic;
	signal dc_ack			: std_logic_vector(jop_cnt-1 downto 0);
	signal RESULT			: std_logic_vector(31 downto 0);
	signal result_array: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_ack		: std_logic;
	signal sip				: std_logic_vector(15 downto 0);
	signal sop				: std_logic_vector(15 downto 0);
	signal debugWire		: std_logic_vector(15 downto 0) := x"0000";
	signal oLEDR_int		: std_logic_vector(17 downto 0);
	signal componentDebug	: std_logic_vector(15 downto 0);
	
	
begin

	------------------------
	--   CLOCK MAPPINGS   --
	------------------------
	sys_pll_inst : sys_pll
	port map(
		inclk0			=> clk0_in,
		c0					=> clk_noc,
		c1					=> clk_recop
	);
	clk_jop				<= clk1_in;
	
	
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
		clk0_in			=> clk_jop,
		clk_noc_in		=> clk_noc,
		clk_jop_out		=> clk_jop_out,
		reset				=> int_res,
		oLEDR				=> open,					
		oLEDG				=> open,
		iSW(15 downto 0)=> iSW(15 downto 0),
		oHEX0_D			=> oHEX0_D,
		oHEX0_DP			=> oHEX0_DP,
		oHEX1_D			=> oHEX1_D,
		oHEX1_DP			=> oHEX1_DP,
		ser_txd			=> ser_txd,
		ser_rxd			=> ser_rxd,
		oUART_CTS		=> oUART_CTS,
		iUART_RTS		=> iUART_RTS,
		wd					=> wd,
		DATACALL_ARRAY	=> DATACALL_ARRAY,
		dc_ack			=> dc_ack,
		RESULT_ARRAY	=> RESULT_ARRAY,
		oSRAM_A			=> oSRAM_A,
		SRAM_DQ			=> SRAM_DQ,
		oSRAM_CE1_N		=> oSRAM_CE1_N,
		oSRAM_OE_N		=> oSRAM_OE_N,
		oSRAM_BE_N		=> oSRAM_BE_N,
		oSRAM_WE_N		=> oSRAM_WE_N,
		oSRAM_GW_N  	=> oSRAM_GW_N,
		oSRAM_CLK		=> oSRAM_CLK,
		oSRAM_ADSC_N	=> oSRAM_ADSC_N,
		oSRAM_ADSP_N	=> oSRAM_ADSP_N,
		oSRAM_ADV_N		=> oSRAM_ADV_N,
		oSRAM_CE2		=> oSRAM_CE2,
		oSRAM_CE3_N 	=> oSRAM_CE3_N,
		debug				=> componentDebug
	);
	
	
	---------------
	--   ReCOP   --
	---------------
	recop_inst0 : ReCOPv2
	port map(
		inclk0			=> clk_recop,
		reset				=> int_res,
		button			=> step_through,
		debug				=> debug,
		dpcr				=> datacall,
		dprr				=> result,
		dprr_ack			=> result_ack,
		sip				=> sip,
		er_btn			=> er_btn,
		er_sw				=> er_sw,
		eot				=> eot,
		z_flag			=> z_flag,
		sop				=> sop
	);
	
	
	----------------------------
	--   DPCR demultiplexer   --
	----------------------------
	dpcr_mux_inst : dpcr_mux
	generic map(
		jop_cnt			=> jop_cnt
	)
	port map(
		datacall_in		=> datacall,
		datacall_out	=> datacall_array
	);
--	dc_ack_mapper : for i in 0 to jop_cnt-1 generate
--		dc_ack(i)		<= result_array(i)(1);
--	end generate;
	

	--------------------------
	--   DPRR multiplexer   --
	--------------------------
	cpdrr_mux_inst : dprr_mux
	generic map(
		jop_cnt			=> jop_cnt
	)
	port map(
		debug				=> open,
		clk_read			=> clk_recop,
		clk_write		=> clk_jop_out,
		reset				=> int_res,
		dprr_in_array	=> result_array,
		dprr_out			=> result,
		dprr_ack			=> result_ack
	);

	
	reset 					<= not iKEY(0);
	debug						<= iSW(17);
	er_sw						<= iSW(16);								--DEBUG function to constantly force ER signal
	sip						<= iSW(15 downto 0);
	oLEDG(0)					<= eot;
	oLEDG(8)					<= z_flag;
--	oLEDR(15 downto 0)	<= oLEDR_int(15 downto 0) OR debugWire;
	oLEDR(15 downto 0)	<= oLEDR_int(15 downto 0);



	---------------------------------------
	--   Sample and Hold Debug Signals   --
	---------------------------------------
	debugger_inst : signal_holder
	port map(
--		clk	=> clk_jop_out,
		clk	=> clk_noc,
		reset	=> int_res,
		iSig	=> debugWire,
		oSig	=> oLEDR_int(15 downto 0)
--		oSig	=> open
	);
--	debugWire(7 downto 0) <= DATACALL_ARRAY(0)(23 downto 16);
--	debugWire(15 downto 8) <= DATACALL_ARRAY(1)(23 downto 16);
--	debugWire <= datacall_array(0)(31 downto 16) or
--						datacall_array(1)(31 downto 16) or
--						datacall_array(2)(31 downto 16) or
--						datacall_array(3)(31 downto 16);
	debugWire <= datacall(31 downto 16);
--	debugWire <= componentDebug;
--	debugWire <= result(15 downto 0);
--	debugWire <= result_array(0)(15 downto 0) or
--						result_array(1)(15 downto 0) or
--						result_array(2)(15 downto 0) or
--						result_array(3)(15 downto 0);
--						result_array(4)(15 downto 0) or
--						result_array(5)(15 downto 0);
--	oLEDR_int(15 downto 0) <= result_array(0)(15 downto 0) or
--										result_array(1)(15 downto 0);
--	debugWire <= "00000000000000" &
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