-- UoA - COMPSYS 701 - ADVANCED DIGITAL DESIGN
-- GROUP 8, TEAM AJS
-- PHASE ONE: RECOP CONTROL
-- REFER TO DATAPATH DIAGRAM AND CONTROL ISA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.recop_opcodes.all;

---------------------------------------------------------------------------------------------------
entity recop_control_AJS is
port(	clk				: in std_logic;
		am					: in std_logic_vector(1 downto 0);
		opcode			: in std_logic_vector(5 downto 0);
		irq_flag			: in std_logic;
		reset				: in std_logic;
			
		m_addr_sel 		: out std_logic_vector(1 downto 0);
		m_data_sel		: out std_logic_vector(1 downto 0);
		m_wr				: out std_logic;
		ir_wr				: out std_logic_vector(1 downto 0);
		r_wr_d_sel		: out std_logic_vector(2 downto 0);
		r_wr_r_sel		: out std_logic;
		r_rd_sel			: out std_logic;
		r_wr 				: out std_logic;
		alu_src_A		: out std_logic_vector(1 downto 0);
		alu_src_B		: out std_logic_vector(1 downto 0);
		alu_op			: out std_logic_vector(2 downto 0);
		pc_src			: out std_logic_vector(1 downto 0);
		set_DPC			: out std_logic;
		set_EOT			: out std_logic;
		reset_DPRR		: out std_logic;
		reset_DPCR		: out std_logic;
		reset_DPC 		: out std_logic;
		reset_EOT		: out std_logic;
		reset_ER			: out std_logic;
		reset_Z			: out std_logic;
		pc_wr				: out std_logic;
		pc_wr_cond_z	: out std_logic;
		pc_wr_cond_p	: out std_logic;
		wr_DPCR			: out std_logic;
		wr_SVOP			: out std_logic;
		wr_SOP 			: out std_logic;
		wr_Z 				: out std_logic;
		dprr_ack			: out std_logic

	);
end entity recop_control_AJS;

---------------------------------------------------------------------------------------------------
architecture behaviour of recop_control_AJS is
-- type, signal, constant declarations here

type states is (IF1, IF1S, ID1, IF2, ID2, EX, LR, MA, SM, JP, DC, DCS, DCC, DS, DR, NOOP, RST); -- states
-- 
signal CS, NS : states := IF1;


---------------------------------------------------------------------------------------------------
-- component declaration here


---------------------------------------------------------------------------------------------------
begin
-- component wiring here


--------------------------------------------------------------------------------------------------
state_updater: process(clk, reset)
begin
	if (reset = '1') then
		CS <= RST;
	elsif (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(clk, irq_flag, am, opcode)
begin
	case CS is	-- must cover all states
		when IF1 => -- Instruction Fetch
			NS <= IF1S;

		when IF2 => -- Operand Fetch
			NS <= ID2;

		when IF1S => -- Instruction Fetch, Memory Stall
			NS <= ID1;

		when ID1 => -- Decode Instruction
			if (am = immediate_am or am = direct_am) then
				NS <= IF2;
		 	elsif (opcode = and_op or opcode = or_op or opcode = add_op) then
		 		NS <= EX;
		 	elsif (opcode = ldr_op) then
		 		NS <= MA;
		 	elsif (opcode = str_op) then
		 		NS <= SM;
		 	elsif (opcode = jmp_op) then
		 		NS <= JP;
		 	elsif (opcode = dcallbl_op or opcode = dcallnb_op) then
		 		NS <= DC;
		 	elsif (opcode = noop_op) then
		 		NS <= NOOP;
		 	else
		 		NS <= LR;
		 	end if;

		when ID2 => -- Decode Operand
		 	if (opcode = ldr_op and am = immediate_am) then
		 		NS <= LR;
		 	elsif (opcode = dcallbl_op or opcode = dcallnb_op) then
		 		NS <= DC;
		 	elsif (opcode = ldr_op and am = direct_am) then
		 		NS <= MA;
		 	elsif (opcode = str_op or opcode = strpc_op) then
		 		NS <= SM;
		 	elsif (opcode = jmp_op or opcode = present_op or opcode = sz_op) then
		 		NS <= JP;
		 	else
		 		NS <= EX;
		 	end if;

		when MA => -- Mem Acces
			NS <= LR;

		when LR => -- Load Register
			if (irq_flag = '1') then
				NS <= DS;
			else
				NS <= IF1;
			end if;
		
		when DC => -- Data Call Invoke
			NS <= DCS;

		when DCS => -- Data Call Stall
			NS <= DCC;

		when DCC => -- Data Call (DPCR) Clear
			if (opcode = dcallbl_op and irq_flag = '0') then
				NS <= DCC;
			elsif (irq_flag = '1') then
				NS <= DS;
			else
				NS <= IF1;
			end if;

		when DS => -- Data Call Result Store
			NS <= DR;				
		
		when DR => -- Data Call (DPRR) Reset
			NS <= IF1;
		
		when others => -- EX, JP, LR, NOOP, SM
			if (irq_flag = '1')then
				NS <= DS;
			else
				NS <= IF1;
			end if;

	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS, irq_flag, am, opcode)
begin
	
	m_addr_sel 		<= "00";		m_data_sel 		<= "00";	
	m_wr 				<= '0';		ir_wr 			<= "00";
	r_wr_d_sel 		<= "000";	r_wr_r_sel 		<= '0';
	r_wr 				<= '0';		alu_src_A 		<= "00";
	alu_src_B 		<= "00";		wr_Z 				<= '0';
	alu_op 			<= "000";	pc_src 			<= "00";
	set_DPC 			<= '0';		set_EOT 			<= '0';
	reset_DPRR 		<= '0';		reset_DPCR 		<= '0';
	reset_DPC 		<= '0';		reset_EOT 		<= '0';
	reset_ER 		<= '0';		reset_Z 			<= '0';
	pc_wr 			<= '0';		pc_wr_cond_z 	<= '0';
	pc_wr_cond_p 	<= '0';		wr_DPCR 			<= '0';
	wr_SVOP 			<= '0';		wr_SOP 			<= '0';
	dprr_ack			<= '0';


	case CS is	-- must cover all states
		when IF1 => -- Instruction Fetch
			alu_src_A <= "00";
			alu_src_B <= "01";
			pc_wr <= '1';
			alu_op <= "000";

		when IF2 => -- Operand Fetch
			alu_src_A <= "00";
			alu_src_B <= "01";
			pc_wr <= '1';
			alu_op <= "000";

		when IF1S => -- Instruction Fetch, Memory Stall
			alu_src_A <= "00";
			alu_src_B <= "01";
			alu_op <= "000";
			ir_wr <= "01";

		when ID1 => -- Instruction Decode
			alu_src_A <= "00";
			alu_src_B <= "01";
			alu_op <= "000";
			ir_wr <= "10";

		when ID2 => -- Operand Decode
			-- Stall for register store
			null;	

		when EX => -- Execute
			case opcode is
				when and_op =>
					if (am = immediate_am) then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "010";
					r_wr <= '1';
					wr_Z <= '1';

				when or_op =>
					if (am = immediate_am) then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "011";
					r_wr <= '1';
					wr_Z <= '1';

				when add_op =>
					if (am = immediate_am) then
						alu_src_A <= "01";
					else
						alu_src_A <= "10";
					end if;
					alu_src_B <= "00";
					alu_op <= "000";
					r_wr <= '1';
					wr_Z <= '1';

				when subv_op =>
					alu_src_A <= "11";
					alu_src_B <= "11";
					alu_op <= "001";
					r_wr <= '1';
					wr_Z <= '1';

				when sub_op =>
					alu_src_A <= "10";
					alu_src_B <= "11";
					alu_op <= "001";
					wr_Z <= '1';	

				when max_op =>
					alu_src_A <= "10";
					alu_src_B <= "11";
					alu_op <= "100";
					r_wr <= '1';

				when others =>
					null;

			end case;

		when LR => -- Load Register
			case opcode is
				when ldr_op =>
					if (am = immediate_am) then
						r_wr_d_sel <= "100";
						r_wr <= '1';
					elsif (am = register_am) then
						m_addr_sel <= "10";
						r_wr_d_sel <= "001";
						r_wr <= '1';
					elsif (am = direct_am) then
						m_addr_sel <= "00";
						r_wr_d_sel <= "001";
						r_wr <= '1';
					end if;	

				when clfz_op =>
					reset_Z <= '1';

				when cer_op =>
					reset_ER <= '1';

				when ceot_op =>
					reset_EOT <= '1';

				when seot_op =>
					set_EOT <= '1';

				when ler_op =>
					r_wr_d_sel <= "010";
					r_wr <= '1';

				when ssvop_op =>
					wr_SVOP <= '1';

				when lsip_op =>
					r_wr_d_sel <= "011";
					r_wr <= '1';

				when ssop_op =>
					wr_SOP <= '1';

				when others =>
					null;

			end case;

		when DC => -- Data Call Invoke
			if (opcode = dcallbl_op) then
				wr_DPCR <= '1';
				set_DPC <= '1';
			elsif (opcode = dcallnb_op) then
				wr_DPCR <= '1';
			end if;

		when DCS => -- Data Call Stall
			null;

		when DCC => -- Data Call (DPCR) Clear
			reset_DPCR <= '1';

		when MA => -- Memory Access
			if (am = register_am) then
				m_addr_sel <= "10";
				r_wr_d_sel <= "001";
			elsif (am = direct_am) then
				m_addr_sel <= "00";
				r_wr_d_sel <= "001";
			end if;

		when SM => -- Store Memory
			if (opcode = strpc_op) then
				m_addr_sel <= "00";
				m_data_sel <= "01";
				m_wr <= '1';
			elsif (am = immediate_am) then -- str_op
				m_addr_sel <= "01";
				m_data_sel <= "00";
				m_wr <= '1';
			elsif (am = register_am) then
				m_addr_sel <= "01";
				m_data_sel <= "10";
				m_wr <= '1';
			elsif (am = direct_am) then
				m_addr_sel <= "00";
				m_data_sel <= "10";
				m_wr <= '1';
			end if;

		when JP => -- Jump
			case opcode is
				when jmp_op =>
					pc_wr <= '1';
					if (am = immediate_am) then
						pc_src <= "01";
					else
						pc_src <= "10";
					end if;

				when present_op =>
					-- Rx | 0
					alu_src_A <= "10";
					alu_src_B <= "10";
					alu_op <= "011";
					pc_wr_cond_p <= '1';
					pc_src <= "01";
					wr_Z <= '1';

				when sz_op =>
					pc_wr_cond_z <= '1';
					pc_src <= "01";

				when others =>
					null;

			end case;


		when DS => -- Data Call Result Store
			if (opcode = dcallbl_op) then -- blocking
				r_wr_r_sel <= '1';
				r_wr_d_sel <= "101";
				r_wr <= '1';
			else -- non-block
				m_addr_sel <= "11";
				m_data_sel <= "11";
				m_wr <= '1';
			end if;

			
		when DR => -- Data Call (DPRR) Reset
			-- D-Type: Reset DPRR, DPCR and DPC
			--reset_DPRR <= '1';
			dprr_ack	<= '1';
			reset_DPCR <= '1';
			reset_DPC <= '1';
			

		when NOOP =>
			null;

		when RST =>
			reset_DPRR <= '1';
			reset_DPCR <= '1';
			reset_DPC  <= '1';
			reset_EOT <= '1';
			reset_ER <= '1';
			reset_Z	 <= '1';


		when others =>
			report "STATE OUTPUT: BAD STATE";
			null;

	end case;

end process output_logic;


---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;

r_rd_sel <= '0' when (am = register_am and (opcode = dcallbl_op or opcode = dcallnb_op)) else
			'1';

---------------------------------------------------------------------------------------------------
end architecture;
