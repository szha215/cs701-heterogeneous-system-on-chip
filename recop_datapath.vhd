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
	resetZ			:	in std_logic;
	PCWriteCond		:	in std_logic;
	PCWrite			:	in std_logic;
	SetEOT			:	in std_logic;
	ResetEOT			:	in std_logic;


	--memory and register controls
	IRWrite			:	in std_logic(1 downto 0);
	MemWrite			:	in std_logic;
	RegWrite			:	in std_logic;	

	--register inputs for ER and SIP
	resetER_in		:	in std_logic;
	SIP_in			:	in	std_logic(reg_width - 1 downto 0);

	--mux control signals
	MemAddSel		:	in std_logic_vector(1 downto 0);
	MemDataSel		:	in std_logic_vector(1 downto 0);
	RegRdSel			:	in std_logic;
	RegWrSel			:	in std_logic_vector(2 downto 0);
	ALUSrcA_Sel		:	in std_logic_vector(1 downto 0);
	ALUSrcB_Sel		:	in std_logic_vector(1 downto 0);

	--ALU control signal
	ALUOp				:	in std_logic_vector(2 downto 0);


	--register outputs
	EOT_out			:	out std_logic;
	DPCR_out			:	out std_logic_vector(31 downto 0);
	SVOP_out			:	out std_logic_vector(15 downto 0);
	SOP_out			:	out std_logic_vector(15 downto 0); 

	--feedback to control
	ins_out			:	out std_logic_vector(7 downto 0)

) ;
end entity ; -- 


architecture behaviour of recop_datapath is

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



