library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

---------------------------------------------------------------------------------------------------
entity test_recop_datapath is
end test_recop_datapath;

---------------------------------------------------------------------------------------------------
architecture behaviour of test_recop_datapath is
-- type, signal declarations
type states is (START,IF1, ID1, IF2, ID2, EX, DM, DR);
signal CS : states := START;
constant t_clk_period : time := 20 ns;
constant t_reg_width : positive := 16;
constant t_m_mux_sel_num : positive := 3;
signal t_clk, t_reset, t_wr_en : std_logic := '0';
signal t_data_in,t_data_out : std_logic_vector(t_reg_width -1 downto 0) := (others => '0'); 


signal t_reset_z, t_wr_z, t_pc_wr_cond_z,t_pc_wr_cond_p,t_pc_wr, t_set_EOT, 	t_reset_EOT, t_m_wr, t_r_wr : std_logic := '0';
signal t_ir_wr : std_logic_vector(1 downto 0) := (others => '0');
signal t_reset_ER,t_reset_DPRR,t_wr_SVOP,t_wr_SOP,t_wr_DPCR, t_ER_in: std_logic := '0';  
signal t_DPRR_in : std_logic_vector(31 downto 0) := (others => '0');
signal  t_SIP_in : std_logic_vector(t_reg_width - 1 downto 0) := (others => '0');
signal t_set_DPC,t_reset_DPC : std_logic := '0';
signal t_m_addr_sel, t_m_data_sel : std_logic_vector(t_m_mux_sel_num - 1 downto 0) := (others => '0');
signal t_r_rd_sel : std_logic := '0';
signal t_r_wr_sel : std_logic_vector(2 downto 0) := (others => '0');
signal t_r_wr_r_sel : std_logic := '0';
signal t_alu_src_A, t_alu_src_B : std_logic_vector(1 downto 0) := (others => '0');
signal t_pc_src : std_logic_vector(1 downto 0) := (others => '0');

signal t_alu_op : std_logic_vector(2 downto 0) := (others => '0');

signal t_SVOP_out, t_SOP_out : std_logic_vector(15 downto 0) := (others => '0');
signal t_EOT_out : std_logic := '0';
signal t_DPCR_out : std_logic_vector(31 downto 0) := (others => '0');

signal t_am : std_logic_vector(1 downto 0) := (others => '0');
signal t_opcode : std_logic_vector(5 downto 0) := (others => '0');
signal t_irq_out : std_logic := '0';


---------------------------------------------------------------------------------------------------
-- component declarations
component recop_datapath
generic(
	constant m_mux_sel_num : positive := 3;
	constant r_wr_mux_sel_num : positive := 3;
	constant reg_width : positive := 16
);


port (
	clk				:	in std_logic;


	--control signal for EOT, PC and Z registers
	reset_z			:	in std_logic;
	wr_z 				:	in std_logic;
	pc_wr_cond_z	:	in std_logic;
	pc_wr_cond_p	:	in std_logic;
	pc_wr				:	in std_logic;
	set_EOT			:	in std_logic;
	reset_EOT		:	in std_logic;


	--control signals for Memory, IR and RegFile
	ir_wr				:	in std_logic_vector(1 downto 0);
	m_wr				:	in std_logic;
	r_wr				:	in std_logic;	


	--registers control signals
	reset_ER			:	in std_logic;
	reset_DPRR		:	in std_logic;
	reset_DPC		:	in std_logic;
	set_DPC			:	in std_logic;
	wr_SVOP			:	in std_logic;
	wr_SOP			:	in std_logic;
	wr_DPCR			:	in std_logic;

	--register inputs for ER and SIP
	ER_in		:	in std_logic;
	DPRR_in			:	in std_logic_vector(31 downto 0);
	SIP_in			:	in	std_logic_vector(reg_width - 1 downto 0);

	--mux control signals
	m_addr_sel		:	in std_logic_vector(2 downto 0);
	m_data_sel		:	in std_logic_vector(2 downto 0);
	r_rd_sel			:	in std_logic;
	r_wr_sel			:	in std_logic_vector(2 downto 0);
	r_wr_r_sel		:	in std_logic;
	alu_src_A		:	in std_logic_vector(1 downto 0);
	alu_src_B		:	in std_logic_vector(1 downto 0);
	pc_src 			:	in std_logic_vector(1 downto 0);

	--ALU control signal
	alu_op				:	in std_logic_vector(2 downto 0);


	--register outputs
	EOT_out			:	out std_logic;
	DPCR_out			:	out std_logic_vector(31 downto 0);
	SVOP_out			:	out std_logic_vector(15 downto 0);
	SOP_out			:	out std_logic_vector(15 downto 0);
	--feedback to control
	irq_out			:	out std_logic;
	am					:	out std_logic_vector(1 downto 0);
	opcode			:	out std_logic_vector(5 downto 0)
) ;
end component ; -- 


---------------------------------------------------------------------------------------------------
begin
--- component wiring

t_recop_datapath : recop_datapath
	generic map(
		m_mux_sel_num => 3,
		r_wr_mux_sel_num => 3,
		reg_width	=>	16
	)
	port map(
		clk				=> t_clk, 


		--control signal for EOT, PC and Z registers
		reset_z			=> t_reset_z, 
		wr_z				=> t_wr_z,
		pc_wr_cond_z	=> t_pc_wr_cond_z, 
		pc_wr_cond_p	=> t_pc_wr_cond_p, 
		pc_wr				=> t_pc_wr, 
		set_EOT			=> t_set_EOT, 
		reset_EOT		=> t_reset_EOT, 


		--control signals for Memory, IR and RegFile
		ir_wr				=> t_ir_wr, 
		m_wr				=> t_m_wr, 
		r_wr				=> t_r_wr, 


		--registers control signals
		reset_ER			=> t_reset_ER,
		reset_DPRR		=> t_reset_DPRR,
		reset_DPC		=> t_reset_DPC,
		set_DPC			=> t_set_DPC, 
		wr_SVOP			=> t_wr_SVOP, 
		wr_SOP			=> t_wr_SOP, 
		wr_DPCR			=> t_wr_DPCR,  


		--register inputs for ER and SIP
		ER_in		=> t_ER_in, 
		DPRR_in			=> t_DPRR_in, 
		SIP_in			=> t_SIP_in, 

		--mux control signals
		m_addr_sel		=> t_m_addr_sel, 
		m_data_sel		=> t_m_data_sel, 
		r_rd_sel			=> t_r_rd_sel, 
		r_wr_sel			=> t_r_wr_sel, 
		r_wr_r_sel		=> t_r_wr_r_sel,
		alu_src_A		=> t_alu_src_A, 
		alu_src_B		=> t_alu_src_B, 
		pc_src 			=> t_pc_src, 

		--ALU control signal
		alu_op			=> t_alu_op, 


		--register outputs 
		EOT_out			=> t_EOT_out, 
		DPCR_out			=> t_DPCR_out, 
		SVOP_out			=> t_SVOP_out, 
		SOP_out			=> t_SOP_out,  

		--feedback to control
		irq_out			=>	t_irq_out,
		am					=> t_am, 
		opcode			=> t_opcode 


	);


---------------------------------------------------------------------------------------------------
t_clk_process : process
begin
	t_clk <= '1';
	wait for t_clk_period/2;
	t_clk <= '0';
	wait for t_clk_period/2;
end process;

---------------------------------------------------------------------------------------------------

t_datapath_proc : process
begin
	wait for t_clk_period * 2;
	-- IF1 --NOOP START
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "01";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	CS <= IF1;
	wait for t_clk_period;
	--ID1
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr <= "00";
	t_pc_wr <= '0';
	t_alu_op <= "000";
	CS <= ID1;
	wait for t_clk_period;
	-- EX --NOOP END
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	CS <= EX;
	wait for t_clk_period;
	

	-- IF1 LDR1 START
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "01";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	CS <= IF1;
	wait for t_clk_period;
	--ID1
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr <= "00";
	t_pc_wr <= '0';
	t_alu_op <= "000";
	CS <= ID1;
	wait for t_clk_period;

	-- IF2
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "10";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	CS <= IF2;
	wait for t_clk_period;

	--ID2
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr <= "00";
	t_pc_wr <= '0';
	t_alu_op <= "000";
	CS <= ID2;
	wait for t_clk_period;

	--EX LDR1 END
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	t_r_wr		<= '1';
	t_r_wr_sel <= "100";
	CS <= EX;
	wait for t_clk_period;

	--IF1 AND START
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "01";
	t_pc_wr		<= '1';
	t_alu_op	<= "000";
	t_r_wr		<= '0';
	t_r_wr_sel <= "000";
	CS <= IF1;
	wait for t_clk_period;

	--ID1
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	t_r_wr		<= '0';
	t_r_wr_sel <= "000";
	CS <= ID1;
	wait for t_clk_period;
	
	-- IF2
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "10";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	CS <= IF2;
	wait for t_clk_period;

	--ID2
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr <= "00";
	t_pc_wr <= '0';
	t_alu_op <= "000";
	CS <= ID2;
	wait for t_clk_period;

	--EX AND END
	t_alu_src_A <= "01";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "010";
	t_r_wr		<= '1';
	t_r_wr_sel <= "000";
	t_wr_z		<= '1';
	CS <= EX;
	wait for t_clk_period;	

	-- IF1 LDR1 (REG TYPE) START
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "01";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	t_r_wr		<= '0';
	CS <= IF1;
	wait for t_clk_period;

	--ID1
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	t_r_wr		<= '0';
	t_r_wr_sel <= "000";
	CS <= ID1;
	wait for t_clk_period;


	--EX
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	t_r_wr		<= '0';
	t_r_wr_sel <= "001";
	t_m_addr_sel <= "011";
	CS <= EX;
	wait for t_clk_period;

	--DM LDR2 END
	t_r_wr_sel <= "001";
	t_m_addr_sel <= "011";
	t_r_wr <= '1';
	CS <= DM;
	wait for t_clk_period;
	

	-- IF1 LDR3 (OPER TYPE) START
	t_r_wr_sel <= "000";
	t_m_addr_sel <= "000";

	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "01";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	t_r_wr		<= '0';
	CS <= IF1;
	wait for t_clk_period;

	--ID1
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr		<= "00";
	t_pc_wr		<= '0';
	t_alu_op	<= "000";
	t_r_wr		<= '0';
	t_r_wr_sel <= "000";
	CS <= ID1;
	wait for t_clk_period;

	-- IF2
	t_alu_src_A <= "00";
	t_alu_src_B <= "01";
	t_ir_wr		<= "10";
	t_pc_wr		<= '1';
	t_alu_op		<= "000";
	CS <= IF2;
	wait for t_clk_period;
	
	--ID2
	t_alu_src_A <= "00";
	t_alu_src_B <= "00";
	t_ir_wr <= "00";
	t_pc_wr <= '0';
	t_alu_op <= "000";
	CS <= ID2;
	wait for t_clk_period;
	
	--EX 
	t_r_wr_sel <= "001";
	t_m_addr_sel <= "001";
	CS <= EX;
	wait for t_clk_period;
	--DM
	t_r_wr_sel <= "001";
	t_m_addr_sel <= "001";
	t_r_wr <= '1';
	CS <= DM;
	wait for t_clk_period;


	wait;

end process;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- combinational logic



end architecture;



