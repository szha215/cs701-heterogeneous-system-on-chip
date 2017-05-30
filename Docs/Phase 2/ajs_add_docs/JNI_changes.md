# JNI Changes

### ASP Mapping

A new function `get_asp_mapping()` has been added to `min_ports_pkg.vhd`. 

The function is used within the "retarded" mapping code in order to correctly send outgoing packets to the NoC in the correct format and port. 

### Additional DPCR FIFO for ASP and DPCR Multiplexer

When JOP sends an Invoke command to ASP, it would not want to receive a ReCOP command until the ASP has sent responds back. 

An additional mux has been added to select between the ReCOP and ASP FIFOs. MAC command will send 3 packets back, so JNI will need to know the number of ASP packets to expect.  This is simply checked by looking in the ASP packet ID, which is defined in the 17 and 16 bits of the `DataResult,AccessGranted` packet. Where if one packet, ID of 0, and three packets, then ID 0 to 2.

To know the number of expected packets, JNI will need to know the ASP command OP code and ignore data packets for STORE since they don't have OP codes. The simplified pseudo code is:

```
if (dprr_in valid and legacy = 1) and (reading from ReCOP FIFO):
	select to read from ASP FIFO
	if op_code = MAC:
		expect packet of ID "10"
	else:
		expect packet of ID "00"
else:
	if packet ID is equal to expected packet ID:
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

