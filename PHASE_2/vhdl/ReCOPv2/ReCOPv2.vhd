-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 15.1.1 Build 189 12/02/2015 SJ Lite Edition"
-- CREATED		"Wed May 25 22:16:34 2016"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
USE ieee.numeric_std.all;

LIBRARY work;

ENTITY ReCOPv2 IS 
GENERIC (recop_id : INTEGER := 0
		);
	PORT
	(
		inclk0 :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		debug :  IN  STD_LOGIC;
		button :  IN  STD_LOGIC;
		er_sw :  IN  STD_LOGIC;
		er_btn :  IN  STD_LOGIC;
		dispatched :  IN  STD_LOGIC;
		dispatched_io :  IN  STD_LOGIC;
		jop_free :  IN  STD_LOGIC;
		dprr :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		sip :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		eot :  OUT  STD_LOGIC;
		z_flag :  OUT  STD_LOGIC;
		dprr_ack :  OUT  STD_LOGIC;
		dpcr :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		sop :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		svop :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ReCOPv2;

ARCHITECTURE bdf_type OF ReCOPv2 IS 

COMPONENT registers
GENERIC (recop_id : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 dpcr_lsb_sel : IN STD_LOGIC;
		 dpcr_wr : IN STD_LOGIC;
		 er_wr : IN STD_LOGIC;
		 er_clr : IN STD_LOGIC;
		 eot_wr : IN STD_LOGIC;
		 eot_clr : IN STD_LOGIC;
		 svop_wr : IN STD_LOGIC;
		 sop_wr : IN STD_LOGIC;
		 dpcr_io_wr : IN STD_LOGIC;
		 dispatched : IN STD_LOGIC;
		 dispatched_io : IN STD_LOGIC;
		 jop_free : IN STD_LOGIC;
		 dprr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ir_operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 r7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sip : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 er : OUT STD_LOGIC;
		 eot : OUT STD_LOGIC;
		 dpcr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 dprr_int : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 sip_r : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sop : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 svop : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT regfile
	PORT(clk : IN STD_LOGIC;
		 init : IN STD_LOGIC;
		 ld_r : IN STD_LOGIC;
		 er_temp : IN STD_LOGIC;
		 aluout : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dm_out : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dprr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ir_operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rf_input_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 rz_max : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 sel_x : IN integer range 0 to 15;
		 sel_z : IN integer range 0 to 15;
		 sip_hold : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 r7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rx : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rz : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem_mux
	PORT(ir_operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 mem_addr_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT controlunit
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 z_flag : IN STD_LOGIC;
		 debug : IN STD_LOGIC;
		 continue : IN STD_LOGIC;
		 dpr_present : IN STD_LOGIC;
		 pm_dataout : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dm_wr : OUT STD_LOGIC;
		 alu_op2_sel : OUT STD_LOGIC;
		 ld_r : OUT STD_LOGIC;
		 dpcr_lsb_sel : OUT STD_LOGIC;
		 dpcr_wr : OUT STD_LOGIC;
		 clr_z_flag : OUT STD_LOGIC;
		 er_clr : OUT STD_LOGIC;
		 eot_wr : OUT STD_LOGIC;
		 eot_clr : OUT STD_LOGIC;
		 svop_wr : OUT STD_LOGIC;
		 sop_wr : OUT STD_LOGIC;
		 dpcr_io_wr : OUT STD_LOGIC;
		 alu_op1_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 alu_operation : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 dm_addr_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 dm_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 ir_operand : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 pm_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rf_input_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		 sel_x : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 sel_z : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT continue_button
	PORT(clk : IN STD_LOGIC;
		 button : IN STD_LOGIC;
		 continue : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT max
	PORT(operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rz_max : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(clk : IN STD_LOGIC;
		 alu_op2_sel : IN STD_LOGIC;
		 clr_z_flag : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 alu_op1_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 alu_operation : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 ir_operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 rz : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 z_flag : OUT STD_LOGIC;
		 z_flag_hack : OUT STD_LOGIC;
		 alu_result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT prog_mem
GENERIC (recop_id : INTEGER
			);
	PORT(clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT data_mem
	PORT(wren : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dm_data_mux
	PORT(dm_data_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 ir_operand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Rx : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 dm_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	data_mem_addr :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	dprr_int :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	prog_mem_addr :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	z_flag_ALTERA_SYNTHESIZED :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_48 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_49 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_50 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_51 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_35 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_36 :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_40 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_52 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_42 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_45 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
signal sel_x_int : integer range 0 to 15;
signal sel_z_int : integer range 0 to 15;

BEGIN 



b2v_inst : registers
GENERIC MAP(recop_id => recop_id
			)
PORT MAP(clk => inclk0,
		 reset => reset,
		 dpcr_lsb_sel => SYNTHESIZED_WIRE_0,
		 dpcr_wr => SYNTHESIZED_WIRE_1,
		 er_wr => SYNTHESIZED_WIRE_48,
		 er_clr => SYNTHESIZED_WIRE_3,
		 eot_wr => SYNTHESIZED_WIRE_4,
		 eot_clr => SYNTHESIZED_WIRE_5,
		 svop_wr => SYNTHESIZED_WIRE_6,
		 sop_wr => SYNTHESIZED_WIRE_7,
		 dpcr_io_wr => SYNTHESIZED_WIRE_8,
		 dispatched => dispatched,
		 dispatched_io => dispatched_io,
		 jop_free => jop_free,
		 dprr => dprr,
		 ir_operand => SYNTHESIZED_WIRE_49,
		 r7 => SYNTHESIZED_WIRE_10,
		 rx => SYNTHESIZED_WIRE_50,
		 sip => sip,
		 eot => eot,
		 dpcr => dpcr,
		 dprr_int => dprr_int,
		 sip_r => SYNTHESIZED_WIRE_21,
		 sop => sop,
		 svop => svop);


b2v_inst1 : regfile
PORT MAP(clk => inclk0,
		 init => reset,
		 ld_r => SYNTHESIZED_WIRE_12,
		 er_temp => SYNTHESIZED_WIRE_48,
		 aluout => SYNTHESIZED_WIRE_14,
		 dm_out => SYNTHESIZED_WIRE_15,
		 dprr => dprr_int,
		 ir_operand => SYNTHESIZED_WIRE_49,
		 rf_input_sel => SYNTHESIZED_WIRE_17,
		 rz_max => SYNTHESIZED_WIRE_18,
		 sel_x => sel_x_int,
		 sel_z => sel_z_int,
		 sip_hold => SYNTHESIZED_WIRE_21,
		 r7 => SYNTHESIZED_WIRE_10,
		 rx => SYNTHESIZED_WIRE_50,
		 rz => SYNTHESIZED_WIRE_51);

sel_x_int <= to_integer(unsigned(SYNTHESIZED_WIRE_19));
sel_z_int <= to_integer(unsigned(SYNTHESIZED_WIRE_20));

b2v_inst10 : mem_mux
PORT MAP(ir_operand => SYNTHESIZED_WIRE_49,
		 mem_addr_sel => SYNTHESIZED_WIRE_23,
		 Rx => SYNTHESIZED_WIRE_50,
		 Rz => SYNTHESIZED_WIRE_51,
		 mem_addr => data_mem_addr);


b2v_inst11 : controlunit
PORT MAP(clk => inclk0,
		 reset => reset,
		 z_flag => z_flag_ALTERA_SYNTHESIZED,
		 debug => debug,
		 continue => SYNTHESIZED_WIRE_26,
		 dpr_present => dprr_int(31),
		 pm_dataout => SYNTHESIZED_WIRE_27,
		 rx => SYNTHESIZED_WIRE_50,
		 rz => SYNTHESIZED_WIRE_51,
		 dm_wr => SYNTHESIZED_WIRE_42,
		 alu_op2_sel => SYNTHESIZED_WIRE_33,
		 ld_r => SYNTHESIZED_WIRE_12,
		 dpcr_lsb_sel => SYNTHESIZED_WIRE_0,
		 dpcr_wr => SYNTHESIZED_WIRE_1,
		 clr_z_flag => SYNTHESIZED_WIRE_34,
		 er_clr => SYNTHESIZED_WIRE_3,
		 eot_wr => SYNTHESIZED_WIRE_4,
		 eot_clr => SYNTHESIZED_WIRE_5,
		 svop_wr => SYNTHESIZED_WIRE_6,
		 sop_wr => SYNTHESIZED_WIRE_7,
		 dpcr_io_wr => SYNTHESIZED_WIRE_8,
		 alu_op1_sel => SYNTHESIZED_WIRE_35,
		 alu_operation => SYNTHESIZED_WIRE_36,
		 dm_addr_sel => SYNTHESIZED_WIRE_23,
		 dm_data_sel => SYNTHESIZED_WIRE_45,
		 ir_operand => SYNTHESIZED_WIRE_49,
		 pm_addr => prog_mem_addr,
		 rf_input_sel => SYNTHESIZED_WIRE_17,
		 sel_x => SYNTHESIZED_WIRE_19,
		 sel_z => SYNTHESIZED_WIRE_20);


SYNTHESIZED_WIRE_52 <= NOT(inclk0);



b2v_inst16 : continue_button
PORT MAP(clk => inclk0,
		 button => er_btn,
		 continue => SYNTHESIZED_WIRE_32);


b2v_inst17 : continue_button
PORT MAP(clk => inclk0,
		 button => button,
		 continue => SYNTHESIZED_WIRE_26);


b2v_inst2 : max
PORT MAP(operand => SYNTHESIZED_WIRE_49,
		 rz => SYNTHESIZED_WIRE_51,
		 rz_max => SYNTHESIZED_WIRE_18);


SYNTHESIZED_WIRE_48 <= er_sw OR SYNTHESIZED_WIRE_32;


b2v_inst3 : alu
PORT MAP(clk => inclk0,
		 alu_op2_sel => SYNTHESIZED_WIRE_33,
		 clr_z_flag => SYNTHESIZED_WIRE_34,
		 reset => reset,
		 alu_op1_sel => SYNTHESIZED_WIRE_35,
		 alu_operation => SYNTHESIZED_WIRE_36,
		 ir_operand => SYNTHESIZED_WIRE_49,
		 rx => SYNTHESIZED_WIRE_50,
		 rz => SYNTHESIZED_WIRE_51,
		 z_flag => z_flag_ALTERA_SYNTHESIZED,
		 z_flag_hack => SYNTHESIZED_WIRE_40,
		 alu_result => SYNTHESIZED_WIRE_14);



b2v_inst5 : prog_mem
GENERIC MAP(recop_id => recop_id
			)
PORT MAP(clock => SYNTHESIZED_WIRE_52,
		 address => prog_mem_addr(15 DOWNTO 0),
		 q => SYNTHESIZED_WIRE_27);


b2v_inst6 : data_mem
PORT MAP(wren => SYNTHESIZED_WIRE_42,
		 clock => SYNTHESIZED_WIRE_52,
		 address => data_mem_addr(11 DOWNTO 0),
		 data => SYNTHESIZED_WIRE_44,
		 q => SYNTHESIZED_WIRE_15);


b2v_inst9 : dm_data_mux
PORT MAP(dm_data_sel => SYNTHESIZED_WIRE_45,
		 ir_operand => SYNTHESIZED_WIRE_49,
		 pc => prog_mem_addr,
		 Rx => SYNTHESIZED_WIRE_50,
		 dm_data => SYNTHESIZED_WIRE_44);

z_flag <= z_flag_ALTERA_SYNTHESIZED;
dprr_ack <= dprr_int(31);

END bdf_type;
