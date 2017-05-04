library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.all;
use work.mux_pkg.all;

entity recop_datapath is
	generic(
		constant m_mux_sel_num : positive := 3;
		constant r_wr_mux_sel_num : positive := 3;
		constant reg_width : positive := 16
	);


port (
	clk				:	in std_logic;


	--control signal for EOT, PC and Z registers
	reset_z			:	in std_logic;
	wr_z				:	in std_logic;
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
	SIP_in			:	in	std_logic_vector(15 downto 0);

	--mux control signals
	m_addr_sel		:	in std_logic_vector(m_mux_sel_num - 1 downto 0);
	m_data_sel		:	in std_logic_vector(1 downto 0);
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
	DPC_out 			:	out std_logic;

	--feedback to control
	irq_flag			:	out std_logic;
	am					:	out std_logic_vector(1 downto 0);
	opcode			:	out std_logic_vector(5 downto 0)
) ;
end entity ; -- 


architecture behaviour of recop_datapath is

constant s_data_width,s_ram_addr_width,s_regfile_regnum : positive := 16;

signal s_DPCR_in : std_logic_vector(31 downto 0) := (others => '0');

signal s_pc_output, s_mem_data_out, s_ir_lower_0, s_SIP_out, s_regfile_out_a, s_regfile_out_b, s_alu_out : std_logic_vector(s_data_width - 1 downto 0) := (others => '0'); 
signal s_m_addr_mux_output, s_m_data_mux_output, s_r_wr_mux_output, s_alu_src_a_mux_output,s_alu_src_b_mux_output,s_r_rd_mux_b_output,s_pc_src_mux_output : std_logic_vector(s_data_width - 1 downto 0) := (others => '0');
signal s_r_rd_mux_a_output, s_ir_upper1,s_ir_upper2 : std_logic_vector(3 downto 0) := (others => '0');
signal s_DPRR_out : std_logic_vector(s_data_width * 2 - 1 downto 0) := (others => '0');
signal s_ir_upper0 : std_logic_vector(7 downto 0) := (others => '0');
signal s_z_out, s_alu_zero, s_alu_overflow, s_pc_wr_en, s_z_wr_en, s_ER_out : std_logic := '0';
signal s_r_wr_r_mux_output : std_logic_vector(3 downto 0) := (others => '0');

--signal s_m_addr_mux_inputs : mux_16_bit_arr(2 ** m_mux_sel_num - 1 downto 0) := 
--																		 (0 => s_pc_output, 
--																		  1 => s_ir_lower_0, 
--																		  2 => s_regfile_out_a, 
--																		  3 => s_regfile_out_b,
--																		  4 => (x"0" & s_DPRR_OUT(23 downto 12)),
--																		  others => x"0000");

--signal s_m_data_mux_inputs : mux_16_bit_arr(2 ** m_mux_sel_num -1 downto 0) := 
--																		 (0 => s_pc_output, 
--																		  1 => s_ir_lower_0, 
--																		  2 => s_regfile_out_a, 
--																		  3 => ("00000000000000" & s_DPRR_OUT(1 downto 0)),
--																		  others => x"0000");

--signal s_r_rd_mux_a_inputs : mux_4_bit_arr(1 downto 0) :=  (0 => x"7", 
--																		  1 => s_ir_upper1); 
--signal s_r_rd_mux_b_inputs : mux_16_bit_arr(1 downto 0) :=  (0 => s_regfile_out_a, 
--																		  1 => s_ir_lower_0); 

--signal s_pc_src_mux_inputs : mux_16_bit_arr(3 downto 0) :=  (0 => s_alu_out, 
--																		  1 => s_ir_lower_0,
--																		  2 => s_regfile_out_b,
--																		  3 => x"0000"); 

--signal s_r_wr_mux_inputs   : mux_16_bit_arr(2 ** r_wr_mux_sel_num - 1 downto 0) := 
--																			 (0 => s_alu_out, 
--																		     1 => s_mem_data_out, 
--																		     2 => ("000000000000000" & ER_in), 
--																		     3 => s_SIP_out,
--																		     4 => s_ir_lower_0,
--																		     5 => (x"0" & s_DPRR_out(23 downto 12)),
--																		     others => x"0000");

--signal s_alu_src_a_mux_inputs : mux_16_bit_arr(3 downto 0) := (0 => s_pc_output, 
--																		  	  1 => s_ir_lower_0, 
--																		     2 => s_regfile_out_a, 
--																		     3 => s_regfile_out_b);

--signal s_alu_src_b_mux_inputs : mux_16_bit_arr(3 downto 0) := (0 => s_regfile_out_b, 
--																		  	  1 => x"0001", 
--																		     2 => x"0000", 
--																		     3 => s_ir_lower_0);


																		  





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
		clk			:	in std_logic;
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
	port map(
		clk		=> clk,
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
		rd_reg1 		=> s_r_rd_mux_a_output,
		rd_reg2 		=> s_ir_upper2,
		wr_reg 		=> s_r_wr_r_mux_output,
		wr_data 		=> s_r_wr_mux_output,

		data_out_a 	=> s_regfile_out_a,
		data_out_b 	=> s_regfile_out_b
	);

alu_component : alu
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

		data_in => s_regfile_out_b,
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

		data_in => s_regfile_out_b,
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
		reg_width => s_data_width
	)
	port map(
		clk	=> clk,
		reset => '0',
		wr_en => clk,

		data_in => SIP_in,
		data_out => s_SIP_out
	);

DPRR : gen_reg
	generic map(
		reg_width => 32
	)
	port map(
		clk => clk,
		reset => reset_DPRR,
		wr_en => DPRR_in(31),

		data_in => DPRR_in,
		data_out => s_DPRR_out
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


Z : gen_reg
	generic map(
		reg_width => 1
	)
	port map(
		clk => clk,
		reset => reset_z,
		wr_en => s_z_wr_en,

		data_in(0) => '1',
		data_out(0) => s_z_out
	);

ER: gen_reg
	generic map(
		reg_width => 1 
	)
	port map(
		clk => clk,
		reset => reset_ER,
		wr_en => ER_in,

		data_in(0) => ER_in,
		data_out(0) => s_ER_out
	);

EOT: gen_reg
	generic map(
		reg_width => 1
	)
	port map(
		clk => clk,
		reset => reset_EOT,
		wr_en => set_EOT,

		data_in(0) => '1',
		data_out(0) => EOT_out
	);

DPC: gen_reg
	generic map(
		reg_width => 1
	)
	port map(
		clk => clk,
		reset => reset_DPC,
		wr_en => set_DPC,

		data_in(0) => '1',
		data_out(0) => DPC_out
	);

--m_addr_mux : mux_16_bit
--	generic map(
--		sel_num => m_mux_sel_num
--	)
--	port map(
--		inputs 	=> s_m_addr_mux_inputs,
--		sel		=>	m_addr_sel,

--		output	=> s_m_addr_mux_output
--	);

--m_data_mux : mux_16_bit
--	generic map(
--		sel_num => m_mux_sel_num
--	)
--	port map(
--		inputs 	=> s_m_data_mux_inputs,
--		sel		=> m_data_sel,

--		output	=>	s_m_data_mux_output
--	);

--r_rd_mux_a : mux_4_bit
--	generic map(
--		sel_num => 1
--	)
--	port map(
--		inputs	=>	s_r_rd_mux_a_inputs,
--		sel(0)		=>	r_rd_sel,

--		output	=> s_r_rd_mux_a_output

--	);

--r_rd_mux_b : mux_16_bit
--	generic map(
--		sel_num => 1
--	)
--	port map(
--		inputs	=>	s_r_rd_mux_b_inputs,
--		sel(0)		=>	r_rd_sel,

--		output	=> s_r_rd_mux_b_output
--	);

--r_wr_mux : mux_16_bit
--	generic map(
--		sel_num => 3
--	)
--	port map(
--		inputs 	=> s_r_wr_mux_inputs,
--		sel		=> r_wr_sel,

--		output	=>	s_r_wr_mux_output
--	);

--alu_src_a_mux : mux_16_bit
--	generic map(
--		sel_num => 2
--	)

--	port map(
--		inputs	=>	s_alu_src_a_mux_inputs,
--		sel		=> alu_src_A,

--		output	=>	s_alu_src_a_mux_output
--	);


--alu_src_b_mux : mux_16_bit
--	generic map(
--		sel_num => 2
--	)

--	port map(
--		inputs	=>	s_alu_src_b_mux_inputs,
--		sel		=> alu_src_B,

--		output	=>	s_alu_src_b_mux_output
--	);

--pc_src_mux	:	mux_16_bit
--	generic map(
--		sel_num => 2
--	)
--	port map(
--		inputs 	=> s_pc_src_mux_inputs,
--		sel	=>	pc_src,

--		output	=> s_pc_src_mux_output

--	);

s_DPCR_in <= s_regfile_out_b & s_r_rd_mux_b_output;

--s_z_out <= '1' when (s_alu_zero = '1' and wr_z = '1') else 
--			  '0'	when reset_z = '1';
s_z_wr_en <= '1' when (s_alu_zero = '1' and wr_z = '1') else
			 '0';

s_pc_wr_en <= (s_alu_zero and pc_wr_cond_p)  or (pc_wr_cond_z and s_z_out) or pc_wr;

--EOT_out <= '1' when set_EOT = '1' else
--			  '0' when reset_EOT = '1' else
--			  '0';

--DPC_out	<= '1' when set_DPC = '1' else
--				'0' when reset_DPC = '1' else
--				'0';

am <= s_ir_upper0(7 downto 6);
opcode <= s_ir_upper0(5 downto 0);

s_m_addr_mux_output <=
s_pc_output									when m_addr_sel = "000" else
s_ir_lower_0 								when m_addr_sel = "001" else
s_regfile_out_a 							when m_addr_sel = "010" else
s_regfile_out_b 						 	when m_addr_sel = "011" else
(x"0" & s_DPRR_OUT(23 downto 12)) 	when m_addr_sel = "100" else
x"0000";

irq_flag <= s_DPRR_OUT(1);

s_m_data_mux_output <=
s_ir_lower_0								when m_data_sel = "00" else
s_pc_output									when m_data_sel = "01" else
s_regfile_out_b							when m_data_sel = "10" else
("00000000000000" & s_DPRR_OUT(1 downto 0)) when m_data_sel = "11" else
x"0000";

s_r_rd_mux_a_output <=
x"7"											when r_rd_sel = '0' else
s_ir_upper1									when r_rd_sel = '1' else
x"0";

s_r_rd_mux_b_output <= 
s_regfile_out_a							when r_rd_sel = '0' else
s_ir_lower_0								when r_rd_sel = '1' else
x"0000";

s_pc_src_mux_output <=
s_alu_out									when pc_src = "00" else
s_ir_lower_0								when pc_src = "01" else
s_regfile_out_b							when pc_src = "10" else
x"0000";

s_r_wr_mux_output <=
s_alu_out									when r_wr_sel = "000" else
s_mem_data_out								when r_wr_sel = "001" else
("000000000000000" & s_ER_out)			when r_wr_sel = "010" else
s_SIP_out									when r_wr_sel = "011" else
s_ir_lower_0								when r_wr_sel = "100" else
("00000000000000" & s_DPRR_OUT(1 downto 0))	when r_wr_sel = "101" else
x"0000";

s_alu_src_a_mux_output	<=
s_pc_output									when alu_src_A = "00" else
s_ir_lower_0								when alu_src_A = "01" else
s_regfile_out_a							when alu_src_A = "10" else
s_regfile_out_b							when alu_src_A = "11" else
x"0000";

s_alu_src_b_mux_output	<=
s_regfile_out_b							when alu_src_B = "00" else
x"0001"										when alu_src_B = "01" else
x"0000"										when alu_src_B = "10" else
s_ir_lower_0								when alu_src_B = "11" else
x"0000";


s_r_wr_r_mux_output <=
s_ir_upper1									when r_wr_r_sel = '0' else
x"0"											when r_wr_r_sel = '1' else
x"0";

end architecture;