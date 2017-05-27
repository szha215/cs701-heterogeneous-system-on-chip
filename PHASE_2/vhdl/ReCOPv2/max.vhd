library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
USE ieee.math_complex.all;
Use ieee.numeric_std.all ;
use work.recop_types.all;
use work.opcodes.all;

-- compare two data and output the bigger one

entity max is
    port
    (
        rz          : in bit_16;
        operand     : in bit_16;
        rz_max      : out bit_16
    );
end max;


architecture behavior of max is

begin

compare: process (operand, rz)
begin
	if(operand>rz) then
		rz_max <= operand;
	else
		rz_max <= rz;
	end if;
end process compare;


end behavior;






































