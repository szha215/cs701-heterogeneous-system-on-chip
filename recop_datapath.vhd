library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all

entity recop_datapath is
generic(
	
	constant reg_width : positive := 16
);


port (
	clk		:	in std_logic;


	--control signal for EOT, PC and Z registers
	resetZ		:	in std_logic;
	PCWriteCond	:	in std_logic;
	PCWrite		:	in std_logic;
	SetEOT		:	in std_logic;
	ResetEOT		:	in std_logic;


	--memory and register controls
	IRWrite		:	in std_logic(1 downto 0);
	MemWrite		:	in std_logic;
	RegWrite		:	in std_logic;	

	--register inputs for ER and SIP
	resetER_in	:	in std_logic;
	SIP_in		:	in	std_logic(reg_width - 1 downto 0);

	--mux control signals
	MemAddSel		:	in std_logic_vector(1 downto 0);
	MemDataSel		:	in std_logic_vector(1 downto 0);
	RegRdSel			:	in std_logic;
	RegWrSel			:	in std_logic_vector(2 downto 0);
	ALUSrcA_Sel		:	in std_logic_vector(1 downto 0);
	ALUSrcB_Sel		:	in std_logic_vector(1 downto 0);

	--ALU control signal
	ALUOp				:	in std_logic_vector(1 downto 0);



) ;
end entity ; -- 