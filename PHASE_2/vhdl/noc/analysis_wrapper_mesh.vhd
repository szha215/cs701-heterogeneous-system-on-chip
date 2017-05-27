library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.noc_types.all;
use work.jop_config.all;
use work.mesh_ports_pkg.all;

entity analysis_wrapper_mesh is
	generic (
		SIMULATION		: std_logic := '0';
		MULTICLK			: std_logic := '0';
		jop_cnt			: integer := 3;
		recop_cnt		: integer := 2;
		period			: integer := 5;
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
end analysis_wrapper_mesh;



architecture rtl of analysis_wrapper_mesh is

	constant number_of_nodes	: integer := jop_cnt + recop_cnt;

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

	component MeshNetwork is
		generic(
			number_of_nodes	: integer := 8;
			buffer_depth		: integer := 4;
			WIDTH 				: integer := 32;
			PERIOD_P 			: integer := 5
		);
		port(
			clk_noc		: in std_logic;
			clk_core		: in std_logic;
			reset			: in std_logic;
			in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
			out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
			ifrd_req		: in std_logic_vector(0 to number_of_nodes-1);
			ifrd_addr	: in FIFO_ADDR_ARRAY_TYPE(0 to number_of_nodes-1)
		);
	end component;

	component jop_min_interface is
		generic(
			recop_cnt: integer;
			jop_cnt	: integer;
			fifo_depth	: integer
		);
		port(
			clk		: in std_logic;
			reset		: in std_logic;
			dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
			dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
			dpcr_req	: out std_logic_vector(jop_cnt-1 downto 0)
		);
	end component;
	
	component recop_min_interface is
		generic(
			recop_cnt: integer;
			jop_cnt	: integer;
			fifo_depth	: integer
		);
		port(
			clk		: in std_logic;
			reset		: in std_logic;
			dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
			dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
			dprr_req	: out std_logic_vector(recop_cnt-1 downto 0)
		);
	end component;

--component shared_bus is
--	generic(
--		MULTICLK			: std_logic;
--		jop_cnt			: integer;
--		recop_cnt		: integer
--	);
--	port(
--		clk_recop		: in std_logic;
--		clk_noc			: in std_logic;
--		clk_jop			: in std_logic;
--		reset				: in std_logic;
--		datacall_in		: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--		datacall_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		datacall_jop_ack : in std_logic_vector(jop_cnt-1 downto 0);
--		dprr_in			: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		dprr_out			: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--		dprr_recop_ack : in std_logic_vector(recop_cnt-1 downto 0);
--		debug				: out std_logic_vector(15 downto 0)
--	);
--end component;

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
		
	signal noc_in_port		: NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
	signal noc_out_port		: NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
	signal ifrd_req			: std_logic_vector(0 to number_of_nodes-1);
	signal ifrd_addr			: FIFO_ADDR_ARRAY_TYPE(0 to number_of_nodes-1);
	
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
	
	
--	--------------------
--	--   Shared Bus   --
--	--------------------
--	shared_bus_inst : shared_bus
--	generic map(
--		MULTICLK				=> MULTICLK,
--		jop_cnt				=> jop_cnt,
--		recop_cnt			=> recop_cnt
--	)
--	port map(
--		clk_recop			=> clk_recop,
--		clk_noc				=> clk_noc,
--		clk_jop				=> clk_jop,
--		reset					=> int_res,
--		datacall_in			=> datacall_recop_array,
--		--datacall_out		=> datacall_jop_array,
--		datacall_out		=> datacall_jop_array_int,
--		datacall_jop_ack	=> datacall_jop_ack,
--		--dprr_in			=> result_jop_array,
--		dprr_in				=> datacall_jop_array_int,
--		--dprr_out			=> result_recop_array,
--		dprr_out			=> result_recop_array_int,
--		dprr_recop_ack	=> result_recop_ack,
--		debug					=> open
--	);
	
	
	-----------------------------------------------------------
	--   TDMA Mesh Network for constant transmission times   --
	-----------------------------------------------------------
	noc : MeshNetwork
	generic map(
		number_of_nodes	=> number_of_nodes,
		buffer_depth		=> buffer_depth,
		WIDTH 				=> 32,
		PERIOD_P 			=> period
	)
	port map(
		clk_noc	=> clk_noc,
		clk_core	=> clk_jop,
		reset		=> int_res,
		in_port	=> noc_in_port,
		out_port	=> noc_out_port,
		ifrd_req	=> ifrd_req,
		ifrd_addr=> ifrd_addr
	);


	-----------------------------------
	--  Network Interface for ReCOP  --
	-----------------------------------
	recop_min_if: recop_min_interface
		generic map(
			recop_cnt	=> recop_cnt,
			jop_cnt		=> jop_cnt,
			fifo_depth	=> buffer_depth
		)
		port map(
			clk		=> clk_recop,
			reset		=> int_res,
			dpcr_in	=> datacall_recop_array,
			dpcr_out	=> datacall_recop_if_array,
			dprr_in	=> result_recop_if_array,
			dprr_ack	=> result_recop_ack,
			dprr_out	=> result_recop_array_int,
			dprr_req	=> result_interf_rdreq
		);
		
		
	---------------------------------
	--  Network Interface for JOP  --
	---------------------------------
	jop_min_if: jop_min_interface
		generic map(
			recop_cnt	=> recop_cnt,
			jop_cnt		=> jop_cnt,
			fifo_depth	=> buffer_depth
		)
		port map(
			clk		=> clk_jop,					
			reset		=> int_res,
			dpcr_in	=> datacall_jop_if_array,
			dpcr_ack	=> datacall_jop_ack,
			dpcr_out	=> datacall_jop_array_int,
			dprr_in	=> datacall_jop_array_int,
			dprr_out	=> result_jop_if_array,
			dpcr_req	=> datacall_interf_rdreq
		);
--	datacall_jop_if_array(0) <= datacall_recop_if_array(0);
--	result_recop_if_array(0) <= result_jop_if_array(0);
	
	------------------------------------------------------
	--  physical wire connections between IF and cores  --
	------------------------------------------------------
	port_mapping: for j in 0 to number_of_nodes-1 generate
		recop_lookup: for i in 0 to recop_cnt-1 generate
			recop_link: if j = i generate
				noc_in_port(j)					<= datacall_recop_if_array(i);
				ifrd_req(j)						<= result_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				result_recop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
		jop_lookup: for i in 0 to jop_cnt-1 generate
			jop_link: if j = i+recop_cnt generate
				noc_in_port(j)					<= result_jop_if_array(i);
				ifrd_req(j)						<= datacall_interf_rdreq(i);
				ifrd_addr(j)					<= (others => '0');										--TODO: selective reading from TX buffer
				datacall_jop_if_array(i)	<= noc_out_port(j);
			end generate;
		end generate;
	end generate;
	
	int_res <= '0';
	
	produce_ors(0) <= (others => '0');
	r_gen : for j in 0 to recop_cnt-1 generate
		produce_ors(j+1) <= produce_ors(j) or result_recop_array_int(j);
	end generate;
	fake_out_array <= produce_ors(recop_cnt);

end architecture;