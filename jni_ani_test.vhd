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
use work.min_ports_pkg.all;    
use work.HMPSoC_config.all;                      

entity jni_ani_test is
end jni_ani_test;
architecture behaviour of jni_ani_test is
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


signal t_asp_valid, t_asp_busy, t_asp_res_ready : std_logic := '0';
signal t_d_from_noc, t_d_to_asp, t_d_from_asp, t_d_to_noc : std_logic_vector(31 downto 0) := (others => '0');

type port_array is array(integer range <>) of std_logic_vector(6 downto 0);
constant recop_cnt 	: integer := 1;
constant jop_cnt		: integer := 3;
constant asp_cnt		: integer := 1;
constant number_of_nodes	: integer := jop_cnt + recop_cnt + asp_cnt;
constant	number_of_stages	: integer := integer(ceil(log2(real(number_of_nodes))));
constant	max_nodes			: integer := integer(2 ** (number_of_stages));

signal ani_port : port_array(asp_cnt-1 downto 0);

	
signal datacall_jop_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
signal datacall_jop_if_array	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
signal result_jop_if_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
signal result_asp_if_array		: NOC_LINK_ARRAY_TYPE(asp_cnt-1 downto 0);
signal datacall_asp_if_array	: NOC_LINK_ARRAY_TYPE(asp_cnt-1 downto 0);  -- AJS
signal min_in_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1) := (others => (others => '0'));
signal min_out_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);


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

-- GROUP 8 ANI
component ani is
	generic(
		constant tdm_port_id		: std_logic_vector(3 downto 0) := "0010";
		constant tdm_slot_width	: positive := 4;
		constant data_width		: positive := 32;
		constant in_depth			: positive := 16;  -- minimum 16
		constant out_depth		: positive := 16;
		constant jop_cnt			: integer := 3;
		constant recop_cnt		: integer := 1;
		constant asp_id			: integer := 0
	);
	port(
		-- control inputs
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot : in std_logic_vector(tdm_slot_width - 1 downto 0);

		-- incoming from NoC to ASP
		d_from_noc	: in std_logic_vector(data_width - 1 downto 0);
		d_to_asp		: out std_logic_vector(data_width - 1 downto 0);
		asp_valid	: out std_logic;

		-- outgoing from ASP to NoC
		asp_busy			: in std_logic;
		asp_res_ready	: in std_logic;
		d_from_asp		: in std_logic_vector(data_width - 1 downto 0);
		d_to_noc			: out std_logic_vector(data_width - 1 downto 0)
	);
end component;





begin


	jni_1 : jop_tdm_min_interface
	generic map(
		recop_cnt => 1,
		jop_cnt	=> 3,
		fifo_depth => 128
		)
	port map (
-- list connections between master ports and signals
	clk => clk,
	dpcr_ack => dpcr_ack,
	dpcr_in => datacall_jop_if_array,
	dpcr_out => dpcr_out,
	dprr_in => dprr_in,
	dprr_out => dprr_out,
	reset => reset,
	tdm_slot => tdm_slot
	);

	--initialize : process
	--begin
	--	reset <= '1', '0' after 10 ns;
	--	wait;
	--end process;

	-----------------------------------------------------------
	--   TDMA Mesh Network for constant transmission times   --
	-----------------------------------------------------------
	noc : TDMA_MINoC
	generic map(
		number_of_nodes	=> max_nodes,
		buffer_depth		=> 4
	)
	port map(
		clk		=> clk,
		reset		=> '0',
		tdm_slot	=> tdm_slot,
		in_port	=> min_in_port,
		out_port	=> min_out_port
	);
	
	---------------------------------
	--  Network Interface for ASP  --
	---------------------------------
	ani_gen: for i in 0 to asp_cnt-1 generate
	ani_1 : ani
		generic map(
			tdm_slot_width	=> number_of_stages,
			data_width		=> 32,
			in_depth			=> 16,
			out_depth		=> 16,
			jop_cnt			=> num_jop,
			recop_cnt 		=> num_recop,
			asp_id			=> 0
		)
		port map(
			clk		=> clk,
			reset		=> reset,
			tdm_slot	=> tdm_slot,

			d_from_noc	=> t_d_from_noc,
			d_to_asp		=> t_d_to_asp,
			asp_valid	=> t_asp_valid,

			asp_busy			=> t_asp_busy,
			asp_res_ready  => t_asp_res_ready,
			d_from_asp		=> t_d_from_asp,
			d_to_noc			=> result_asp_if_array(i)
		);
	end generate;


	--ani_port(0) <=  std_logic_vector(to_unsigned(get_asp_mapping(0, number_of_nodes, 3, 1), 7));

	--min_in_port(0) <= t_d_to_noc;
	--min_out_port(0) <= t_d_from_noc;

	--min_in_port(1) <= dprr_out(0);
	--min_in_port(2) <= dprr_out(1);
	--min_in_port(3) <= dprr_out(2);
	--min_in_port(4) <= t_d_to_noc;

	--dpcr_in(0) <= min_out_port(3);
	--dpcr_in(1) <= min_out_port(2);
	--dpcr_in(2) <= min_out_port(3);
	--t_d_from_noc <= min_out_port(4);


	------------------------------------------------------
	--  physical wire connections between IF and cores  --
	------------------------------------------------------
	port_mapping: for j in 0 to max_nodes-1 generate

		jop_lookup: for i in 0 to jop_cnt-1 generate
			jop_link: if j = get_jop_mapping(i, number_of_nodes, recop_cnt) generate
				min_in_port(j)					<= result_jop_if_array(i);				--TODO: selective reading from TX buffer
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
		asp_look_up: for i in 0 to asp_cnt-1 generate
			asp_link: if j = get_asp_mapping(i, number_of_nodes, jop_cnt, recop_cnt) generate
				min_in_port(j)					<= result_asp_if_array(i);
				datacall_asp_if_array(i)	<= min_out_port(j);
			end generate;
		end generate;
	end generate;
	



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

dprr_test : process
begin
	wait for 2 ns;

	dprr_in(0) <= x"00000000";
	dprr_in(1) <= x"00000000";
	dprr_in(2) <= x"00000000";

	wait for t_clk_period * 5 ;  -- #5

	wait for t_clk_period * 4;   -- #9

	dprr_in(1) <= x"C1000E02";  -- ASP call, MAC, sets expected packets in to be 3
	wait for t_clk_period;
	dprr_in(1) <= x"00000000";


	wait for t_clk_period * 16;

	dprr_in(1) <= x"00000000";
	wait for t_clk_period;

	wait for 9 * t_clk_period;

 wait;
end process; -- dprr_test


dpcr_test : process
begin
	wait for 2 ns;

	dpcr_in(0) <= x"00000000";
	dpcr_in(1) <= x"00000000";
	dpcr_in(2) <= x"00000000";

	wait for t_clk_period * 5;  -- #5

	dpcr_in(0) <= x"00000000";
	dpcr_in(1) <= x"81000AAA";  -- ReCOP call
	dpcr_in(2) <= x"00000000";
	wait for t_clk_period;      -- #6

	dpcr_in(1) <= x"00000000";
	wait for t_clk_period * 3;  -- #9


	dpcr_in(1) <= x"81000BBB";  -- ReCOP call 2, should not be popped to JOP yet
	wait for t_clk_period;      -- #10

	dpcr_in(1) <= x"C104D3F8";  -- MAC 0
	wait for t_clk_period;      -- #11

	dpcr_in(1) <= x"C1050015";  -- MAC 1
	wait for t_clk_period;      -- #12

	dpcr_in(1) <= x"C1060000";  -- MAC 2
	wait for t_clk_period;      -- #13

	dpcr_in(1) <= x"00000000";
	wait for t_clk_period * 10; -- #23



	wait;
end process ; -- dpcr_test


dpcr_ack_test : process
begin
	wait for 2 ns;

	dpcr_ack(0) <= '0';
	dpcr_ack(1) <= '0';
	dpcr_ack(2) <= '0';

	wait for t_clk_period * 6;  -- #8

	dpcr_ack(1) <= '1';
	wait for t_clk_period;      -- #9

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;  -- #12

	dpcr_ack(1) <= '1';
	wait for t_clk_period;      -- #13

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;  -- #16

	dpcr_ack(1) <= '1';
	wait for t_clk_period;      -- #17

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;  -- #20

	dpcr_ack(1) <= '1';
	wait for t_clk_period;      -- #17

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;  -- #20

	dpcr_ack(1) <= '1';
	wait for t_clk_period;

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;



	wait;
end process ; -- dpcr_ack




end architecture;
