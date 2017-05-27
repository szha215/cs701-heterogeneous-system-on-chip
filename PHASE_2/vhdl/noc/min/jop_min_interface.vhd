library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library work;
use work.noc_types.all;
use work.min_ports_pkg.all;

entity jop_min_interface is
	generic(
		recop_cnt: integer;
		jop_cnt	: integer;
		fifo_depth	: integer
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
	);
end jop_min_interface;

architecture rtl of jop_min_interface is
	constant nodes 			: integer := recop_cnt + jop_cnt;
	type bit_array is array(integer range <>) of std_logic;
	type int_array is array(integer range <>) of integer;
	type port_array is array(integer range <>) of std_logic_vector(2 downto 0);
	signal dprr_valid			: bit_array(jop_cnt-1 downto 0);
	signal dprr_recop_ID		: int_array(jop_cnt-1 downto 0);
	signal dprr_recop_port	: port_array(jop_cnt-1 downto 0);
	
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

	dpcr_interface: for i in 0 to jop_cnt-1 generate
		dpcr_fifo : min_switch_in_fifo
		generic map(
			gen_depth => fifo_depth
		)
		port map(
			aclr	=>	reset,
			clock	=> clk,
			data	=> dpcr_in(i),
			rdreq => dpcr_ack(i),
			wrreq => dpcr_in(i)(31),
			empty	=> open,
			full	=> open,
			q		=> dpcr_out(i)
		
		);
	end generate;
	
	dprr_interface: for i in 0 to jop_cnt-1 generate
		dprr_valid(i)		<= dprr_in(i)(1);
		dprr_recop_ID(i)		<= to_integer(unsigned(dprr_in(i)(30 downto 28)));
		
		-- stupid way to get constant loop boundaries in function
		with dprr_recop_ID(i) select dprr_recop_port(i) <=
			std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 3)) when 0,
			std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 3)) when 1,
			std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 3)) when 2,
			std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 3)) when 3,
			std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 3)) when 4,
			std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 3)) when 5,
			std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 3)) when 6,
			std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 3)) when 7,
			(others => 'X') when others;
		dprr_out(i)				<= dprr_valid(i) & dprr_recop_port(i) & dprr_in(i)(27 downto 0);
	end generate;
	
end architecture;