# JNI Changes

### ASP Mapping

A new function `get_asp_mapping()` has been added to `min_ports_pkg.vhd`. 

The function is used within the "retarded" mapping code in order to correctly send outgoing packets to the NoC in the correct format and port. 

### Additional DPCR FIFO for ASP

When JOP sends an Invoke command to ASP, it would not want to receive a ReCOP command until the ASP has sent responds back. 

An additional mux has been added to select between the ReCOP and ASP FIFOs. MAC command will send 3 packets back, so JNI will need to know the number of ASP packets to expect. 

To know the number of expected packets, JNI will need to know the ASP command OP code and ignore data packets for STORE since they don't have OP codes. The simplified pseudo code is:

```
packet recieved:
   if (dprr_in valid and legacy = 1) and (reading from ReCOP FIFO):
      select to read from ASP FIFO
      if op_code = MAC:
         expect 3 packets
      else:
         expect 1 packet
   else:
      if number of packets read by JOP is expected packets:
         select to read from ReCOP FIFO
```

## JNI Test Bench

The test bench for our JNI is as follows:

- A ReCOP data call is sent to the JNI
- A JOP calls an ASP MAC function
- DPCR_out reads ASP FIFO
- Another ReCOP data call is sent to the JNI (not sent to DPCR_out)
- Set of JOP acknowledgements, ASP FIFO popped
- The DPCR_out reads ReCOP FIFO after 3 packets acknowledged