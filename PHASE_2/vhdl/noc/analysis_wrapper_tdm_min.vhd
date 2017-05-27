library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
USE ieee.math_real.all;

use work.noc_types.all;
use work.jop_config.all;
use work.min_ports_pkg.all;


entity analysis_wrapper_tdm_min is
	generic (
		SIMULATION		: std_logic := '0';
		MULTICLK			: std_logic := '0';
		jop_cnt			: integer := 10;
		recop_cnt		: integer := 4;
		period			: integer := 3;
		buffer_depth	: integer := 1		
	);
	port(
		clk0_in					: in std_logic;
		clk1_in					: in std_logic;
		--fake_input_array		: in std_logic_vector(31 downto 0);
		fake_out_array			: out std_logic_vector(31 downto 0);
		datacall_recop_array	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		--datacall_jop_array	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		datacall_jop_ack		: in std_logic_vector(jop_cnt-1 downto 0);
		--result_jop_array		: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		--result_recop_array	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		result_recop_ack		: in std_logic_vector(recop_cnt-1 downto 0)
		
	);
end analysis_wrapper_tdm_min;



architecture rtl of analysis_wrapper_tdm_min is

	constant number_of_nodes	: integer := jop_cnt + recop_cnt;
	constant	number_of_stages	: integer := integer(ceil(log2(real(number_of_nodes))));
	constant	max_nodes			: integer := integer(2 ** (number_of_stages));

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
	
--	component MultiStageNetwork is
--		generic(
--			number_of_nodes	: integer;
--			buffer_depth		: integer
--		);
--		port(
--			clk			: in std_logic;
--			reset			: in std_logic;
--			in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
--			out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1)
--		);
--	end component;
--	
--	component recop_min_interface is
--		generic(
--			recop_cnt: integer;
--			jop_cnt	: integer;
--			fifo_depth	: integer
--		);
--		port(
--			clk		: in std_logic;
--			reset		: in std_logic;
--			dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--			dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--			dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--			dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
--			dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0)
--		);
--	end component;
--	
--	component jop_min_interface is
--	generic(
--		recop_cnt: integer;
--		jop_cnt	: integer;
--		fifo_depth	: integer
--	);
--	port(
--		clk		: in std_logic;
--		reset		: in std_logic;
--		dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
--		dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
--	);
--	end component;


component reset_counter is
	port(
		clk			: in std_logic;
		reset			: in std_logic;
		reset_int	: out std_logic
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
	
	signal tdm_slot		: std_logic_vector(integer(ceil(log2(real(number_of_nodes))))-1 downto 0);

	
	signal noc_in_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);
	signal noc_out_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);
	

	signal datacall_jop_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal datacall_jop_if_array	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	--signal datacall_recop_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal datacall_recop_if_array: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	--signal datacall_jop_ack			: std_logic_vector(jop_cnt-1 downto 0);
	signal datacall_interf_rdreq	: std_logic_vector(jop_cnt-1 downto 0);
	
	signal result_jop_array			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_jop_if_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_recop_array		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal result_recop_if_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	--signal result_recop_ack			: std_logic_vector(recop_cnt-1 downto 0);
	signal result_interf_rdreq		: std_logic_vector(recop_cnt-1 downto 0);
	
	signal datacall_jop_array_int	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_recop_array_int	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	
	signal produce_ors : NOC_LINK_ARRAY_TYPE(recop_cnt downto 0);
	
	signal ifrd_req			: std_logic_vector(0 to max_nodes-1);
	signal ifrd_addr			: FIFO_ADDR_ARRAY_TYPE(0 to max_nodes-1);
	
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
		in_port	=> noc_in_port,
		out_port	=> noc_out_port
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
			dprr_out	=> result_recop_array_int
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
			dpcr_out	=> datacall_jop_array_int,
			dprr_in	=> datacall_jop_array_int,
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
				noc_in_port(j)					<= datacall_recop_if_array(i);
				ifrd_req(j)						<= result_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				result_recop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
		jop_lookup: for i in 0 to jop_cnt-1 generate
			jop_link: if j = get_jop_mapping(i, number_of_nodes, recop_cnt) generate
				noc_in_port(j)					<= result_jop_if_array(i);
				ifrd_req(j)						<= datacall_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				datacall_jop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
	end generate;
	
	
--	-------------------------------------------------------
--	--  physical wire connections between MIN and cores  --
--	-------------------------------------------------------
--	port_mapping: for j in 0 to max_nodes-1 generate
--		recop_lookup: for i in 0 to recop_cnt-1 generate
--			recop_link: if j = get_recop_mapping(i, number_of_nodes, recop_cnt) generate
--				min_in_port(j)					<= datacall_recop_if_array(i);
--				result_recop_if_array(i)	<= min_out_port(j);
--			end generate;
--		end generate;
--		jop_lookup: for i in 0 to jop_cnt-1 generate
--			jop_link: if j = get_jop_mapping(i, number_of_nodes, recop_cnt) generate
--				min_in_port(j)				<= result_jop_if_array(i);
--				datacall_jop_if_array(i)<= min_out_port(j);
--			end generate;
--		end generate;
--	end generate;
--	
--	-----------------------------------
--	--  Network Interface for ReCOP  --
--	-----------------------------------
--	recop_min_if: recop_min_interface
--		generic map(
--			recop_cnt	=> recop_cnt,
--			jop_cnt		=> jop_cnt,
--			fifo_depth	=> buffer_depth
--		)
--		port map(
--			clk		=> clk_recop,
--			reset		=> int_res,
--			dpcr_in	=> datacall_recop_array,
--			dpcr_out	=> datacall_recop_if_array,
--			dprr_in	=> result_recop_if_array,
--			dprr_ack	=> result_recop_ack,
--			dprr_out	=> result_recop_array_int
--		);
--		
--		
--	--------------------------------
--	--  Network Interface for JOP  --
--	--------------------------------
--	jop_min_if: jop_min_interface
--		generic map(
--			recop_cnt	=> recop_cnt,
--			jop_cnt		=> jop_cnt,
--			fifo_depth	=> buffer_depth
--		)
--		port map(
--			clk		=> clk_jop,					
--			reset		=> int_res,
--			dpcr_in	=> datacall_jop_if_array,
--			dpcr_ack	=> datacall_jop_ack,
--			dpcr_out	=> datacall_jop_array_int,
--			dprr_in	=> datacall_jop_array_int,
--			dprr_out	=> result_jop_if_array
--		);


	
	int_res <= '0';
	
	produce_ors(0) <= (others => '0');
	r_gen : for j in 0 to recop_cnt-1 generate
		produce_ors(j+1) <= produce_ors(j) or result_recop_array_int(j);
	end generate;
	fake_out_array <= produce_ors(recop_cnt);

end architecture;