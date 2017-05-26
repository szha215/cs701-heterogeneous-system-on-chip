library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity min_switch is
	generic(
		number_of_stages	: integer range 1 to 8 := 3;
		stage					: integer range 1 to 8 := 1
	);
	port(
		tdm_slot		: in std_logic_vector(number_of_stages-1 downto 0);
		in_portA		: in std_logic_vector(31 downto 0);
		in_portB		: in std_logic_vector(31 downto 0);
		out_portA	: out std_logic_vector(31 downto 0);
		out_portB	: out std_logic_vector(31 downto 0)
	);
end min_switch;


architecture behaviour of min_switch is
begin
	
	out_PortA	<= in_PortA	when tdm_slot(number_of_stages - stage) = '0' else 
						in_PortB;
	out_PortB	<= in_PortB	when tdm_slot(number_of_stages - stage) = '0' else 
						in_PortA;

end architecture;