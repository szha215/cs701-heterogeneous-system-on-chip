library ieee;
use ieee.std_logic_1164.all;

use IEEE.numeric_std.all;

use work.recop_types.all;
use work.various_constants.all;

entity regfile is
	port (
		clk: in bit_1;
		init: in bit_1;
		-- control signal to allow data to write into Rz
		ld_r: in bit_1;
		-- Rz and Rx select signals
		sel_z: in integer range 0 to 15;
		sel_x: in integer range 0 to 15;
		-- register data outputs
		rx : out bit_16;
		rz: out bit_16;
		-- select signal for input data to be written into Rz
		rf_input_sel: in bit_3;
		-- input data
		ir_operand: in bit_16;
		dm_out: in bit_16;
		aluout: in bit_16;
		rz_max: in bit_16;
		sip_hold: in bit_16;
		er_temp: in bit_1;
		-- R7 for writing to lower byte of dpcr
		r7 : out bit_16;
--		dprr_res : in bit_1;
--		dprr_res_reg : in bit_1;
--		dprr_wren : in bit_1
		dprr : in bit_32
		);
end regfile;

architecture beh of regfile is
	type reg_array is array (15 downto 0) of bit_16;
	signal regs: reg_array;
	signal data_input_z: bit_16;
	signal r0_backup: bit_16 := x"0000";
	signal r7_backup: bit_16 := x"0000";
	signal restored: bit_1 := '1';
begin
	r7 <=regs(7);

	-- mux selecting input data to be written to Rz
	input_select: process (rf_input_sel, ir_operand, dm_out, aluout, rz_max, sip_hold, er_temp, dprr)
    begin
        case rf_input_sel is
            when "000" =>
                data_input_z <= ir_operand;
				when "001" =>
					 data_input_z <= X"000"&"000"&dprr(0);
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
	
	process (clk, init)
	begin
		if init = '1' then
			for i in 0 to 15 loop
				regs(i) <= (others => '0');
			end loop;
		elsif rising_edge(clk) then
			-- write data into Rz if ld signal is asserted
--			if ld_r = '1' then
--				regs(sel_z) <= data_input_z;
--			elsif dprr(1) = '1' then
--				regs(0) <= X"000"&"000"&dprr(0);
--			end if;
			if ld_r = '1' then
				regs(sel_z) <= data_input_z;
			end if;
			
			
--			if restored = '0' then
--				regs(0) <= r0_backup;
--				regs(7) <= r7_backup;
--				restored <= '1';
--			end if;
--			if dprr(1) = '1' then
--				r0_backup <= regs(0);
--				r7_backup <= regs(7);
--				restored <= '0';
--				regs(0) <= "00000000000000" & dprr(1 downto 0);		-- result to R0
--				regs(7) <= dprr(17 downto 2);	-- write back address to R7
--			end if;
			
			
			if dprr(31) = '1' then
				if restored = '1' then
					r0_backup <= regs(0);
					r7_backup <= regs(7);
				end if;
				restored <= '0';
				regs(0) <= X"0" & dprr(11 downto 0);		-- result to R0
				regs(7) <= X"0" & dprr(23 downto 12);	-- write back address to R7
			elsif restored = '0' then
				regs(0) <= r0_backup;
				regs(7) <= r7_backup;
				restored <= '1';
			end if;
			
			
		end if;
	end process;
	

	rx <= regs(sel_x);
	rz <= regs(sel_z);


	
end beh;
