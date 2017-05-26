--
--  Copyright 2012 Rasmus Bo Soerensen <rasmus@rbscloud.dk>,
--                 Technical University of Denmark, DTU Informatics. 
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
--
--                

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.min_ports_pkg.all;
use work.noc_types.all;

entity TDMA_MINoC is
	generic(
		number_of_nodes	: integer := 6;
		buffer_depth		: integer := 2
	);
	port(
		clk			: in std_logic;
		reset			: in std_logic;
		tdm_slot		: in std_logic_vector(integer(ceil(log2(real(number_of_nodes))))-1 downto 0);
		in_port		: in NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1);
		out_port		: out NOC_LINK_ARRAY_TYPE(0 to number_of_nodes-1)
	);
end entity TDMA_MINoC;

architecture struct of TDMA_MINoC is

	constant number_of_stages : integer := integer(ceil(log2(real(number_of_nodes))));                                                                      
	constant switches_per_stage : integer := integer(2 ** (number_of_stages-1));

	component min_switch is
		generic(
			number_of_stages	: integer range 1 to 8 := 3;
			stage					: integer range 1 to 8 := 1
		);
		port(
			tdm_slot		: in std_logic_vector(number_of_stages-1 downto 0);
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
	signal shuffle_wire	: min_wire(1 to number_of_stages);
	
begin
	
	assert number_of_stages <= 8
				report "To many nodes in network! Current design only supports 7 bit addresses for nodes. Max number of nodes is 128"
				severity error;
		
				
	stage : for s in 1 to number_of_stages generate
		s_in : if s = 1 generate
			switch : for x in 0 to switches_per_stage-1 generate
				more_than_one_statge : if number_of_stages > 1 generate
					twoPortSwitch : if (2*x)+1 < number_of_nodes generate
						sx : min_switch
						generic map(
							number_of_stages	=> number_of_stages,
							stage					=> s
						)
						port map(
							in_portA		=> in_port(2*x),
							in_portB		=> in_port(2*x +1),
							tdm_slot		=> tdm_slot,
							out_portA	=> shuffle_wire(s)(2*x),
							out_portB	=> shuffle_wire(s)(2*x +1)
						);
					end generate;
					onePortSwitch : if (2*x)+1 = number_of_nodes generate
						sx : min_switch
						generic map(
							number_of_stages	=> number_of_stages,
							stage					=> s
						)
						port map(
							in_portA		=> in_port(2*x),
							in_portB		=> x"00000000",
							tdm_slot		=> tdm_slot,
							out_portA	=> shuffle_wire(s)(2*x),
							out_portB	=> shuffle_wire(s)(2*x +1)
						);
					end generate;
				end generate;
				single_stage : if number_of_stages = 1 generate
					twoPortSwitch : if (2*x)+1 < number_of_nodes generate
						sx : min_switch
						generic map(
							number_of_stages	=> number_of_stages,
							stage					=> s
						)
						port map(
							in_portA		=> in_port(2*x),
							in_portB		=> in_port(2*x +1),
							tdm_slot		=> tdm_slot,
							out_portA	=> out_port(2*x),
							out_portB	=> out_port(2*x + 1)
						);
					end generate;
					onePortSwitch : if (2*x)+1 = number_of_nodes generate
						sx : min_switch
						generic map(
							number_of_stages	=> number_of_stages,
							stage					=> s
						)
						port map(
							in_portA		=> in_port(2*x),
							in_portB		=> x"00000000",
							tdm_slot		=> tdm_slot,
							out_portA	=> out_port(2*x),
							out_portB	=> open
						);
					end generate;
				end generate;
			end generate;
		end generate;
		
		s_mid : if s > 1 and s < number_of_stages generate
			switch : for x in 0 to switches_per_stage-1 generate
				sx : min_switch
				generic map(
						number_of_stages	=> number_of_stages,
						stage					=> s
					)
				port map(
					in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
					in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
					tdm_slot		=> tdm_slot,
					out_portA	=> shuffle_wire(s)(2*x),
					out_portB	=> shuffle_wire(s)(2*x +1)
				);
			end generate;
		end generate;
		
		s_out : if s = number_of_stages and s > 1 generate
			switch : for x in 0 to switches_per_stage-1 generate
				twoPortSwitch : if (2*x)+1 < number_of_nodes generate
					sx : min_switch
					generic map(
						number_of_stages	=> number_of_stages,
						stage					=> s
					)
					port map(
						in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
						in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
						tdm_slot		=> tdm_slot,
						out_portA	=> out_port(2*x),
						out_portB	=> out_port(2*x + 1)
					);
				end generate;
				onePortSwitch : if (2*x)+1 = number_of_nodes generate
					sx : min_switch
					generic map(
						number_of_stages	=> number_of_stages,
						stage					=> s
					)
					port map(
						in_portA		=> shuffle_wire(s-1)(get_wire_mapping(x,0,s-1)),
						in_portB		=> shuffle_wire(s-1)(get_wire_mapping(x,1,s-1)),
						tdm_slot		=> tdm_slot,
						out_portA	=> out_port(2*x),
						out_portB	=> open
					);
				end generate;
			end generate;
		end generate;
	end generate;
	
end architecture struct;

