library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all

use work.all;
use work.mux_pkg.all;

entity recop_datapath is
generic(
	
	constant reg_width : positive := 16
);


port (
	clk				:	in std_logic;


	--control signal for EOT, PC and Z registers
	reset_z			:	in std_logic;
	pc_wr_cond		:	in std_logic;
	pc_wr				:	in std_logic;
	set_EOT			:	in std_logic;
	reset_EOT		:	in std_logic;


	--control signals for Memory, IR and RegFile
	ir_wr				:	in std_logic(1 downto 0);
	m_wr				:	in std_logic;
	r_wr				:	in std_logic;	


	--registers control signals
	reset_ER			:	in std_logic;
	wr_SVOP			:	in std_logic;
	wr_SOP			:	in std_logic;
	wr_DPCR			:	in std_logic;

	--SIP input
	SIP_in			:	in std_logic;

	--register inputs for ER and SIP
	resetER_in		:	in std_logic;
	SIP_in			:	in	std_logic(reg_width - 1 downto 0);

	--mux control signals
	m_addr_sel		:	in std_logic_vector(1 downto 0);
	m_data_sel		:	in std_logic_vector(1 downto 0);
	r_rd_sel			:	in std_logic;
	r_wr_sel			:	in std_logic_vector(2 downto 0);
	alu_src_A		:	in std_logic_vector(1 downto 0);
	alu_src_B		:	in std_logic_vector(1 downto 0);
	pc_src 			:	in std_logic;

	--ALU control signal
	alu_op				:	in std_logic_vector(2 downto 0);


	--register outputs
	EOT_out			:	out std_logic;
	DPCR_out			:	out std_logic_vector(31 downto 0);
	SVOP_out			:	out std_logic_vector(15 downto 0);
	SOP_out			:	out std_logic_vector(15 downto 0); 

	--feedback to control
	am					:	out std_logic_vector(1 downto 0);
	opcode			:	out std_logic_vector(5 downto 0)
) ;
end entity ; -- 


architecture behaviour of recop_datapath is

constant s_data_width : positive := 16;

signal s_DPCR_in : std_logic_vector(31 downto 0) := (others => '0');

signal s_pc_output, s_mem_data_out, s_ir_upper0 ,s_ir_upper1, s_ir_upper2, s_ir_lower_0, s_SIP_out, s_regfile_out_a, s_regfile_out_b, s_alu_out : std_logic_vector(s_data_width - 1 downto 0) := (others => '0'); 
signal s_m_addr_mux_output, s_m_data_mux_output, s_r_wr_mux_output, s_alu_src_a_mux_output,s_alu_src_b_mux_output,s_r_rd_mux_b_output,s_pc_src_mux_output : std_logic_vector(s_data_width - 1 downto 0) := (others => '0');
signal s_r_rd_mux_a_output : std_logic_vector(3 downto 0) := (others => '0');
signal s_pc_wr_en, s_z_out : std_logic := '0';


signal s_m_addr_mux_inputs : mux_16_bit(3 downto 0) := (0 => s_pc_output, 
																		  1 => s_ir_lower_0, 
																		  2 => s_regfile_out_a, 
																		  3 => s_regfile_out_b);

signal s_m_data_mux_inputs : mux_16_bit(3 downto 0) := (0 => s_pc_output, 
																		  1 => s_ir_lower_0, 
																		  2 => s_regfile_out_a, 
																		  3 => x"0000");

signal s_r_rd_mux_a_inputs : mux_4_bit(1 downto 0) :=  (0 => x"7", 
																		  1 => s_ir_upper1); 
signal s_r_rd_mux_b_inputs : mux_16_bit(1 downto 0):=  (0 => s_regfile_out_a, 
																		  1 => s_ir_lower_0); 

signal s_pc_src_mux_inputs : mux_4_bit(3 downto 0) :=  (0 => s_alu_out, 
																		  1 => s_ir_lower_0
																		  2 => s_regfile_out_b
																		  3 => x"0000"); 

signal s_r_wr_mux_inputs   : mux_16_bit(3 downto 0) 	 := (0 => s_alu_out, 
																		     1 => s_mem_data_out, 
																		     2 => "000000000000000" & resetER_in, 
																		     3 => s_SIP_out);

signal s_alu_src_a_mux_inputs : mux_16_bit(3 downto 0) := (0 => s_pc_output, 
																		  	  1 => s_ir_lower_0, 
																		     2 => s_regfile_out_a, 
																		     3 => s_regfile_out_b);

signal s_alu_src_b_mux_inputs : mux_16_bit(3 downto 0) := (0 => s_regfile_out_b, 
																		  	  1 => x"0001", 
																		     2 => x"0000", 
																		     3 => s_ir_lower_0);


																		  





--------------------------------------------------------------------------------
component ins_reg
	generic(
		constant reg_width 	: 	positive := 16
	);

	port (
		clk		:	in std_logic;
		reset		:	in std_logic;
		data_in	:	in std_logic_vector(reg_width - 1 downto 0);
		ir_wr_en	:	in std_logic_vector(1 downto 0);
		

		upper_0	:	out std_logic_vector(7 downto 0);
		upper_1	:	out std_logic_vector(3 downto 0);
		upper_2	:	out std_logic_vector(3 downto 0);

		lower_0	:	out std_logic_vector(reg_width - 1 downto 0) 			
	) ;
end component;

--------------------------------------------------------------------------------

component data_mem
	generic(
		constant ram_addr_width : positive := 16;
		constant ram_data_width : positive := 16
	);

	port (
		wr_en		:	in std_logic;
		addr		:	in std_logic_vector(ram_addr_width - 1 downto 0);
		data_in	:	in std_logic_vector(ram_data_width - 1 downto 0);

		data_out	:	out std_logic_vector(ram_data_width - 1 downto 0)		
	) ;
end component;

--------------------------------------------------------------------------------

component reg_file
	generic(
		constant reg_num 	 : positive := 16;
		constant reg_width : positive := 16
	);
	port(	clk			: 	in std_logic;
			reset			: 	in std_logic;
			wr_en			:	in std_logic; 
			rd_reg1		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
			rd_reg2		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
			wr_reg		:	in std_logic_vector(integer(ceil(log2(real(reg_width)))) - 1 downto 0);
			wr_data		: 	in std_logic_vector(reg_width - 1 downto 0);

			data_out_a	:	out std_logic_vector(reg_width - 1 downto 0);
			data_out_b	:	out std_logic_vector(reg_width - 1 downto 0)
			);
end component;

--------------------------------------------------------------------------------

component alu
	port(	
		data_A		:	in std_logic_vector(15 downto 0);
		data_B		:	in std_logic_vector(15 downto 0);
		alu_op		:	in std_logic_vector(2 downto 0);

		data_out		:	out std_logic_vector(15 downto 0);
		zero			:	out std_logic;
		overflow		:	out std_logic
		);
end component;

--------------------------------------------------------------------------------

component gen_reg
	generic(
		constant reg_width : positive := 16
	);
	port(
		clk		:	in std_logic;
		reset		:	in std_logic;
		wr_en		:	in std_logic;
		data_in	:	in	std_logic_vector(reg_width - 1 downto 0);
		
		data_out :	out std_logic_vector(reg_width - 1 downto 0) 

	);
end component;
--------------------------------------------------------------------------------
component mux_4_bit
	generic(
		constant sel_num 	 : positive := 2
	);
	port(	inputs 	: in mux_4_bit_arr(2 ** sel_num - 1 downto 0);
			sel		: in std_logic_vector(sel_num - 1 downto 0);
			
			output	: out std_logic_vector(3 downto 0)
	);
end component;
--------------------------------------------------------------------------------
component mux_16_bit
	generic(
		constant sel_num 	 : positive := 2
	);
	port(	inputs 	: in mux_16_bit_arr(2 ** sel_num - 1 downto 0);
			sel		: in std_logic_vector(sel_num - 1 downto 0);
			
			output	: out std_logic_vector(15 downto 0)
	);
end component;

begin

memory : data_mem
	generic map(
		ram_addr_width => s_ram_addr_width,
		ram_data_width => s_data_width
	)
	port (
		wr_en 	=> m_wr,
		addr		=>	s_m_addr_mux_output,
		data_in 	=> s_m_data_mux_output,
		data_out => s_mem_data_out
	);

ir : ins_reg
	generic map(
		reg_width => s_data_width
	)
	port map(
		clk		=>	clk,
		reset 	=> '0',
		data_in 	=> s_mem_data_out,
		ir_wr_en => ir_wr,

		upper_0 	=> s_ir_upper0,
		upper_1 	=> s_ir_upper1,
		upper_2 	=> s_ir_upper2,

		lower_0 	=> s_ir_lower_0
	);

regfile : reg_file
	generic map(
		reg_num		=> s_regfile_regnum,
		reg_width 	=> s_data_width
	)
	port map(
		clk 			=> clk,
		reset 		=> '0',
		wr_en 		=> r_wr,
		rd_reg1 		=> s_r_rd_mux_a_output
		rd_reg2 		=> s_ir_upper2,
		wr_reg 		=> s_ir_upper1,
		wr_data 		=> s_r_wr_mux_output,

		data_out_a 	=> s_regfile_out_a,
		data_out_b 	=> s_regfile_out_b
	);

alu : alu
	port map(
		data_A	=>	s_alu_src_a_mux_output,
		data_B	=>	s_alu_src_b_mux_output,
		alu_op 	=>	alu_op,

		data_out => s_alu_out,
		zero		=>	s_alu_zero,
		overflow => s_alu_overflow
	);

SVOP : gen_reg
	generic map(
		reg_width => s_data_width
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => wr_SVOP,

		data_in => s_regfile_out_a,
		data_out => SVOP_out

	);

SOP : gen_reg
	generic map(
		reg_width => s_data_width
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => wr_SOP,

		data_in => s_regfile_out_a,
		data_out => SOP_out

	);

DPCR : gen_reg
	generic map(
		reg_width => s_data_width * 2
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => wr_DPCR,

		data_in => s_DPCR_in,
		data_out => DPCR_out

	);

SIP : gen_reg
	generic map(
		reg_width => 1
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => clk,

		data_in => SIP_in,
		data_out => s_SIP_out
	);


PC : gen_reg
	generic map(
		reg_width => 16
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => s_pc_wr_en,

		data_in => s_pc_src_mux_output,
		data_out => s_pc_output
	);

m_addr_mux : mux_16_bit
	generic map(
		sel_num => 2
	)
	port map(
		inputs 	=> s_m_addr_mux_inputs,
		sel		=>	m_addr_sel,

		output	=> s_m_addr_mux_output
	);

m_data_mux : mux_16_bit
	generic map(
		sel_num => 2
	)
	port map(
		inputs 	=> s_m_data_mux_inputs,
		sel		=> m_data_sel,

		output	=>	s_m_data_mux_output
	);

r_rd_mux_a : mux_4_bit
	generic map(
		sel_num => 1
	)
	port map(
		inputs	=>	s_r_rd_mux_a_inputs,
		sel		=>	r_rd_sel,

		output	=> s_r_rd_mux_a_output

	);

r_rd_mux_b : mux_16_bit
	generic map(
		sel_num => 1
	)
	port map(
		inputs	=>	s_r_rd_mux_b_inputs,
		sel		=>	r_rd_sel,

		output	=> s_r_rd_mux_b_output
	);

r_wr_mux : mux_16_bit
	generic map(
		sel_num => 2
	)
	port map(
		inputs 	=> s_r_wr_mux_inputs,
		sel		=> r_wr_sel,

		output	=>	s_r_wr_mux_output
	);

alu_src_a_mux : mux_16_bit
	generic map(
		sel_num => 2
	)

	port map(
		inputs	=>	s_alu_src_a_mux_inputs
		sel		=> alu_src_A,

		output	=>	s_alu_src_a_mux_output
	);


alu_src_b_mux : mux_16_bit
	generic map(
		sel_num => 2
	)

	port map(
		inputs	=>	s_alu_src_b_mux_inputs
		sel		=> alu_src_B,

		output	=>	s_alu_src_b_mux_output
	);

pc_src_mux	:	mux_16_bit
	generic map(
		sel_num => 2
	)
	port map(
		inputs 	=> s_pc_src_mux_inputs,
		sel		=>	pc_src,

		output	=> s_pc_src_mux_output

	)

s_DPCR_in <= s_regfile_out_b & s_r_rd_mux_b_output;

s_z_out <= '1' when s_alu_zero = '1' else 
			  '0'	when reset_z = '1' else
			  '0';

s_pc_wr_en <= ((s_z_out and pc_wr_cond) or pc_wr);

EOT_out <= '1' when set_EOT = '1' else
			  '0' when reset_EOT = '1' else
			  '0';

am <= s_ir_upper0(7 downto 6);
opcode <= s_ir_upper0(5 downto 0);
 
end architecture;