-- UoA - COMPSYS 701 - ADVANCED DIGITAL DESIGN
-- GROUP 8, TEAM AJS
-- PHASE ONE: RECOP
-- REFER TO DATAPATH DIAGRAM AND CONTROL ISA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity recop is
-- generic and port declration here
generic(
	constant recop_id  : integer := 0
);

port(	clk				: in std_logic;
		ER_in			: in std_logic;
		DPRR_in			: in std_logic_vector(31 downto 0);
		SIP_in			: in std_logic_vector(15 downto 0);
		reset 			: in std_logic;

		EOT_out			: out std_logic;
		DPCR_out		: out std_logic_vector(31 downto 0);
		SVOP_out		: out std_logic_vector(15 downto 0);
		SOP_out			: out std_logic_vector(15 downto 0)
	);
end entity recop;

---------------------------------------------------------------------------------------------------
architecture behaviour of recop is

	signal s_clk			: std_logic;
	signal s_am				: std_logic_vector(1 downto 0);
	signal s_opcode			: std_logic_vector(5 downto 0);
	signal s_irq_flag		: std_logic;
		
	signal s_m_addr_sel 	: std_logic_vector(1 downto 0);
	signal s_m_data_sel		: std_logic_vector(1 downto 0);
	signal s_m_wr			: std_logic;
	signal s_ir_wr			: std_logic_vector(1 downto 0);
	signal s_r_wr_d_sel		: std_logic_vector(2 downto 0);
	signal s_r_wr_r_sel		: std_logic;
	signal s_r_rd_sel		: std_logic;
	signal s_r_wr 			: std_logic;
	signal s_alu_src_A		: std_logic_vector(1 downto 0);
	signal s_alu_src_B		: std_logic_vector(1 downto 0);
	signal s_alu_op			: std_logic_vector(2 downto 0);
	signal s_pc_src			: std_logic_vector(1 downto 0);
	signal s_set_DPC		: std_logic;
	signal s_set_EOT		: std_logic;
	signal s_reset_DPRR		: std_logic;
	signal s_reset_DPCR		: std_logic;
	signal s_reset_DPC 		: std_logic;
	signal s_reset_EOT		: std_logic;
	signal s_reset_ER		: std_logic;
	signal s_reset_Z		: std_logic;
	signal s_pc_wr			: std_logic;
	signal s_pc_wr_cond_z	: std_logic;
	signal s_pc_wr_cond_p	: std_logic;
	signal s_wr_DPCR		: std_logic;
	signal s_wr_SVOP		: std_logic;
	signal s_wr_SOP 		: std_logic;
	signal s_wr_Z 			: std_logic;

---------------------------------------------------------------------------------------------------
-- component declaration here
component recop_datapath
	generic(
		constant m_mux_sel_num : positive := 3;
		constant r_wr_mux_sel_num : positive := 3;
		constant reg_width : positive := 16
	);

	port (
		clk				:	in std_logic;
		reset			:   in std_logic;

		--control signal for EOT, PC and Z registers
		reset_z			:	in std_logic;
		wr_z			:	in std_logic;
		pc_wr_cond_z	:	in std_logic;
		pc_wr_cond_p	:	in std_logic;
		pc_wr			:	in std_logic;
		set_EOT			:	in std_logic;
		reset_EOT		:	in std_logic;

		--control signals for Memory, IR and RegFile
		ir_wr			:	in std_logic_vector(1 downto 0);
		m_wr			:	in std_logic;
		r_wr			:	in std_logic;	

		--registers control signals
		reset_ER		:	in std_logic;
		reset_DPRR		:	in std_logic;
		reset_DPC		:	in std_logic;
		set_DPC			:	in std_logic;
		wr_SVOP			:	in std_logic;
		wr_SOP			:	in std_logic;
		wr_DPCR			:	in std_logic;

		--register inputs for ER and SIP
		ER_in			:	in std_logic;
		DPRR_in			:	in std_logic_vector(31 downto 0);
		SIP_in			:	in	std_logic_vector(15 downto 0);

		--mux control signals
		m_addr_sel		:	in std_logic_vector(1 downto 0);
		m_data_sel		:	in std_logic_vector(1 downto 0);
		r_rd_sel		:	in std_logic;
		r_wr_sel		:	in std_logic_vector(2 downto 0);
		r_wr_r_sel 		:	in std_logic;
		alu_src_A		:	in std_logic_vector(1 downto 0);
		alu_src_B		:	in std_logic_vector(1 downto 0);
		pc_src 			:	in std_logic_vector(1 downto 0);

		--ALU control signal
		alu_op			:	in std_logic_vector(2 downto 0);

		--register outputs
		EOT_out			:	out std_logic;
		DPCR_out		:	out std_logic_vector(31 downto 0);
		SVOP_out		:	out std_logic_vector(15 downto 0);
		SOP_out			:	out std_logic_vector(15 downto 0);

		--feedback to control
		irq_flag		:	out std_logic;
		am				:	out std_logic_vector(1 downto 0);
		opcode			:	out std_logic_vector(5 downto 0)
	);
end component;

component recop_control
	port (	
		
		clk				: in std_logic;
		am				: in std_logic_vector(1 downto 0);
		opcode			: in std_logic_vector(5 downto 0);
		irq_flag		: in std_logic;
		reset			: in std_logic;
			
		m_addr_sel 		: out std_logic_vector(1 downto 0);
		m_data_sel		: out std_logic_vector(1 downto 0);
		m_wr			: out std_logic;
		ir_wr			: out std_logic_vector(1 downto 0);
		r_wr_d_sel		: out std_logic_vector(2 downto 0);
		r_wr_r_sel		: out std_logic;
		r_rd_sel		: out std_logic;
		r_wr 			: out std_logic;
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
		reset_ER		: out std_logic;
		reset_Z			: out std_logic;
		pc_wr			: out std_logic;
		pc_wr_cond_z	: out std_logic;
		pc_wr_cond_p	: out std_logic;
		wr_DPCR			: out std_logic;
		wr_SVOP			: out std_logic;
		wr_SOP 			: out std_logic;
		wr_Z 			: out std_logic

	);
end component;

---------------------------------------------------------------------------------------------------
begin
-- component wiring here

datapath_unit : recop_datapath
	generic map (
		m_mux_sel_num => 3,
		r_wr_mux_sel_num => 3,
		reg_width	=>	16
	)
	port map (
		clk => clk,
		reset => reset,
		ER_in => ER_in,
		DPRR_in => DPRR_in,
		SIP_in => SIP_in,

		EOT_out => EOT_out,
		DPCR_out => DPCR_out,
		SVOP_out => SVOP_out,
		SOP_out => SOP_out,

		--control signal for EOT, PC and Z registers
		reset_z => s_reset_Z,
		wr_z    => s_wr_Z,
		pc_wr_cond_z => s_pc_wr_cond_z,
		pc_wr_cond_p => s_pc_wr_cond_p,
		pc_wr => s_pc_wr,
		set_EOT => s_set_EOT,
		reset_EOT => s_reset_EOT,

		--control signals for Memory, IR and RegFile
		ir_wr => s_ir_wr,
		m_wr => s_m_wr,
		r_wr => s_r_wr,

		--registers control signals
		reset_ER => s_reset_ER,
		reset_DPRR => s_reset_DPRR,
		reset_DPC	=> s_reset_DPC,
		set_DPC => s_set_DPC,
		wr_SVOP => s_wr_SVOP,
		wr_SOP => s_wr_SOP,
		wr_DPCR => s_wr_DPCR,

		--mux control signals
		m_addr_sel => s_m_addr_sel,
		m_data_sel => s_m_data_sel,
		r_rd_sel => s_r_rd_sel,
		r_wr_sel => s_r_wr_d_sel,
		r_wr_r_sel => s_r_wr_r_sel,
		alu_src_A => s_alu_src_A,
		alu_src_B => s_alu_src_B,
		pc_src => s_pc_src,

		--ALU control signal
		alu_op => s_alu_op,

		--feedback to control
		am => s_am,
		opcode => s_opcode,
		irq_flag => s_irq_flag
	);

control_unit : recop_control
	port map (
		clk => clk,
		reset => reset,
		am => s_am,
		opcode => s_opcode,
		irq_flag => s_irq_flag,

		m_addr_sel => s_m_addr_sel,
		m_data_sel => s_m_data_sel,
		m_wr => s_m_wr,
		ir_wr => s_ir_wr,
		r_wr_d_sel => s_r_wr_d_sel,
		r_wr_r_sel => s_r_wr_r_sel,
		r_rd_sel => s_r_rd_sel,
		r_wr => s_r_wr,
		alu_src_A => s_alu_src_A,
		alu_src_B => s_alu_src_B,
		alu_op => s_alu_op,
		pc_src => s_pc_src,
		set_DPC => s_set_DPC,
		set_EOT => s_set_EOT,
		reset_DPRR => s_reset_DPRR,
		reset_DPCR => s_reset_DPCR,
		reset_DPC => s_reset_DPC,
		reset_EOT => s_reset_EOT,
		reset_ER => s_reset_ER,
		reset_Z => s_reset_Z,
		pc_wr => s_pc_wr,
		pc_wr_cond_z => s_pc_wr_cond_z,
		pc_wr_cond_p => s_pc_wr_cond_p,
		wr_DPCR => s_wr_DPCR,
		wr_SVOP => s_wr_SVOP,
		wr_SOP => s_wr_SOP,
		wr_Z => s_wr_Z
	);
	
---------------------------------------------------------------------------------------------------
-- other processes here



---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;


---------------------------------------------------------------------------------------------------
end architecture;