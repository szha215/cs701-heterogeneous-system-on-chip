--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--
--	Testbench for the tb_multiReCOP
--

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiReCOP is
end;

architecture tb of tb_multiReCOP is

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


component memory is
	generic(add_bits : integer; data_bits : integer);
	port(
		addr	: in std_logic_vector(add_bits-1 downto 0);
		data	: inout std_logic_vector(data_bits-1 downto 0);
		ncs		: in std_logic;
		noe		: in std_logic;
		nwr		: in std_logic
	); 
end component;

	signal LEDr		: std_logic_vector(17 downto 0);
	signal LEDg		: std_logic_vector(8 downto 0);
	signal sw		: std_logic_vector(17 downto 0);
	signal pb		: std_logic_vector(3 downto 0);
	
	signal clk0		: std_logic := '1';
	signal clk1		: std_logic := '1';

--
--	RAM connection. We use address and control lines only
--	from rama.
--
	signal ram_addr	: std_logic_vector(18 downto 0) := (others => '0');
	signal ram_data	: std_logic_vector(31 downto 0);
	signal ram_noe	: std_logic;
	signal ram_ncs	: std_logic;
	signal ram_nwr	: std_logic;

	signal txd		: std_logic;
	signal ser_rxd	: std_logic := '1';
	signal cts		: std_logic;
	signal rts		: std_logic;
	
	signal iSW		: std_logic_vector(17 downto 0);

	-- size of main memory simulation in 32-bit words.
	-- change it to less memory to speedup the simulation
	-- minimum is 64 KB, 14 bits
	constant  MEM_BITS	: integer := 15;

begin

--	joptop: jop port map(
--		clk => clk,
--		ser_rxd => ser_rxd,
--		ser_ncts => '0',
--		ser_txd => txd,
--		fl_rdy => '1',
--		rama_a => ram_addr,
--		rama_d => ram_data(15 downto 0),
--		ramb_d => ram_data(31 downto 16),
--		rama_noe => ram_noe,
--		rama_ncs => ram_ncs,
--		rama_nwe => ram_nwr
--	);

	sw		<= "010000000000000000";
	pb		<= "1111";
	cts		<= '0';
	
	dut : multiReCOP
	port map(
		--
		-- System wide ports
		clk0_in			=> clk0,
		clk1_in			=> clk1,
		oLEDR			=> LEDr,
		oLEDG			=> LEDg,
		oHEX0_D			=> open,
		oHEX0_DP		=> open,
		oHEX1_D			=> open,
		oHEX1_DP		=> open,
		iSW				=> sw,
		iKEY			=> pb,
		ser_txd			=> txd,
		ser_rxd			=> ser_rxd,
		-- 
		-- JOP ports
		oUART_CTS		=> cts,
		iUART_RTS		=> rts,
		wd				=> open,
		oSRAM_A			=> ram_addr,
		SRAM_DQ			=> ram_data,
		oSRAM_CE1_N		=> open,
		oSRAM_OE_N		=> ram_noe,
		oSRAM_BE_N		=> open,
		oSRAM_WE_N		=> ram_nwr,
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

	main_mem: memory
	generic map(MEM_BITS, 32)
	port map(
			addr => ram_addr(MEM_BITS-1 downto 0),
			data => ram_data,
			ncs => ram_ncs,
			noe => ram_noe,
			nwr => ram_nwr
		);
		
--	80 MHz clock
clock0 : process
   begin
   wait for 6.25 ns; clk0  <= not clk0;
end process clock0;
--	60 MHz clock
clock1 : process
   begin
   wait for 8.33 ns; clk1  <= not clk1;
end process clock1;

--
--	print out data from uart
--
process

	variable data : std_logic_vector(8 downto 0);
	variable l : line;

begin
	wait until txd='0';
	wait for 4.34 us;
	for i in 0 to 8 loop
		wait for 8.68 us;
		data(i) := txd;
	end loop;
	write(l, character'val(to_integer(unsigned(data(7 downto 0)))));
	writeline(output, l);

end process;

--
--	simulate download for jvm.asm test
--
process

	variable data : std_logic_vector(10 downto 0);
	variable l : line;

begin

	data := "11010100110";
	wait for 10 us;
	for i in 0 to 9 loop
		wait for 8.68 us;
		ser_rxd <= data(i);
	end loop;

end process;

end tb;

