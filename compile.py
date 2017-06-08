# This script will compile, link .cpp files using SystemC compiler in the current directory
# and copy a command into your clipboard.
# The command will start simulation, add waves of interest, and run for a time of interest.
# Author: John Zhang
# Feel free to edit, redistribute.

import sys
from subprocess import check_call, CalledProcessError

    
def asp():
    args = []

    # start simulation without optimisation
    args.append('vsim -c -novopt work.test_asp -do')
    args.append('"add wave -position insertpoint')

    # waves to add
    args.append('sim:/asp/clock.m_cur_val')
    args.append('sim:/asp/t_reset')
    args.append('sim:/asp/t_valid')
    args.append('sim:/asp/t_data_in')
    args.append('sim:/asp/t_busy')
    args.append('sim:/asp/my_asp/current_state')
    args.append('sim:/asp/my_asp/A')
    args.append('sim:/asp/my_asp/B')
    args.append('sim:/asp/my_asp/op_code')
    args.append('sim:/asp/t_res_ready')
    args.append('sim:/asp/t_data_out')

    # run duration
    args.append('; run 1 us"')

    # concatenate into a single string
    txt = ' '.join(args)

    return txt

def ani():
    args = []

    args.append('vsim -novopt work.test_ani;')

    args.append('add wave -position insertpoint')  # GLOBAL
    args.append('sim:/test_ani/t_clk')
    args.append('sim:/test_ani/t_reset')
    args.append('-radix binary sim:/test_ani/t_tdm_slot')

    args.append('; add wave -position insertpoint -color mediumslateblue')  # NoC incoming
    args.append('-radix hexadecimal sim:/test_ani/t_d_from_noc')

    args.append('; add wave -position insertpoint -color darkorchid')  # ANI
    # args.append('sim:/test_ani/t_ani/s_inc_wr_en')  # push to incoming queue
    # args.append('sim:/test_ani/t_ani/incoming_fifo/queue')
    # args.append('sim:/test_ani/t_ani/s_inc_empty')
    # args.append('sim:/test_ani/t_ani/s_inc_full')
    # args.append('sim:/test_ani/t_ani/s_inc_rd_en')  # pop to ASP
    args.append('-radix hexadecimal sim:/test_ani/t_d_to_asp')
    args.append('sim:/test_ani/t_asp_valid')
    # args.append('sim:/test_ani/t_ani/s_out_wr_en')
    # args.append('sim:/test_ani/t_ani/s_out_empty')
    args.append('sim:/test_ani/t_ani/s_out_rd_en')

    args.append('; add wave -position insertpoint -color mediumslateblue')  # NoC outgoing
    args.append('-radix hexadecimal sim:/test_ani/t_d_to_noc')

    args.append('; add wave -position insertpoint -color gold')  # ASP ports
    args.append('sim:/test_ani/t_asp_busy')
    args.append('sim:/test_ani/t_asp_res_ready')
    args.append('-radix hexadecimal sim:/test_ani/t_d_from_asp')

    args.append('; add wave -position insertpoint -color coral')  # ASP control
    # args.append('sim:/test_ani/t_asp/reg_a/registers')
    # args.append('sim:/test_ani/t_asp/reg_b/registers')
    # args.append('sim:/test_ani/t_asp/s_B')
    args.append('-radix hexadecimal sim:/test_ani/t_asp/s_op_code')
    # args.append('sim:/test_ani/t_asp/s_invoke_en')
    args.append('sim:/test_ani/t_asp/CS')
    # args.append('sim:/test_ani/t_asp/NS')
    # args.append('sim:/test_ani/t_asp/pointer_start_addr_ld')
    args.append('sim:/test_ani/t_asp/rd_pointer_sel')

    args.append('; add wave -position insertpoint -color mediumseagreen')  # ASP datapath
    args.append('sim:/test_ani/t_asp/s_pointer')
    args.append('-radix hexadecimal sim:/test_ani/t_asp/s_start_addr')
    args.append('sim:/test_ani/t_asp/s_end_addr')
    # args.append('sim:/test_ani/t_asp/rd_pointer_inc_en')
    # args.append('sim:/test_ani/t_asp/aveage_block/s_values')
    args.append('sim:/test_ani/t_asp/s_reg_out sim:/test_ani/t_asp/s_reg_a_out sim:/test_ani/t_asp/s_reg_b_out')

    args.append('; add wave -position insertpoint -color cadetblue')  # ASP datapath2
    args.append('-radix hexadecimal sim:/test_ani/t_asp/aveage_block/s_avg')
    args.append('sim:/test_ani/t_asp/s_calc_res')
    args.append('sim:/test_ani/t_asp/s_mac_res')

    args.append('; add wave -position insertpoint -color coral')  # ASP control
    args.append('sim:/test_ani/t_asp/reg_a_ld')
    args.append('sim:/test_ani/t_asp/reg_b_ld')

    args.append('; add wave -position insertpoint -color mediumseagreen')  # ASP datapath
    args.append('-radix hexadecimal sim:/test_ani/t_asp/s_addr_to_store')
    args.append('sim:/test_ani/t_asp/s_d_to_store')
    args.append('sim:/test_ani/t_asp/s_words_to_send')
    args.append('sim:/test_ani/t_asp/s_packet_id')
    args.append('sim:/test_ani/t_asp/s_words_sent')
    args.append('sim:/test_ani/t_asp/s_d_out')
    args.append('sim:/test_ani/t_asp/wr_pointer_sel')
    args.append('sim:/test_ani/t_asp/s_wr_pointer')
    # args.append('sim:/test_ani/t_asp/reg_a/rd_reg1 sim:/test_ani/t_asp/reg_a/rd_reg2

    args.append('; run 3.6 us')

    txt = ' '.join(args)

    return txt

def alu():
    args = []

    args.append('vsim -novopt work.test_alu;')
    args.append('add wave -position insertpoint -radix hexadecimal')

    args.append('sim:/test_alu/t_clk')
    args.append('sim:/test_alu/t_data_A')
    args.append('sim:/test_alu/t_data_B')
    args.append('sim:/test_alu/t_alu_op')
    args.append('sim:/test_alu/t_overflow')
    args.append('sim:/test_alu/t_zero')
    args.append('sim:/test_alu/t_data_out')

    args.append('; run 400 ns')

    txt = ' '.join(args)

    return txt

def mult():
    args = []

    args.append('vsim -novopt work.test_multiplier;')
    args.append('add wave -position insertpoint -radix unsigned')

    args.append('sim:/test_multiplier/t_clk')
    args.append('sim:/test_multiplier/t_a')
    args.append('sim:/test_multiplier/t_b')
    args.append('sim:/test_multiplier/t_res')

    args.append('; run 200 ns')

    txt = ' '.join(args)

    return txt

def avg():
    args = []

    args.append('vsim -novopt work.test_average_filter;')
    args.append('add wave -position insertpoint -radix hexadecimal')

    args.append('sim:/test_average_filter/t_clk')
    args.append('sim:/test_average_filter/t_reset')
    args.append('sim:/test_average_filter/filter/s_count')
    args.append('sim:/test_average_filter/t_pointer')
    args.append('sim:/test_average_filter/t_data')
    args.append('sim:/test_average_filter/filter/s_values')
    args.append('sim:/test_average_filter/t_wr_pointer')
    args.append('sim:/test_average_filter/reg_a_ld')
    args.append('sim:/test_average_filter/filter/s_sum')
    args.append('sim:/test_average_filter/t_avg')

    args.append('; run 600 ns')

    txt = ' '.join(args)

    return txt

def copy_to_clipboard(arg):

    if (arg.lower() == "asp"):
        txt = asp()  # ASP only
    elif (arg.lower() == "ani"):
        txt = ani()  # ANI and ASP
    elif (arg.lower() == "alu"):
        txt = alu()
    elif (arg.lower() == "mult"):
        txt = mult()
    elif (arg.lower() == "avg"):
        txt = avg()
    else:
        print '\n***BAD ARGUMENT: "asp", "ani" or "alu" only'
        exit()

    # copy to clipboard
    cmd = 'echo ' + txt.strip() + '|clip'
    return check_call(cmd, shell=True)

def compile_and_link():

    compile_list = []

    # compile_list.append('./altera_mf/altera_mf_components.vhd')
    # compile_list.append('./altera_mf/altera_mf.vhd')
    compile_list.append('./reg_file.vhd')
    compile_list.append('./work/HMPSoC_config.vhd')
    compile_list.append('./work/min_ports_pkg.vhd')

    compile_list.append('./fake_tdm_counter.vhd')
    compile_list.append('./fake_jop.vhd')
    compile_list.append('./ani.vhd')
    compile_list.append('./asp.vhd')
    compile_list.append('./test_ani.vhd')
    # compile_list.append('./test_asp.vhd')

    compile_list.append('./alu.vhd')
    compile_list.append('./test_alu.vhd')

    compile_list.append('./multiplier.vhd')
    compile_list.append('./test_multiplier.vhd')

    compile_list.append('./average_filter.vhd')
    compile_list.append('./test_average_filter.vhd')

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