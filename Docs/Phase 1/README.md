# CS701 Group 8 Phase 1

## ASP & ANI

### How to simulate:

1. Change directory to `/CS701_g8_phase1/`
2. Run the batch file `compile.bat ARG` in command line console. The supported list of `ARG` is :  `ani`, `mult`, `avg`. Argument indicates the individual part of ASP/ANI that you want to test. 
   1. `ani` argument will copy the combination of ASP and ANI waveforms into your clipboard. (This step assumes that the desktop already has python installed)
3. After compilation, paste the commands into the Modelsim console and enter. 
4. If you encounter `failed to load altera_mf library` error. Change the `altera_mf` library directory to the `altera_mf` folder provided in the zip file. And then compile the `.vhd` files in the `altera_mf` folder. 
5. For the purpose of seeing waveforms, `N`, the length of vectors A and B is 8. This can be easily changed by changing the generic map in `test_ani.vhd`.

### How to run on DE2 board (Run simulation first to compare results)

1. Open fake_jop.vhd and test_ani.vhd to see what's going on in detail
2. Connect DE2 Board to Desktop.
3. Open `group8.qpf` Quartus project file.
4. Top level should be test_asp, open it to see block connectivity.
5. Open Programmer, and press program.
6. Refer to `fake_jop.vhd` for detailed instructions.
7. Use **Switches 2..0** to choose a command, press **Key 3** to activate.
8. Use Key 0 to reset 7 seg display and ANI.
9. Returned packet will be displayed on 7 seg display. Only the newest packet will be shown.

Switches:

`000 = Store Reset` (we realised that this doesn't work at the last minute)
`001 = Store B[1] to B[6]`, expected result: `0xC440 0001`
`010 = Store A[0] to A[7]`, expected result: `0xC840 0001`
`011 = XOR A[0] to A[5]`, expected result: `0xC080 0FDF`
`100 = MAC [2] to [7]`, expected result: `0xC902 0000 `(data = 0 because the most sinificant packet is supposed to be `0`, see simulation)
`101 = AVE A`, expected result: `0xC540 0001`
`110 = XOR B[2] to B[6]`, expected result: `0xC9C0 0109`
`111 = AVE B`, expected result: `0xC180 0001`

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