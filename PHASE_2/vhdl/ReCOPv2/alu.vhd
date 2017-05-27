library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;

use work.recop_types.all;
use work.opcodes.all;
use work.various_constants.all;


entity alu is
	port (
		clk				: in bit_1;
		z_flag			: out bit_1;
		z_flag_hack		: out bit_1;
		-- ALU operation selection
		alu_operation	: in bit_3;
		-- operand selection
		alu_op1_sel		: in bit_2;
		alu_op2_sel		: in bit_1;
		-- alu_carry		: in bit_1;  --WARNING: carry in currently is not used
		alu_result		: out bit_16 := X"0000";
		-- operands
		rx				: in bit_16;
		rz				: in bit_16;
		ir_operand		: in bit_16;
		-- flag control signal
		clr_z_flag		: in bit_1;
		reset : in bit_1
	);
end alu;

architecture combined of alu is
	signal operand_1	: bit_16;
	signal operand_2	: bit_16;
	signal result		: bit_16;
begin
	--MUX selecting first operand
	op1_select: process (alu_op1_sel, rx, ir_operand)
	begin
		case alu_op1_sel is
			when "00" =>
				operand_1 <= rx;
			when "01" =>
				operand_1 <= ir_operand;
			when "10" => --not used currently
				operand_1 <= X"0001";
			when others =>
				operand_1 <= X"0000";
		end case;
	end process op1_select;
	
	--MUX selecting second operand
	op2_select: process (alu_op2_sel, rx, rz)
	begin
		case alu_op2_sel is
			when '0' =>
				operand_2 <= rx;
			when '1' =>
				operand_2 <= rz;
			when others =>
				operand_2 <= X"0000";
		end case;
	end process op2_select;
	
	-- perform ALU operation
	alu: process (alu_operation, operand_1, operand_2, reset, clr_z_flag)
	begin
		case alu_operation is
			when alu_add =>
				result <= operand_2 + operand_1;
			when alu_sub =>
				result <= operand_2 - operand_1;
			when alu_and =>
				result <= operand_2 and operand_1;
			when alu_or =>
				result <= operand_2 or operand_1;
			when alu_not =>
				result <= not operand_1;
			when alu_lsl =>
				result <= operand_1(14 downto 0)&'0';
			when alu_lsr =>
				result <= '0'&operand_1(15 downto 1);
			when others =>
				result <= X"0000";
		end case;		
	end process alu;
	alu_result <= result;

	z_flag_hack <= not (or_reduce(result) or alu_operation(2));
	
	-- zero flag
	z1gen: process (clk, reset)
--	z1gen: process (result, reset, clr_z_flag)
	begin
		if reset = '1' then
			z_flag <= '0';
		elsif rising_edge(clk) then
			if clr_z_flag = '1' then
--		elsif clr_z_flag = '1' then
				z_flag <= '0';
			-- if alu is working (operation is valid)
			elsif alu_operation(2) = '0' then
				if result = X"0000" then
					z_flag <= '1';
				else
					z_flag <= '0';
				end if;
			end if;
		end if;
	end process z1gen;

end combined;
