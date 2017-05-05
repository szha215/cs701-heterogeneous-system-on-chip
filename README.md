# CS701 Group 8 Phase 1

## ASP & ANI

### How to simulate:

1. Change directory to `/CS701_g8_phase1/`
2. Run the batch file `compile.bat ARG` in command line console. The supported list of `ARG` is : `asp`, `ani`, `alu`, `mult`, `avg`. Argument indicates the individual part of ASP/ANI that you want to test. 
   1. `ani` argument will copy the combination of ASP and ANI waveforms into your clipboard. (This step assumes that the desktop already has python installed)
3. After compilation, paste the commands into the Modelsim console and enter. 
4. If you encounter `failed to load altera_mf library` error. Change the `altera_mf` library directory to the `altera_mf` folder provided in the zip file. And then compile the `.vhd` files in the `altera_mf` folder. 

### Resource Utilisation

|      | LE   | M9K  | DSP  |
| ---- | ---- | ---- | ---- |
| ASP  | 504  | 2    | 2    |
| ANI  | 109  | 2    | 0    |

### Timing Summary

$F_{max} = 78.49MHz$

***Critical Path:*** Output of `altsyncram` to input of calculation result register.


## ReCOP

### How to simulate:

1. Change directory to `/CS701_g8_phase1/`
2. Run the batch file `recop_compile.bat ARG` in command line console. The supported list of `ARG` is : `alu`, `reg_file`, `mux`, `gen_reg`, `data_mem`, `ins_reg`, `recop_datapath`, `recop_control`, `recop`. Argument indicates the individual part of ReCOP(or the ReCOP itself) that you want to test. (This step assumes that the desktop already has python installed)
3. After compilation, paste the commands into the Modelsim console and enter. 
4. If you encounter `failed to load altera_mf library` error. Change the `altera_mf` library directory to the `altera_mf` folder provided in the zip file. And then compile the `.vhd` files in the `altera_mf` folder. 

### Resource Utilisation
|          | LE   | M9K  | DSP  |
| -------- | ---- | ---- | ---- |
| Control  | 92   | 0    | 0    |
| Datapath | 789  | 129  | 0    |
| ReCOP    | 880  | 129  | 0    |

### Timing Summary
$F_{max} = 71.87MHz$
***Critical Path:*** Register file output to PC register output.

### Memory Pipeline
- Tested in Modelsim:
- Time before pipelined: $12120 ns$
- Time after pipelined $11520 ns$
- Time difference : $640 ns$
- Speed up: $\frac{640}{12120} =  5.28\%$
- Maximum frequency tested with Quartus is reduced $69MHz$ from $71MHz$. But the number of cycles for each instruction is reduced by one.