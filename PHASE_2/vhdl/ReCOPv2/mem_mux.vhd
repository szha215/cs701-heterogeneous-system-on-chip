library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.recop_types.all;
use work.opcodes.all;

-- select the source of address for the data memory

entity mem_mux is
    port (
		-- mux select signal
		mem_addr_sel: in bit_2;
		-- address sources and address output
		Rx: in bit_16;
		Rz: in bit_16;
		ir_operand: in bit_16;
		mem_addr: out bit_16		
		);
end mem_mux;

architecture beh of mem_mux is

  begin
	--MUX selecting addr
	process (mem_addr_sel, Rx, Rz, ir_operand)
	begin
		case mem_addr_sel is
			when "00" =>
				mem_addr <= Rx;
			when "01" =>
				mem_addr <= Rz;
			when "10" =>
				mem_addr <= ir_operand;
			when others =>
				mem_addr <= X"FFFF";
		end case;
	end process;

end beh;
