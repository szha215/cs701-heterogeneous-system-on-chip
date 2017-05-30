library ieee;
use ieee.std_logic_1164.all;

use work.jop_config_global.all;

package noc_types is

	type NOC_LINK_ARRAY_TYPE is array (integer range <>) of std_logic_vector(31 downto 0);
	type BIT16_SIGNAL_ARRAY_TYPE is array (integer range <>) of std_logic_vector(15 downto 0);
	type FIFO_ADDR_ARRAY_TYPE is array (integer range <>) of std_logic_vector(7 downto 0);

end noc_types;