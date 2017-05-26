library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
use work.HMPSoC_config.all;

package min_ports_pkg is
	type min_port is array(natural range<>) of std_logic_vector(31 downto 0);
	
	function get_addr_width (d	: integer) return integer;
	function get_recop_mapping(recop_id : integer; nodes : integer; recop_cnt : integer) return integer;
	function get_jop_mapping(jop_id : integer; nodes : integer; recop_cnt : integer) return integer;
	function get_asp_mapping(asp_id : integer; nodes : integer; jop_cnt : integer; recop_cnt : integer) return integer;
	function reverse_n_bits(in_vector : std_logic_vector;	n : integer) return std_logic_vector;

end min_ports_pkg;

package body min_ports_pkg is

	function get_addr_width (d	: integer) return integer is
		variable w	: integer := 0;
	begin
		w := integer(ceil(log2(real(d))));
		if w <= 0 then
			return 1;
		else
			return w;
		end if;
	end get_addr_width;
	
	-------------------------------------------------------
	--  adaptive core mapping to network ports           --
	--  this avoides large number of package collisions  --
	-------------------------------------------------------
	function get_recop_mapping(
			recop_id	: integer;	-- id of recop
			nodes		: integer;
			recop_cnt: integer
		)	return integer is
		variable number_of_stages	: integer	:= 0;
		variable max_nodes			: integer	:= 0;
		variable recop_spread		: real 		:= 0.0;
		variable p						: integer	:= 0;
	begin
		if TDMA_OPTIMIZED = '0' then
			number_of_stages	:= integer(ceil(log2(real(nodes))));
			max_nodes			:= integer(2 ** (number_of_stages));
			recop_spread		:= real(max_nodes) / real(recop_cnt);
			p						:= integer(floor(recop_spread*real(recop_id)));
		else
			p 						:= pReCOP(recop_id rem num_recop);
		end if;
		return p;
	end get_recop_mapping;
	
	function get_jop_mapping(
			jop_id	: integer;	-- id of jop
			nodes		: integer;
			recop_cnt: integer
		)	return integer is
		variable offset				: integer := 0;
		variable p						: integer	:= 0;
	begin
		if TDMA_OPTIMIZED = '0' then
			for j in 0 to jop_id loop
				for i in 0 to recop_cnt-1 loop
					if (j + offset) = get_recop_mapping(i, nodes, recop_cnt) then
						offset := offset + 1;
					end if;
				end loop;
			end loop;
			p := jop_id+offset;
		else
			p := pJOP(jop_id rem num_jop);
		end if;
		return p;
	end get_jop_mapping;
	
	function reverse_n_bits(
			in_vector	: std_logic_vector;
			n				: integer
		)	return std_logic_vector is
		variable out_vector	: std_logic_vector(in_vector'RANGE) := (others => '0');
	begin
		for i in 0 to (n-1) loop
			out_vector(i) := in_vector((n-1)-i);
		end loop;
		return out_vector(n-1 downto 0);
	end reverse_n_bits;

	-- AJS

	function get_asp_mapping(
		asp_id	: integer;  -- id of the ASP
		nodes		: integer;
		jop_cnt  : integer;
		recop_cnt  : integer
	) return integer is
		variable p		: integer := 0;
	begin

		p := get_jop_mapping(asp_id + jop_cnt, nodes, recop_cnt);

		return p;
	end get_asp_mapping;
	
end min_ports_pkg;