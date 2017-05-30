library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.min_ports_pkg.all;
use work.noc_types.all;


entity MultiStageNetwork is
	generic(
		number_of_nodes	: integer := 6;
		buffer_depth		: integer := 2
	);
	port(
		clk			: in std_logic;
		reset			: in std_logic;
		in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
		out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1)
	);
end MultiStageNetwork;

architecture behaviour of MultiStageNetwork is

	constant number_of_stages : integer := integer(ceil(log2(real(number_of_nodes))));
	constant switches_per_stage : integer := integer(2 ** (number_of_stages-1));

	component min_switch is
		generic(
			this_stage		: positive range 1 to 4 := 1;
			buffer_depth	: positive := 4
		);
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			in_portA		: in std_logic_vector(31 downto 0);
			in_portB		: in std_logic_vector(31 downto 0);
			out_portA	: out std_logic_vector(31 downto 0);
			out_portB	: out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	
	function get_wire_mapping(
			switch	: integer;	-- switch number
			p			: integer;	-- port on switch (A/B)
			stage 	: integer	-- wire source stage
		)	return integer is
		
		variable subnet_switches: integer := 0;	-- switches in a subnet
		variable subnet_wires	: integer := 0;	-- wires/ports in a subnet
		variable subnet			: integer := 0;	-- subnet number for given switch
		variable w_src				: integer := 0;	-- subnet wire number from prev stage
		variable w_dest			: integer := 0;	-- subnet wire number for this stage
		variable m					: integer := 0;	-- final mapping / retun value
		
	begin
	
		subnet_switches	:= integer(real(switches_per_stage)/real(2**(stage-1)));
		subnet_wires		:= subnet_switches*2;
		subnet 				:= integer(floor(real(switch)/real(subnet_switches)));
		w_dest				:= (2*switch +p) mod subnet_wires;
		
		w_src	:= ( (2*w_dest) + integer(floor( real(2*w_dest) / real(subnet_wires))) ) mod subnet_wires;
		m		:= w_src + subnet*subnet_wires;
	
		return m;
		
	end get_wire_mapping;
	
	
	
	type min_wire is array(natural range<>) of min_port(0 to (2**number_of_stages)-1);
	signal shuffle_wire	: min_wire(1 to number_of_stages-1);

begin

	assert number_of_stages <= 3
				report "To many nodes in network! Current design only supports 3 bit addresses for nodes. Max number of nodes is 8"
				severity error;

	stage : for s in 1 to number_of_stages generate
		s_in : if s = 1 generate
			switch : for x in 0 to switches_per_stage-1 generate
				twoPortSwitch : if (2*x)+1 < number_of_nodes generate
					sx : min_switch
					generic map(
						this_stage		=> s,
						buffer_depth	=> buffer_depth*(2**(s-1))
					)
					port map(
						clk			=> clk,
						reset			=> reset,
						in_portA		=> in_port(2*x),
						in_portB		=> in_port(2*x +1),
						out_portA	=> shuffle_wire(s)(2*x),
						out_portB	=> shuffle_wire(s)(2*x +1)
					);
				end generate;
				onePortSwitch : if (2*x)+1 = number_of_nodes generate
					sx : min_switch
					generic map(
						this_stage		=> s,
						buffer_depth	=> buffer_depth*(2**(s-1))
					)
					port map(
						clk			=> clk,
						reset			=> reset,
						in_portA		=> in_port(2*x),
						in_portB		=> x"00000000",
						out_portA	=> shuffle_wire(s)(2*x),
						out_portB	=> shuffle_wire(s)(2*x +1)
					);
				end generate;
			end generate;
		end generate;
		
		s_mid : if s > 1 and s < number_of_stages generate
			switch : for x in 0 to switches_per_stage-1 generate
				sx : min_switch
				generic map(
					this_stage		=> s,
					buffer_depth	=> buffer_depth*(2**(s-1))
				)
				port map(
					clk			=> clk,
					reset			=> reset,
					in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
					in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
					out_portA	=> shuffle_wire(s)(2*x),
					out_portB	=> shuffle_wire(s)(2*x +1)
				);
			end generate;
		end generate;
		
		s_out : if s = number_of_stages generate
			switch : for x in 0 to switches_per_stage-1 generate
				twoPortSwitch : if (2*x)+1 < number_of_nodes generate
					sx : min_switch
					generic map(
						this_stage		=> s,
						buffer_depth	=> buffer_depth*(2**(s-1))
					)
					port map(
						clk			=> clk,
						reset			=> reset,
						in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
						in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
						out_portA	=> out_port(2*x),
						out_portB	=> out_port(2*x + 1)
					);
				end generate;
				onePortSwitch : if (2*x)+1 = number_of_nodes generate
					sx : min_switch
					generic map(
						this_stage		=> s,
						buffer_depth	=> buffer_depth*(2**(s-1))
					)
					port map(
						clk			=> clk,
						reset			=> reset,
						in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
						in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
						out_portA	=> out_port(2*x),
						out_portB	=> open
					);
				end generate;
			end generate;
		end generate;
	end generate;

end architecture;