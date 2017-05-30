# CS701 Group 8 ADD-HSoC Phase 2

## HOW TO RUN ON BOARD:

1. Extract a fresh copy of  the `NoC-HMP_ve57305b` and copy and replace the `NoC-HMP_ve57305b` file given so that the files that are created/edited are placed into their respective directories
2. Open up Cygwin and change directory to `NoC-HMP_ve57305b/`
3. Type in the console the following: `make P1=test P2=group8 P3=PacketSender`
4. Wait for compile and refer to `recop_asp_jop_integration` for details on results.

## TEST BENCH FOR NOC

1. Open up ModelSim

2. Change directory to  `NoC-HMP_ve57305b/simulation/`

3. Type in the console the following : `do jni_ani.do`, it does include RNI as well.

4. Refer to `rni_jni_ani_simulation` for details on results.

   ​