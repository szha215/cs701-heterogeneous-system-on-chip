library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.recop_types.all;
use work.various_constants.all;
use work.opcodes.all;

entity controlunit is
	port(
		clk				: in bit_1		:= '0';
		reset				: in bit_1		:= '0';
		-- program memory I/O
		pm_addr			: out bit_16	:= X"0000";
		pm_dataout    	: in bit_16		:= X"0000";
		-- data memory control signals
		dm_addr_sel 	: out bit_2		:= "11";
		dm_wr				: out bit_1		:= '0';
		dm_data_sel		: out bit_2		:= "00";
		-- ALU control signals
		alu_operation	: out bit_3		:= "100";
		alu_op1_sel		: out bit_2		:= "00";
		alu_op2_sel		: out bit_1		:= '0';
		
		ir_operand		: out bit_16	:= X"0000";
		-- register file control signals
		ld_r				: out bit_1		:= '0';
		sel_z				: out bit_4		:= X"0";
		sel_x				: out bit_4		:= X"0";
		rf_input_sel	: out bit_3		:= "000";
		rx					: in bit_16		:= X"0000";
		rz					: in bit_16		:= X"0000";
		-- control signals to flags and register
		dpcr_lsb_sel	: out bit_1		:= '0'; -- select lower byte to be written to dpcr
		dpcr_wr			: out bit_1		:= '0'; -- enable write to dpcr
		z_flag			: in bit_1		:= '0'; 
		clr_z_flag		: out bit_1		:= '0'; -- clear zero flag
		
		er_clr			: out bit_1		:= '0'; -- clear environment ready flag
		eot_wr			: out bit_1		:= '0'; -- set end of thread flag
		eot_clr			: out bit_1		:= '0'; -- clear end of thread flag
		svop_wr			: out bit_1		:= '0'; -- enable write to svop
		sop_wr			: out bit_1		:= '0'; -- enable write to sop
		debug				: in bit_1		:= '0'; -- '1' for debug mode (instruction-by-instruction)
		continue			: in bit_1		:= '0'; -- in debug mode, continue to the next instruction
		dpr_present		: in bit_1		:= '0';
		dpcr_io_wr		: out bit_1		:= '0'
-- synthesis translate_off
		; debugWire : out bit_1 := '0'
-- synthesis translate_on
	);
end controlunit;

architecture combined of controlunit is
	type state_type is (Ini, DB, NE);
	
	signal state				: state_type	:= Ini;
	signal next_state			: state_type	:= Ini;
	signal pc					: bit_16			:= X"0000";
	signal instr_reg_stage0	: bit_32			:= X"34000000";
	signal instr_reg_stage1	: bit_32			:= X"34000000";
begin
	pm_addr <= pc;
	ir_operand <= instr_reg_stage1(15 downto 0);
	sel_x <= instr_reg_stage1(19 downto 16);
	sel_z <= instr_reg_stage1(23 downto 20);
  
	---------------------------------------
	-- pulse distributor
	---------------------------------------
	pulsedistributor: process (clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				state<=Ini;
			else
				state<=next_state;
			end if;
		end if;
	end process pulsedistributor;
	---------------------------------------
	-- operation decoder circuit
	---------------------------------------
	opdec: process(state, pm_dataout, instr_reg_stage1, dpr_present, next_state, debug, continue)
	begin
		case state is
		-- Ini: Initialisation
		when Ini =>
			-- reset control signals
			next_state<=DB;
			alu_operation <= alu_idle;
			alu_op1_sel <= "00";
			alu_op2_sel <= '0';
			ld_r <= '0';
			rf_input_sel <= "000";
			dm_addr_sel <= "11";
			dm_wr <= '0';
			dm_data_sel <= "11";
			dpcr_lsb_sel <= '0';
    		dpcr_wr <= '0';
    		clr_z_flag <= '0';
			er_clr <= '0';
			eot_wr <= '0';
			eot_clr <= '0';
			svop_wr <= '0';
			sop_wr <= '0';
			dpcr_io_wr <= '0';
		-- DB: Block execution for debugging
		when DB => 
			alu_operation <= alu_idle;
			alu_op1_sel <= "00";
			alu_op2_sel <= '0';
			ld_r <= '0';
			rf_input_sel <= "000";
			dm_addr_sel <= "11";
			dm_wr <= '0';
			dm_data_sel <= "11";
			dpcr_lsb_sel <= '0';
    		dpcr_wr <= '0';
    		clr_z_flag <= '0';
			er_clr <= '0';
			eot_wr <= '0';
			eot_clr <= '0';
			svop_wr <= '0';
			sop_wr <= '0';
			dpcr_io_wr <= '0';
			
			-- when in debug mode, wait for the presence of continue signal to execute instruction
			if debug = '1' then
				if continue = '1' then
					next_state<=NE;
				else
					next_state<=DB;
				end if;
			else
				next_state<=NE;
			end if;
			
--			-- wait in this state if a data call is running
--			if dpr_present = '1' then
--				next_state<=T0;
--			else
--				next_state<=DB;
--			end if;
			
		-- execute instruction
		when NE =>
			next_state<=NE;
			dpcr_io_wr <= '0';
			-- decoder to set corresponding control signals for each instruction
			case instr_reg_stage1(29 downto 24) is
			when andr =>
				alu_operation <= alu_and;
				ld_r <= '1'; -- enable write data into Rz
				rf_input_sel <= "011"; --alu result as source data to register file
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose alu operands according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					alu_op1_sel <= "01";
					alu_op2_sel <= '0';	
				when am_register =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '1';	
				when others =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '0';	
				end case;
			when orr =>
				alu_operation <= alu_or;
				ld_r <= '1';
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose alu operands according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					alu_op1_sel <= "01";
					alu_op2_sel <= '0';	
				when am_register =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '1';	
				when others =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '0';	
				end case;
			when addr =>
				alu_operation <= alu_add;
				ld_r <= '1'; -- enable write data into Rz
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose alu operands according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					alu_op1_sel <= "01";
					alu_op2_sel <= '0';	
				when am_register =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '1';	
				when others =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '0';	
				end case;
			when subr =>
				alu_operation <= alu_sub;
				ld_r <= '0'; -- result is not stored
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose alu operands according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					alu_op1_sel <= "01";
					alu_op2_sel <= '0';	
				when am_register =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '1';	
				when others =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '0';	
				end case;
			when subvr =>
				alu_operation <= alu_sub;
				ld_r <= '1'; -- enable write data into Rz
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose alu operands according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					alu_op1_sel <= "01";
					alu_op2_sel <= '0';	
				when am_register =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '1';	
				when others =>
					alu_op1_sel <= "00";
					alu_op2_sel <= '0';	
				end case;
			when lslr =>
				alu_operation <= alu_lsl;
				ld_r <= '1';
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';	
			when lsrr =>
				alu_operation <= alu_lsr;
				ld_r <= '1';
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';	
			when notr =>
				alu_operation <= alu_not;
				ld_r <= '1';
				rf_input_sel <= "011";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';	
			when ldr =>
				alu_operation <= alu_idle;
				ld_r <= '1'; -- enable write data into Rz
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose data memory address source and register file data source according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					dm_addr_sel <= "11";
					rf_input_sel <= "000";
				when am_direct =>
					dm_addr_sel <= "10";
					rf_input_sel <= "111";
				when am_register =>
					dm_addr_sel <= "00";
					rf_input_sel <= "111";
				when others =>
					dm_addr_sel <= "11";
					rf_input_sel <= "000";
				end case;
			when str =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '1';
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose data memory address and data source according to addressing mode
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					dm_addr_sel <= "01";
					dm_data_sel <= "01";
				when am_direct =>
					dm_addr_sel <= "10";
					dm_data_sel <= "00";
				when am_register =>
					dm_addr_sel <= "01";
					dm_data_sel <= "00";
				when others =>
					dm_addr_sel <= "11";
					dm_data_sel <= "11";
				end case;
			when datacall => -- DCALLBL
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose lower byte to be written to dpcr register
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					dpcr_lsb_sel <= '1';
					dpcr_wr <= '1';
				when am_register =>
					dpcr_lsb_sel <= '0';
					dpcr_wr <= '1';
				when others =>
					dpcr_lsb_sel <= '0';
					dpcr_wr <= '0';
				end case;
			when dcallnb =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				-- choose lower byte to be written to dpcr register
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					dpcr_lsb_sel <= '1';
					dpcr_wr <= '1';
				when am_register =>
					dpcr_lsb_sel <= '0';
					dpcr_wr <= '1';
				when others =>
					dpcr_lsb_sel <= '0';
					dpcr_wr <= '0';
				end case;
			when iocall =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
				dpcr_wr <= '0';
				-- choose lower byte to be written to dpcr register
				case instr_reg_stage1(31 downto 30) is
				when am_immediate =>
					dpcr_lsb_sel <= '1';
					dpcr_io_wr <= '1';
				when am_register =>
					dpcr_lsb_sel <= '0';
					dpcr_io_wr <= '1';
				when others =>
					dpcr_lsb_sel <= '0';
					dpcr_io_wr <= '0';
				end case;
			when clfz =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '1';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when cer =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '1';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when ceot =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '1';
				svop_wr <= '0';
				sop_wr <= '0';
			when seot =>
				alu_operation <= alu_idle;
				ld_r <= '0';
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				rf_input_sel <= "000";
				dm_wr <= '0';
				dm_addr_sel <= "11";
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '1';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when ler =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '1';
				rf_input_sel <= "110";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when ssvop =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '0';
				rf_input_sel <= "000";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '1';
				sop_wr <= '0';
			when lsip =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '1';
				rf_input_sel <= "101";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when ssop =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '0';
				rf_input_sel <= "000";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '1';
			when noop =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '0';
				rf_input_sel <= "000";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when max =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '1';
				rf_input_sel <= "100";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when strpc =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '0';
				rf_input_sel <= "000";
				dm_addr_sel <= "10";
				dm_wr <= '1';
				dm_data_sel <= "10";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when sres =>
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '1';
				rf_input_sel <= "001"; --select dprr[0] (res) as data into register
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			when others =>
				-- do nothing
				alu_operation <= alu_idle;
				alu_op1_sel <= "00";
				alu_op2_sel <= '0';
				ld_r <= '0';
				rf_input_sel <= "000";
				dm_addr_sel <= "11";
				dm_wr <= '0';
				dm_data_sel <= "11";
				dpcr_lsb_sel <= '0';
				dpcr_wr <= '0';
				clr_z_flag <= '0';
				er_clr <= '0';
				eot_wr <= '0';
				eot_clr <= '0';
				svop_wr <= '0';
				sop_wr <= '0';
			end case;
				
		when others =>
			-- do nothing
			next_state<=next_state;
			alu_operation <= alu_idle;
			alu_op1_sel <= "00";
			alu_op2_sel <= '0';
			dpcr_io_wr <= '0';
			ld_r <= '0';
			rf_input_sel <= "000";
			dm_addr_sel <= "11";
			dm_wr <= '0';
			dm_data_sel <= "11";
			dpcr_lsb_sel <= '0';
			dpcr_wr <= '0';
			clr_z_flag <= '0';
			er_clr <= '0';
			eot_wr <= '0';
			eot_clr <= '0';
			svop_wr <= '0';
			sop_wr <= '0';
		end case;
	end process opdec;
    
	--program counter and instruction register (rising edge sync)
	process(clk, state)
		variable jmp_taken : bit_1 := '0';
	begin
		jmp_taken := '0';
		if rising_edge(clk) then
			if reset='1' then
				pc <= X"0000";
				instr_reg_stage0 <= X"34000000";
				instr_reg_stage1 <= X"34000000";
			else
-- synthesis translate_off				
				debugWire <= '0';
-- synthesis translate_on
				-- read instruction into register
				instr_reg_stage0(31 downto 16) <= pm_dataout;
				instr_reg_stage1 <= instr_reg_stage0;
				pc <= pc + 1;
				
				
				-- read operand if addressing mode is immediate or direct
				if (instr_reg_stage0(31 downto 30)=am_immediate or
						instr_reg_stage0(31 downto 30)=am_direct) then
					
					instr_reg_stage1(15 downto 0) <= pm_dataout;
					instr_reg_stage0 <= X"34000000";		-- stage 0 tainted with operand, FLUSH it
				end if;
				
				
				-- perform jump/branch instructions accordingly
				case instr_reg_stage1(29 downto 24) is
				when jmp =>
					jmp_taken := '1';
					case instr_reg_stage1(31 downto 30) is
					when am_immediate =>
						pc <= instr_reg_stage1(15 downto 0);
					when am_register =>
						pc <= rx;
					when others =>
					end case;
					instr_reg_stage0 <= X"34000000";
					instr_reg_stage1 <= X"34000000";
					
				when present =>
					if rz = X"0000" then 
						jmp_taken := '1';
						pc <= instr_reg_stage1(15 downto 0);
						instr_reg_stage0 <= X"34000000";
						instr_reg_stage1 <= X"34000000";
					end if;
				when sz =>
					if z_flag = '1' then
						jmp_taken := '1';
						pc <= instr_reg_stage1(15 downto 0);
						instr_reg_stage0 <= X"34000000";
						instr_reg_stage1 <= X"34000000";
					end if;
				when others =>
				end case;
				
				if dpr_present = '1' then
					-- store result to memory
					-- 						am				& inst	& addr	& data	& im_operand
					instr_reg_stage1 <=	am_register	& str		& x"7"	& x"0"	& x"0000";
					
					-- directly after jmp the pipeline is empty and does not need to be stalled
					if jmp_taken = '0' then
						-- stall pipeline while executing inserted str in stage1
						instr_reg_stage0 <= instr_reg_stage0;
						pc <= pc;
					end if; 
				end if;
-- synthesis translate_off				
				debugWire <= jmp_taken;
-- synthesis translate_on
			end if;
		end if;
    end process;
-- synthesis translate_off
	opcode_recop: entity work.recop_instr port map(instr_reg_stage1(29 downto 24));
-- synthesis translate_on

end combined;