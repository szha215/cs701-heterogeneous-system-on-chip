library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.noc_types.all;
use work.jop_config.all;

entity analysis_wrapper_shared_bus is
	generic (
		SIMULATION		: std_logic := '0';
		MULTICLK			: std_logic := '0';
		jop_cnt			: integer := 20;
		recop_cnt		: integer := 5
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
end analysis_wrapper_shared_bus;



architecture rtl of analysis_wrapper_shared_bus is

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

component shared_bus is
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
		dprr_in			: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out			: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_recop_ack : in std_logic_vector(recop_cnt-1 downto 0);
		debug				: out std_logic_vector(15 downto 0)
	);
end component;

component reset_counter is
	port(
		clk			: in std_logic;
		reset			: in std_logic;
		reset_int	: out std_logic
	);
end component;



--component dpcr_bus is
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
--		debug				: out std_logic_vector(15 downto 0)
--	);
--end component;
--
--component dprr_bus is
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
--		dprr_in			: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--		dprr_out			: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--		dprr_recop_ack : in std_logic_vector(recop_cnt-1 downto 0);
--		debug				: out std_logic_vector(15 downto 0)
--	);
--end component;


	signal clk_jop			: std_logic;								-- drive jop
	signal clk_jop_inv	: std_logic;								-- clk_jop shifted by 180deg
	signal clk_recop		: std_logic;								-- drive ReCOP
	signal clk_noc			: std_logic;								-- drive interconnects
	signal clk_system		: std_logic;								-- system wide clock if single clock design
	signal clk_system_inv: std_logic;								-- clk_system shifted by 180deg
	
	signal reset			: std_logic;
	signal int_res			: std_logic;
	
--	signal datacall_recop_array: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--	signal result_jop_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);

	signal datacall_jop_array_int	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal result_recop_array_int	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--	signal produce_ors : NOC_LINK_ARRAY_TYPE(recop_cnt+jop_cnt downto 0);
	signal produce_ors : NOC_LINK_ARRAY_TYPE(recop_cnt downto 0);
	
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
	
	
	--------------------
	--   Shared Bus   --
	--------------------
	shared_bus_inst : shared_bus
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
		--datacall_out		=> datacall_jop_array,
		datacall_out		=> datacall_jop_array_int,
		datacall_jop_ack	=> datacall_jop_ack,
		--dprr_in			=> result_jop_array,
		dprr_in				=> datacall_jop_array_int,
		--dprr_out			=> result_recop_array,
		dprr_out			=> result_recop_array_int,
		dprr_recop_ack	=> result_recop_ack,
		debug					=> open
	);

-- -- fake inputs	
--	dc_gen : for j in 0 to recop_cnt-1 generate
--		datacall_recop_array(j) <= fake_input_array;
--	end generate;
--	r_gen : for j in 0 to jop_cnt-1 generate
--		result_jop_array(j) <= fake_input_array;
--	end generate;

-- -- ored outputs

	produce_ors(0) <= (others => '0');
--	dc_gen : for j in 0 to jop_cnt-1 generate
--		produce_ors(j+1) <= produce_ors(j) or datacall_jop_array_int(j);
--	end generate;
--	r_gen : for j in jop_cnt to jop_cnt+recop_cnt-1 generate
--		produce_ors(j+1) <= produce_ors(j) or result_recop_array_int(j-jop_cnt);
--	end generate;
--	fake_out_array <= produce_ors(jop_cnt+recop_cnt);
	
	r_gen : for j in 0 to recop_cnt-1 generate
		produce_ors(j+1) <= produce_ors(j) or result_recop_array_int(j);
	end generate;
	fake_out_array <= produce_ors(recop_cnt);
	

--	------------------
--	--   DPCR Bus   --
--	------------------
--	dpcr_bus_inst : dpcr_bus
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
--		datacall_out		=> datacall_jop_array,
--		datacall_jop_ack	=> datacall_jop_ack,
--		debug					=> componentDebugI
--	);
--	
--	
--	------------------
--	--   DPRR Bus   --
--	------------------
--	dprr_bus_inst : dprr_bus
--	generic map(
--		MULTICLK			=> MULTICLK,
--		jop_cnt			=> jop_cnt,
--		recop_cnt		=> recop_cnt
--	)
--	port map(
--		clk_recop		=> clk_recop,
--		clk_noc			=> clk_noc,
--		clk_jop			=> clk_jop,
--		reset				=> int_res,
--		dprr_in			=> result_jop_array,
--		dprr_out			=> result_recop_array,
--		dprr_recop_ack	=> result_recop_ack,
--		debug				=> componentDebugII
--	);



--	-------------------------
--	---   Reset Counter   ---
--	-------------------------
--	rescnt_inst : reset_counter
--	port map(
--		clk			=> clk_noc,
--		reset			=> reset,
--		reset_int	=> int_res
--	);
	int_res <= '0';

end architecture;