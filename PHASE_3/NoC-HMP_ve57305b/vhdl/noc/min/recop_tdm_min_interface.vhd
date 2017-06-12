library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.noc_types.all;
use work.min_ports_pkg.all;
use work.HMPSoC_config.all;

entity recop_tdm_min_interface is
	generic(
		recop_cnt: integer;
		jop_cnt	: integer;
		fifo_depth	: integer;
		asp_cnt	: integer  -- AJS
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		jop_free : in std_logic_vector(num_recop-1 downto 0); 
		dispatched : out std_logic_vector(recop_cnt-1 downto 0);
		dispatched_io : out std_logic_vector(recop_cnt-1 downto 0);
		tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt+asp_cnt))))-1 downto 0);  -- AJS
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
		dprr_ack	: in std_logic_vector(recop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0)
	);
end recop_tdm_min_interface;

architecture rtl of recop_tdm_min_interface is
	constant nodes 			: integer := recop_cnt + jop_cnt + asp_cnt;  -- AJS
	constant stages_cnt		: integer := integer(ceil(log2(real(nodes))));
	type bit_array is array(integer range <>) of std_logic;
	type int_array is array(integer range <>) of integer;
	type port_array is array(integer range <>) of std_logic_vector(6 downto 0);
	signal dpcr_valid			: bit_array(recop_cnt-1 downto 0);
	signal dpcr_jop_ID		: int_array(recop_cnt-1 downto 0);
	signal dpcr_jop_port		: port_array(recop_cnt-1 downto 0);
	signal dpcr_recop_port	: port_array(recop_cnt-1 downto 0);
	signal dpcr_int			: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal dpcr_fifo			: NOC_LINK_ARRAY_TYPE(recop_cnt-1 downto 0);
	signal fifo_ack			: std_logic_vector(recop_cnt-1 downto 0);

	signal debug1 : port_array(recop_cnt-1 downto 0);
	signal debug2 : port_array(recop_cnt-1 downto 0);
	signal debug3 : port_array(recop_cnt-1 downto 0);
	signal debug4 : port_array(recop_cnt-1 downto 0);
	
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
		dpcr_jop_ID(i)		<= to_integer(unsigned(dpcr_in(i)(30 downto 24)));
		
		dpcr_recop_port(i)<= std_logic_vector(to_unsigned(get_recop_mapping(i, nodes, recop_cnt), 7));
		
		-- retarded way to get constant loop boundaries in function
		addr_loopup2: if TOTAL_NI_NUM <= 2 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
								(others => '0') ;
		end generate;
		
		addr_loopup4: if TOTAL_NI_NUM > 2 and TOTAL_NI_NUM <= 4 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
								(others => '0') ;
		end generate;
		
		addr_loopup8: if TOTAL_NI_NUM > 4 and TOTAL_NI_NUM <= 8 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 7)) when 7,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
							(others => '0') ;
		end generate;
		
		addr_loopup16: if TOTAL_NI_NUM > 8 and TOTAL_NI_NUM <= 16 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_jop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_jop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_jop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_jop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_jop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_jop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_jop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_jop_mapping(15, nodes, recop_cnt), 7)) when 15,
				(others => 'X') when others;
				
				
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
								(others => '0') ;
		end generate;
		
		addr_loopup32: if TOTAL_NI_NUM > 16 and TOTAL_NI_NUM <= 32 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_jop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_jop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_jop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_jop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_jop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_jop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_jop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_jop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_jop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_jop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_jop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_jop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_jop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_jop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_jop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_jop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_jop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_jop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_jop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_jop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_jop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_jop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_jop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_jop_mapping(31, nodes, recop_cnt), 7)) when 31,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
								(others => '0') ;
		end generate;
		
		addr_loopup64: if TOTAL_NI_NUM > 32 and TOTAL_NI_NUM <= 64 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_jop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_jop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_jop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_jop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_jop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_jop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_jop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_jop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_jop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_jop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_jop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_jop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_jop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_jop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_jop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_jop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_jop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_jop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_jop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_jop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_jop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_jop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_jop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_jop_mapping(31, nodes, recop_cnt), 7)) when 31,
				std_logic_vector(to_unsigned(get_jop_mapping(32, nodes, recop_cnt), 7)) when 32,
				std_logic_vector(to_unsigned(get_jop_mapping(33, nodes, recop_cnt), 7)) when 33,
				std_logic_vector(to_unsigned(get_jop_mapping(34, nodes, recop_cnt), 7)) when 34,
				std_logic_vector(to_unsigned(get_jop_mapping(35, nodes, recop_cnt), 7)) when 35,
				std_logic_vector(to_unsigned(get_jop_mapping(36, nodes, recop_cnt), 7)) when 36,
				std_logic_vector(to_unsigned(get_jop_mapping(37, nodes, recop_cnt), 7)) when 37,
				std_logic_vector(to_unsigned(get_jop_mapping(38, nodes, recop_cnt), 7)) when 38,
				std_logic_vector(to_unsigned(get_jop_mapping(39, nodes, recop_cnt), 7)) when 39,
				std_logic_vector(to_unsigned(get_jop_mapping(40, nodes, recop_cnt), 7)) when 40,
				std_logic_vector(to_unsigned(get_jop_mapping(41, nodes, recop_cnt), 7)) when 41,
				std_logic_vector(to_unsigned(get_jop_mapping(42, nodes, recop_cnt), 7)) when 42,
				std_logic_vector(to_unsigned(get_jop_mapping(43, nodes, recop_cnt), 7)) when 43,
				std_logic_vector(to_unsigned(get_jop_mapping(44, nodes, recop_cnt), 7)) when 44,
				std_logic_vector(to_unsigned(get_jop_mapping(45, nodes, recop_cnt), 7)) when 45,
				std_logic_vector(to_unsigned(get_jop_mapping(46, nodes, recop_cnt), 7)) when 46,
				std_logic_vector(to_unsigned(get_jop_mapping(47, nodes, recop_cnt), 7)) when 47,
				std_logic_vector(to_unsigned(get_jop_mapping(48, nodes, recop_cnt), 7)) when 48,
				std_logic_vector(to_unsigned(get_jop_mapping(49, nodes, recop_cnt), 7)) when 49,
				std_logic_vector(to_unsigned(get_jop_mapping(50, nodes, recop_cnt), 7)) when 50,
				std_logic_vector(to_unsigned(get_jop_mapping(51, nodes, recop_cnt), 7)) when 51,
				std_logic_vector(to_unsigned(get_jop_mapping(52, nodes, recop_cnt), 7)) when 52,
				std_logic_vector(to_unsigned(get_jop_mapping(53, nodes, recop_cnt), 7)) when 53,
				std_logic_vector(to_unsigned(get_jop_mapping(54, nodes, recop_cnt), 7)) when 54,
				std_logic_vector(to_unsigned(get_jop_mapping(55, nodes, recop_cnt), 7)) when 55,
				std_logic_vector(to_unsigned(get_jop_mapping(56, nodes, recop_cnt), 7)) when 56,
				std_logic_vector(to_unsigned(get_jop_mapping(57, nodes, recop_cnt), 7)) when 57,
				std_logic_vector(to_unsigned(get_jop_mapping(58, nodes, recop_cnt), 7)) when 58,
				std_logic_vector(to_unsigned(get_jop_mapping(59, nodes, recop_cnt), 7)) when 59,
				std_logic_vector(to_unsigned(get_jop_mapping(60, nodes, recop_cnt), 7)) when 60,
				std_logic_vector(to_unsigned(get_jop_mapping(61, nodes, recop_cnt), 7)) when 61,
				std_logic_vector(to_unsigned(get_jop_mapping(62, nodes, recop_cnt), 7)) when 62,
				std_logic_vector(to_unsigned(get_jop_mapping(63, nodes, recop_cnt), 7)) when 63,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else
								(others => '0') ;
		end generate;
		
		addr_loopup128: if TOTAL_NI_NUM > 64 and TOTAL_NI_NUM <= 128 generate
			with dpcr_jop_ID(i) select dpcr_jop_port(i) <=
				std_logic_vector(to_unsigned(get_jop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_jop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_jop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_jop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_jop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_jop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_jop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_jop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_jop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_jop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_jop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_jop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_jop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_jop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_jop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_jop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_jop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_jop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_jop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_jop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_jop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_jop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_jop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_jop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_jop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_jop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_jop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_jop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_jop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_jop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_jop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_jop_mapping(31, nodes, recop_cnt), 7)) when 31,
				std_logic_vector(to_unsigned(get_jop_mapping(32, nodes, recop_cnt), 7)) when 32,
				std_logic_vector(to_unsigned(get_jop_mapping(33, nodes, recop_cnt), 7)) when 33,
				std_logic_vector(to_unsigned(get_jop_mapping(34, nodes, recop_cnt), 7)) when 34,
				std_logic_vector(to_unsigned(get_jop_mapping(35, nodes, recop_cnt), 7)) when 35,
				std_logic_vector(to_unsigned(get_jop_mapping(36, nodes, recop_cnt), 7)) when 36,
				std_logic_vector(to_unsigned(get_jop_mapping(37, nodes, recop_cnt), 7)) when 37,
				std_logic_vector(to_unsigned(get_jop_mapping(38, nodes, recop_cnt), 7)) when 38,
				std_logic_vector(to_unsigned(get_jop_mapping(39, nodes, recop_cnt), 7)) when 39,
				std_logic_vector(to_unsigned(get_jop_mapping(40, nodes, recop_cnt), 7)) when 40,
				std_logic_vector(to_unsigned(get_jop_mapping(41, nodes, recop_cnt), 7)) when 41,
				std_logic_vector(to_unsigned(get_jop_mapping(42, nodes, recop_cnt), 7)) when 42,
				std_logic_vector(to_unsigned(get_jop_mapping(43, nodes, recop_cnt), 7)) when 43,
				std_logic_vector(to_unsigned(get_jop_mapping(44, nodes, recop_cnt), 7)) when 44,
				std_logic_vector(to_unsigned(get_jop_mapping(45, nodes, recop_cnt), 7)) when 45,
				std_logic_vector(to_unsigned(get_jop_mapping(46, nodes, recop_cnt), 7)) when 46,
				std_logic_vector(to_unsigned(get_jop_mapping(47, nodes, recop_cnt), 7)) when 47,
				std_logic_vector(to_unsigned(get_jop_mapping(48, nodes, recop_cnt), 7)) when 48,
				std_logic_vector(to_unsigned(get_jop_mapping(49, nodes, recop_cnt), 7)) when 49,
				std_logic_vector(to_unsigned(get_jop_mapping(50, nodes, recop_cnt), 7)) when 50,
				std_logic_vector(to_unsigned(get_jop_mapping(51, nodes, recop_cnt), 7)) when 51,
				std_logic_vector(to_unsigned(get_jop_mapping(52, nodes, recop_cnt), 7)) when 52,
				std_logic_vector(to_unsigned(get_jop_mapping(53, nodes, recop_cnt), 7)) when 53,
				std_logic_vector(to_unsigned(get_jop_mapping(54, nodes, recop_cnt), 7)) when 54,
				std_logic_vector(to_unsigned(get_jop_mapping(55, nodes, recop_cnt), 7)) when 55,
				std_logic_vector(to_unsigned(get_jop_mapping(56, nodes, recop_cnt), 7)) when 56,
				std_logic_vector(to_unsigned(get_jop_mapping(57, nodes, recop_cnt), 7)) when 57,
				std_logic_vector(to_unsigned(get_jop_mapping(58, nodes, recop_cnt), 7)) when 58,
				std_logic_vector(to_unsigned(get_jop_mapping(59, nodes, recop_cnt), 7)) when 59,
				std_logic_vector(to_unsigned(get_jop_mapping(60, nodes, recop_cnt), 7)) when 60,
				std_logic_vector(to_unsigned(get_jop_mapping(61, nodes, recop_cnt), 7)) when 61,
				std_logic_vector(to_unsigned(get_jop_mapping(62, nodes, recop_cnt), 7)) when 62,
				std_logic_vector(to_unsigned(get_jop_mapping(63, nodes, recop_cnt), 7)) when 63,
				std_logic_vector(to_unsigned(get_jop_mapping(64, nodes, recop_cnt), 7)) when 64,
				std_logic_vector(to_unsigned(get_jop_mapping(65, nodes, recop_cnt), 7)) when 65,
				std_logic_vector(to_unsigned(get_jop_mapping(66, nodes, recop_cnt), 7)) when 66,
				std_logic_vector(to_unsigned(get_jop_mapping(67, nodes, recop_cnt), 7)) when 67,
				std_logic_vector(to_unsigned(get_jop_mapping(68, nodes, recop_cnt), 7)) when 68,
				std_logic_vector(to_unsigned(get_jop_mapping(69, nodes, recop_cnt), 7)) when 69,
				std_logic_vector(to_unsigned(get_jop_mapping(70, nodes, recop_cnt), 7)) when 70,
				std_logic_vector(to_unsigned(get_jop_mapping(71, nodes, recop_cnt), 7)) when 71,
				std_logic_vector(to_unsigned(get_jop_mapping(72, nodes, recop_cnt), 7)) when 72,
				std_logic_vector(to_unsigned(get_jop_mapping(73, nodes, recop_cnt), 7)) when 73,
				std_logic_vector(to_unsigned(get_jop_mapping(74, nodes, recop_cnt), 7)) when 74,
				std_logic_vector(to_unsigned(get_jop_mapping(75, nodes, recop_cnt), 7)) when 75,
				std_logic_vector(to_unsigned(get_jop_mapping(76, nodes, recop_cnt), 7)) when 76,
				std_logic_vector(to_unsigned(get_jop_mapping(77, nodes, recop_cnt), 7)) when 77,
				std_logic_vector(to_unsigned(get_jop_mapping(78, nodes, recop_cnt), 7)) when 78,
				std_logic_vector(to_unsigned(get_jop_mapping(79, nodes, recop_cnt), 7)) when 79,
				std_logic_vector(to_unsigned(get_jop_mapping(80, nodes, recop_cnt), 7)) when 80,
				std_logic_vector(to_unsigned(get_jop_mapping(81, nodes, recop_cnt), 7)) when 81,
				std_logic_vector(to_unsigned(get_jop_mapping(82, nodes, recop_cnt), 7)) when 82,
				std_logic_vector(to_unsigned(get_jop_mapping(83, nodes, recop_cnt), 7)) when 83,
				std_logic_vector(to_unsigned(get_jop_mapping(84, nodes, recop_cnt), 7)) when 84,
				std_logic_vector(to_unsigned(get_jop_mapping(85, nodes, recop_cnt), 7)) when 85,
				std_logic_vector(to_unsigned(get_jop_mapping(86, nodes, recop_cnt), 7)) when 86,
				std_logic_vector(to_unsigned(get_jop_mapping(87, nodes, recop_cnt), 7)) when 87,
				std_logic_vector(to_unsigned(get_jop_mapping(88, nodes, recop_cnt), 7)) when 88,
				std_logic_vector(to_unsigned(get_jop_mapping(89, nodes, recop_cnt), 7)) when 89,
				std_logic_vector(to_unsigned(get_jop_mapping(90, nodes, recop_cnt), 7)) when 90,
				std_logic_vector(to_unsigned(get_jop_mapping(91, nodes, recop_cnt), 7)) when 91,
				std_logic_vector(to_unsigned(get_jop_mapping(92, nodes, recop_cnt), 7)) when 92,
				std_logic_vector(to_unsigned(get_jop_mapping(93, nodes, recop_cnt), 7)) when 93,
				std_logic_vector(to_unsigned(get_jop_mapping(94, nodes, recop_cnt), 7)) when 94,
				std_logic_vector(to_unsigned(get_jop_mapping(95, nodes, recop_cnt), 7)) when 95,
				std_logic_vector(to_unsigned(get_jop_mapping(96, nodes, recop_cnt), 7)) when 96,
				std_logic_vector(to_unsigned(get_jop_mapping(97, nodes, recop_cnt), 7)) when 97,
				std_logic_vector(to_unsigned(get_jop_mapping(98, nodes, recop_cnt), 7)) when 98,
				std_logic_vector(to_unsigned(get_jop_mapping(99, nodes, recop_cnt), 7)) when 99,
				std_logic_vector(to_unsigned(get_jop_mapping(100, nodes, recop_cnt), 7)) when 100,
				std_logic_vector(to_unsigned(get_jop_mapping(101, nodes, recop_cnt), 7)) when 101,
				std_logic_vector(to_unsigned(get_jop_mapping(102, nodes, recop_cnt), 7)) when 102,
				std_logic_vector(to_unsigned(get_jop_mapping(103, nodes, recop_cnt), 7)) when 103,
				std_logic_vector(to_unsigned(get_jop_mapping(104, nodes, recop_cnt), 7)) when 104,
				std_logic_vector(to_unsigned(get_jop_mapping(105, nodes, recop_cnt), 7)) when 105,
				std_logic_vector(to_unsigned(get_jop_mapping(106, nodes, recop_cnt), 7)) when 106,
				std_logic_vector(to_unsigned(get_jop_mapping(107, nodes, recop_cnt), 7)) when 107,
				std_logic_vector(to_unsigned(get_jop_mapping(108, nodes, recop_cnt), 7)) when 108,
				std_logic_vector(to_unsigned(get_jop_mapping(109, nodes, recop_cnt), 7)) when 109,
				std_logic_vector(to_unsigned(get_jop_mapping(110, nodes, recop_cnt), 7)) when 110,
				std_logic_vector(to_unsigned(get_jop_mapping(111, nodes, recop_cnt), 7)) when 111,
				std_logic_vector(to_unsigned(get_jop_mapping(112, nodes, recop_cnt), 7)) when 112,
				std_logic_vector(to_unsigned(get_jop_mapping(113, nodes, recop_cnt), 7)) when 113,
				std_logic_vector(to_unsigned(get_jop_mapping(114, nodes, recop_cnt), 7)) when 114,
				std_logic_vector(to_unsigned(get_jop_mapping(115, nodes, recop_cnt), 7)) when 115,
				std_logic_vector(to_unsigned(get_jop_mapping(116, nodes, recop_cnt), 7)) when 116,
				std_logic_vector(to_unsigned(get_jop_mapping(117, nodes, recop_cnt), 7)) when 117,
				std_logic_vector(to_unsigned(get_jop_mapping(118, nodes, recop_cnt), 7)) when 118,
				std_logic_vector(to_unsigned(get_jop_mapping(119, nodes, recop_cnt), 7)) when 119,
				std_logic_vector(to_unsigned(get_jop_mapping(120, nodes, recop_cnt), 7)) when 120,
				std_logic_vector(to_unsigned(get_jop_mapping(121, nodes, recop_cnt), 7)) when 121,
				std_logic_vector(to_unsigned(get_jop_mapping(122, nodes, recop_cnt), 7)) when 122,
				std_logic_vector(to_unsigned(get_jop_mapping(123, nodes, recop_cnt), 7)) when 123,
				std_logic_vector(to_unsigned(get_jop_mapping(124, nodes, recop_cnt), 7)) when 124,
				std_logic_vector(to_unsigned(get_jop_mapping(125, nodes, recop_cnt), 7)) when 125,
				std_logic_vector(to_unsigned(get_jop_mapping(126, nodes, recop_cnt), 7)) when 126,
				std_logic_vector(to_unsigned(get_jop_mapping(127, nodes, recop_cnt), 7)) when 127,
				(others => 'X') when others;
			dpcr_int(i)	<= dpcr_valid(i) & dpcr_jop_port(i) & dpcr_in(i)(23 downto 0) when dpcr_valid(i) = '1' else	(others => '0') ;
		end generate;
	end generate;
	
	fifo_gen: if DYNAMIC = '0' or DYNAMIC_FIFO = '1' generate
		dpcr_buffer_gen: for i in 0 to recop_cnt-1 generate
			dpcr_buffer : min_switch_in_fifo
				generic map(
					gen_depth => fifo_depth
				)
				port map(
					aclr	=>	reset,
					clock	=> clk,
					data	=> dpcr_int(i),
					rdreq => fifo_ack(i),
					wrreq => dpcr_int(i)(31),
					empty	=> open,
					full	=> open,
					q		=> dpcr_fifo(i)
				
				);
		end generate;
	end generate;
		
	static_generation: if DYNAMIC = '0' and DYNAMIC_FIFO = '0' generate
		process(tdm_slot)
			variable n_rx	: port_array(recop_cnt-1 downto 0);
		begin
			for i in 0 to recop_cnt-1 loop
				n_rx(i)(stages_cnt-1 downto 0) := reverse_n_bits(dpcr_recop_port(i), stages_cnt) xor tdm_slot;
				n_rx(i)(n_rx(i)'LENGTH-1 downto stages_cnt) := (others=> '0');
				
				debug1(i)(stages_cnt-1 downto 0) <= reverse_n_bits(dpcr_recop_port(i), stages_cnt);
				debug2(i)(stages_cnt-1 downto 0) <= tdm_slot;
				debug1(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
				debug2(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
				
				debug3(i)	<= n_rx(i);
				debug4(i)	<= dpcr_fifo(i)(30 downto 24);
				
				if "1" & n_rx(i) = dpcr_fifo(i)(31 downto 24) then
					dpcr_out(i) <= dpcr_fifo(i);
					fifo_ack(i)	<= '1';
				else
					dpcr_out(i) <= (others => '0');
					fifo_ack(i) <= '0';
				end if;
			end loop;
		end process;
	end generate;
	

	-- AJS
	dprr_interface: for i in 0 to recop_cnt-1 generate
		dprr_fifo : min_switch_in_fifo
		generic map(
			gen_depth => fifo_depth
		)
		port map(
			aclr	=>	reset,
			clock	=> clk,
			data	=> dprr_in(i),
			rdreq => dprr_ack(i),
			wrreq => dprr_in(i)(31),
			empty	=> open,
			full	=> open,
			q		=> dprr_out(i)
		
		);
	end generate;
	
	
	dynamic_generation: if DYNAMIC = '1' and DYNAMIC_FIFO = '0' generate
		process(tdm_slot, dpcr_int,dpcr_valid,dpcr_jop_ID,jop_free,dpcr_recop_port)
			variable n_rx	: port_array(recop_cnt-1 downto 0);
		begin
			for i in 0 to recop_cnt-1 loop
				n_rx(i)(stages_cnt-1 downto 0) := reverse_n_bits(dpcr_recop_port(i), stages_cnt) xor tdm_slot;
				n_rx(i)(n_rx(i)'LENGTH-1 downto stages_cnt) := (others=> '0');
				
				debug1(i)(stages_cnt-1 downto 0) <= reverse_n_bits(dpcr_recop_port(i), stages_cnt);
				debug2(i)(stages_cnt-1 downto 0) <= tdm_slot;
				debug1(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
				debug2(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');			
				debug3(i)	<= n_rx(i);
				
				dpcr_out(i) <= (others => '0');
				dispatched(i) <= '0';
				dispatched_io(i) <= '0';
				if dpcr_valid(i) = '1' then
					if dpcr_jop_ID(i) = 0 then
						if to_integer(unsigned(n_rx(i)(stages_cnt-1 downto 0))) = get_jop_mapping(0, nodes, recop_cnt) then
								dpcr_out(i) <= dpcr_int(i);
								dispatched_io(i) <= '1';
						end if;
					elsif jop_free(i) = '1' then 
							dpcr_out(i) <= dpcr_valid(i) & n_rx(i) & dpcr_int(i)(23 downto 0);
							dispatched(i) <= '1';
					end if;
				end if;
			end loop;
		end process;
	end generate;
	
	dyn_fifo_gen: if DYNAMIC_FIFO = '1' generate
		process(tdm_slot, dpcr_fifo, jop_free,dpcr_recop_port)
			variable n_rx	: port_array(recop_cnt-1 downto 0);
		begin
			for i in 0 to recop_cnt-1 loop
				n_rx(i)(stages_cnt-1 downto 0) := reverse_n_bits(dpcr_recop_port(i), stages_cnt) xor tdm_slot;
				n_rx(i)(n_rx(i)'LENGTH-1 downto stages_cnt) := (others=> '0');
				
				debug1(i)(stages_cnt-1 downto 0) <= reverse_n_bits(dpcr_recop_port(i), stages_cnt);
				debug2(i)(stages_cnt-1 downto 0) <= tdm_slot;
				debug1(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
				debug2(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');			
				debug3(i)	<= n_rx(i);
				
				dpcr_out(i) <= (others => '0');
				dispatched(i) <= '0';		-- not used
				dispatched_io(i) <= '0';	-- not used
				fifo_ack(i) <= '0';
				if dpcr_fifo(i)(31) = '1' then
					if to_integer(unsigned(dpcr_fifo(i)(30 downto 24))) = get_jop_mapping(0, nodes, recop_cnt) then
						if to_integer(unsigned(n_rx(i)(stages_cnt-1 downto 0))) = get_jop_mapping(0, nodes, recop_cnt) then
								dpcr_out(i) <= dpcr_fifo(i);
								fifo_ack(i) <= '1';
						end if;
					elsif jop_free(i) = '1' then 
							dpcr_out(i) <= dpcr_fifo(i);
							fifo_ack(i) <= '1';
					end if;
				end if;
			end loop;
		end process;
	end generate;
	
end architecture;