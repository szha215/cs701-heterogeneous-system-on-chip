library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all; 

entity sc_counter is
generic (idx : unsigned (31 downto 0) := (others => '0'); cpu_id: integer := 0);
port (

	clk : in std_logic;
	reset : in std_logic;
--		address	=> sc_io_out.address(SLAVE_ADDR_BITS-1 downto 0),
	wr_data	: in std_logic_vector(31 downto 0);
	rd			: in std_logic;
	wr			: in std_logic;
	rd_data	: out std_logic_vector(31 downto 0);
	rdy_cnt	: out unsigned(1 downto 0)
	
);
end entity;

architecture beh of sc_counter is
	type STATE_TYPE is (idle, counting);
	signal state : STATE_TYPE := idle;
begin

	rdy_cnt <= "00";	-- no wait states
	
process(clk, reset)
	file  outfile  : text is out "perf"&"_cpu"&integer'image(cpu_id)&"_"&integer'image(to_integer(idx))&".log";
	variable l : line;
	variable counter : unsigned (31 downto 0);
begin
	if reset = '1' then
		counter := (others => '0');
		state <= idle;
	elsif rising_edge(clk) then
		state <= state;
		rd_data <= (others => '0');
		if rd = '1' then
			rd_data <= std_logic_vector(counter);
		end if;
		case state is
			when idle =>
				if wr = '1' and wr_data = std_logic_vector(idx) then
					state <= counting;
					counter := counter + 1;
				end if;
			when counting =>
				if wr = '1' and wr_data = std_logic_vector(idx) then
					write(l, to_integer(counter));
					writeline(outfile, l);
					state <= idle;
					counter := (others => '0');
				else
					counter := counter + 1;
				end if;
		end case;

	end if;
end process;

end architecture;