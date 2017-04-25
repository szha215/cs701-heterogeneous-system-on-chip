library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--mux bus idea from http://stackoverflow.com/questions/28468334/using-array-of-std-logic-vector-as-a-port-type-with-both-ranges-using-a-generic
--and http://stackoverflow.com/questions/32562488/variable-number-of-inputs-and-outputs-in-vhdl

package mux_pkg is
	type mux_4_bit_arr is array(integer range <>) of std_logic_vector(3 downto 0);
	type mux_16_bit_arr is array(integer range <>) of std_logic_vector(15 downto 0);
end mux_pkg;