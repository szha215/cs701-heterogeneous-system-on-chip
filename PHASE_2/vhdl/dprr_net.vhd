library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;

entity dprr_net is
	generic(
		jop_cnt			: integer;
		recop_cnt		: integer
	);
	port(
		clk_recop		: in std_logic;
		clk_noc			: in std_logic;
		clk_jop			: in std_logic;
		reset				: in std_logic;
		dprr_in			: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out			: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_recop_ack : in std_logic_vector(recop_cnt-1 downto 0);
		debug				: out std_logic_vector(15 downto 0)
	);
end dprr_net;
	

architecture beh of dprr_net is

	signal in_fifo_ack			: std_logic_vector(jop_cnt-1 downto 0) := (others => '0');
	signal in_fifo_empty			: std_logic_vector(jop_cnt-1 downto 0) := (others => '1');
	signal out_fifo_empty		: std_logic_vector(recop_cnt-1 downto 0) := (others => '1');
	signal dprr_bus_intern		: std_logic_vector(31 downto 0) := (others => '0');
	signal dprr_in_queued		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal dprr_recop_mux		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal dprr_recop_queued	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal jop_tdm_slot			: integer range 0 to jop_cnt-1 := 0;
	
begin


	-----------------------
	--   DPRR in FIFOs   --
	-----------------------
	gen_dprr_jop_fifo: for i in 0 to jop_cnt-1 generate
		dprr_jop_fifo_inst: entity work.dprr_jop_fifo
		port map(
			aclr		=> reset,
			data		=> dprr_in(i),
			rdclk		=> clk_noc,
			rdreq		=> in_fifo_ack(i),
			wrclk		=> clk_jop,
			wrreq		=> dprr_in(i)(1),
			q			=> dprr_in_queued(i),
			rdempty	=> in_fifo_empty(i)
		);
	end generate;
	
	
	------------------------
	--   DPRR out FIFOs   --
	------------------------
	gen_dprr_recop_fifo: for i in 0 to recop_cnt-1 generate
		dprr_recop_fifo_inst: entity work.dprr_recop_fifo
		port map(
			aclr		=> reset,
			data		=> dprr_recop_mux(i),
			rdclk		=> clk_recop,
			rdreq		=> dprr_recop_ack(i),
			wrclk		=> clk_noc,
			wrreq		=> dprr_recop_mux(i)(1),
			q			=> dprr_recop_queued(i),
			rdempty	=> out_fifo_empty(i)
		);
	end generate;
	
	
	--------------------
	--   Bus Write   ---
	--------------------
	process(clk_noc) 
		
		variable dprr_temp 		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);

	begin
		if reset = '1' then
			jop_tdm_slot <= 0;
			dprr_bus_intern <= (others => '0');
		
		elsif rising_edge(clk_noc) then
		
			for j in 0 to jop_cnt-1 loop
			
				if in_fifo_empty(j) = '1' then
					dprr_temp(j) := (others => '0');
				else
					dprr_temp(j) := dprr_in_queued(j);
				end if;
				
			end loop;
			
			dprr_bus_intern <= dprr_temp(jop_tdm_slot);
			jop_tdm_slot <= jop_tdm_slot + 1;
			
		end if;
		
	end process;

	
	---------------------
	--   ACK in FIFO   --
	---------------------
	process(jop_tdm_slot, in_fifo_empty)
	begin
		for j in 0 to jop_cnt-1 loop
			if j = jop_tdm_slot then
				in_fifo_ack(j) <=  not in_fifo_empty(j);
			else
				in_fifo_ack(j) <= '0';
			end if;
		end loop;
	end process;
	
	
	------------------
	--   Bus Read   --
	------------------
	process(dprr_bus_intern)
	begin
		for j in 0 to recop_cnt-1 loop
			if j = unsigned(dprr_bus_intern(30 downto 28)) then	-- recop address mux
				dprr_recop_mux(j) <= dprr_bus_intern;
			else
				dprr_recop_mux(j) <= (others => '0');
			end if;
		end loop;
	end process;
	
	
	-----------------------------------------
	--   protect ReCOP from empty queues   --
	-----------------------------------------
	process (out_fifo_empty, dprr_recop_queued)
	begin
		for i in 0 to recop_cnt-1 loop
			if out_fifo_empty(i) = '1' then
				dprr_out(i) <= (others => '0');
			else
				dprr_out(i) <= dprr_recop_queued(i);
			end if;
		end loop;
	end process;

	debug <= dprr_bus_intern(15 downto 0);
	
end architecture;
