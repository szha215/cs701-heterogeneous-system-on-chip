-- copyright (c) 1991-2013 altera corporation
-- your use of altera corporation's design tools, logic functions 
-- and other software and tools, and its ampp partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the altera program license 
-- subscription agreement, altera megacore function license 
-- agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by altera and sold by 
-- altera or its authorized distributors.  please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- this file contains a vhdl test bench template that is freely editable to   
-- suit user's needs .comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- generated on "05/24/2017 11:24:05"
                                                            
-- vhdl test bench template for design  :  jop_tdm_min_interface
-- 
-- simulation tool : modelsim-altera (vhdl)
-- 

library ieee;                                               
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library work;
use work.noc_types.all;                              

entity jop_tdm_min_interface_vhd_tst is
end jop_tdm_min_interface_vhd_tst;
architecture jop_tdm_min_interface_arch of jop_tdm_min_interface_vhd_tst is
-- constants                             
constant t_clk_period : time := 20 ns;                    
-- signals                                                   
signal clk : std_logic;
signal dpcr_ack : std_logic_vector(2 downto 0) := "000";
signal dpcr_in : NOC_LINK_ARRAY_TYPE(2 downto 0);
signal dpcr_out : NOC_LINK_ARRAY_TYPE(2 downto 0);
signal dprr_in : NOC_LINK_ARRAY_TYPE(2 downto 0);
signal dprr_out : NOC_LINK_ARRAY_TYPE(2 downto 0);

signal reset : std_logic;
signal tdm_slot : std_logic_vector(integer(ceil(log2(real(1+3+1))))-1 downto 0) := (others => '0');
component jop_tdm_min_interface is
	generic(
		recop_cnt: integer := 1;
		jop_cnt	: integer := 3;
		fifo_depth	: integer := 8;
		asp_cnt	: integer := 1
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt+asp_cnt))))-1 downto 0);
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
	);
end component;

begin
	i1 : jop_tdm_min_interface
	generic map(
		recop_cnt => 1,
		jop_cnt	=> 3,
		fifo_depth => 128,
		asp_cnt	=> 1
		)
	port map (
-- list connections between master ports and signals
	clk => clk,
	dpcr_ack => dpcr_ack,
	dpcr_in => dpcr_in,
	dpcr_out => dpcr_out,
	dprr_in => dprr_in,
	dprr_out => dprr_out,
	reset => reset,
	tdm_slot => tdm_slot
	);

	initialize : process
	begin
		reset <= '1', '0' after 10 ns;
		wait;
	end process;

t_clk_process : process
begin
	clk <= '1';
	wait for t_clk_period/2;
	clk <= '0';
	wait for t_clk_period/2;
end process;


identifier : process(clk)
   begin
	   if (rising_edge(clk)) then
	   	tdm_slot <= tdm_slot + '1';
	   end if;
   end process ; -- identifier

process
begin
	wait for 2 ns;
	dpcr_in(0) <= x"00000000";
	dpcr_in(1) <= x"81000AAA";
	dpcr_in(2) <= x"00000000";

	dprr_in(0) <= x"00000000";
	dprr_in(1) <= x"00000000";
	dprr_in(2) <= x"00000000";

	wait for t_clk_period ;

	dpcr_in(1) <= x"00000000";
	dpcr_in(1) <= x"81000BBB";

	wait for t_clk_period;

	dpcr_in(1) <= x"81000CCC";

	wait for t_clk_period;

	dpcr_in(1) <= x"00000000";
	dprr_in(1) <= x"80000551";
wait for t_clk_period * 16;
	dprr_in(1) <= x"00000000";
	dpcr_ack(0) <= '0';
	dpcr_ack(1) <= '1';
	dpcr_ack(2) <= '0';

	wait for t_clk_period;
	dpcr_ack(1) <= '0';

	wait for 9 * t_clk_period;


	dpcr_ack(1) <= '1';
	wait for t_clk_period;
	dpcr_ack(1) <= '0';

 wait;
end process;


	




end jop_tdm_min_interface_arch;
