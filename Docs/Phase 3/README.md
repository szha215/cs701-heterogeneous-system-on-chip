# CS701 Group 8 ADD-HSoC Phase 3

## HOW TO RUN ON BOARD:

### Compilation and Bottling Station

1. Extract a fresh copy of  the `NoC-HMP_ve57305b` and copy and replace the `NoC-HMP_ve57305b` file given so that the files that are created/edited are placed into their respective directories.
2. Check `vhdl/noc/hmpsoc_config.vhd` that `USE_AJS_RECOP` is set to `1`.
3. Open up Cygwin and change directory to `NoC-HMP_ve57305b/`
4. Type in the console the following: `make`
5. Make sure `SW16` is on.
6. Bottling station simulator should run upon completion.

### SystemJ Program

1. After the compilation and bottling station simulation, run `./run_sysj.sh` to run our simple multi-CD, reactions, ASP calls program (see report for diagram).

### Java Program

1. Move and replace the `asm/src/java_test/rawOutput0.mif` file to `asm/recop_src`.
2. Run `./run_java.sh` to run Java API tests and JOP vs ASP comparisons.

All modifications to provided code are tagged with `-- AJS`.

## SIMULATIONS

See Phase 1 and 2 submissions.