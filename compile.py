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
    args.append('add wave -position insertpoint')

    args.append('sim:/test_ani/t_clk')
    args.append('sim:/test_ani/t_reset')
    args.append('-radix unsigned sim:/test_ani/t_tdm_slot')
    args.append('-radix hexadecimal sim:/test_ani/t_d_from_noc')
    args.append('sim:/test_ani/t_ani/s_inc_wr_en')
    # args.append('sim:/test_ani/t_ani/incoming_fifo/queue')
    args.append('sim:/test_ani/t_ani/s_inc_empty')
    args.append('sim:/test_ani/t_ani/s_inc_full')
    args.append('sim:/test_ani/t_ani/s_inc_rd_en')
    args.append('sim:/test_ani/t_d_to_asp')
    args.append('sim:/test_ani/t_asp_valid')
    args.append('sim:/test_ani/t_asp_busy')
    args.append('sim:/test_ani/t_asp/s_A')
    args.append('sim:/test_ani/t_asp/s_B')
    args.append('sim:/test_ani/t_asp/s_op_code')
    args.append('sim:/test_ani/t_asp/CS')
    args.append('sim:/test_ani/t_asp/NS')
    args.append('sim:/test_ani/t_asp_res_ready')
    args.append('sim:/test_ani/t_d_from_asp')
    args.append('sim:/test_ani/t_d_to_noc')

    args.append('; run 1 us')

    txt = ' '.join(args)

    return txt


def copy_to_clipboard(arg):

    if (arg.lower() == "asp"):
        txt = asp()  # ASP only
    elif (arg.lower() == "ani"):
        txt = ani()  # ANI and ASP
    else:
        print '\n***BAD ARGUMENT: "asp" or "ani" only'
        exit()

    # copy to clipboard
    cmd = 'echo ' + txt.strip() + '|clip'
    return check_call(cmd, shell=True)

def compile_and_link():

    compile_list = []

    # compile_list.append('./altera_mf/altera_mf_components.vhd')
    # compile_list.append('./altera_mf/altera_mf.vhd')
    compile_list.append('./fifo.vhd')
    compile_list.append('./mega_fifo.vhd')

    compile_list.append('./ani.vhd')
    compile_list.append('./asp.vhd')
    compile_list.append('./test_ani.vhd')
    # compile_list.append('./test_asp.vhd')


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