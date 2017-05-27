library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.noc_types.all;
use work.HMPSoC_config.all;
use work.min_ports_pkg.all;

entity tdm_slot_counter is
	generic(
		number_of_stages	: integer range 1 to 8
	);
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		data_call_valid : in std_logic_vector((2 ** number_of_stages)-1 downto 0);
		clear_jop_status : in std_logic_vector((2 ** number_of_stages)-1 downto 0);
		jop_free : out std_logic_vector(num_recop-1 downto 0);
		q			: out std_logic_vector(number_of_stages-1 downto 0)
	);
end entity;

architecture beh of tdm_slot_counter is
	constant max_nodes  : integer := integer(2 ** (number_of_stages));
	constant nodes      : integer := num_recop + num_jop;
	type recop_address is array(integer range<>) of std_logic_vector(number_of_stages-1 downto 0);
	signal data_node_status_register :  std_logic_vector(max_nodes-1 downto 0) := (others => '0');
	signal q_int    : std_logic_vector(number_of_stages-1 downto 0);
	signal recop_port_address : recop_address(num_recop-1 downto 0) := (others => (others => '0'));
--	signal recop_at : std_logic_vector(max_nodes-1 downto 0) := (others => '0');
--	signal jop_at : std_logic_vector(max_nodes-1 downto 0) := (others => '0');
begin

	normal_counter: if TDMA_OPTIMIZED = '0' generate
		process(reset, clk)
			variable count	: natural range 0 to (2**number_of_stages)-1;
		begin
			if (reset = '1') then
				count := 0;
			elsif rising_edge(clk) then
			  if count < (2**number_of_stages)-1 then
				 count := count + 1;
			  else
				 count := 0;
			  end if;
			end if;
			q_int <= std_logic_vector(to_unsigned(count, number_of_stages));
		end process;
	end generate;
	
	optimized_counter: if TDMA_OPTIMIZED ='1' generate
		process(reset, clk)
			variable count	: natural range 0 to TDMA_MAX_SLOT - 1;
		begin
			if (reset = '1') then
				count := 0;
			elsif rising_edge(clk) then
			  if count < TDMA_MAX_SLOT - 1 then
				 count := count + 1;
			  else
				 count := 0;
			  end if;
			end if;
			q_int <= std_logic_vector(to_unsigned(v_slot_counter(count), number_of_stages));
		end process;
	end generate;
	
	q <= q_int;
	
	
	------------------------------------------
	-- NAC
	------------------------------------------	
	dynamic_generation: if DYNAMIC = '1' or DYNAMIC_FIFO = '1' generate
		jop_free_gen: for i in 0 to num_recop-1 generate
			recop_port_address(i) <= std_logic_vector(to_unsigned(get_recop_mapping(i, nodes, num_recop), number_of_stages));
			jop_free(i) <= data_node_status_register(to_integer(unsigned(reverse_n_bits(recop_port_address(i), number_of_stages) xor q_int)));
		end generate;
		
--		recop_at_gen: for i in 0 to num_recop-1 generate
--			recop_at(get_recop_mapping(i, nodes, num_recop)) <= '1';
--		end generate;

--		jop_at_gen: for i in 1 to num_jop-1 generate
--			jop_at(get_jop_mapping(i, nodes, num_recop)) <= '1';
--		end generate;		
		
		DNSR: process(reset, clk)
		begin
			if reset = '1' then
				for i in 0 to max_nodes-1 loop
					data_node_status_register(i) <= '0'; -- 1 is free and 0 is busy
				end loop;
				for i in 1 to num_jop-1 loop
					data_node_status_register(get_jop_mapping(i, nodes, num_recop)) <= '1';
				end loop;
			elsif rising_edge(clk) then
				for i in 0 to max_nodes-1 loop
					if data_call_valid(i) = '1' then
						data_node_status_register(to_integer(unsigned(reverse_n_bits(std_logic_vector(to_unsigned(i, number_of_stages)), number_of_stages) xor q_int))) <= '0';
					end if;
					if clear_jop_status(i) = '1' and get_jop_mapping(0, nodes, num_recop) /= i then
						data_node_status_register(i) <= '1';
					end if;
				end loop;
			end if;
		end process;
	end generate;
	
end architecture;