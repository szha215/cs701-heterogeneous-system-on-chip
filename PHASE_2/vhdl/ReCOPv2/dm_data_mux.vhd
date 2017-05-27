library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.recop_types.all;
use work.opcodes.all;

-- selects the data source going to the data memory

entity dm_data_mux is
    port (
		-- mux selection signal
		dm_data_sel: in bit_2 := "00";
		-- data sources & output
		Rx: in bit_16 := X"0000";
		ir_operand: in bit_16 := X"0000";
		dm_data: out bit_16;
		pc : in bit_16
		);
end dm_data_mux;

architecture beh of dm_data_mux is
  begin
	--MUX selecting data
	process (dm_data_sel, Rx, ir_operand, pc)
	begin
		case dm_data_sel is
			when "00" =>
				dm_data <= Rx;
			when "01" =>
				dm_data <= ir_operand;
			when "10" =>
				dm_data <= pc;
			when others =>
				dm_data <= X"0000";
		end case;
	end process;

end beh;
