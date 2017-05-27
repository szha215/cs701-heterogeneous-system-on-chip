library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;

entity dpcr_bus is
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
		debug				: out std_logic_vector(15 downto 0)
	);
end dpcr_bus;
	

architecture beh of dpcr_bus is

	signal in_fifo_ack			: std_logic_vector(recop_cnt-1 downto 0) := (others => '0');
	signal in_fifo_empty			: std_logic_vector(recop_cnt-1 downto 0) := (others => '1');
	signal out_fifo_empty		: std_logic_vector(jop_cnt-1 downto 0) := (others => '1');
	signal datacall_bus_intern	: std_logic_vector(31 downto 0) := (others => '0');
	signal datacall_in_queued	: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal datacall_jop_mux		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal datacall_jop_queued	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal recop_tdm_slot		: integer range 0 to recop_cnt-1 := 0;
	
begin


	-----------------------
	--   DPCR in FIFOs   --
	-----------------------
	gen_dpcr_recop_fifo: for i in 0 to recop_cnt-1 generate
		gen_dpcr_recop_fifo_dualclock: if MULTICLK = '1' generate
			dpcr_recop_fifo_dualclock_inst: entity work.dpcr_recop_fifo_dualclock
			port map(
				aclr		=> reset,
				data		=> datacall_in(i),
				rdclk		=> clk_noc,
				rdreq		=> in_fifo_ack(i),
				wrclk		=> clk_recop,
				wrreq		=> datacall_in(i)(31),
				q			=> datacall_in_queued(i),
				rdempty	=> in_fifo_empty(i)
			);
		end generate;
		gen_dpcr_recop_fifo_singleclock: if MULTICLK = '0' generate
			dpcr_recop_fifo_singleclock_inst: entity work.dpcr_recop_fifo_singleclock
			port map(
				aclr		=> reset,
				clock		=> clk_noc,
				data		=> datacall_in(i),
				rdreq		=> in_fifo_ack(i),
				wrreq		=> datacall_in(i)(31),
				empty		=> in_fifo_empty(i),
				q			=> datacall_in_queued(i)
			);			
		end generate;
	end generate;
	
	
	------------------------
	--   DPCR out FIFOs   --
	------------------------
	gen_dpcr_jop_fifo: for i in 0 to jop_cnt-1 generate
		gen_dpcr_jop_fifo_dualclock: if MULTICLK = '1' generate
			dpcr_jop_fifo_dualclock_inst: entity work.dpcr_jop_fifo_dualclock
			port map(
				aclr		=> reset,
				data		=> datacall_jop_mux(i),
				rdclk		=> clk_jop,
				rdreq		=> datacall_jop_ack(i),
				wrclk		=> clk_noc,
				wrreq		=> datacall_jop_mux(i)(31),
				q			=> datacall_jop_queued(i),
				rdempty	=> out_fifo_empty(i)
			);
		end generate;
		gen_dpcr_jop_fifo_singleclock: if MULTICLK = '0' generate
			dpcr_jop_fifo_singleclock_inst: entity work.dpcr_jop_fifo_singleclock
			port map(
				aclr		=> reset,
				clock		=> clk_noc,
				data		=> datacall_jop_mux(i),
				rdreq		=> datacall_jop_ack(i),
				wrreq		=> datacall_jop_mux(i)(31),
				empty		=> out_fifo_empty(i),
				q			=> datacall_jop_queued(i)
			);
		end generate;
	end generate;
	
	--------------
	--   TDMA   --
	--------------
	process(clk_noc, reset)
	begin
		if reset = '1' then
			recop_tdm_slot <= 0;
		elsif rising_edge(clk_noc) then
			if recop_tdm_slot = recop_cnt-1 then
				recop_tdm_slot <= 0;
			else
				recop_tdm_slot <= recop_tdm_slot + 1;
			end if;
		end if;
	end process;
	
--	-------------------------------
--	--   registered Bus Write   ---
--	-------------------------------
--	process(clk_noc, reset) 
--		
--		variable dpcr_temp 		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
--
--	begin
--		if reset = '1' then
--			datacall_bus_intern <= (others => '0');
--		
--		elsif rising_edge(clk_noc) then
--			for j in 0 to recop_cnt-1 loop
--				if in_fifo_empty(j) = '1' then
--					dpcr_temp(j) := (others => '0');
--				else
--					dpcr_temp(j) := datacall_in_queued(j);
--				end if;
--			end loop;
--		datacall_bus_intern <= dpcr_temp(recop_tdm_slot);
--		end if;
--		
--	end process;

	
--	-----------------------------------
--	--   registerd Bus ACK in FIFO   --
--	-----------------------------------
--	process(clk_noc)
--	begin
--		for j in 0 to recop_cnt-1 loop
--			if j = recop_tdm_slot then
--				in_fifo_ack(j) <=  datacall_in_queued(j)(31);
--			else
--				in_fifo_ack(j) <= '0';
--			end if;
--		end loop;
--	end process;
	
	
	---------------------------
	--   direct Bus Write   ---
	---------------------------
	process(recop_tdm_slot, datacall_in_queued, in_fifo_empty)
	
		variable dpcr_temp 		: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		
	begin
		for j in 0 to recop_cnt-1 loop
			if in_fifo_empty(j) = '1' then
				dpcr_temp(j) := (others => '0');
			else
				dpcr_temp(j) := datacall_in_queued(j);
			end if;
		end loop;
		datacall_bus_intern <= dpcr_temp(recop_tdm_slot);
		
	end process;
	
	
	--------------------------------
	--   direct Bus ACK in FIFO   --
	--------------------------------
	process(recop_tdm_slot, in_fifo_empty)
	begin
		for j in 0 to recop_cnt-1 loop
			if j = recop_tdm_slot then
				in_fifo_ack(j) <=  not in_fifo_empty(j);
			else
				in_fifo_ack(j) <= '0';
			end if;
		end loop;
	end process;
	
	
	------------------
	--   Bus Read   --
	------------------
	process(datacall_bus_intern)
	begin
		for j in 0 to jop_cnt-1 loop
			if j = unsigned(datacall_bus_intern(30 downto 28)) then	-- jop address mux
				datacall_jop_mux(j) <= datacall_bus_intern;
			else
				datacall_jop_mux(j) <= (others => '0');
			end if;
		end loop;
	end process;
	
	
	---------------------------------------
	--   protect JOP from empty queues   --
	---------------------------------------
	process (out_fifo_empty, datacall_jop_queued)
	begin
		for i in 0 to jop_cnt-1 loop
			if out_fifo_empty(i) = '1' then
				datacall_out(i) <= (others => '0');
			else
				datacall_out(i) <= datacall_jop_queued(i);
			end if;
		end loop;
	end process;

--	debug <= datacall_bus_intern(31 downto 16);
	debug <= datacall_jop_mux(0)(31 downto 16) or
				datacall_jop_mux(1)(31 downto 16) or
				datacall_jop_mux(2)(31 downto 16);
--	debug <= datacall_jop_queued(0)(31 downto 16);
--	debug <= datacall_in(0)(31 downto 16) or
--				datacall_in(1)(31 downto 16);
--	debug <= datacall_in_queued(0)(31 downto 16) or
--				datacall_in_queued(1)(31 downto 16);
--	debug <= (in_fifo_ack(0) or in_fifo_ack(1)) & "000000000000000";
	
end architecture;
	
	
	
	
--architecture beh of dpcr_mux is
--
--begin
--
--	process(clk, reset, datacall_in, dc_ack)
--	
--		variable datacall_buffer	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--	
--	begin
--	
--		if reset = '1' then
--			for i in 0 to jop_cnt-1 loop
--				datacall_buffer(i) := (others => '0');
--			end loop;
--			
--		elsif rising_edge(clk) then
--			for i in 0 to jop_cnt-1 loop
--			
--				datacall_buffer(i) := datacall_buffer(i);	-- hold the datacall
--				
--				if dc_ack(i) = '1' then							-- erase when result is returned
--					datacall_buffer(i) := (others => '0');
--				end if;
--				
--				if datacall_in(31) = '1' then	-- overwrite when valid datacall is present
--					if (i = unsigned(datacall_in(30 downto 28))) then	-- mux to right JOP core
--						datacall_buffer(i) := datacall_in;
--					end if;
--				end if;
--			end loop;
--		end if;
--		
--		datacall_out <= datacall_buffer;
--		
--	end process;
--	
--end architecture;


---- working version for multiJop
--architecture beh of dpcr_mux is
--
--begin
--
--	process(clk, reset, datacall_in, dc_ack)
--	
--		variable datacall_buffer	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--	
--	begin
--	
--		if reset = '1' then
--			for i in 0 to jop_cnt-1 loop
--				datacall_buffer(i) := (others => '0');
--			end loop;
--			
--		elsif rising_edge(clk) then
--			for i in 0 to jop_cnt-1 loop
--			
--				datacall_buffer(i) := datacall_buffer(i);	-- hold the datacall
--				
--				if dc_ack(i) = '1' then							-- erase when result is returned
--					datacall_buffer(i) := (others => '0');
--				end if;
--				
--				if datacall_buffer(i) = x"00000000" then	-- do not overwrite present datacalls
--					if (i = unsigned(datacall_in(30 downto 28))) then	-- mux to right JOP core
--						datacall_buffer(i) := datacall_in;
--					end if;
--				end if;
--			end loop;
--		end if;
--		
--		datacall_out <= datacall_buffer;
--		
--	end process;
--	
--end architecture;

---- remove buffer since we have a fifo now
--architecture beh of dpcr_mux is
--
--begin
--
--	process(datacall_in)
--	begin
--		for i in 0 to jop_cnt-1 loop
--			if (datacall_in(31) = '1' and i = unsigned(datacall_in(30 downto 28))) then	-- mux to right JOP core
--				datacall_out(i) <= datacall_in;
--			else
--				datacall_out(i) <= (others => '0');
--			end if;
--		end loop;
--	end process;
--	
--end architecture;


--architecture beh of dpcr_mux is
--
--begin
--
--	process(clk, reset, datacall_in, dc_ack)
--	
--		variable datacall_buffer	: NOC_LINK_ARRAY_TYPE(0 downto 0);
--	
--	begin
--	
--		if reset = '1' then
--			datacall_buffer(0) := (others => '0');
--
--		elsif rising_edge(clk) then
--			datacall_buffer(0) := datacall_buffer(0);	-- hold the datacall
--			if dc_ack(0) = '1' then							-- erase when result is returned
--				datacall_buffer(0) := (others => '0');
--			end if;
--			if datacall_buffer(0) = x"00000000" then	-- do not overwrite present datacalls
--				datacall_buffer(0) := datacall_in;
--			end if;
--		end if;
--		datacall_out <= datacall_buffer;
--		
--	end process;
--	
--end architecture;



--architecture beh of dpcr_mux is
--
--	signal data_int		: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--	signal q_int			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
--	signal dc_write		: std_logic_vector(jop_cnt-1 downto 0);
--	signal wraddress		: FIFO_ADDR_ARRAY_TYPE(jop_cnt-1 downto 0);
--	signal rdaddress		: FIFO_ADDR_ARRAY_TYPE(jop_cnt-1 downto 0);
--
--begin
--
--	fifo_ram_gen: for i in 0 to jop_cnt-1 generate
--	fifo: entity work.ram256x32
--		port map(
--			clock			=> clk,
--			data			=> data_int(i),
--			rdaddress	=> rdaddress(i),
--			rden			=> '1',
--			wraddress	=> wraddress(i),
--			wren			=> dc_write(i),
--			q				=> q_int(i)
--		);
--	end generate;
--
--
----	gen_dpcr_fifo: for i in 0 to jop_cnt-1 generate
----	fifo: entity work.dpcr_fifo
----		port map(
----			clock		=> clk,
----			data		=> datacall_int(i),
----			rdreq		=> dc_ack(i),
----			sclr		=> reset,
----			wrreq		=> dc_write(i),
----			empty		=> open,
----			q			=> datacall_out(i)
----		);
----	end generate;
--
--	process(clk)
--	begin
--		if rising_edge(clk) then
--			for i in 0 to jop_cnt-1 loop
--			
--				if datacall_in(31) = '1' then			
--					if (i = unsigned(datacall_in(30 downto 28))) then	-- mux to right JOP core
--						data_int(i) <= datacall_in;
--						wraddress(i) <= std_logic_vector(unsigned(wraddress(i))+"1");
--						dc_write(i) <= '1';
--					else
--						dc_write(i) <= '0';
--					end if;
--				end if;
--				
--				if dc_ack(i) = '1' then
--					rdaddress(i) <= std_logic_vector(unsigned(rdaddress(i))+"1");	
--				end if;
--				
--			end loop;
--		end if;
--	end process;
--	
--	process(wraddress, rdaddress)
--	begin
--		for i in 0 to jop_cnt-1 loop
--			if wraddress(i) = rdaddress(i) then
--				datacall_out(i) <= (others => '0');
--			else
--				datacall_out(i) <= q_int(i);
--			end if;
--		end loop;
--	end process;
--end architecture;