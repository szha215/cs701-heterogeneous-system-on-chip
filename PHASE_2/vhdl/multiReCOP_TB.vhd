library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multiReCOP_TB is
end multiReCOP_TB;

architecture sim of multiReCOP_TB is

	component multiReCOP is
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
	end component;
	
	signal tb_clk 	: std_logic;
	signal LEDr		: std_logic_vector(17 downto 0);
	signal LEDg		: std_logic_vector(8 downto 0);
	signal sw		: std_logic_vector(17 downto 0);
	signal pb		: std_logic_vector(3 downto 0);
	signal tx		: std_logic;
	signal rx		: std_logic;
	signal cts		: std_logic;
	signal rts		: std_logic;
	signal sram_DQ	: std_logic_vector(31 downto 0);
	
begin
	
	dut : multiReCOP
	port map(
		--
		-- System wide ports
		clk0_in			=> tb_clk,
		clk1_in			=> tb_clk,
		oLEDR				=> LEDr,
		oLEDG				=> LEDg,
		oHEX0_D			=> open,
		oHEX0_DP			=> open,
		oHEX1_D			=> open,
		oHEX1_DP			=> open,
		iSW				=> sw,
		iKEY				=> pb,
		ser_txd			=> tx,
		ser_rxd			=> rx,
		-- 
		-- JOP ports
		oUART_CTS		=> cts,
		iUART_RTS		=> rts,
		wd					=> open,
		oSRAM_A			=> open,
		SRAM_DQ			=> sram_DQ,
		oSRAM_CE1_N		=> open,
		oSRAM_OE_N		=> open,
		oSRAM_BE_N		=> open,
		oSRAM_WE_N		=> open,
		oSRAM_GW_N  	=> open,
		oSRAM_CLK		=> open,
		oSRAM_ADSC_N	=> open,
		oSRAM_ADSP_N	=> open,
		oSRAM_ADV_N		=> open,
		oSRAM_CE2		=> open,
		oSRAM_CE3_N 	=> open
		--
		-- ReCOP ports
		-- sip			: in std_logic_vector(15 downto 0);
		-- sop			: out std_logic_vector(15 downto 0)
	);
	
	CLK_gen: process
	begin
		wait for 20 ns;
		tb_clk <= not tb_clk;
	end process;
	
	sw			<= "010000000000000000";
	pb			<= "1111";
	rx			<= '0';
	cts		<= '0';
	sram_DQ	<= x"00000000";
	
end architecture;