library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;

entity dpcr_mux is
	generic(
		jop_cnt			: integer
	);
	port(
		datacall_in		: in std_logic_vector(31 downto 0);
		datacall_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
	);
end dpcr_mux;
	
	
	
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

-- remove buffer since we have a fifo now
architecture beh of dpcr_mux is

begin

	process(datacall_in)
	begin
		for i in 0 to jop_cnt-1 loop
			if (datacall_in(31) = '1' and i = unsigned(datacall_in(30 downto 28))) then	-- mux to right JOP core
				datacall_out(i) <= datacall_in;
			else
				datacall_out(i) <= (others => '0');
			end if;
		end loop;
	end process;
	
end architecture;


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