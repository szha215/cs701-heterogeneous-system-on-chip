-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "05/03/2017 12:01:34"
                                                            
-- Vhdl Test Bench template for design  :  recop_control
-- 
-- Simulation tool : ModelSim (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY recop_control_vhd_tst IS
END recop_control_vhd_tst;
ARCHITECTURE recop_control_arch OF recop_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL alu_src_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL alu_src_B : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL am : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL clk : STD_LOGIC;
SIGNAL ir_wr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL irq_flag : STD_LOGIC;
SIGNAL m_addr_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL m_data_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL m_wr : STD_LOGIC;
SIGNAL opcode : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL pc_src : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL pc_wr : STD_LOGIC;
SIGNAL pc_wr_cond_p : STD_LOGIC;
SIGNAL pc_wr_cond_z : STD_LOGIC;
SIGNAL r_rd_sel : STD_LOGIC;
SIGNAL r_wr : STD_LOGIC;
SIGNAL r_wr_d_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL r_wr_r_sel : STD_LOGIC;
SIGNAL reset_DPC : STD_LOGIC;
SIGNAL reset_DPCR : STD_LOGIC;
SIGNAL reset_DPRR : STD_LOGIC;
SIGNAL reset_EOT : STD_LOGIC;
SIGNAL reset_ER : STD_LOGIC;
SIGNAL reset_Z : STD_LOGIC;
SIGNAL set_DPC : STD_LOGIC;
SIGNAL set_EOT : STD_LOGIC;
SIGNAL wr_DPCR : STD_LOGIC;
SIGNAL wr_SOP : STD_LOGIC;
SIGNAL wr_SVOP : STD_LOGIC;
SIGNAL wr_Z : STD_LOGIC;
COMPONENT recop_control
	PORT (
	alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	alu_src_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	alu_src_B : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	am : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	clk : IN STD_LOGIC;
	ir_wr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	irq_flag : IN STD_LOGIC;
	m_addr_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	m_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	m_wr : OUT STD_LOGIC;
	opcode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
	pc_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	pc_wr : OUT STD_LOGIC;
	pc_wr_cond_p : OUT STD_LOGIC;
	pc_wr_cond_z : OUT STD_LOGIC;
	r_rd_sel : OUT STD_LOGIC;
	r_wr : OUT STD_LOGIC;
	r_wr_d_sel : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	r_wr_r_sel : OUT STD_LOGIC;
	reset_DPC : OUT STD_LOGIC;
	reset_DPCR : OUT STD_LOGIC;
	reset_DPRR : OUT STD_LOGIC;
	reset_EOT : OUT STD_LOGIC;
	reset_ER : OUT STD_LOGIC;
	reset_Z : OUT STD_LOGIC;
	set_DPC : OUT STD_LOGIC;
	set_EOT : OUT STD_LOGIC;
	wr_DPCR : OUT STD_LOGIC;
	wr_SOP : OUT STD_LOGIC;
	wr_SVOP : OUT STD_LOGIC;
	wr_Z : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : recop_control
	PORT MAP (
-- list connections between master ports and signals
	alu_op => alu_op,
	alu_src_A => alu_src_A,
	alu_src_B => alu_src_B,
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
	reset_DPC => reset_DPC,
	reset_DPCR => reset_DPCR,
	reset_DPRR => reset_DPRR,
	reset_EOT => reset_EOT,
	reset_ER => reset_ER,
	reset_Z => reset_Z,
	set_DPC => set_DPC,
	set_EOT => set_EOT,
	wr_DPCR => wr_DPCR,
	wr_SOP => wr_SOP,
	wr_SVOP => wr_SVOP,
	wr_Z => wr_Z
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
WAIT;                                                        
END PROCESS always;                                          
END recop_control_arch;
