----
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
--	jop_512x32.vhd
--
--	top level for a 512x32 SSRAM board (e.g. Altera DE2-70 board)
--
--	2009-03-31	adapted from jop_256x16.vhd
--  2010-06-25  Working version with SSRAM
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;
use work.sc_arbiter_pack.all;
use work.jop_config.all;
use work.noc_types.all;



entity jop_cmp is

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
	
--
--	LEDs
--
	oLEDR		: out std_logic_vector(9 downto 0);

	
--
--	Switches
--
	iSW				: in std_logic_vector(9 downto 0);

--
-- Seven Segment Displays
--
   oHEX0      : out std_logic_vector(6 downto 0);
   oHEX1      : out std_logic_vector(6 downto 0);
   oHEX2      : out std_logic_vector(6 downto 0);
   oHEX3      : out std_logic_vector(6 downto 0);
   oHEX4      : out std_logic_vector(6 downto 0);
   oHEX5      : out std_logic_vector(6 downto 0);
	
--
--	serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
	oUART_CTS		: in std_logic;
	iUART_RTS		: out std_logic;
	
--
-- GPIO
--
   GP_IN : in std_logic_vector(15 downto 0);
   GP_OUT : out std_logic_vector(15 downto 0); -- for mechatronics
		
--
--	watchdog
--
	wd				: out std_logic;

--
-- recop interfacing
--
	DATACALL_ARRAY	: in NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
	dc_ack			: out std_logic_vector(cpu_cnt-1 downto 0);
	RESULT_ARRAY	: out NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
	
	
	debug			 : out std_logic_vector(15 downto 0)
);
end jop_cmp;

architecture rtl of jop_cmp is

--
--	components:
--

--
--	Signals
--
	signal clk_int			: std_logic;
	signal clk_int_inv		: std_logic;
	signal pll_lock			: std_logic;

	signal int_res			: std_logic;


--
--	jopcpu connections
--
--	signal sc_mem_out		: sc_out_type;
--	signal sc_mem_in		: sc_in_type;
--	signal sc_io_out		: sc_out_type;
--	signal sc_io_in		: sc_in_type;
--	signal irq_in			: irq_bcf_type;
--	signal irq_out			: irq_ack_type;
--	signal exc_req			: exception_type;
	signal sc_arb_out		: arb_out_type(0 to cpu_cnt-1);
	signal sc_arb_in		: arb_in_type(0 to cpu_cnt-1);
	signal sc_mem_out		: sc_out_array_type(0 to cpu_cnt-1);
	signal sc_mem_in		: sc_in_array_type(0 to cpu_cnt-1);
	signal sc_sm_out		: sc_out_type;
	signal sc_sm_in		  : sc_in_type;
	signal sc_io_out		: sc_out_array_type(0 to cpu_cnt-1);
	signal sc_io_in		  : sc_in_array_type(0 to cpu_cnt-1);
	signal sc_io_out_int	: sc_out_type;
	signal sc_io_in_int		: sc_in_type;
	signal irq_in			: irq_in_array_type(0 to cpu_cnt-1);
	signal irq_out			: irq_out_array_type(0 to cpu_cnt-1);
	signal exc_req			: exception_array_type(0 to cpu_cnt-1);

	
--
--	IO interface
--
	signal ser_in			: ser_in_type;
	signal ser_out			: ser_out_type;
	type wd_out_array is array (0 to cpu_cnt-1) of std_logic;
	signal wd_out			: wd_out_array;
	
	-- cmpsync
	signal sync_in_array	: sync_in_array_type(0 to cpu_cnt-1);
	signal sync_out_array	: sync_out_array_type(0 to cpu_cnt-1);

-- not available at this board:
	signal ser_ncts			: std_logic;
	signal ser_nrts			: std_logic;
	
-- remove the comment for RAM access counting
-- signal ram_count		: std_logic;


--	recop testing
--	signal DATACALL	: std_logic_vector(31 downto 0);
--	signal RESULT		: std_logic_vector(31 downto 0);

--	signal DATACALL_ARRAY_fifo	: NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
--	signal DATACALL_ARRAY_int	: NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);
	signal dc_ack_int				: std_logic_vector(cpu_cnt-1 downto 0);
	signal dpcr_empty				: std_logic_vector(cpu_cnt-1 downto 0);
--	signal RESULT_ARRAY_int		: NOC_LINK_ARRAY_TYPE(cpu_cnt-1 downto 0);

	constant SIM : std_logic := '0'
-- synthesis translate_off
		or '1'
-- synthesis translate_on
	;
begin

	--ser_ncts <= '0';
--
--	intern reset
	int_res <= reset;

	debug <= DATACALL_ARRAY(0)(31 downto 16);
--				DATACALL_ARRAY_int(1)(31 downto 16) or
--				DATACALL_ARRAY_int(2)(31 downto 16) or
--				DATACALL_ARRAY_int(3)(31 downto 16) or
--				DATACALL_ARRAY_int(4)(31 downto 16) or
--				DATACALL_ARRAY_int(5)(31 downto 16);
	
	
--
--	components of jop
--


	------------------------
	--   CLOCK MAPPINGS   --
	------------------------
	clk_int		<= clk_in;
	clk_int_inv	<= clk_in_inv;
	
	wd <= wd_out(0);

--	cpu: entity work.jopcpu
--		generic map(
--			jpc_width => jpc_width,
--			block_bits => block_bits,
--			spm_width => spm_width
--		)
--		port map(clk_int, int_res,
--			sc_mem_out, sc_mem_in,
--			sc_io_out, sc_io_in,
--			irq_in, irq_out, exc_req,
--			DATACALL => DATACALL,
--			RESULT => RESULT
--		);

	gen_cpu: for i in 0 to cpu_cnt-1 generate
		cpu: entity work.jopcpu_extsc
			generic map(
				jpc_width => jpc_width,
				block_bits => block_bits,
				spm_width => spm_width
			)
			port map(clk_int, int_res,
				sc_mem_out(i), sc_mem_in(i),
				sc_io_out(i), sc_io_in(i),
				irq_in(i), irq_out(i), exc_req(i),
				DATACALL => DATACALL_ARRAY(i),
				dc_ack => dc_ack_int(i),
				RESULT => RESULT_ARRAY(i),

				sc_scratch_out => sc_arb_out(i),
				sc_scratch_in => sc_arb_in(i)
			);
	end generate;
	
	dc_ack <= dc_ack_int;

	arbiter: entity work.arbiter
		generic map(
			addr_bits => SC_ADDR_SIZE,
			cpu_cnt => cpu_cnt,
			write_gap => 2,
			read_gap => 2,
			slot_length => 3			
		)
		port map(clk_int, int_res,
			sc_arb_out, sc_arb_in,
			sc_sm_out, sc_sm_in
		);

	-- Shared memory for signals and channels
	shared_memory: entity work.sc_mem_int
	generic map(
		 element_size => 32,
		 memory_depth => 8
	 )
	port map (clk_int, int_res, sc_sm_out, sc_sm_in);

	sc_scio_sim:
	if SIM = '1' generate 
		-- This is just to ease the simulation by allowing all cpus to print on the console
		gen_io_sim: for i in 0 to cpu_cnt-1 generate
			io: entity work.scio generic map (
					cpu_id => 0,
					cpu_cnt => cpu_cnt
			)
			port map (clk_int, int_res,
			sc_io_out(i), sc_io_in(i),
			irq_in(i), irq_out(i), exc_req(i),

			sync_out => sync_out_array(i),
			sync_in => sync_in_array(i),

			txd => ser_txd,
			rxd => ser_rxd,
			ncts => oUART_CTS,
			nrts => iUART_RTS,

			oLEDR => oLEDR,
			iSW => iSW,

			oHEX0 => oHEX0,
			oHEX1 => oHEX1,
			oHEX2 => oHEX2,
			oHEX3 => oHEX3,
			oHEX4 => oHEX4,
			oHEX5 => oHEX5,

			GP_IN => GP_IN,
			GP_OUT => GP_OUT,

			wd => wd_out(i),
			l => open,
			r => open,
			t => open,
			b => open
		);
		end generate;
	end generate;
	
	sc_scio:
	if SIM = '0' generate 
		-- io for processor 0
		io: entity work.scio generic map (
				cpu_id => 0,
				cpu_cnt => cpu_cnt
			)
			port map (clk_int, int_res,
				sc_io_out(0), sc_io_in(0),
				irq_in(0), irq_out(0), exc_req(0),

				sync_out => sync_out_array(0),
				sync_in => sync_in_array(0),

				txd => ser_txd,
				rxd => ser_rxd,
				ncts => oUART_CTS,
				nrts => iUART_RTS,
				
				oLEDR => oLEDR,
				iSW => iSW,
				
				oHEX0 => oHEX0,
				oHEX1 => oHEX1,
				oHEX2 => oHEX2,
				oHEX3 => oHEX3,
				oHEX4 => oHEX4,
				oHEX5 => oHEX5,
				
				GP_IN => GP_IN,
				GP_OUT => GP_OUT,
							
				wd => wd_out(0),
				l => open,
				r => open,
				t => open,
				b => open
				-- remove the comment for RAM access counting
				-- ram_cnt => ram_count
			);
		-- io for processors with only sc_sys
		gen_io: for i in 1 to cpu_cnt-1 generate
			io2: entity work.sc_sys generic map (
				addr_bits => 4,
				clk_freq => clk_freq,
				cpu_id => 0,
				cpu_cnt => cpu_cnt
			)
			port map(
				clk => clk_int,
				reset => int_res,
				address => sc_io_out(i).address(3 downto 0),
				wr_data => sc_io_out(i).wr_data,
				rd => sc_io_out(i).rd,
				wr => sc_io_out(i).wr,
				rd_data => sc_io_in(i).rd_data,
				rdy_cnt => sc_io_in(i).rdy_cnt,
				
				irq_in => irq_in(i),
				irq_out => irq_out(i),
				exc_req => exc_req(i),
				
				sync_out => sync_out_array(i),
				sync_in => sync_in_array(i),
				wd => wd_out(i)
				-- remove the comment for RAM access counting
				-- ram_count => ram_count
			);
		end generate;
	end generate;

	
	-- syncronization of processors
	sync: entity work.cmpsync generic map (
		cpu_cnt => cpu_cnt)
		port map
		(
			clk => clk_int,
			reset => int_res,
			sync_in_array => sync_in_array,
			sync_out_array => sync_out_array
		);
		
--	DATACALL <= x"0000" & iSW(15 downto 0);
--	oLEDR(15 downto 0) <= RESULT(15 downto 0);

	
	-- remove the comment for RAM access counting
	-- ram_count <= ram_ncs;
	gen_memory: for i in 0 to cpu_cnt-1 generate
		 scm : entity work.sc_mem_int
		  generic map(
				element_size => 32,
				memory_depth => 16,
				main_mem => true,
				jop_id => i
				)
		  port map(

				clk   => clk_int,
				reset => int_res,

				--  SimpCon memory interface
				sc_mem_out => sc_mem_out(i),
				sc_mem_in  => sc_mem_in(i)
				);
	end generate;

end rtl;
