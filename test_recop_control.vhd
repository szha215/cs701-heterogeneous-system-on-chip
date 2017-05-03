-- copyright (c) 1991-2013 altera corporation
-- your use of altera corporation's design tools, logic functions 
-- and other software and tools, and its ampp partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the altera program license 
-- subscription agreement, altera megacore function license 
-- agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by altera and sold by 
-- altera or its authorized distributors.  please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- this file contains a vhdl test bench template that is freely editable to   
-- suit user's needs .comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- generated on "05/03/2017 12:01:34"
                                                            
-- vhdl test bench template for design  :  recop_control
-- 
-- simulation tool : modelsim (vhdl)
-- 

library ieee;                                               
use ieee.std_logic_1164.all;                                
use work.recop_opcodes.all;

entity test_recop_control is
end test_recop_control;
architecture recop_control_arch of test_recop_control is
	-- constants
	constant clk_period : time := 5 ns;
	-- signals                                                   
	signal alu_op : std_logic_vector(2 downto 0);
	signal alu_src_a : std_logic_vector(1 downto 0);
	signal alu_src_b : std_logic_vector(1 downto 0);
	signal am : std_logic_vector(1 downto 0);
	signal clk : std_logic;
	signal ir_wr : std_logic_vector(1 downto 0);
	signal irq_flag : std_logic;
	signal m_addr_sel : std_logic_vector(2 downto 0);
	signal m_data_sel : std_logic_vector(1 downto 0);
	signal m_wr : std_logic;
	signal opcode : std_logic_vector(5 downto 0);
	signal pc_src : std_logic_vector(1 downto 0);
	signal pc_wr : std_logic;
	signal pc_wr_cond_p : std_logic;
	signal pc_wr_cond_z : std_logic;
	signal r_rd_sel : std_logic;
	signal r_wr : std_logic;
	signal r_wr_d_sel : std_logic_vector(2 downto 0);
	signal r_wr_r_sel : std_logic;
	signal reset_dpc : std_logic;
	signal reset_dpcr : std_logic;
	signal reset_dprr : std_logic;
	signal reset_eot : std_logic;
	signal reset_er : std_logic;
	signal reset_z : std_logic;
	signal set_dpc : std_logic;
	signal set_eot : std_logic;
	signal wr_dpcr : std_logic;
	signal wr_sop : std_logic;
	signal wr_svop : std_logic;
	signal wr_z : std_logic;
	type instruction_type is (
		AND_t,
		OR_t,
		ADD_t,
		SUBV_t,
		SUB_t,
		LDR_t,
		STR_t,
		JMP_t,
		PRESENT_t,
		DCALLBL_t,
		DCALLNB_t,
		SZ_t,
		CLFZ_t,
		CER_t,
		CEOT_t,
		SEOT_t,
		LER_t,
		SSVOP_t,
		LSIP_t,
		SSOP_t,
		NOOP_t,
		MAX_t,
		STRPC_t
	);
	type address_type is (IMMEDIATE_t, INHERENT_t, DIRECT_t, REGISTER_t);
	signal INSTRUCTION : instruction_type;
	signal ADDRESS_MODE : address_type;
	component recop_control
		port (
			alu_op : out std_logic_vector(2 downto 0);
			alu_src_a : out std_logic_vector(1 downto 0);
			alu_src_b : out std_logic_vector(1 downto 0);
			am : in std_logic_vector(1 downto 0);
			clk : in std_logic;
			ir_wr : out std_logic_vector(1 downto 0);
			irq_flag : in std_logic;
			m_addr_sel : out std_logic_vector(2 downto 0);
			m_data_sel : out std_logic_vector(1 downto 0);
			m_wr : out std_logic;
			opcode : in std_logic_vector(5 downto 0);
			pc_src : out std_logic_vector(1 downto 0);
			pc_wr : out std_logic;
			pc_wr_cond_p : out std_logic;
			pc_wr_cond_z : out std_logic;
			r_rd_sel : out std_logic;
			r_wr : out std_logic;
			r_wr_d_sel : out std_logic_vector(2 downto 0);
			r_wr_r_sel : out std_logic;
			reset_dpc : out std_logic;
			reset_dpcr : out std_logic;
			reset_dprr : out std_logic;
			reset_eot : out std_logic;
			reset_er : out std_logic;
			reset_z : out std_logic;
			set_dpc : out std_logic;
			set_eot : out std_logic;
			wr_dpcr : out std_logic;
			wr_sop : out std_logic;
			wr_svop : out std_logic;
			wr_z : out std_logic
		);
	end component;

begin

i1 : recop_control
port map (
	-- list connections between master ports and signals
	alu_op => alu_op,
	alu_src_a => alu_src_a,
	alu_src_b => alu_src_b,
	am => am,
	clk => clk,
	ir_wr => ir_wr,
	irq_flag => irq_flag,
	m_addr_sel => m_addr_sel,
	m_data_sel => m_data_sel,
	m_wr => m_wr,
	opcode => opcode,
	pc_src => pc_src,
	pc_wr => pc_wr,
	pc_wr_cond_p => pc_wr_cond_p,
	pc_wr_cond_z => pc_wr_cond_z,
	r_rd_sel => r_rd_sel,
	r_wr => r_wr,
	r_wr_d_sel => r_wr_d_sel,
	r_wr_r_sel => r_wr_r_sel,
	reset_dpc => reset_dpc,
	reset_dpcr => reset_dpcr,
	reset_dprr => reset_dprr,
	reset_eot => reset_eot,
	reset_er => reset_er,
	reset_z => reset_z,
	set_dpc => set_dpc,
	set_eot => set_eot,
	wr_dpcr => wr_dpcr,
	wr_sop => wr_sop,
	wr_svop => wr_svop,
	wr_z => wr_z
);

test_signal : process
begin
	INSTRUCTION <= AND_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= and_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= AND_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= and_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= OR_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= or_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= OR_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= or_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= ADD_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= add_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= ADD_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= add_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= SUBV_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= subv_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= SUB_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= sub_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= LDR_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= ldr_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= LDR_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= ldr_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 4;

	INSTRUCTION <= LDR_t;
	ADDRESS_MODE <= DIRECT_t;
	opcode <= ldr_op;
	am <= direct_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 6;

	INSTRUCTION <= STR_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= str_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= STR_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= str_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= STR_t;
	ADDRESS_MODE <= DIRECT_t;
	opcode <= str_op;
	am <= direct_am;
	irq_flag <=  '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= JMP_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= jmp_op;
	am <= immediate_am;
	irq_flag <=  '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= JMP_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= jmp_op;
	am <= register_am;
	irq_flag <=  '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= PRESENT_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= present_op;
	am <= immediate_am;
	irq_flag <=  '0';
	wait for clk_period * 2 * 5;

	INSTRUCTION <= DCALLBL_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= dcallbl_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 10;

	irq_flag <= '1';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= DCALLBL_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= dcallbl_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 50;

	irq_flag <= '1';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= DCALLNB_t;
	ADDRESS_MODE <= REGISTER_t;
	opcode <= dcallnb_op;
	am <= register_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 3;

	INSTRUCTION <= SZ_t;
	ADDRESS_MODE <= IMMEDIATE_t;
	opcode <= sz_op;
	am <= immediate_am;
	irq_flag <= '0';
	wait for clk_period * 2 * 5;

	irq_flag <= '1';
	
	wait for clk_period * 20;
	irq_flag <= '0';
	--INSTRUCTION <= _t;
	--ADDRESS_MODE <= _t;
	--opcode <= _op;
	--am <= _am;
	--irq_flag <= '';
	--wait for clk_period * 2 * ;


	wait;

end process test_signal;





clk_process : process                                              
begin                                                         
	clk <= '1';
	wait for clk_period;
	clk <= '0';
	wait for clk_period;
end process clk_process;                                          
end recop_control_arch;
