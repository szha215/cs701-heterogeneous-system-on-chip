Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.sc_pack.all;
use work.jop_config.all;

entity scio_com is

generic(
	cpu_id	: integer range 0 to 7
	);
	
port (
	clk		: in std_logic;
	reset	: in std_logic;

--
--	SimpCon IO interface
--
	sc_rd		: in std_logic;
	sc_rd_data	: out std_logic_vector(31 downto 0);
	
	sc_wr		: in std_logic;
	sc_wr_data	: in std_logic_vector(31 downto 0);
	
	sc_rdy_cnt	: out unsigned(1 downto 0);
	
	DPCR: in std_logic_vector(31 downto 0);
	DPRR: out std_logic_vector(31 downto 0);
	
	dpcr_ack		: out std_logic
	
	);
end scio_com;


architecture beh of scio_com is

	signal DPCR_local	: std_logic_vector(31 downto 0);

begin

	process(CLK,RESET)
	begin
		if RESET = '1' then
			DPCR_local <= (others => '0');
		elsif rising_edge(CLK) then
			DPCR_local <= DPCR;
		end if;
	end process;
	
	process(CLK,RESET)
	begin
		if RESET = '1' then
			sc_rd_data <= (others => '0');
			DPRR <= (others => '0');
		elsif rising_edge(CLK) then
			if sc_rd = '1' then
				sc_rd_data <= DPCR_local;
				dpcr_ack <= '1';
				DPRR <= (others => '0');
			else
				dpcr_ack <= '0';
			end if;
			if sc_wr = '1' then
				DPRR <= sc_wr_data;
			end if;
		end if;
	end process;

end beh;
