library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

use work.ajs_pkgs.all;
--use ieee.numeric_std.all;

---------------------------------------------------------------------------------------------------
entity recop_control is

port(	clk			: in std_logic;
		am			: in std_logic_vector(1 downto 0);
		opcode		: in std_logic_vector(5 downto 0);
		
		m_addr_sel 	: out std_logic_vector(1 downto 0);
		m_data_sel	: out std_logic_vector(1 downto 0);
		m_rd		: out std_logic;
		m_wr		: out std_logic;
		ir_wr		: out std_logic_vector(1 downto 0);
		r_wr_sel	: out std_logic_vector(1 downto 0);
		r_rd_sel	: out std_logic_vector(1 downto 0);
		r_wr 		: out std_logic;
		alu_src_A	: out std_logic_vector(1 downto 0);
		alu_src_B	: out std_logic_vector(1 downto 0);
		alu_op		: out std_logic_vector(2 downto 0);
		pc_src		: out std_logic_vector(1 downto 0);
		set_EOT		: out std_logic;
		reset_EOT	: out std_logic;
		reset_Z		: out std_logic;
		pc_wr		: out std_logic;
		pc_wr_cond	: out std_logic;
		wr_SVOP		: out std_logic;
		wr_SOP 		: out std_logic
	);


end entity recop_control;

---------------------------------------------------------------------------------------------------
architecture behaviour of recop_control is
-- type, signal, constant declarations here

type states is (IF1, IF2, EX, CM);	-- states -- Instruction Fetch 1 & 2, Execute, Complete/Mem Acc
signal CS, NS : states := IF1;

---------------------------------------------------------------------------------------------------
-- component declaration here


---------------------------------------------------------------------------------------------------
begin
-- component wiring here


---------------------------------------------------------------------------------------------------
state_updater: process(clk)
begin
	if (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(CS)
begin
	case CS is	-- must cover all states
		when IF1 => -- Instruction Fetch
			if (am = "01" or am = "10") then
				NS <= IF2;
			else
			 	NS <= CM;
			end if;			
		when IF2 => -- Operand Fetch
			NS <= EX;
		when EX => -- Execute
			if (opcode = and_op or opcode = or_op or opcode = add_op or opcode = subv_op or
				opcode = sub_op or opcode = present_op or opcode = max_op) then
				NS <= CM;
			else
				NS <= IF1;
			end if;
		when CM => -- Complete/Memory Access
			NS <= IF1;
		when others =>
			report "STATE TRANSITION: BAD STATE";
			NS <= IF1;
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin

	m_addr_sel 	<= "00";	m_data_sel	<= "00";
	m_rd		<= '0';		m_wr		<= '0';
	ir_wr		<= '0';		r_wr_sel	<= "000";
	r_wr 		<= '0'; 	alu_src_A	<= "00";
	alu_src_B	<= "00";	alu_op		<= "000";
	pc_src		<= "00";	set_EOT		<= '0';
	reset_EOT	<= '0';		reset_Z		<= '0';
	pc_wr		<= '0';		pc_wr_cond	<= '0';
	wr_SVOP		<= '0';		wr_SOP 		<= '0';

	case CS is	-- must cover all states
		when IF1 =>
			alu_src_A <= "00";
			alu_src_B <= "01";
			ir_wr <= "01";
			m_rd <= '1';
			pc_wr <= '1';
			alu_op <= "00";
		when IF2 =>
			alu_src_A <= "00";
			alu_src_B <= "01";
			ir_wr <= "10";
			m_rd <= '1';
			pc_wr <= '1';
			alu_op <= "000";
		when EX =>
			case opcode is
				when and_op => -- AND
					if (am = "01") then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "010";
				when or_op => -- OR
					if (am = "01") then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "011";
				when add_op => -- ADD
					if (am = "01") then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "000";
				when subv_op => -- SUBV
					-- Rx - Operand
					alu_src_A <= "11";
					alu_src_B <= "11";
					alu_op <= "001"
				when sub_op => -- SUB
					alu_src_A <= "10";
					alu_src_B <= "11";
					alu_op <= "001"
				when jmp_op => -- jump
					pc_wr <= '1';
					if (am = "01") then -- operand
						pc_src <= "01";
					else -- Rx
						pc_src <= "10";
					end if;
				when sz_op => -- sz
					pc_wr_cond <= '1';
					pc_src <= "01";
				when present_op => -- present
					-- Rx | 0
					alu_src_A <= "10";
					alu_src_B <= "10";
					alu_op <= "011";
				when "" =>
				when "" =>
				when others =>
					null;
			end case;
		when CM =>
			null;
		when others =>
			report "STATE OUTPUT: BAD STATE";
			null;
	end case;

end process output_logic;


---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;

r_rd_sel <= '0' when (am = "11" and (opcode = "101001" or opcode = "101000")) else
			'1';

---------------------------------------------------------------------------------------------------
end architecture;