library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;


entity dprr_mux is
	generic(
		jop_cnt			: integer
	);
	port(
		debug				: out std_logic_vector(15 downto 0) := x"0000";
		clk_read			: in std_logic;
		clk_write		: in std_logic;
		reset				: in std_logic;
		dprr_in_array	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out			: out std_logic_vector(31 downto 0) := (others => '0');
		dprr_ack			: in std_logic
	);
end dprr_mux;

architecture beh of dprr_mux is

	signal dprr_int	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal fifo_empty	: std_logic_vector(jop_cnt-1 downto 0) := (others => '1');
	signal fifo_ack	: std_logic_vector(jop_cnt-1 downto 0);
	
begin

	--------------------
	--   DPRR FIFOs   --
	--------------------
	gen_dprr_fifo: for i in 0 to jop_cnt-1 generate
		fifo: entity work.dprr_fifo
		port map(
			aclr		=> reset,
			data		=> dprr_in_array(i),
			rdclk		=> clk_read,
			rdreq		=> fifo_ack(i),
			wrclk		=> clk_write,
			wrreq		=> dprr_in_array(i)(1),
			q			=> dprr_int(i),
			rdempty	=> fifo_empty(i)
		);
	end generate;
	
	--debug(jop_cnt-1 downto 0) <= fifo_empty;
	
	process(clk_read)
		
		variable tdm_slot : integer range 0 to jop_cnt-1 := 0;
		variable dprr_buffer : NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	
	begin
		if reset = '1' then
			dprr_out <= (others => '0');
			fifo_ack <= (others => '0');
			tdm_slot := 0;
			
		elsif rising_edge(clk_read) then
			for j in 0 to jop_cnt-1 loop
				if fifo_empty(j) /= '1' then
					dprr_buffer(j) := dprr_int(j);
				else
					dprr_buffer(j) := (others => '0');
				end if;
			end loop;
			
			dprr_out <= dprr_buffer(tdm_slot);
			fifo_ack(tdm_slot) <= dprr_buffer(tdm_slot)(1);
			
			tdm_slot := tdm_slot + 1;
		end if;
		
--	begin
--		if reset = '1' then
--			dprr_out <= (others => '0');
--			fifo_ack <= (others => '0');
--			dprr_out <= (others => '0');
--			tdm_slot := 0;
--			
--		elsif rising_edge(clk_read) then
--			dprr_out <= (others => '0');
--			case tdm_slot is
--				when 0 =>
--					if fifo_empty(0) /= '1' then
--						dprr_out <= dprr_int(0);
--					end if;
--				when 1 =>
--					if fifo_empty(1) /= '1' then
--						dprr_out <= dprr_int(1);
--					end if;
--				when others =>
--			end case;
--			
--			tdm_slot := tdm_slot + 1;
--			if tdm_slot >= jop_cnt then
--				tdm_slot := 0;
--			end if;
--		end if;
		
--		if reset = '1' then
--			dprr_out <= (others => '0');
--			fifo_ack <= (others => '0');
--			dprr_out <= (others => '0');
--			tdm_slot := 0;
--			
--		elsif rising_edge(clk_read) then
--			dprr_out <= (others => '0');
--			for j in 0 to jop_cnt-1 loop
--				if tdm_slot = j and fifo_empty(j) /= '1' then
--					dprr_out <= dprr_int(j);
--					fifo_ack(j) <= '1';
--				else
--					fifo_ack(j) <= '0';
--				end if;
--			end loop;
--			tdm_slot := tdm_slot + 1;
--		end if;
		
		
		
--		if reset = '1' then
--			dprr_out <= (others => '0');
--			fifo_ack <= (others => '0');
--			dprr_out <= (others => '0');
--			tdm_slot := 0;
--			
--		elsif rising_edge(clk_read) then
--		
--			fifo_ack <= (others => '0');
--			dprr_out <= (others => '0');
--			
--			if fifo_empty(tdm_slot) = '0' then
--				dprr_out <= dprr_int(tdm_slot);
--				fifo_ack(tdm_slot) <= '1';
--			end if;
--		
--			tdm_slot := tdm_slot + 1;
--		end if;
		
	end process;
	
end architecture;