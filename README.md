# COMPSYS701 Group 8 Phase 1

## ASP & ANI





## ReCOP

### How to simulate:

1. Change into the directory. 
2. Run the batch file `recop_compile.bat ARG` in command line console. The supported list of `ARG` is : `alu`, `reg_file`, `mux`, `gen_reg`, `data_mem`, `ins_reg`, `recop_datapath`, `recop_control`, `recop`. Argument indicates the part of ReCOP(or the ReCOP itself) that you want to test. (This step assumes that the desktop already has python installed)
3. After compilation, paste the commands into the Modelsim console and enter. 
4. If you encounter `failed to load altera_mf library` error. Change the `altera_mf` library directory to the `altera_mf` folder provided in the zip file. And then compile the `.vhd` files in the `altera_mf` folder. 

### Memory Pipeline
- Tested in Modelsim:
- Time before pipelined: $12120 ns$
- Time after pipelined $11520 ns$
- Time difference : $640 ns$
- Speed up: $\frac{640}{12120} =  5.28\%$
- Maximum frequency tested with Quartus is reduced $69MHz$ from $71MHz$. But the number of cycles for each instruction is reduced by one.