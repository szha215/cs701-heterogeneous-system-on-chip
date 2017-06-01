library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

package HMPSoC_config is
	constant num_jop			: integer := 3;
	constant num_recop		: integer := 1;
	constant num_asp			: integer := 1;  -- AJS
	constant USE_AJS_RECOP	: std_logic := '1';  -- AJS
	constant DYNAMIC        : std_logic := '0';
	constant DYNAMIC_FIFO   : std_logic := '0';
	constant TDMA_OPTIMIZED : std_logic := '0';
	constant TDMA_MAX_SLOT  : natural := 4;
	type NOC_PORT_SLOT_ARRAY is array (integer range <>) of natural range 0 to 128;
	constant	pReCOP : NOC_PORT_SLOT_ARRAY(0 to num_recop) 					:= (others=>0); -- (7,2,    others=>0);
	constant	pJOP   : NOC_PORT_SLOT_ARRAY(0 to num_jop)   					:= (others=>0); -- (1,5,0,  others=>0);
	constant	v_slot_counter : NOC_PORT_SLOT_ARRAY(0 to TDMA_MAX_SLOT) 	:= (others=>0); -- (2,3,6,7 others=>0);
end HMPSoC_config;