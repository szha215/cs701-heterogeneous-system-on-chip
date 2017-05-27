library IEEE;
use IEEE.STD_LOGIC_1164.all;

package dpcr_intercon_pkg is

	type dpcr_intercon_array is array (0 to 2) of std_logic_vector(31 downto 0);
	type dpcr_mux_array is array (0 to 1) of std_logic_vector(31 downto 0);
	type dprr_intercon_array is array (0 to 2) of std_logic_vector(31 downto 0);
	type dprr_mux_array is array (0 to 1) of std_logic_vector(31 downto 0);
	
end package;