library ieee;                                               
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

library work;
use work.noc_types.all;    
use work.min_ports_pkg.all;    
use work.HMPSoC_config.all;                      

---------------------------------------------------------------------------------------------------
entity jni_ani_test is
end jni_ani_test;

---------------------------------------------------------------------------------------------------
architecture behaviour of jni_ani_test is
-- constants                             
constant t_clk_period : time := 20 ns;              

-- signals                                                   
signal clk, reset : std_logic;

signal tdm_slot : std_logic_vector(integer(ceil(log2(real(1+3+1))))-1 downto 0) := (others => '0');

constant recop_cnt 	: integer := 1;
constant jop_cnt		: integer := 3;
constant asp_cnt		: integer := 1;
constant number_of_nodes	: integer := jop_cnt + recop_cnt + asp_cnt;
constant	number_of_stages	: integer := integer(ceil(log2(real(number_of_nodes))));
constant	max_nodes			: integer := integer(2 ** (number_of_stages));


signal dpcr_ack : std_logic_vector(jop_cnt-1 downto 0) := "000";  -- test bench controlled
signal dpcr_in : NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);			-- test bench controlled
signal dpcr_in_recop : NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);			-- test bench controlled
signal dpcr_out : NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);        -- JNI controlled
signal dprr_in : NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);		 	-- test bench controlled
--signal dprr_out : NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);        -- replaced by result_jop_if_array
	
signal datacall_jop_if_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
signal datacall_recop_if_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
signal datacall_asp_if_array	: NOC_LINK_ARRAY_TYPE(asp_cnt-1 downto 0);  -- AJS

signal result_jop_if_array		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
signal result_recop_array		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
signal result_recop_if_array	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
signal result_asp_if_array		: NOC_LINK_ARRAY_TYPE(asp_cnt-1 downto 0);  -- AJS


signal min_in_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);
signal min_out_port		: NOC_LINK_ARRAY_TYPE(0 to max_nodes-1);

---------------------------------------------------------------------------------------------------
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

component recop_tdm_min_interface is
	generic(
		recop_cnt: integer;
		jop_cnt	: integer;
		fifo_depth	: integer;
		asp_cnt	: integer
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		jop_free : in std_logic_vector(num_recop-1 downto 0); 
		dispatched : out std_logic_vector(recop_cnt-1 downto 0);
		dispatched_io : out std_logic_vector(recop_cnt-1 downto 0);
		tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt+asp_cnt))))-1 downto 0);
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0)
	);
end component;



-- GROUP 8 ANI
component asp_ani_combined is
	generic(
		constant tdm_slot_width	: positive := 4;
		constant jop_cnt			: integer := 3;
		constant recop_cnt		: integer := 1;
		constant asp_id			: integer := 0
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot : in std_logic_vector(tdm_slot_width - 1 downto 0);

		d_from_noc	: in std_logic_vector(31 downto 0);
		d_to_noc		: out std_logic_vector(31 downto 0)
	);

end component;

---------------------------------------------------------------------------------------------------
begin		
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
	--  Network Interface for JOP  --
	---------------------------------
	jop_min_if : jop_tdm_min_interface
	generic map(
		recop_cnt => recop_cnt,
		jop_cnt	=> jop_cnt,
		fifo_depth => 8
		)
	port map (
	-- list connections between master ports and signals
		clk => clk,
		dpcr_ack => dpcr_ack,
		dpcr_in => datacall_jop_if_array,
		dpcr_out => dpcr_out,
		dprr_in => dprr_in,
		dprr_out => result_jop_if_array,
		reset => reset,
		tdm_slot => tdm_slot
		);

	-----------------------------------
	--  Network Interface for ReCOP  --
	-----------------------------------
	recop_min_if: recop_tdm_min_interface
		generic map(
			recop_cnt	=> recop_cnt,
			jop_cnt		=> jop_cnt,
			fifo_depth	=> 4,
			asp_cnt		=> asp_cnt  -- AJS
		)
		port map(
			clk		=> clk,
			reset		=> reset,
			jop_free => "0",
			dispatched => open,
			dispatched_io => open,
			tdm_slot	=> tdm_slot,
			dpcr_in	=> dpcr_in_recop,
			dpcr_out	=> datacall_recop_if_array,
			dprr_in	=> result_recop_if_array,
			dprr_ack	=> "0",
			dprr_out	=> result_recop_array
		);

	---------------------------------
	--  Network Interface for ASP  --
	---------------------------------
	ani_gen: for i in 0 to asp_cnt-1 generate
		asp_ani : asp_ani_combined
			generic map(
				tdm_slot_width	=> number_of_stages,
				jop_cnt			=> jop_cnt,
				recop_cnt 		=> recop_cnt,
				asp_id			=> i
			)
			port map(
				clk		=> clk,
				reset		=> reset,
				tdm_slot	=> tdm_slot,

				d_from_noc	=> datacall_asp_if_array(i),
				d_to_noc		=> result_asp_if_array(i)
			);

	end generate;


	------------------------------------------------------
	--  physical wire connections between IF and cores  --
	------------------------------------------------------
	port_mapping: for j in 0 to max_nodes-1 generate
		recop_lookup: for i in 0 to recop_cnt-1 generate
			recop_link: if j = get_recop_mapping(i, number_of_nodes, recop_cnt) generate
				result_recop_if_array(i)	<= min_out_port(j);
				min_in_port(j)					<= datacall_recop_if_array(i);
			end generate;
		end generate;
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
	


---------------------------------------------------------------------------------------------------
t_clk_process : process
begin
	clk <= '1';
	wait for t_clk_period/2;
	clk <= '0';
	wait for t_clk_period/2;
end process;

t_reset : process
begin
	reset <= '1';
	wait for t_clk_period;
	reset <= '0';
	wait for t_clk_period;

	wait;
end process;


t_tdm_slot : process(clk)
   begin
	   if (rising_edge(clk)) then
	   	tdm_slot <= tdm_slot + '1';
	   end if;
   end process ; -- t_tdm_slot

t_dprr : process
begin
	wait for 2 ns;

	dprr_in(0) <= x"00000000";
	dprr_in(1) <= x"00000000";
	dprr_in(2) <= x"00000000";

	wait for t_clk_period * 14 ;  -- #5

	dprr_in(1) <= x"C1000E02";  -- ASP call, MAC, sets expected packets in to be 3
	wait for t_clk_period;
	dprr_in(1) <= x"00000000";


	wait for t_clk_period * 16;

	dprr_in(1) <= x"00000000";
	wait for t_clk_period;

	wait for 9 * t_clk_period;

 wait;
end process; -- t_dprr


t_dprr_ReCOP : process
begin
	wait for 2 ns;

	dpcr_in_recop(0) <= x"00000000";

	wait for t_clk_period * 3;  -- #5

	dpcr_in_recop(0) <= x"81000AAA";  -- ReCOP call JOP
	wait for t_clk_period;      -- #6

	dpcr_in_recop(0) <= x"00000000";
	wait for t_clk_period * 3;  -- #9

	dpcr_in_recop(0) <= x"81000BBB";  -- ReCOP call JOP 2, should not be popped to JOP yet
	wait for t_clk_period;      -- #10

	dpcr_in_recop(0) <= x"00000000";

	wait;

end process ; -- t_dprr_ReCOP


-- JOP DPCR
--t_dpcr : process
--begin
--	wait for 2 ns;

--	dpcr_in(0) <= x"00000000";
--	dpcr_in(1) <= x"00000000";
--	dpcr_in(2) <= x"00000000";

--	wait for t_clk_period * 5;  -- #5

--	dpcr_in(0) <= x"00000000";
--	dpcr_in(1) <= x"81000AAA";  -- ReCOP call
--	dpcr_in(2) <= x"00000000";
--	wait for t_clk_period;      -- #6

--	dpcr_in(1) <= x"00000000";
--	wait for t_clk_period * 3;  -- #9

--	dpcr_in(1) <= x"81000BBB";  -- ReCOP call 2, should not be popped to JOP yet
--	wait for t_clk_period;      -- #10

--	dpcr_in(1) <= x"C104D3F8";  -- MAC 0
--	wait for t_clk_period;      -- #11

--	dpcr_in(1) <= x"C1050015";  -- MAC 1
--	wait for t_clk_period;      -- #12

--	dpcr_in(1) <= x"C1060000";  -- MAC 2
--	wait for t_clk_period;      -- #13

--	dpcr_in(1) <= x"00000000";
--	wait for t_clk_period * 10; -- #23



--	wait;
--end process ; -- t_dpcr


t_dpcr_ack : process
begin
	wait for 2 ns;

	dpcr_ack(0) <= '0';
	dpcr_ack(1) <= '0';
	dpcr_ack(2) <= '0';

	wait for t_clk_period * 12;  -- #6

	dpcr_ack(1) <= '1';
	wait for t_clk_period;      -- #7

	dpcr_ack(1) <= '0';
	wait for t_clk_period * 3;  -- #10

	for i in 0 to 15 loop
		dpcr_ack(1) <= '1';
		wait for t_clk_period;      -- #11

		dpcr_ack(1) <= '0';
		wait for t_clk_period * 3;  -- #14
	end loop;


	wait;
end process ; -- t_dpcr_ack




end architecture;
