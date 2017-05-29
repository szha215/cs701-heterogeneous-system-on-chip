--
--	jtbl.vhd
--
--	jump table for java bc to jvm address
--
--		DONT edit this file!
--		generated by Jopa.java
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtbl is
port (
	bcode	: in std_logic_vector(7 downto 0);
	int_pend	: in  std_logic;
	exc_pend	: in  std_logic;
	q		: out std_logic_vector(10 downto 0)
);
end jtbl;

--
--	unregistered rdbcode
--	unregistered dout
--
architecture rtl of jtbl is

	signal	addr	: std_logic_vector(10 downto 0);

begin

process(bcode) begin

	case bcode is

		when "10111011" => addr <= "00001111110";	--	007e	new
		when "10111101" => addr <= "00001111110";	--	007e	anewarray
		when "11000000" => addr <= "00001111110";	--	007e	checkcast
		when "11000001" => addr <= "00001111110";	--	007e	instanceof
		when "10111100" => addr <= "00010011001";	--	0099	newarray
		when "11100011" => addr <= "00010101110";	--	00ae	putfield_ref
		when "11100001" => addr <= "00011000100";	--	00c4	putstatic_ref
		when "10110111" => addr <= "00011111101";	--	00fd	invokespecial
		when "10111000" => addr <= "00011111101";	--	00fd	invokestatic
		when "11011110" => addr <= "00100000101";	--	0105	jopsys_invoke
		when "10111001" => addr <= "00100001000";	--	0108	invokeinterface
		when "11101100" => addr <= "00100111010";	--	013a	invokesuper
		when "10110110" => addr <= "00101110000";	--	0170	invokevirtual
		when "10110000" => addr <= "00111010011";	--	01d3	areturn
		when "10101110" => addr <= "00111010011";	--	01d3	freturn
		when "10101100" => addr <= "00111010011";	--	01d3	ireturn
		when "10101111" => addr <= "00111101010";	--	01ea	dreturn
		when "10101101" => addr <= "00111101010";	--	01ea	lreturn
		when "10110001" => addr <= "01000000011";	--	0203	return
		when "00000000" => addr <= "01000011000";	--	0218	nop
		when "00000010" => addr <= "01000011001";	--	0219	iconst_m1
		when "00001011" => addr <= "01000011010";	--	021a	fconst_0
		when "00000001" => addr <= "01000011010";	--	021a	aconst_null
		when "00000011" => addr <= "01000011010";	--	021a	iconst_0
		when "00000100" => addr <= "01000011011";	--	021b	iconst_1
		when "00000101" => addr <= "01000011100";	--	021c	iconst_2
		when "00000110" => addr <= "01000011101";	--	021d	iconst_3
		when "00000111" => addr <= "01000011110";	--	021e	iconst_4
		when "00001000" => addr <= "01000011111";	--	021f	iconst_5
		when "00010000" => addr <= "01000100000";	--	0220	bipush
		when "00010001" => addr <= "01000100010";	--	0222	sipush
		when "00010010" => addr <= "01000100101";	--	0225	ldc
		when "00010011" => addr <= "01000101100";	--	022c	ldc_w
		when "00011001" => addr <= "01000110100";	--	0234	aload
		when "00010111" => addr <= "01000110100";	--	0234	fload
		when "00010101" => addr <= "01000110100";	--	0234	iload
		when "00101010" => addr <= "01000110110";	--	0236	aload_0
		when "00100010" => addr <= "01000110110";	--	0236	fload_0
		when "00011010" => addr <= "01000110110";	--	0236	iload_0
		when "00101011" => addr <= "01000110111";	--	0237	aload_1
		when "00100011" => addr <= "01000110111";	--	0237	fload_1
		when "00011011" => addr <= "01000110111";	--	0237	iload_1
		when "00101100" => addr <= "01000111000";	--	0238	aload_2
		when "00100100" => addr <= "01000111000";	--	0238	fload_2
		when "00011100" => addr <= "01000111000";	--	0238	iload_2
		when "00101101" => addr <= "01000111001";	--	0239	aload_3
		when "00100101" => addr <= "01000111001";	--	0239	fload_3
		when "00011101" => addr <= "01000111001";	--	0239	iload_3
		when "00111010" => addr <= "01000111010";	--	023a	astore
		when "00111000" => addr <= "01000111010";	--	023a	fstore
		when "00110110" => addr <= "01000111010";	--	023a	istore
		when "01001011" => addr <= "01000111100";	--	023c	astore_0
		when "01000011" => addr <= "01000111100";	--	023c	fstore_0
		when "00111011" => addr <= "01000111100";	--	023c	istore_0
		when "01001100" => addr <= "01000111101";	--	023d	astore_1
		when "01000100" => addr <= "01000111101";	--	023d	fstore_1
		when "00111100" => addr <= "01000111101";	--	023d	istore_1
		when "01001101" => addr <= "01000111110";	--	023e	astore_2
		when "01000101" => addr <= "01000111110";	--	023e	fstore_2
		when "00111101" => addr <= "01000111110";	--	023e	istore_2
		when "01001110" => addr <= "01000111111";	--	023f	astore_3
		when "01000110" => addr <= "01000111111";	--	023f	fstore_3
		when "00111110" => addr <= "01000111111";	--	023f	istore_3
		when "01010111" => addr <= "01001000000";	--	0240	pop
		when "01011000" => addr <= "01001000001";	--	0241	pop2
		when "01011001" => addr <= "01001000011";	--	0243	dup
		when "01011010" => addr <= "01001000100";	--	0244	dup_x1
		when "01011011" => addr <= "01001001001";	--	0249	dup_x2
		when "01011100" => addr <= "01001010000";	--	0250	dup2
		when "01011101" => addr <= "01001010110";	--	0256	dup2_x1
		when "01011110" => addr <= "01001011110";	--	025e	dup2_x2
		when "01011111" => addr <= "01001101000";	--	0268	swap
		when "01100000" => addr <= "01001101100";	--	026c	iadd
		when "01100100" => addr <= "01001101101";	--	026d	isub
		when "01110100" => addr <= "01001101110";	--	026e	ineg
		when "01111110" => addr <= "01001110010";	--	0272	iand
		when "10000000" => addr <= "01001110011";	--	0273	ior
		when "10000010" => addr <= "01001110100";	--	0274	ixor
		when "01111000" => addr <= "01001110101";	--	0275	ishl
		when "01111010" => addr <= "01001110110";	--	0276	ishr
		when "01111100" => addr <= "01001110111";	--	0277	iushr
		when "01101000" => addr <= "01001111000";	--	0278	imul
		when "10000100" => addr <= "01010000100";	--	0284	iinc
		when "10010010" => addr <= "01010001100";	--	028c	i2c
		when "11000110" => addr <= "01010001110";	--	028e	ifnull
		when "11000111" => addr <= "01010001110";	--	028e	ifnonnull
		when "10011001" => addr <= "01010001110";	--	028e	ifeq
		when "10011010" => addr <= "01010001110";	--	028e	ifne
		when "10011011" => addr <= "01010001110";	--	028e	iflt
		when "10011100" => addr <= "01010001110";	--	028e	ifge
		when "10011101" => addr <= "01010001110";	--	028e	ifgt
		when "10011110" => addr <= "01010001110";	--	028e	ifle
		when "10100101" => addr <= "01010010010";	--	0292	if_acmpeq
		when "10100110" => addr <= "01010010010";	--	0292	if_acmpne
		when "10011111" => addr <= "01010010010";	--	0292	if_icmpeq
		when "10100000" => addr <= "01010010010";	--	0292	if_icmpne
		when "10100001" => addr <= "01010010010";	--	0292	if_icmplt
		when "10100010" => addr <= "01010010010";	--	0292	if_icmpge
		when "10100011" => addr <= "01010010010";	--	0292	if_icmpgt
		when "10100100" => addr <= "01010010010";	--	0292	if_icmple
		when "10100111" => addr <= "01010010110";	--	0296	goto
		when "11100000" => addr <= "01010011010";	--	029a	getstatic_ref
		when "10110010" => addr <= "01010011010";	--	029a	getstatic
		when "11101110" => addr <= "01010011111";	--	029f	jopsys_getstatic
		when "10110011" => addr <= "01010100100";	--	02a4	putstatic
		when "11101111" => addr <= "01010101001";	--	02a9	jopsys_putstatic
		when "11100010" => addr <= "01010101110";	--	02ae	getfield_ref
		when "10110100" => addr <= "01010101110";	--	02ae	getfield
		when "11101001" => addr <= "01010110011";	--	02b3	jopsys_getfield
		when "10110101" => addr <= "01010111000";	--	02b8	putfield
		when "11101010" => addr <= "01010111110";	--	02be	jopsys_putfield
		when "10111110" => addr <= "01011000101";	--	02c5	arraylength
		when "01010100" => addr <= "01011001011";	--	02cb	bastore
		when "01010101" => addr <= "01011001011";	--	02cb	castore
		when "01010001" => addr <= "01011001011";	--	02cb	fastore
		when "01001111" => addr <= "01011001011";	--	02cb	iastore
		when "01010110" => addr <= "01011001011";	--	02cb	sastore
		when "00110010" => addr <= "01011010001";	--	02d1	aaload
		when "00110011" => addr <= "01011010001";	--	02d1	baload
		when "00110100" => addr <= "01011010001";	--	02d1	caload
		when "00110000" => addr <= "01011010001";	--	02d1	faload
		when "00101110" => addr <= "01011010001";	--	02d1	iaload
		when "00110101" => addr <= "01011010001";	--	02d1	saload
		when "11000010" => addr <= "01011010110";	--	02d6	monitorenter
		when "11000011" => addr <= "01011101001";	--	02e9	monitorexit
		when "00010100" => addr <= "01011111101";	--	02fd	ldc2_w
		when "00001110" => addr <= "01100001110";	--	030e	dconst_0
		when "00001001" => addr <= "01100001110";	--	030e	lconst_0
		when "00001010" => addr <= "01100010000";	--	0310	lconst_1
		when "10001000" => addr <= "01100010010";	--	0312	l2i
		when "10000101" => addr <= "01100010101";	--	0315	i2l
		when "00100110" => addr <= "01100011010";	--	031a	dload_0
		when "00011110" => addr <= "01100011010";	--	031a	lload_0
		when "00100111" => addr <= "01100011100";	--	031c	dload_1
		when "00011111" => addr <= "01100011100";	--	031c	lload_1
		when "00101000" => addr <= "01100011110";	--	031e	dload_2
		when "00100000" => addr <= "01100011110";	--	031e	lload_2
		when "00101001" => addr <= "01100100000";	--	0320	dload_3
		when "00100001" => addr <= "01100100000";	--	0320	lload_3
		when "00011000" => addr <= "01100101011";	--	032b	dload
		when "00010110" => addr <= "01100101011";	--	032b	lload
		when "01000111" => addr <= "01100110110";	--	0336	dstore_0
		when "00111111" => addr <= "01100110110";	--	0336	lstore_0
		when "01001000" => addr <= "01100111000";	--	0338	dstore_1
		when "01000000" => addr <= "01100111000";	--	0338	lstore_1
		when "01001001" => addr <= "01100111010";	--	033a	dstore_2
		when "01000001" => addr <= "01100111010";	--	033a	lstore_2
		when "01001010" => addr <= "01100111100";	--	033c	dstore_3
		when "01000010" => addr <= "01100111100";	--	033c	lstore_3
		when "00111001" => addr <= "01101000111";	--	0347	dstore
		when "00110111" => addr <= "01101000111";	--	0347	lstore
		when "11100100" => addr <= "01101010010";	--	0352	getstatic_long
		when "11100101" => addr <= "01101100010";	--	0362	putstatic_long
		when "11100110" => addr <= "01101110011";	--	0373	getfield_long
		when "11100111" => addr <= "01110010100";	--	0394	putfield_long
		when "01010010" => addr <= "01111000001";	--	03c1	dastore
		when "01010000" => addr <= "01111000001";	--	03c1	lastore
		when "00110001" => addr <= "10000000001";	--	0401	daload
		when "00101111" => addr <= "10000000001";	--	0401	laload
		when "01110101" => addr <= "10000101100";	--	042c	lneg
		when "01100001" => addr <= "10000110100";	--	0434	ladd
		when "01100101" => addr <= "10001001110";	--	044e	lsub
		when "10010100" => addr <= "10001110100";	--	0474	lcmp
		when "01111101" => addr <= "10011001101";	--	04cd	lushr
		when "01111011" => addr <= "10011110101";	--	04f5	lshr
		when "01111001" => addr <= "10100011101";	--	051d	lshl
		when "10000011" => addr <= "10101000101";	--	0545	lxor
		when "01111111" => addr <= "10101001101";	--	054d	land
		when "10000001" => addr <= "10101010101";	--	0555	lor
		when "11010001" => addr <= "10101011101";	--	055d	jopsys_rd
		when "11010011" => addr <= "10101011101";	--	055d	jopsys_rdmem
		when "11010010" => addr <= "10101100001";	--	0561	jopsys_wr
		when "11010100" => addr <= "10101100001";	--	0561	jopsys_wrmem
		when "11010101" => addr <= "10101100110";	--	0566	jopsys_rdint
		when "11010110" => addr <= "10101101001";	--	0569	jopsys_wrint
		when "11010111" => addr <= "10101101100";	--	056c	jopsys_getsp
		when "11011000" => addr <= "10101101111";	--	056f	jopsys_setsp
		when "11011001" => addr <= "10101110011";	--	0573	jopsys_getvp
		when "11011010" => addr <= "10101110100";	--	0574	jopsys_setvp
		when "11011011" => addr <= "10101110110";	--	0576	jopsys_int2ext
		when "11011100" => addr <= "10110010001";	--	0591	jopsys_ext2int
		when "11101000" => addr <= "10110101101";	--	05ad	jopsys_memcpy
		when "11011101" => addr <= "10110110010";	--	05b2	jopsys_nop
		when "11011111" => addr <= "10110110011";	--	05b3	jopsys_cond_move
		when "11001100" => addr <= "10110111001";	--	05b9	jopsys_inval

		when others => addr <= "00011101100";		--	00ec	sys_noim
	end case;
end process;

process(int_pend, exc_pend, addr) begin

	q <= addr;
	if exc_pend='1' then
		q <= "00011100010";		--	00e2	sys_exc
	elsif int_pend='1' then
		q <= "00011011010";		--	00da	sys_int
	end if;
end process;

end rtl;