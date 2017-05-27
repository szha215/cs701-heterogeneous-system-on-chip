library ieee;
use ieee.std_logic_1164.all;

use IEEE.numeric_std.all;

use work.recop_types.all;
use work.various_constants.all;

entity registerfile_mux is
	port (
		-- select signal for input data to be written into Rz
		rf_input_sel: in bit_3;
		-- input data
		ir_operand: in bit_16;
		dm_out: in bit_16;
		aluout: in bit_16;
		rz_max: in bit_16;
		sip_hold: in bit_16;
		er_temp: in bit_1;
		dprr_res : in bit_1;
		
		data_to_reg : out bit_16
		
		);
end registerfile_mux;

architecture beh of registerfile_mux is
	signal data_input_z: bit_16;
begin

	data_to_reg<=data_input_z;
	-- mux selecting input data to be written to Rz
	input_select: process (rf_input_sel, ir_operand, dm_out, aluout, rz_max, sip_hold, er_temp)
    begin
        case rf_input_sel is
            when "000" =>
                data_input_z <= ir_operand;
				when "001" =>
					 data_input_z <= X"000"&"000"&dprr_res;
            when "011" =>
                data_input_z <= aluout;
            when "100" =>
                data_input_z <= rz_max;
            when "101" =>
                data_input_z <= sip_hold;
            when "110" =>
                data_input_z <= X"000"&"000"&er_temp;
            when "111" =>
                data_input_z <= dm_out;
            when others =>
                data_input_z <= X"0000";
        end case;
    end process input_select;


	
end beh;
