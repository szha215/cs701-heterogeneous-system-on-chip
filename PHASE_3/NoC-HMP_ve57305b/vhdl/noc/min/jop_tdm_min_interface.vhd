library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.noc_types.all;
use work.min_ports_pkg.all;

entity jop_tdm_min_interface is
	generic(
		recop_cnt: integer := 1;
		jop_cnt	: integer := 3;
		fifo_depth	: integer := 128;
		asp_cnt	: integer := 1
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot	: in std_logic_vector(integer(ceil(log2(real(recop_cnt+jop_cnt+asp_cnt))))-1 downto 0);
		dpcr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dpcr_ack	: in std_logic_vector(jop_cnt-1 downto 0);
		dpcr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_in	: in NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
		dprr_out	: out NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0)
	);
end jop_tdm_min_interface;

architecture rtl of jop_tdm_min_interface is
	constant nodes 			: integer := recop_cnt + jop_cnt + asp_cnt;
	constant stages_cnt		: integer := integer(ceil(log2(real(nodes))));
	type bit_array is array(integer range <>) of std_logic;
	type int_array is array(integer range <>) of integer;
	type port_array is array(integer range <>) of std_logic_vector(6 downto 0);
	signal dprr_valid			: bit_array(jop_cnt-1 downto 0);
	signal dprr_legacy		: bit_array(jop_cnt-1 downto 0);  -- AJS
	signal dprr_recop_ID		: int_array(jop_cnt-1 downto 0);
	signal dprr_asp_ID		: int_array(jop_cnt-1 downto 0);  -- AJS
	signal dprr_recop_port	: port_array(jop_cnt-1 downto 0);
	signal dprr_asp_port		: port_array(jop_cnt-1 downto 0);  -- AJS
	signal dprr_jop_port		: port_array(jop_cnt-1 downto 0);
	signal dprr_int			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal dprr_fifo			: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0);
	signal fifo_ack			: std_logic_vector(jop_cnt-1 downto 0);
	
		signal debug1 : port_array(jop_cnt-1 downto 0);
		signal debug2 : port_array(jop_cnt-1 downto 0);
		signal debug3 : port_array(jop_cnt-1 downto 0);
		signal debug4 : port_array(jop_cnt-1 downto 0);
	
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


	-- AJS
	type expected_packets_in_array is array (integer range <>) of std_logic_vector(1 downto 0);

	-- ASP STUFF
	signal wrreq_asp_ni					: bit_array(jop_cnt-1 downto 0) :=  (others => '0');
	signal wrreq_recop_ni				: bit_array(jop_cnt-1 downto 0) := (others => '0');

	signal dpcr_out_sel					: bit_array(jop_cnt-1 downto 0) := (others => '0');
	signal dpcr_out_recop, dpcr_out_asp	: NOC_LINK_ARRAY_TYPE(jop_cnt-1 downto 0) := (others => (others => '0'));
	signal recop_ack						: bit_array(jop_cnt-1 downto 0) := (others => '0');
	signal asp_ack							: bit_array(jop_cnt-1 downto 0) := (others => '0');

	signal expected_asp_packets_in	: expected_packets_in_array(jop_cnt-1 downto 0) := (others => (others => '0'));

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
			rdreq => recop_ack(i),
			wrreq => wrreq_recop_ni(i),
			empty	=> open,
			full	=> open,
			q		=> dpcr_out_recop(i)
		
		);
	end generate;

	-- AJS
	asp_interface: for i in 0 to jop_cnt-1 generate
		asp_fifo : min_switch_in_fifo
		generic map(
			gen_depth => 16
		)
		port map(
			aclr	=>	reset,
			clock	=> clk,
			data	=> dpcr_in(i),
			rdreq => asp_ack(i),
			wrreq => wrreq_asp_ni(i),
			empty	=> open,
			full	=> open,
			q		=> dpcr_out_asp(i)
		);
	end generate;

	asp_and_gates: process(dpcr_in)
	begin
		for i in 0 to jop_cnt-1 loop
			wrreq_asp_ni(i) <= (dpcr_in(i)(31)) and (dpcr_in(i)(30));
		end loop;
	end process;

	recop_and_gates: process(dpcr_in)
	begin
		for i in 0 to jop_cnt-1 loop
			wrreq_recop_ni(i) <= (dpcr_in(i)(31)) and not (dpcr_in(i)(30));
		end loop;
	end process;





	dprr_interface: for i in 0 to jop_cnt-1 generate
		dprr_valid(i)			<= dprr_in(i)(31);
		dprr_legacy(i)			<= dprr_in(i)(30);  -- AJS
		dprr_recop_ID(i)		<= to_integer(unsigned(dprr_in(i)(29 downto 24)));  -- AJS
		dprr_asp_ID(i)			<= to_integer(unsigned(dprr_in(i)(29 downto 26)));  -- AJS
		
		dprr_jop_port(i)<= std_logic_vector(to_unsigned(get_jop_mapping(i, nodes, recop_cnt), 7));
		
		-- retarded way to get constant loop boundaries in function
		addr_loopup2: if TOTAL_NI_NUM <= 2 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;




		addr_loopup4: if TOTAL_NI_NUM > 2 and TOTAL_NI_NUM <= 4 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;






		addr_loopup8: if TOTAL_NI_NUM > 4 and TOTAL_NI_NUM <= 8 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 7)) when 7,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_asp_mapping(4, nodes, jop_cnt, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_asp_mapping(5, nodes, jop_cnt, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_asp_mapping(6, nodes, jop_cnt, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_asp_mapping(7, nodes, jop_cnt, recop_cnt), 7)) when 7,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;






		addr_loopup16: if TOTAL_NI_NUM > 8 and TOTAL_NI_NUM <= 16 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_recop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_recop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_recop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_recop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_recop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_recop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_recop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_recop_mapping(15, nodes, recop_cnt), 7)) when 15,
				(others => 'X') when others;	

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_asp_mapping(4, nodes, jop_cnt, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_asp_mapping(5, nodes, jop_cnt, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_asp_mapping(6, nodes, jop_cnt, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_asp_mapping(7, nodes, jop_cnt, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_asp_mapping(8, nodes, jop_cnt, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_asp_mapping(9, nodes, jop_cnt, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_asp_mapping(10, nodes, jop_cnt, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_asp_mapping(11, nodes, jop_cnt, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_asp_mapping(12, nodes, jop_cnt, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_asp_mapping(13, nodes, jop_cnt, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_asp_mapping(14, nodes, jop_cnt, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_asp_mapping(15, nodes, jop_cnt, recop_cnt), 7)) when 15,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;



		addr_loopup32: if TOTAL_NI_NUM > 16 and TOTAL_NI_NUM <= 32 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_recop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_recop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_recop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_recop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_recop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_recop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_recop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_recop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_recop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_recop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_recop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_recop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_recop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_recop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_recop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_recop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_recop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_recop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_recop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_recop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_recop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_recop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_recop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_recop_mapping(31, nodes, recop_cnt), 7)) when 31,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_asp_mapping(4, nodes, jop_cnt, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_asp_mapping(5, nodes, jop_cnt, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_asp_mapping(6, nodes, jop_cnt, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_asp_mapping(7, nodes, jop_cnt, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_asp_mapping(8, nodes, jop_cnt, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_asp_mapping(9, nodes, jop_cnt, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_asp_mapping(10, nodes, jop_cnt, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_asp_mapping(11, nodes, jop_cnt, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_asp_mapping(12, nodes, jop_cnt, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_asp_mapping(13, nodes, jop_cnt, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_asp_mapping(14, nodes, jop_cnt, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_asp_mapping(15, nodes, jop_cnt, recop_cnt), 7)) when 15,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;
		
		addr_loopup64: if TOTAL_NI_NUM > 32 and TOTAL_NI_NUM <= 64 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_recop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_recop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_recop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_recop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_recop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_recop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_recop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_recop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_recop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_recop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_recop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_recop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_recop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_recop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_recop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_recop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_recop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_recop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_recop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_recop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_recop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_recop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_recop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_recop_mapping(31, nodes, recop_cnt), 7)) when 31,
				std_logic_vector(to_unsigned(get_recop_mapping(32, nodes, recop_cnt), 7)) when 32,
				std_logic_vector(to_unsigned(get_recop_mapping(33, nodes, recop_cnt), 7)) when 33,
				std_logic_vector(to_unsigned(get_recop_mapping(34, nodes, recop_cnt), 7)) when 34,
				std_logic_vector(to_unsigned(get_recop_mapping(35, nodes, recop_cnt), 7)) when 35,
				std_logic_vector(to_unsigned(get_recop_mapping(36, nodes, recop_cnt), 7)) when 36,
				std_logic_vector(to_unsigned(get_recop_mapping(37, nodes, recop_cnt), 7)) when 37,
				std_logic_vector(to_unsigned(get_recop_mapping(38, nodes, recop_cnt), 7)) when 38,
				std_logic_vector(to_unsigned(get_recop_mapping(39, nodes, recop_cnt), 7)) when 39,
				std_logic_vector(to_unsigned(get_recop_mapping(40, nodes, recop_cnt), 7)) when 40,
				std_logic_vector(to_unsigned(get_recop_mapping(41, nodes, recop_cnt), 7)) when 41,
				std_logic_vector(to_unsigned(get_recop_mapping(42, nodes, recop_cnt), 7)) when 42,
				std_logic_vector(to_unsigned(get_recop_mapping(43, nodes, recop_cnt), 7)) when 43,
				std_logic_vector(to_unsigned(get_recop_mapping(44, nodes, recop_cnt), 7)) when 44,
				std_logic_vector(to_unsigned(get_recop_mapping(45, nodes, recop_cnt), 7)) when 45,
				std_logic_vector(to_unsigned(get_recop_mapping(46, nodes, recop_cnt), 7)) when 46,
				std_logic_vector(to_unsigned(get_recop_mapping(47, nodes, recop_cnt), 7)) when 47,
				std_logic_vector(to_unsigned(get_recop_mapping(48, nodes, recop_cnt), 7)) when 48,
				std_logic_vector(to_unsigned(get_recop_mapping(49, nodes, recop_cnt), 7)) when 49,
				std_logic_vector(to_unsigned(get_recop_mapping(50, nodes, recop_cnt), 7)) when 50,
				std_logic_vector(to_unsigned(get_recop_mapping(51, nodes, recop_cnt), 7)) when 51,
				std_logic_vector(to_unsigned(get_recop_mapping(52, nodes, recop_cnt), 7)) when 52,
				std_logic_vector(to_unsigned(get_recop_mapping(53, nodes, recop_cnt), 7)) when 53,
				std_logic_vector(to_unsigned(get_recop_mapping(54, nodes, recop_cnt), 7)) when 54,
				std_logic_vector(to_unsigned(get_recop_mapping(55, nodes, recop_cnt), 7)) when 55,
				std_logic_vector(to_unsigned(get_recop_mapping(56, nodes, recop_cnt), 7)) when 56,
				std_logic_vector(to_unsigned(get_recop_mapping(57, nodes, recop_cnt), 7)) when 57,
				std_logic_vector(to_unsigned(get_recop_mapping(58, nodes, recop_cnt), 7)) when 58,
				std_logic_vector(to_unsigned(get_recop_mapping(59, nodes, recop_cnt), 7)) when 59,
				std_logic_vector(to_unsigned(get_recop_mapping(60, nodes, recop_cnt), 7)) when 60,
				std_logic_vector(to_unsigned(get_recop_mapping(61, nodes, recop_cnt), 7)) when 61,
				std_logic_vector(to_unsigned(get_recop_mapping(62, nodes, recop_cnt), 7)) when 62,
				std_logic_vector(to_unsigned(get_recop_mapping(63, nodes, recop_cnt), 7)) when 63,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_asp_mapping(4, nodes, jop_cnt, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_asp_mapping(5, nodes, jop_cnt, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_asp_mapping(6, nodes, jop_cnt, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_asp_mapping(7, nodes, jop_cnt, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_asp_mapping(8, nodes, jop_cnt, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_asp_mapping(9, nodes, jop_cnt, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_asp_mapping(10, nodes, jop_cnt, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_asp_mapping(11, nodes, jop_cnt, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_asp_mapping(12, nodes, jop_cnt, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_asp_mapping(13, nodes, jop_cnt, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_asp_mapping(14, nodes, jop_cnt, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_asp_mapping(15, nodes, jop_cnt, recop_cnt), 7)) when 15,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;




		addr_loopup128: if TOTAL_NI_NUM > 64 and TOTAL_NI_NUM <= 128 generate
			with dprr_recop_ID(i) select dprr_recop_port(i) <=
				std_logic_vector(to_unsigned(get_recop_mapping(0, nodes, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_recop_mapping(1, nodes, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_recop_mapping(2, nodes, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_recop_mapping(3, nodes, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_recop_mapping(4, nodes, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_recop_mapping(5, nodes, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_recop_mapping(6, nodes, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_recop_mapping(7, nodes, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_recop_mapping(8, nodes, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_recop_mapping(9, nodes, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_recop_mapping(10, nodes, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_recop_mapping(11, nodes, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_recop_mapping(12, nodes, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_recop_mapping(13, nodes, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_recop_mapping(14, nodes, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_recop_mapping(15, nodes, recop_cnt), 7)) when 15,
				std_logic_vector(to_unsigned(get_recop_mapping(16, nodes, recop_cnt), 7)) when 16,
				std_logic_vector(to_unsigned(get_recop_mapping(17, nodes, recop_cnt), 7)) when 17,
				std_logic_vector(to_unsigned(get_recop_mapping(18, nodes, recop_cnt), 7)) when 18,
				std_logic_vector(to_unsigned(get_recop_mapping(19, nodes, recop_cnt), 7)) when 19,
				std_logic_vector(to_unsigned(get_recop_mapping(20, nodes, recop_cnt), 7)) when 20,
				std_logic_vector(to_unsigned(get_recop_mapping(21, nodes, recop_cnt), 7)) when 21,
				std_logic_vector(to_unsigned(get_recop_mapping(22, nodes, recop_cnt), 7)) when 22,
				std_logic_vector(to_unsigned(get_recop_mapping(23, nodes, recop_cnt), 7)) when 23,
				std_logic_vector(to_unsigned(get_recop_mapping(24, nodes, recop_cnt), 7)) when 24,
				std_logic_vector(to_unsigned(get_recop_mapping(25, nodes, recop_cnt), 7)) when 25,
				std_logic_vector(to_unsigned(get_recop_mapping(26, nodes, recop_cnt), 7)) when 26,
				std_logic_vector(to_unsigned(get_recop_mapping(27, nodes, recop_cnt), 7)) when 27,
				std_logic_vector(to_unsigned(get_recop_mapping(28, nodes, recop_cnt), 7)) when 28,
				std_logic_vector(to_unsigned(get_recop_mapping(29, nodes, recop_cnt), 7)) when 29,
				std_logic_vector(to_unsigned(get_recop_mapping(30, nodes, recop_cnt), 7)) when 30,
				std_logic_vector(to_unsigned(get_recop_mapping(31, nodes, recop_cnt), 7)) when 31,
				std_logic_vector(to_unsigned(get_recop_mapping(32, nodes, recop_cnt), 7)) when 32,
				std_logic_vector(to_unsigned(get_recop_mapping(33, nodes, recop_cnt), 7)) when 33,
				std_logic_vector(to_unsigned(get_recop_mapping(34, nodes, recop_cnt), 7)) when 34,
				std_logic_vector(to_unsigned(get_recop_mapping(35, nodes, recop_cnt), 7)) when 35,
				std_logic_vector(to_unsigned(get_recop_mapping(36, nodes, recop_cnt), 7)) when 36,
				std_logic_vector(to_unsigned(get_recop_mapping(37, nodes, recop_cnt), 7)) when 37,
				std_logic_vector(to_unsigned(get_recop_mapping(38, nodes, recop_cnt), 7)) when 38,
				std_logic_vector(to_unsigned(get_recop_mapping(39, nodes, recop_cnt), 7)) when 39,
				std_logic_vector(to_unsigned(get_recop_mapping(40, nodes, recop_cnt), 7)) when 40,
				std_logic_vector(to_unsigned(get_recop_mapping(41, nodes, recop_cnt), 7)) when 41,
				std_logic_vector(to_unsigned(get_recop_mapping(42, nodes, recop_cnt), 7)) when 42,
				std_logic_vector(to_unsigned(get_recop_mapping(43, nodes, recop_cnt), 7)) when 43,
				std_logic_vector(to_unsigned(get_recop_mapping(44, nodes, recop_cnt), 7)) when 44,
				std_logic_vector(to_unsigned(get_recop_mapping(45, nodes, recop_cnt), 7)) when 45,
				std_logic_vector(to_unsigned(get_recop_mapping(46, nodes, recop_cnt), 7)) when 46,
				std_logic_vector(to_unsigned(get_recop_mapping(47, nodes, recop_cnt), 7)) when 47,
				std_logic_vector(to_unsigned(get_recop_mapping(48, nodes, recop_cnt), 7)) when 48,
				std_logic_vector(to_unsigned(get_recop_mapping(49, nodes, recop_cnt), 7)) when 49,
				std_logic_vector(to_unsigned(get_recop_mapping(50, nodes, recop_cnt), 7)) when 50,
				std_logic_vector(to_unsigned(get_recop_mapping(51, nodes, recop_cnt), 7)) when 51,
				std_logic_vector(to_unsigned(get_recop_mapping(52, nodes, recop_cnt), 7)) when 52,
				std_logic_vector(to_unsigned(get_recop_mapping(53, nodes, recop_cnt), 7)) when 53,
				std_logic_vector(to_unsigned(get_recop_mapping(54, nodes, recop_cnt), 7)) when 54,
				std_logic_vector(to_unsigned(get_recop_mapping(55, nodes, recop_cnt), 7)) when 55,
				std_logic_vector(to_unsigned(get_recop_mapping(56, nodes, recop_cnt), 7)) when 56,
				std_logic_vector(to_unsigned(get_recop_mapping(57, nodes, recop_cnt), 7)) when 57,
				std_logic_vector(to_unsigned(get_recop_mapping(58, nodes, recop_cnt), 7)) when 58,
				std_logic_vector(to_unsigned(get_recop_mapping(59, nodes, recop_cnt), 7)) when 59,
				std_logic_vector(to_unsigned(get_recop_mapping(60, nodes, recop_cnt), 7)) when 60,
				std_logic_vector(to_unsigned(get_recop_mapping(61, nodes, recop_cnt), 7)) when 61,
				std_logic_vector(to_unsigned(get_recop_mapping(62, nodes, recop_cnt), 7)) when 62,
				std_logic_vector(to_unsigned(get_recop_mapping(63, nodes, recop_cnt), 7)) when 63,
				std_logic_vector(to_unsigned(get_recop_mapping(64, nodes, recop_cnt), 7)) when 64,
				std_logic_vector(to_unsigned(get_recop_mapping(65, nodes, recop_cnt), 7)) when 65,
				std_logic_vector(to_unsigned(get_recop_mapping(66, nodes, recop_cnt), 7)) when 66,
				std_logic_vector(to_unsigned(get_recop_mapping(67, nodes, recop_cnt), 7)) when 67,
				std_logic_vector(to_unsigned(get_recop_mapping(68, nodes, recop_cnt), 7)) when 68,
				std_logic_vector(to_unsigned(get_recop_mapping(69, nodes, recop_cnt), 7)) when 69,
				std_logic_vector(to_unsigned(get_recop_mapping(70, nodes, recop_cnt), 7)) when 70,
				std_logic_vector(to_unsigned(get_recop_mapping(71, nodes, recop_cnt), 7)) when 71,
				std_logic_vector(to_unsigned(get_recop_mapping(72, nodes, recop_cnt), 7)) when 72,
				std_logic_vector(to_unsigned(get_recop_mapping(73, nodes, recop_cnt), 7)) when 73,
				std_logic_vector(to_unsigned(get_recop_mapping(74, nodes, recop_cnt), 7)) when 74,
				std_logic_vector(to_unsigned(get_recop_mapping(75, nodes, recop_cnt), 7)) when 75,
				std_logic_vector(to_unsigned(get_recop_mapping(76, nodes, recop_cnt), 7)) when 76,
				std_logic_vector(to_unsigned(get_recop_mapping(77, nodes, recop_cnt), 7)) when 77,
				std_logic_vector(to_unsigned(get_recop_mapping(78, nodes, recop_cnt), 7)) when 78,
				std_logic_vector(to_unsigned(get_recop_mapping(79, nodes, recop_cnt), 7)) when 79,
				std_logic_vector(to_unsigned(get_recop_mapping(80, nodes, recop_cnt), 7)) when 80,
				std_logic_vector(to_unsigned(get_recop_mapping(81, nodes, recop_cnt), 7)) when 81,
				std_logic_vector(to_unsigned(get_recop_mapping(82, nodes, recop_cnt), 7)) when 82,
				std_logic_vector(to_unsigned(get_recop_mapping(83, nodes, recop_cnt), 7)) when 83,
				std_logic_vector(to_unsigned(get_recop_mapping(84, nodes, recop_cnt), 7)) when 84,
				std_logic_vector(to_unsigned(get_recop_mapping(85, nodes, recop_cnt), 7)) when 85,
				std_logic_vector(to_unsigned(get_recop_mapping(86, nodes, recop_cnt), 7)) when 86,
				std_logic_vector(to_unsigned(get_recop_mapping(87, nodes, recop_cnt), 7)) when 87,
				std_logic_vector(to_unsigned(get_recop_mapping(88, nodes, recop_cnt), 7)) when 88,
				std_logic_vector(to_unsigned(get_recop_mapping(89, nodes, recop_cnt), 7)) when 89,
				std_logic_vector(to_unsigned(get_recop_mapping(90, nodes, recop_cnt), 7)) when 90,
				std_logic_vector(to_unsigned(get_recop_mapping(91, nodes, recop_cnt), 7)) when 91,
				std_logic_vector(to_unsigned(get_recop_mapping(92, nodes, recop_cnt), 7)) when 92,
				std_logic_vector(to_unsigned(get_recop_mapping(93, nodes, recop_cnt), 7)) when 93,
				std_logic_vector(to_unsigned(get_recop_mapping(94, nodes, recop_cnt), 7)) when 94,
				std_logic_vector(to_unsigned(get_recop_mapping(95, nodes, recop_cnt), 7)) when 95,
				std_logic_vector(to_unsigned(get_recop_mapping(96, nodes, recop_cnt), 7)) when 96,
				std_logic_vector(to_unsigned(get_recop_mapping(97, nodes, recop_cnt), 7)) when 97,
				std_logic_vector(to_unsigned(get_recop_mapping(98, nodes, recop_cnt), 7)) when 98,
				std_logic_vector(to_unsigned(get_recop_mapping(99, nodes, recop_cnt), 7)) when 99,
				std_logic_vector(to_unsigned(get_recop_mapping(100, nodes, recop_cnt), 7)) when 100,
				std_logic_vector(to_unsigned(get_recop_mapping(101, nodes, recop_cnt), 7)) when 101,
				std_logic_vector(to_unsigned(get_recop_mapping(102, nodes, recop_cnt), 7)) when 102,
				std_logic_vector(to_unsigned(get_recop_mapping(103, nodes, recop_cnt), 7)) when 103,
				std_logic_vector(to_unsigned(get_recop_mapping(104, nodes, recop_cnt), 7)) when 104,
				std_logic_vector(to_unsigned(get_recop_mapping(105, nodes, recop_cnt), 7)) when 105,
				std_logic_vector(to_unsigned(get_recop_mapping(106, nodes, recop_cnt), 7)) when 106,
				std_logic_vector(to_unsigned(get_recop_mapping(107, nodes, recop_cnt), 7)) when 107,
				std_logic_vector(to_unsigned(get_recop_mapping(108, nodes, recop_cnt), 7)) when 108,
				std_logic_vector(to_unsigned(get_recop_mapping(109, nodes, recop_cnt), 7)) when 109,
				std_logic_vector(to_unsigned(get_recop_mapping(110, nodes, recop_cnt), 7)) when 110,
				std_logic_vector(to_unsigned(get_recop_mapping(111, nodes, recop_cnt), 7)) when 111,
				std_logic_vector(to_unsigned(get_recop_mapping(112, nodes, recop_cnt), 7)) when 112,
				std_logic_vector(to_unsigned(get_recop_mapping(113, nodes, recop_cnt), 7)) when 113,
				std_logic_vector(to_unsigned(get_recop_mapping(114, nodes, recop_cnt), 7)) when 114,
				std_logic_vector(to_unsigned(get_recop_mapping(115, nodes, recop_cnt), 7)) when 115,
				std_logic_vector(to_unsigned(get_recop_mapping(116, nodes, recop_cnt), 7)) when 116,
				std_logic_vector(to_unsigned(get_recop_mapping(117, nodes, recop_cnt), 7)) when 117,
				std_logic_vector(to_unsigned(get_recop_mapping(118, nodes, recop_cnt), 7)) when 118,
				std_logic_vector(to_unsigned(get_recop_mapping(119, nodes, recop_cnt), 7)) when 119,
				std_logic_vector(to_unsigned(get_recop_mapping(120, nodes, recop_cnt), 7)) when 120,
				std_logic_vector(to_unsigned(get_recop_mapping(121, nodes, recop_cnt), 7)) when 121,
				std_logic_vector(to_unsigned(get_recop_mapping(122, nodes, recop_cnt), 7)) when 122,
				std_logic_vector(to_unsigned(get_recop_mapping(123, nodes, recop_cnt), 7)) when 123,
				std_logic_vector(to_unsigned(get_recop_mapping(124, nodes, recop_cnt), 7)) when 124,
				std_logic_vector(to_unsigned(get_recop_mapping(125, nodes, recop_cnt), 7)) when 125,
				std_logic_vector(to_unsigned(get_recop_mapping(126, nodes, recop_cnt), 7)) when 126,
				std_logic_vector(to_unsigned(get_recop_mapping(127, nodes, recop_cnt), 7)) when 127,
				(others => 'X') when others;

			with dprr_asp_ID(i) select dprr_asp_port(i) <=
				std_logic_vector(to_unsigned(get_asp_mapping(0, nodes, jop_cnt, recop_cnt), 7)) when 0,
				std_logic_vector(to_unsigned(get_asp_mapping(1, nodes, jop_cnt, recop_cnt), 7)) when 1,
				std_logic_vector(to_unsigned(get_asp_mapping(2, nodes, jop_cnt, recop_cnt), 7)) when 2,
				std_logic_vector(to_unsigned(get_asp_mapping(3, nodes, jop_cnt, recop_cnt), 7)) when 3,
				std_logic_vector(to_unsigned(get_asp_mapping(4, nodes, jop_cnt, recop_cnt), 7)) when 4,
				std_logic_vector(to_unsigned(get_asp_mapping(5, nodes, jop_cnt, recop_cnt), 7)) when 5,
				std_logic_vector(to_unsigned(get_asp_mapping(6, nodes, jop_cnt, recop_cnt), 7)) when 6,
				std_logic_vector(to_unsigned(get_asp_mapping(7, nodes, jop_cnt, recop_cnt), 7)) when 7,
				std_logic_vector(to_unsigned(get_asp_mapping(8, nodes, jop_cnt, recop_cnt), 7)) when 8,
				std_logic_vector(to_unsigned(get_asp_mapping(9, nodes, jop_cnt, recop_cnt), 7)) when 9,
				std_logic_vector(to_unsigned(get_asp_mapping(10, nodes, jop_cnt, recop_cnt), 7)) when 10,
				std_logic_vector(to_unsigned(get_asp_mapping(11, nodes, jop_cnt, recop_cnt), 7)) when 11,
				std_logic_vector(to_unsigned(get_asp_mapping(12, nodes, jop_cnt, recop_cnt), 7)) when 12,
				std_logic_vector(to_unsigned(get_asp_mapping(13, nodes, jop_cnt, recop_cnt), 7)) when 13,
				std_logic_vector(to_unsigned(get_asp_mapping(14, nodes, jop_cnt, recop_cnt), 7)) when 14,
				std_logic_vector(to_unsigned(get_asp_mapping(15, nodes, jop_cnt, recop_cnt), 7)) when 15,
				(others => 'X') when others;

			dprr_int(i)	<= dprr_valid(i) & '0' & dprr_recop_port(i)(5 downto 0) & dprr_in(i)(23 downto 0) 																			when (dprr_valid(i) = '1' and dprr_legacy(i) = '0') else
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & dprr_in(i)(25 downto 22) & dprr_jop_port(i)(3 downto 0) & dprr_in(i)(17 downto 0) when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '0') else -- Sending INVOKE
								dprr_valid(i) & '1' & dprr_asp_port(i)(3 downto 0) & '0' & dprr_in(i)(24 downto 0) 																		when (dprr_valid(i) = '1' and dprr_legacy(i) = '1' and dpcr_out_sel(i) = '1') else -- Sending STORE data
								(others => '0') ;
		end generate;
	end generate;
	
	dprr_buffer_gen: for i in 0 to jop_cnt-1 generate
		dprr_buffer : min_switch_in_fifo
			generic map(
				gen_depth => fifo_depth
			)
			port map(
				aclr	=>	reset,
				clock	=> clk,
				data	=> dprr_int(i),
				rdreq => fifo_ack(i),
				wrreq => dprr_int(i)(31),
				empty	=> open,
				full	=> open,
				q		=> dprr_fifo(i)
			
			);
	end generate;
	
	process(tdm_slot)
		variable n_rx	: port_array(jop_cnt-1 downto 0);
	begin
		for i in 0 to jop_cnt-1 loop
			n_rx(i)(stages_cnt-1 downto 0) := reverse_n_bits(dprr_jop_port(i), stages_cnt) xor tdm_slot;
			
			debug1(i)(stages_cnt-1 downto 0) <= reverse_n_bits(dprr_jop_port(i), stages_cnt);
			debug2(i)(stages_cnt-1 downto 0) <= tdm_slot;
			debug1(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
			debug2(i)(n_rx(i)'LENGTH-1 downto stages_cnt) <= (others=> '0');
			
			debug3(i)	<= n_rx(i);
			debug4(i)	<= dprr_fifo(i)(30 downto 24);
			
			n_rx(i)(n_rx(i)'LENGTH-1 downto stages_cnt) := (others=> '0');

			-- AJS
			if (dprr_fifo(i)(31) = '1') then
				if ((dprr_fifo(i)(30) = '1') and (n_rx(i)(3 downto 0) = dprr_fifo(i)(29 downto 26))) then
					dprr_out(i) <= dprr_fifo(i);
					fifo_ack(i)	<= '1';
				elsif ((n_rx(i) = dprr_fifo(i)(30 downto 24))) then
					dprr_out(i) <= dprr_fifo(i);
					fifo_ack(i)	<= '1';
				else
					dprr_out(i) <= (others => '0');
					fifo_ack(i) <= '0';
				end if;
			else
				dprr_out(i) <= (others => '0');
				fifo_ack(i) <= '0';
			end if;
		end loop;
	end process;
	
	-- AJS
	process (dprr_int, clk, dpcr_out_sel)
	begin
		for i in 0 to jop_cnt-1 loop
			if (rising_edge(clk)) then
				if (dpcr_out_sel(i) = '0') then
					if (dprr_int(i)(31 downto 30) = "11") then
						dpcr_out_sel(i) <= '1';
						if (dprr_int(i)(25 downto 22) = "0100") then
							expected_asp_packets_in(i) <= "10";
						else
							expected_asp_packets_in(i) <= "00";
						end if;
					end if;
				else
					if (dpcr_out_asp(i)(31 downto 30) = "11") and
						(dpcr_out_asp(i)(17 downto 16) = expected_asp_packets_in(i)) and
						(asp_ack(i) = '1') then
						dpcr_out_sel(i) <= '0';
					end if;
				end if;
			end if;
		end loop;

	end process;

	-- AJS
	dpcr_out_mux : process(dpcr_out_sel, dpcr_out_asp, dpcr_out_recop, dpcr_ack)
	begin
		for i in 0 to jop_cnt-1 loop
			if (dpcr_out_sel(i) = '1') then
				dpcr_out(i) <= dpcr_out_asp(i);
				asp_ack(i) <= dpcr_ack(i);
				recop_ack(i) <= '0';
			else
				dpcr_out(i) <= dpcr_out_recop(i);
				asp_ack(i) <= '0';
				recop_ack(i) <= dpcr_ack(i);
			end if;
		end loop;
	end process ; -- dpcr_out_mux


end architecture;