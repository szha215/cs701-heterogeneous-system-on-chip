library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.all;
use work.mux_pkg.all;
---------------------------------------------------------------------------------------------------
entity mux_4_bit is
-- generic and port declration here
generic(
	constant port_num 	 : positive := 4
);
port(	inputs 	: in mux_4_bit_arr(port_num - 1 downto 0);
		sel		: in std_logic_vector(integer(ceil(log2(real(port_num)))) - 1 downto 0);
		
		output	: out std_logic_vector(3 downto 0)
		);
end entity mux_4_bit;
------
architecture behaviour of mux_4_bit is
begin
output <= inputs(to_integer(unsigned(sel)));
end architecture;


---------------------------------------------------------------------------------------------------



--16 bit mux
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.all;
use work.mux_pkg.all;
---------------------------------------------------------------------------------------------------
entity mux_16_bit is
generic(
	constant port_num 	 : positive := 4
);
port(	inputs 	: in mux_16_bit_arr(port_num - 1 downto 0);
		sel		: in std_logic_vector(integer(ceil(log2(real(port_num)))) - 1 downto 0);
		
		output	: out std_logic_vector(15 downto 0)
		);
end entity mux_16_bit;
----
architecture behaviour of mux_16_bit is
begin
output <= inputs(to_integer(unsigned(sel)));
end architecture;