library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library work;
use work.noc_types.all;
use work.min_ports_pkg.all;

entity recop_min_interface is
	generic(
		recop_cnt: integer;
		jop_cnt	: integer;
		fifo_depth	: integer
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0)
	);
end recop_min_interface;

architecture rtl of recop_min_interface is
	constant nodes 			: integer := recop_cnt + jop_cnt;
	type bit_array is array(integer range <>) of std_logic;
	type int_array is array(integer range <>) of integer;
	type port_array is array(integer range <>) of std_logic_vector(2 downto 0);
	signal dpcr_valid			: bit_array(recop_cnt-1 downto 0);
	signal dpcr_jop_ID		: int_array(recop_cnt-1 downto 0);
	signal dpcr_jop_port		: port_array(recop_cnt-1 downto 0);
	
	component min_switch_in_fifo IS
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
	END component;

begin
	dpcr_interface: for i in 0 to recop_cnt-1 generate
		dpcr_valid(i)		<= dpcr_in(i)(31);
		dpcr_jop_ID(i)		<= to_integer(unsigned(dpcr_in(i)(30 downto 28)));
		
		-- stupid way to get constant loop boundaries in function
		with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
			std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 3)) when 0,
			std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 3)) when 1,
			std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 3)) when 2,
			std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 3)) when 3,
			std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 3)) when 4,
			std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 3)) when 5,
			std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 3)) when 6,
			std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 3)) when 7,
			(others => 'X') when others;
		dpcr_out(i)				<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(27 downto 0);
	end generate;

	dprr_interface: for i in 0 to recop_cnt-1 generate
		dprr_fifo : min_switch_in_fifo
		generic map(
			gen_depth => fifo_depth
		)
		port map(
			aclr	=>	reset,
			clock	=> clk,
			data	=> "0000" & dprr_in(i)(27 downto 0),
			rdreq => dprr_ack(i),
			wrreq => dprr_in(i)(1),
			empty	=> open,
			full	=> open,
			q		=> dprr_out(i)
		
		);
	end generate;
	
end architecture;