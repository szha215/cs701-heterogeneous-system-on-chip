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
    args.append('sim:/test_alu/t_opcode')


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


def copy_to_clipboard(arg):

    if (arg.lower() == "alu"):
        txt = alu()  # ALU
    elif (arg.lower() == "reg_file"):
        txt = reg_file()  # REG_FILE

    elif (arg.lower() == "mux"):
        txt = mux() #MUX

    else:
        print '\n***BAD ARGUMENT: "asp" or "ani" only'
        exit()

    # copy to clipboard
    cmd = 'echo ' + txt.strip() + '|clip'
    return check_call(cmd, shell=True)

def compile_and_link():

    compile_list = []
    compile_list.append('./alu.vhd')
    compile_list.append('./test_alu.vhd')
    compile_list.append('./reg_file.vhd')
    compile_list.append('./test_reg_file.vhd')
    compile_list.append('./mux.vhd')
    compile_list.append('./test_mux.vhd')

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