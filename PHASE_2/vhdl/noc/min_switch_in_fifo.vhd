LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

LIBRARY work;
USE work.mesh_ports_pkg.all;

ENTITY min_switch_in_fifo IS
	GENERIC(
		gen_depth	: INTEGER := 4
	);
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END min_switch_in_fifo;


ARCHITECTURE SYN OF min_switch_in_fifo IS
	
	type logic_mem_block is array(0 to gen_depth-1) of std_logic_vector(31 downto 0);
	signal cell	: logic_mem_block;
	signal cell_in	: logic_mem_block;
	signal cell_enable : std_logic_vector(gen_depth-1 downto 0);
	signal last : integer range 0 to gen_depth;
	
BEGIN

	selective_shift : for i in 0 to gen_depth-1 generate
		cell_enable(i) <= rdreq or wrreq	when i = last else
								rdreq;
	end generate;
	data_select : for i in 0 to gen_depth-2 generate
		cell_in(i)		<= data when ((i = last and rdreq = '0') or (i = last-1 and rdreq = '1')) else
								cell(i+1);
	end generate;
	
	q <= cell(0);
	cell_in(gen_depth-1)	<= data when gen_depth-1 = last else
									(others => '0');
	
	full	<= '1' when last = gen_depth else
				'0';
	empty	<= '1' when last = 0 else
				'0';
	
	
	process (aclr, clock)
	begin
		if aclr = '1' then
			for i in 0 to gen_depth-1 loop
				cell(i) <= (others => '0');
			end loop;
		elsif rising_edge(clock) then
			for i in 0 to gen_depth-1 loop
				if cell_enable(i) = '1' then
					cell(i) <= cell_in(i);
				end if;
			end loop;
		end if;
	end process;
	
	process (aclr, clock)
		variable diff : integer range 0 to gen_depth;
	begin
		if aclr = '1' then
			diff := 0;
		elsif rising_edge(clock) then
			if wrreq = '1' and diff < gen_depth then
				diff := diff+1;
			end if;
			if rdreq = '1' and diff > 0 then
				diff := diff-1;
			end if;
		end if;
		last <= diff;
	end process;
			
END SYN;
