library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc_GPIO is
generic (addr_bits : integer := 23);

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);
	
-- External interface
	GP_IN		: in std_logic_vector(15 downto 0);
	GP_OUT		: out std_logic_vector(15 downto 0)

);
end sc_GPIO;

architecture rtl of sc_GPIO is
signal outs : std_logic_vector(15 downto 0);

begin

	rdy_cnt <= "00";	-- no wait states
	rd_data(31 downto 16) <= (others => '0');
	GP_OUT <= outs;

process(clk, reset)
begin

	if (reset='1') then
		outs <= (others => '0');
	elsif rising_edge(clk) then

		if address(0) = '0' then
			if rd='1' then
				rd_data(15 downto 0) <= GP_IN;
			end if;
		
			if wr='1' then
				outs <= outs or wr_data(15 downto 0);
			end if;
			
		elsif address(0) = '1' then
			-- for clearing
			if wr='1' then
				outs <= outs and wr_data(15 downto 0);
			end if;
		end if;
		
		
	end if;

end process;

end rtl;
