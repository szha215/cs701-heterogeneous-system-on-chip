library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--mux bus idea from http://stackoverflow.com/questions/28468334/using-array-of-std-logic-vector-as-a-port-type-with-both-ranges-using-a-generic
--and http://stackoverflow.com/questions/32562488/variable-number-of-inputs-and-outputs-in-vhdl

package mux_pkg is
	type mux_4_bit_arr is array(integer range <>) of std_logic_vector(3 downto 0);
	type mux_16_bit_arr is array(integer range <>) of std_logic_vector(15 downto 0);
end mux_pkg;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package recop_opcodes is
	-- instruction opcodes
	constant and_op: std_logic_vector(5 downto 0) := "001000";
	constant or_op: std_logic_vector(5 downto 0) := "001100";
	constant add_op: std_logic_vector(5 downto 0) := "111000";
	constant subv_op: std_logic_vector(5 downto 0) := "000011";
	constant sub_op: std_logic_vector(5 downto 0) := "000100";
	constant ldr_op: std_logic_vector(5 downto 0) := "000000";
	constant str_op: std_logic_vector(5 downto 0) := "000010";
	constant jmp_op: std_logic_vector(5 downto 0) := "011000";
	constant present_op: std_logic_vector(5 downto 0) := "011100";
	constant dcallbl_op: std_logic_vector(5 downto 0) := "101000";
	constant dcallnb_op: std_logic_vector(5 downto 0) := "101001";
	constant sz_op: std_logic_vector(5 downto 0) := "010100";
	constant clfz_op: std_logic_vector(5 downto 0) := "010000";
	constant cer_op: std_logic_vector(5 downto 0) := "111100";
	constant ceot_op: std_logic_vector(5 downto 0) := "111110";
	constant seot_op: std_logic_vector(5 downto 0) := "111111";
	constant ler_op: std_logic_vector(5 downto 0) := "110110";
	constant ssvop_op: std_logic_vector(5 downto 0) := "111011";
	constant lsip_op: std_logic_vector(5 downto 0) := "110111";
	constant ssop_op: std_logic_vector(5 downto 0) := "111010";
	constant noop_op: std_logic_vector(5 downto 0) := "110100";
	constant max_op: std_logic_vector(5 downto 0) := "011110";
	constant strpc_op: std_logic_vector(5 downto 0) := "011101";

	-- address modes
	constant in_am: std_logic_vector(1 downto 0) := "00";
	constant im_am: std_logic_vector(1 downto 0) := "01";
	constant d_am: std_logic_vector(1 downto 0) := "10";
	constant r_am: std_logic_vector(1 downto 0) := "11";

end recop_opcodes;