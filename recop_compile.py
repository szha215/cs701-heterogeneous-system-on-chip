# This script will compile, link .cpp files using SystemC compiler in the current directory
# and copy a command into your clipboard.
# The command will start simulation, add waves of interest, and run for a time of interest.
# Author: John Zhang
# Feel free to edit, redistribute.

import sys
from subprocess import check_call, CalledProcessError

    
def alu():
    args = []

    # start simulation without optimisation
    args.append('vsim -c -novopt work.test_alu -do')
    args.append('"add wave -position insertpoint')

    # waves to add
    args.append('sim:/test_alu/t_clk')
    args.append('sim:/test_alu/t_reset')
    args.append('sim:/test_alu/t_overflow')
    args.append('sim:/test_alu/t_zero')
    args.append('sim:/test_alu/t_data_A')
    args.append('sim:/test_alu/t_data_B')
    args.append('sim:/test_alu/t_data_out')
    args.append('sim:/test_alu/t_alu_op')


    # run duration
    args.append('; run 1 us"')

    # concatenate into a single string
    txt = ' '.join(args)

    return txt

def reg_file():
    args = []

    args.append('vsim -novopt work.test_reg_file;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_reg_file/t_clk')
    args.append('sim:/test_reg_file/t_reset')
    args.append('sim:/test_reg_file/t_wr_en')
    args.append('sim:/test_reg_file/t_rd_reg1')
    args.append('sim:/test_reg_file/t_rd_reg2')
    args.append('sim:/test_reg_file/t_wr_reg')
    args.append('sim:/test_reg_file/t_wr_data')
    args.append('sim:/test_reg_file/t_data_out_a')
    args.append('sim:/test_reg_file/t_data_out_b')
    args.append('sim:/test_reg_file/t_reg_file/registers')

    args.append('; run 1 us')

    txt = ' '.join(args)

    return txt

def mux():
    args = []

    args.append('vsim -novopt work.test_mux;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_mux/t_clk')
    args.append('sim:/test_mux/t_inputs_4_bit')
    args.append('sim:/test_mux/t_inputs_16_bit')
    args.append('sim:/test_mux/t_sel_4_bit')
    args.append('sim:/test_mux/t_sel_16_bit')
    args.append('sim:/test_mux/t_output_4_bit')
    args.append('sim:/test_mux/t_output_16_bit')


    args.append('; run 1000 ns')
    return ' '.join(args)

def gen_reg():
    args = []


    args.append('vsim -novopt work.test_gen_reg;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_gen_reg/t_clk')
    args.append('sim:/test_gen_reg/t_reset')
    args.append('sim:/test_gen_reg/t_wr_en')
    args.append('sim:/test_gen_reg/t_data_in')
    args.append('sim:/test_gen_reg/t_data_out')
    args.append('; run 1000 ns')
    return ' '.join(args)

def data_mem():
    args = []
    args.append('vsim -novopt work.test_data_mem;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_data_mem/t_clk')
    args.append('sim:/test_data_mem/t_reset')
    args.append('sim:/test_data_mem/t_wr_en')
    args.append('sim:/test_data_mem/t_addr')
    args.append('sim:/test_data_mem/t_data_in')
    args.append('sim:/test_data_mem/t_data_out')
    args.append('; run 1000 ns')
    return ' '.join(args)

def ins_reg():
    args = []
    args.append('vsim -novopt work.test_ins_reg;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_ins_reg/t_clk')
    args.append('sim:/test_ins_reg/t_reset')
    args.append('sim:/test_ins_reg/t_ir_wr_en')
    args.append('sim:/test_ins_reg/t_data_in')
    args.append('sim:/test_ins_reg/t_lower0')
    args.append('sim:/test_ins_reg/t_upper0')
    args.append('sim:/test_ins_reg/t_upper1')
    args.append('sim:/test_ins_reg/t_upper2')
    args.append('; run 1000 ns')
    return ' '.join(args)
	
	
def recop_control():
    args = []
    args.append('vsim -novopt work.test_recop_control;')

    args.append('add wave -radix unsigned -position insertpoint -color red')
    args.append('sim:/test_recop_control/clk')
    args.append('sim:/test_recop_control/opcode')
    args.append('sim:/test_recop_control/am')
    args.append('sim:/test_recop_control/irq_flag')

    args.append('; add wave -radix unsigned -position insertpoint -color green')
    args.append('sim:/test_recop_control/INSTRUCTION')
    args.append('sim:/test_recop_control/ADDRESS_MODE')
    args.append('sim:/test_recop_control/i1/CS')
    args.append('sim:/test_recop_control/i1/NS')
    
    args.append('; add wave -radix unsigned -position insertpoint -color lightblue')
    args.append('sim:/test_recop_control/m_addr_sel')
    args.append('sim:/test_recop_control/m_data_sel')
    args.append('sim:/test_recop_control/m_wr')
    args.append('sim:/test_recop_control/pc_src')
    args.append('sim:/test_recop_control/pc_wr')
    args.append('sim:/test_recop_control/pc_wr_cond_p')
    args.append('sim:/test_recop_control/pc_wr_cond_z')
    args.append('sim:/test_recop_control/r_rd_sel')
    args.append('sim:/test_recop_control/r_wr')
    args.append('sim:/test_recop_control/r_wr_d_sel')
    args.append('sim:/test_recop_control/r_wr_r_sel')
    args.append('sim:/test_recop_control/reset_dpc')
    args.append('sim:/test_recop_control/reset_dpcr')
    args.append('sim:/test_recop_control/reset_dprr')
    args.append('sim:/test_recop_control/reset_eot')
    args.append('sim:/test_recop_control/reset_er')
    args.append('sim:/test_recop_control/reset_z')
    args.append('sim:/test_recop_control/set_dpc')
    args.append('sim:/test_recop_control/set_eot')
    args.append('sim:/test_recop_control/wr_dpcr')
    args.append('sim:/test_recop_control/wr_sop')
    args.append('sim:/test_recop_control/wr_svop')
    args.append('sim:/test_recop_control/wr_z')
    args.append('; run 1800 ns')

    return ' '.join(args)
	
def recop():
    args = []
    args.append('vsim -novopt work.test_recop;')

    args.append('add wave -position insertpoint -color green')
    args.append('sim:/test_recop/t_clk')

    args.append('; add wave -position insertpoint -color pink')
    args.append('sim:/test_recop/t_recop/control_unit/am')
    args.append('sim:/test_recop/t_recop/control_unit/opcode')
    args.append('sim:/test_recop/t_recop/control_unit/CS')
    
    args.append('; add wave -position insertpoint -color lightblue')
    args.append('sim:/test_recop/t_recop/datapath_unit/memory/addr')
    args.append('sim:/test_recop/t_recop/datapath_unit/memory/data_in')
    args.append('sim:/test_recop/t_recop/datapath_unit/memory/data_out')

    args.append('; add wave -position insertpoint -color gold')
    args.append('sim:/test_recop/t_recop/datapath_unit/regfile/registers')

    args.append('; run 3 us')
    return ' '.join(args)



def datapath():
    args = []
    args.append('vsim -novopt work.test_recop_datapath;')
    args.append('add wave -position insertpoint')

    args.append('sim:/test_recop_datapath/t_clk')
    args.append('sim:/test_recop_datapath/t_reset_z')
    args.append('sim:/test_recop_datapath/t_pc_wr_cond_z')
    args.append('sim:/test_recop_datapath/t_pc_wr_cond_p')
    args.append('sim:/test_recop_datapath/t_pc_wr')
    args.append('sim:/test_recop_datapath/t_set_EOT')
    args.append('sim:/test_recop_datapath/t_reset_EOT')
    args.append('sim:/test_recop_datapath/t_m_wr')
    args.append('sim:/test_recop_datapath/t_r_wr')
    args.append('sim:/test_recop_datapath/t_ir_wr')
    args.append('sim:/test_recop_datapath/t_reset_ER')
    args.append('sim:/test_recop_datapath/t_reset_DPRR')
    args.append('sim:/test_recop_datapath/t_wr_SVOP')
    args.append('sim:/test_recop_datapath/t_wr_SOP')
    args.append('sim:/test_recop_datapath/t_wr_DPCR')
    args.append('sim:/test_recop_datapath/t_ER_in')
    args.append('sim:/test_recop_datapath/t_DPRR_in')
    args.append('sim:/test_recop_datapath/t_SIP_in')
    args.append('sim:/test_recop_datapath/t_m_addr_sel')
    args.append('sim:/test_recop_datapath/t_m_data_sel')
    args.append('sim:/test_recop_datapath/t_r_rd_sel')
    args.append('sim:/test_recop_datapath/t_r_wr_sel')
    args.append('sim:/test_recop_datapath/t_alu_src_A')
    args.append('sim:/test_recop_datapath/t_alu_src_B')
    args.append('sim:/test_recop_datapath/t_pc_src')
    args.append('sim:/test_recop_datapath/t_alu_op')
    args.append('sim:/test_recop_datapath/t_DPRR_out')
    args.append('sim:/test_recop_datapath/t_SVOP_out')
    args.append('sim:/test_recop_datapath/t_SOP_out')
    args.append('sim:/test_recop_datapath/t_EOT_out')
    args.append('sim:/test_recop_datapath/t_DPCR_out')
    args.append('sim:/test_recop_datapath/t_am')
    args.append('sim:/test_recop_datapath/t_opcode')
    args.append('sim:/test_recop_datapath/CS')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_pc_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_ir_lower_0')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_ir_upper0')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_ir_upper1')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_ir_upper2')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_mem_data_out')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_regfile_out_a')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_regfile_out_b')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_alu_out')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_m_addr_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_m_data_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_r_wr_r_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_r_wr_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_r_rd_mux_a_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_alu_src_a_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_alu_src_b_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_pc_src_mux_output')
    args.append('sim:/test_recop_datapath/t_recop_datapath/s_pc_wr_en')
    args.append('sim:/test_recop_datapath/t_recop_datapath/regfile/registers')
    args.append('; run 800 ns')
    return ' '.join(args)



def copy_to_clipboard(arg):

    if (arg.lower() == "alu"):
        txt = alu()  # ALU
    elif (arg.lower() == "reg_file"):
        txt = reg_file()  # REG_FILE

    elif (arg.lower() == "mux"):
        txt = mux() #MUX

    elif(arg.lower() == "gen_reg"):
        txt = gen_reg()

    elif(arg.lower() == "data_mem"):
        txt = data_mem()

    elif(arg.lower() == "ins_reg"):
        txt = ins_reg()
    elif(arg.lower() == "datapath"):
        txt = datapath()

    elif(arg.lower() == "recop_control"):
        txt = recop_control()

    elif(arg.lower() == "recop"):
        txt = recop()

    else:
        print '\n***BAD ARGUMENT: Refer to README or this script for valid arguments'
        exit()

    # copy to clipboard
    cmd = 'echo ' + txt.strip() + '|clip'
    return check_call(cmd, shell=True)



def compile_and_link():

    compile_list = []
    # compile_list.append('./altera_mf/altera_mf_components.vhd')
    # compile_list.append('./altera_mf/altera_mf.vhd')
    compile_list.append('./ajs_pkgs.vhd')
    compile_list.append('./alu.vhd')
    compile_list.append('./test_alu.vhd')
    compile_list.append('./reg_file.vhd')
    compile_list.append('./test_reg_file.vhd')
    compile_list.append('./mux.vhd')
    compile_list.append('./test_mux.vhd')
    compile_list.append('./gen_reg.vhd')
    compile_list.append('./test_gen_reg.vhd')
    compile_list.append('./data_mem.vhd')
    compile_list.append('./test_data_mem.vhd')
    compile_list.append('./ins_reg.vhd')
    compile_list.append('./test_ins_reg.vhd')
    compile_list.append('./recop_control.vhd')
    compile_list.append('./test_recop_control.vhd')
    compile_list.append('./recop_datapath.vhd')
    compile_list.append('./test_recop_datapath.vhd')
    compile_list.append('./recop.vhd')
    compile_list.append('./test_recop.vhd')
    compile_str = ' '.join(compile_list)

    try:
        check_call('vcom -reportprogress 300 -work work ' + compile_str, shell=True)
    except CalledProcessError:
        try:
            check_call('C:\modeltech_10.4c\win32\\vcom.exe -reportprogress 300 -work work ' + compile_str, shell=True)
        except:
            print '\n***COMPILE FAILED'
            exit()
    
def main(arg):
    copy_to_clipboard(arg)
    compile_and_link()
    print("\n***SUCCESS: Paste command into ModelSim console (it's already in your clipboard)")


if __name__ == '__main__':
    main(sys.argv[1])