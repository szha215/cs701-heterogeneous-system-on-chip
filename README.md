# C0MPSYS 7O1 Heterogeneous Multiprocessor System on Network-on-Chip 2O17

Design of a CISC Reactive Co-processor (ReCOP), Application Specific Processor (ASP), Java Optimised Processor (JOP, provided) and their network interfaces, interconnected using the Network-on-Chip (NoC) model and Time-division Multiple Access (TDMA) to intercommunicate.

The system consists of:

-  ReCOP(s): Schedules JOP(s) to run Java microcode.
- JOP(s): Runs Java programs, assembled using the SystemJ language.
- ASP(s): accelerate certain operations, such as vector XOR, dot product of vectors, and apply moving average filter on the vectors.

## Group members 

- Andrew (Kuan-Hao) Lai
- John Zhang
- Shiyang Wu

## Skills involved

- Datapath and Control design
- VHDL
- Test-bench simulation using ModelSim
- FPGA integration on DE2-115 board
