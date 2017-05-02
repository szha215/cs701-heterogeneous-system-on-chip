library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

--library lpm;
--use lpm.lpm_components.all;

library altera_mf;
use altera_mf.all;

---------------------------------------------------------------------------------------------------
entity asp is
-- generic and port declration here
generic(
	constant N : positive := 16;
	constant L : positive := 4
);
port(	clk		: in std_logic;
		reset		: in std_logic;
		valid		: in std_logic;
		d_in		: in std_logic_vector(31 downto 0);

		busy			: out std_logic;
		res_ready	: out std_logic;
		d_out			: out std_logic_vector(31 downto 0)
		);
end entity asp;

---------------------------------------------------------------------------------------------------
architecture behaviour of asp is
-- type, signal, constant declarations here

type states is (IDLE, STORE_RESET, STORE_INIT, STORE_WAIT, STORE_DATA, INVOKE_INIT, INVOKE, INVOKE_BUSY, XOR_1, AVE_1, AVE_2, MAC_1, MAC_2, SEND_ACC, SEND_DATA, SEND_PAUSE);	-- states
signal CS, NS	: states := IDLE;

signal d_in_copy	: std_logic_vector(31 downto 0) := (others => '0');

type data_vector is array (0 to N - 1) of std_logic_vector(15 downto 0);
signal s_A, s_B : data_vector := (others => (others =>'0'));

-- Control signals
signal words_stored_inc_en, packet_id_inc_en, wr_pointer_inc_en	: std_logic := '0';
signal op_ld, start_addr_ld, end_addr_ld, mem_sel_ld, src_port_ld, dest_port_ld, reg_a_ld, reg_b_ld, vector_ld	: std_logic := '0';
signal words_stored_reset, vectors_reset, packet_id_reset, ave_filter_reset, calc_result_reset	: std_logic := '0';
signal d_packet_sel, calc_res_sel 	: std_logic_vector(1 downto 0) := (others => '0');
signal d_out_sel, vector_addr_sel, vector_d_sel	: std_logic := '0';

signal cmp_store, cmp_sent, cmp_pointer_l, cmp_pointer_1 : std_logic := '0';


-- Datapath

signal s_op_code	: std_logic_vector(3 downto 0) := (others => '0');
signal s_start_addr, s_end_addr		: std_logic_vector(8 downto 0) := (others => '0');
signal s_mem_sel		: std_logic := '0';

signal s_packet_id		: std_logic_vector(1 downto 0) := (others => '0');
signal s_packet, s_data	: std_logic_vector(15 downto 0) := (others => '0');
signal s_d_out				: std_logic_vector(31 downto 0) := (others => '0');

signal s_addr_to_store	: std_logic_vector(8 downto 0) := (others => '0');
signal s_d_to_store	:std_logic_vector(15 downto 0) := (others => '0');

signal s_reg_a_out, s_reg_b_out	: std_logic_vector(15 downto 0) := (others => '0');
signal s_calc_res, s_mult_res, s_mac_res	: std_logic_vector(63 downto 0) := (others => '0');
signal s_xor_res, s_reg_out, s_ave_res	: std_logic_vector(15 downto 0) := (others => '0');


--type output_vector is array (0 to 3) of std_logic_vector(31 downto 0);
--signal s_output_buffer 							: output_vector := (others => (others =>'0'));
signal s_words_sent, s_words_to_send		: std_logic_vector(1 downto 0) := (others => '0');  -- max 4 packets
signal s_words_stored, s_words_to_store	: std_logic_vector(8 downto 0) := (others => '0');

signal s_store_addr	: std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

signal s_invoke_en, s_invoke_init, s_invoke_done	: std_logic := '0';
signal s_src_port, s_dest_port	: std_logic_vector(3 downto 0) := (others => '0');

signal s_pointer, s_wr_pointer : std_logic_vector(8 downto 0) := (others => '0');

---------------------------------------------------------------------------------------------------
-- component declaration here

component multiplier is
	generic( 
	in_width	: positive;
	res_witdh	: positive;
	result_lowbit	: natural
	);
	port(
	a		: in std_logic_vector(in_width-1 downto 0);
	b		: in std_logic_vector(in_width-1 downto 0);
	res	: out std_logic_vector(res_witdh-1 downto 0)
	);
end component;

component average_filter is
	generic(
		window_size	: positive := 4;
		data_width	: positive := 16
	);
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		data	: in std_logic_vector(data_width - 1 downto 0);

		avg	: out std_logic_vector(data_width - 1 downto 0)
	);
end component;

component reg_file is
generic(
	constant reg_num 	 : positive := 16;
	constant reg_width : positive := 16
);
port(	clk			: 	in std_logic;
		reset			: 	in std_logic;
		wr_en			:	in std_logic; 
		rd_reg1		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		rd_reg2		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		wr_reg		:	in std_logic_vector(integer(ceil(log2(real(reg_num)))) - 1 downto 0);
		wr_data		: 	in std_logic_vector(reg_width - 1 downto 0);

		data_out_a	:	out std_logic_vector(reg_width - 1 downto 0);
		data_out_b	:	out std_logic_vector(reg_width - 1 downto 0)
		);
end component reg_file;

component altsyncram
	generic (
		address_aclr_b		: string;
		address_reg_b		: string;
		clock_enable_input_a		: string;
		clock_enable_input_b		: string;
		clock_enable_output_b		: string;
		init_file	: string;
		intended_device_family		: string;
		lpm_type		: string;
		numwords_a		: natural;
		numwords_b		: natural;
		operation_mode		: string;
		outdata_aclr_b		: string;
		outdata_reg_b		: string;
		power_up_uninitialized		: string;
		read_during_write_mode_mixed_ports		: string;
		widthad_a		: natural;
		widthad_b		: natural;
		width_a		: natural;
		width_b		: natural;
		width_byteena_a		: natural
	);
	port (
			aclr0	: in std_logic ;
			address_a	: in std_logic_vector (8 downto 0);
			clock0	: in std_logic ;
			data_a	: in std_logic_vector (15 downto 0);
			q_b	: out std_logic_vector (15 downto 0);
			wren_a	: in std_logic ;
			address_b	: in std_logic_vector (8 downto 0)
	);
	end component;

component data_mem is
generic(
	constant ram_addr_width : positive := 16;
	constant ram_data_width : positive := 16
);

port (
	wr_en		:	in std_logic;
	addr		:	in std_logic_vector(ram_addr_width - 1 downto 0);
	data_in	:	in std_logic_vector(ram_data_width - 1 downto 0);

	data_out	:	out std_logic_vector(ram_data_width - 1 downto 0)		
) ;
end component ; -- data_mem

---------------------------------------------------------------------------------------------------
begin
-- component wiring here

mult_block : multiplier
	generic map(
		in_width			=> 16,
		res_witdh		=> 64,
		result_lowbit	=> 0
	)
	port map(
		a		=> s_reg_a_out,
		b		=> s_reg_b_out,
		res	=> s_mult_res
	);

aveage_block : average_filter
	generic map(
		window_size	=> L,
		data_width	=> 16
	)
	port map(
		clk	=> clk,
		reset	=> ave_filter_reset,
		data	=> s_reg_out,

		avg	=> s_ave_res
	);


-- REGISTER

--reg_a : reg_file
--	generic map(
--		reg_num 		=> N,
--		reg_width	=> 16
--	)
--	port map(
--		clk		=> clk,
--		reset		=> vectors_reset,
--		wr_en		=> reg_a_ld,
--		rd_reg1	=> s_pointer(integer(ceil(log2(real(N)))) - 1 downto 0),
--		rd_reg2	=> (others => '0'),
--		wr_reg	=> s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
--		wr_data	=> s_d_to_store,

--		data_out_a	=> s_reg_a_out,
--		data_out_b	=> open
--	);

--reg_b : reg_file
--	generic map(
--		reg_num 		=> N,
--		reg_width	=> 16
--	)
--	port map(
--		clk		=> clk,
--		reset		=> vectors_reset,
--		wr_en		=> reg_b_ld,
--		rd_reg1	=> s_pointer(integer(ceil(log2(real(N)))) - 1 downto 0),
--		rd_reg2	=> (others => '0'),
--		wr_reg	=> s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
--		wr_data	=> s_d_to_store,

--		data_out_a	=> s_reg_b_out,
--		data_out_b	=> open
--	);

-- LPM

--ram_a : lpm_ram_dq
--	generic map(
--		lpm_widthad	=> integer(ceil(log2(real(N)))),
--		lpm_width	=> 16
--	)
--	port map(
--		data		=> s_d_to_store,
--		address	=> s_addr_to_store(integer(ceil(log2(real(N))))-1 downto 0),
--		we			=> reg_a_ld,
--		q			=> s_reg_a_out,
--		inclock	=> clk,
--		outclock	=> clk
--	);

--ram_a : ram
--	port map(
--		aclr	=> vectors_reset,
--		clock	=> clk,
--		data	=> s_d_to_store,
--		rdaddress	=> s_pointer,
--		wraddress	=> s_addr_to_store(integer(ceil(log2(real(N))))-1 downto 0),
--		wren	=> reg_a_ld,
--		q		=> s_reg_a_out
--	);


-- ALT RAM

--ram_a : altsyncram
--	generic map (
--		address_aclr_b => "CLEAR0",
--		address_reg_b => "clock0",
--		clock_enable_input_a => "BYPASS",
--		clock_enable_input_b => "BYPASS",
--		clock_enable_output_b => "BYPASS",
--		intended_device_family => "CYCLONE IV E",
--		lpm_type => "ALTSYNCRAM",
--		numwords_a => N,
--		numwords_b => N,
--		operation_mode => "DUAL_PORT",
--		outdata_aclr_b => "CLEAR0",
--		outdata_reg_b => "CLOCK0",
--		power_up_uninitialized => "FALSE",
--		read_during_write_mode_mixed_ports => "OLD_DATA",
--		widthad_a => integer(ceil(log2(real(N)))),
--		widthad_b => integer(ceil(log2(real(N)))),
--		width_a => 16,
--		width_b => 16,
--		width_byteena_a => 1
--	)
--	port map (
--		clock0 => clk,
--		aclr0 => vectors_reset,
--		address_a => s_addr_to_store(integer(ceil(log2(real(N))))-1 downto 0),
--		data_a => s_d_to_store,
--		wren_a => reg_a_ld,
--		address_b => s_pointer(integer(ceil(log2(real(N))))-1 downto 0),
--		q_b => s_reg_a_out
--	);

ram_a : altsyncram
	generic map (
		address_aclr_b => "CLEAR0",
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_b => "BYPASS",
		init_file => "ram_a.mif",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		numwords_a => N,
		numwords_b => N,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "CLEAR0",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		widthad_a => integer(ceil(log2(real(N)))),
		widthad_b => integer(ceil(log2(real(N)))),
		width_a => 16,
		width_b => 16,
		width_byteena_a => 1
	)
	port map (
		clock0 => clk,
		aclr0 => vectors_reset,
		address_a => s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
		data_a => s_d_to_store,
		wren_a => reg_a_ld,
		address_b => s_pointer(integer(ceil(log2(real(N)))) - 1 downto 0),
		q_b => s_reg_a_out
	);

ram_b : altsyncram
	generic map (
		address_aclr_b => "CLEAR0",
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_b => "BYPASS",
		init_file => "ram_b.mif",
		intended_device_family => "Cyclone IV E",
		lpm_type => "altsyncram",
		numwords_a => N,
		numwords_b => N,
		operation_mode => "DUAL_PORT",
		outdata_aclr_b => "CLEAR0",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		widthad_a => integer(ceil(log2(real(N)))),
		widthad_b => integer(ceil(log2(real(N)))),
		width_a => 16,
		width_b => 16,
		width_byteena_a => 1
	)
	port map (
		clock0 => clk,
		aclr0 => vectors_reset,
		address_a => s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
		data_a => s_d_to_store,
		wren_a => reg_b_ld,
		address_b => s_pointer(integer(ceil(log2(real(N)))) - 1 downto 0),
		q_b => s_reg_b_out
	);	

---------------------------------------------------------------------------------------------------
state_updater: process(clk, reset)
begin
	if (reset = '1') then
		CS <= IDLE;
	elsif (rising_edge(clk)) then
		CS <= NS;
	end if;
end process state_updater;

---------------------------------------------------------------------------------------------------
state_transition_logic : process(clk)
begin
	case CS is	-- must cover all states
		when IDLE =>
			if (valid = '1') then
				case (d_in(25 downto 22)) is
					when "0000" =>
						NS <= STORE_RESET;

					when "0001" =>
						NS <= STORE_INIT;

					--when "0010" =>
					--	NS <= INVOKE;

					when others =>
						NS <= INVOKE_INIT;
				end case;

			else
				NS <= IDLE;
			end if;

		when STORE_RESET =>
			NS <= SEND_ACC;

		when STORE_INIT =>
			NS <= STORE_WAIT;

		when STORE_WAIT =>
			if (valid = '1') then
				NS <= STORE_DATA;
			else
				NS <= STORE_WAIT;
			end if;

		when STORE_DATA =>
			if (cmp_store = '1') then
				NS <= SEND_ACC;
			else
				NS <= STORE_WAIT;
			end if;

		when INVOKE_INIT =>
			case (d_in_copy(25 downto 22)) is
				when "0010" =>
					NS <= XOR_1;

				when "0011" =>
					NS <= XOR_1;

				when "0100" =>
					NS <= MAC_1;

				when "0101" =>
					NS <= AVE_1;

				when "0110" =>
					NS <= AVE_1;

				when others =>
					NS <= IDLE;
			end case;

		when INVOKE =>
			NS <= INVOKE_BUSY;

		when INVOKE_BUSY =>
			if (s_invoke_done = '1') then
				NS <= SEND_DATA;
			else
				NS <= INVOKE_BUSY;
			end if;

		when XOR_1 =>

		when MAC_1 =>
			if (s_invoke_done = '1') then
				NS <= MAC_2;
			else
				NS <= MAC_1;
			end if;

		when MAC_2 =>
			NS <= SEND_PAUSE;

		when AVE_1 =>
			if (cmp_pointer_l = '1') then
				NS <= AVE_2;
			else
				NS <= AVE_1;
			end if;

		when AVE_2 =>
			if (cmp_pointer_1 = '1') then
				NS <= SEND_ACC;
			else
				NS <= AVE_2;
			end if;

		when SEND_ACC =>
			NS <= IDLE;

		when SEND_DATA =>
			if (cmp_sent = '1') then
				NS <= IDLE;
			else
				NS <= SEND_PAUSE;
			end if;

		when SEND_PAUSE =>
			NS <= SEND_DATA;

		when others =>
			report "STATE TRANSITION: BAD STATE" severity error;
			NS <= IDLE;
			
	end case;
end process state_transition_logic;

---------------------------------------------------------------------------------------------------
output_logic : process(CS)
begin
	dest_port_ld <= '0';
	op_ld <= '0';
	end_addr_ld <= '0';
	start_addr_ld <= '0';
	mem_sel_ld <= '0';
	src_port_ld <= '0';

	vector_ld <= '0';
	vector_d_sel <= '0';
	vectors_reset <= '0';
	words_stored_reset <= '0';
	words_stored_inc_en <= '0';

	wr_pointer_inc_en <= '0';
	vector_addr_sel <= '1';

	busy <= '0';
	res_ready <= '0';

	calc_result_reset <= '0';
	calc_res_sel <= "00";

	packet_id_reset <= '0';
	packet_id_inc_en <= '0';
	d_out_sel <= '1';

	ave_filter_reset <= '0';

	case CS is
		when IDLE =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			words_stored_reset <= '1';
			packet_id_reset <= '1';

			ave_filter_reset <= '1';
			s_words_sent <= (others => '0');

			calc_result_reset <= '1';

		when STORE_RESET =>
			vectors_reset <= '1';

			start_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_ld <= '1';

		when STORE_INIT =>
			s_invoke_init <= '0';
			op_ld <= '1';
			
			--report "STORE INIT: words to store = " & integer'image(to_integer(unsigned(d_in_copy(integer(ceil(log2(real(N))))) - 1  downto 0)));
			start_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_ld <= '1';

			vector_addr_sel <= '0';

		when STORE_WAIT =>
			s_invoke_en <= '0';
			s_invoke_init <= '0';

			s_words_sent <= (others => '0');

			vector_addr_sel <= '0';

		when STORE_DATA =>
			s_invoke_en <= '1';
			s_invoke_init <= '0';

			words_stored_inc_en <= '1';
			vector_ld <= '1';

			vector_addr_sel <= '0';

			-- s_words_stored <= (others => '0');
			s_words_sent <= (others => '0');

			busy <= '1';
			
			--report "STORE ADDR = " & integer'image(conv_integer(unsigned(d_in_copy(24 downto 16))));
			--report "STORE DATA = " & integer'image(conv_integer(unsigned(d_in_copy(15 downto 0))));
			--if (s_mem_sel = '1') then  -- B
			--	s_B(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			--else
			--	s_A(conv_integer(unsigned(d_in_copy(24 downto 16)))) <= (d_in_copy(15 downto 0));
			--end if;

		when INVOKE_INIT =>
			s_invoke_init <= '1';
			ave_filter_reset <= '1';

			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';

			vector_addr_sel <= '1';

			calc_result_reset <= '1';

			busy <= '1';

		when INVOKE =>
			s_invoke_en <= '1';
			s_invoke_init <= '1';
			ave_filter_reset <= '1';

			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';

			vector_addr_sel <= '1';

			busy <= '1';

		when INVOKE_BUSY =>
			report "OP CODE = " & integer'image(to_integer(unsigned(s_op_code)));

			s_invoke_en <= '1';
			s_invoke_init <= '0';

			vector_addr_sel <= '1';

			busy <= '1';

		when XOR_1 =>

			calc_res_sel <= "01";

			busy <= '1';

		when MAC_1 =>

			calc_res_sel <= "10";

			busy <= '1';
			
		when MAC_2 =>

			calc_res_sel <= "10";

			busy <= '1';
			
		when AVE_1 =>

			calc_res_sel <= "00";

			busy <= '1';
			
		when AVE_2 =>

			wr_pointer_inc_en <= '1';
			calc_res_sel <= "00";

			busy <= '1';
			
		when SEND_ACC =>
			s_invoke_en <= '0';

			d_out_sel <= '0';

			busy <= '1';
			res_ready <= '1';

		when SEND_DATA =>

			s_invoke_en <= '0';
			s_invoke_init <= '0';

			d_out_sel <= '1';

			busy <= '1';
			res_ready <= '1';
			--if (s_mem_sel = '1') then  -- B
			--	d_out <= "1100010001001000" & s_B(6);
			--else
			--	d_out <= "1100010001001000" & s_A(6);
			--end if;

		when SEND_PAUSE =>

			s_invoke_en <= '0';
			s_invoke_init <= '0';

			busy <= '1';
			packet_id_inc_en <= '1';

		when others =>
			s_invoke_en <= '0';
			s_invoke_init <= '1';

			s_words_sent <= (others => '0');
			
			report "STATE OUTPUT: BAD STATE" severity error;
			
	end case;
end process output_logic;

---------------------------------------------------------------------------------------------------
-- other processes here
copy_d_in : process(clk)
begin
	if (rising_edge(clk)) then
		if (valid = '1') then
			d_in_copy <= d_in;
		end if;
	end if;
end process;

---------------------------------------------------------------------------------------------------
--invoke_process : process(clk, s_invoke_en)
--begin
--	if (rising_edge(clk)) then

--		--if (s_invoke_init = '1') then
--		--	s_pointer <= d_in_copy(8 downto 0);
--		--elsif (s_invoke_done = '0') then
--		--	s_pointer <= s_pointer + '1';
--		--end if;	
--		if (s_invoke_en = '1') then
--			case(s_op_code) is
			
--				when "0010" =>	-- XOR A
--					--s_calc_res(15 downto 0) <= s_calc_res(15 downto 0) xor s_reg_a_out;
--					calc_res_sel <= "01";

--				when "0011" => -- XOR B
--					--s_calc_res(15 downto 0) <= s_calc_res(15 downto 0) xor s_reg_b_out;
--					calc_res_sel <= "01";

--				when "0100" => -- MAC


--				when "0101" => -- AVE A


--				when "0110" => -- AVE B
					
			
--				when others =>
--					report "INVOKE: bad OP" severity error;
			
--			end case;

--		else
--			calc_res_sel <= "01";
--		end if;
--	end if;

--end process;

---------------------------------------------------------------------------------------------------
op_code_process : process (clk, op_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (op_ld = '1') then
			s_op_code <= d_in_copy(25 downto 22);
		else
			s_op_code <= s_op_code;
		end if;
	end if;	
end process;

---------------------------------------------------------------------------------------------------
start_addr_process : process(clk, start_addr_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (start_addr_ld = '1') then
			s_start_addr <= d_in_copy(8 downto 0);
		else
			s_start_addr <= s_start_addr;
		end if;
	end if;

	s_words_to_store <= s_start_addr - '1';

end process;

---------------------------------------------------------------------------------------------------
end_addr_process : process(clk, end_addr_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (end_addr_ld = '1') then
			s_end_addr <= d_in_copy(17 downto 9);
		else
			s_end_addr <= s_end_addr;
		end if;
	end if;
end process ; -- end_addr_process

---------------------------------------------------------------------------------------------------
mem_sel_process : process(clk, mem_sel_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (mem_sel_ld = '1') then
			s_mem_sel <= d_in_copy(17);
		else
			s_mem_sel <= s_mem_sel;
		end if;
	end if;
end process ; -- mem_sel_process

---------------------------------------------------------------------------------------------------
words_stored_process : process(clk, words_stored_inc_en, words_stored_reset)
begin
	if (rising_edge(clk)) then
		if (words_stored_reset = '1') then
			s_words_stored <= (others => '0');
		elsif (words_stored_inc_en = '1') then
			s_words_stored <= s_words_stored + '1';
		else
			s_words_stored <= s_words_stored;
		end if;
	end if;
end process ; -- words_stored_process

---------------------------------------------------------------------------------------------------
src_port_process : process(clk, src_port_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (src_port_ld = '1') then
			s_src_port <= d_in_copy(21 downto 18);
		else
			s_src_port <= s_src_port;
		end if;
	end if;
end process ; -- src_port_process

---------------------------------------------------------------------------------------------------
dest_port_process : process(clk, dest_port_ld, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (dest_port_ld = '1') then
			s_dest_port <= d_in_copy(29 downto 26);
		else
			s_dest_port <= s_dest_port;
		end if;
	end if;
end process ; -- dest_port_process

---------------------------------------------------------------------------------------------------
store_complete : process(s_words_to_store, s_words_stored)
begin
	if (s_words_to_store = s_words_stored) then
		cmp_store <= '1';
	else
		cmp_store <= '0';
	end if;
end process ; -- store_complete

-----------------------------------------------------------------------------------------------------
--vector_store : process(clk, vector_ld, vectors_reset, s_mem_sel, d_in_copy)
--begin
--	if (rising_edge(clk)) then
--		if (vectors_reset = '1') then
--			s_A <= (others => (others => '0'));
--			s_B <= (others => (others => '0'));
--		elsif (vector_ld = '1') then
--			null;
--		end if;
--	end if;
--end process ; -- vector_b_store

---------------------------------------------------------------------------------------------------
sent_complete : process(s_words_to_send, s_words_sent)
begin
	if (s_words_to_send = s_words_sent) then
		cmp_sent <= '1';
	else
		cmp_sent <= '0';
	end if;
end process ; -- sent_complete

---------------------------------------------------------------------------------------------------
invoke_complete : process(clk, s_pointer, s_end_addr)
begin
	if (rising_edge(clk)) then
		if (s_pointer = s_end_addr) then
			s_invoke_done <= '1';
		else
			s_invoke_done <= '0';
		end if;
	end if;
end process ; -- invoke_complete

---------------------------------------------------------------------------------------------------
packet_id_process : process(clk, packet_id_reset, packet_id_inc_en)
begin
	if (rising_edge(clk)) then
		if (packet_id_reset = '1') then
			s_packet_id <= (others => '0');
		elsif (packet_id_inc_en = '1') then
			s_packet_id <= s_packet_id + '1';
		else 
			s_packet_id <= s_packet_id;
		end if;
	end if;
end process ; -- packet_id_process

---------------------------------------------------------------------------------------------------
rd_pointer_process : process(clk, s_invoke_init, words_stored_inc_en, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (s_invoke_init = '1') then
			s_pointer <= d_in_copy(8 downto 0);
		elsif (words_stored_inc_en = '1') then
			s_pointer <= d_in_copy(24 downto 16);
		else
			s_pointer <= s_pointer + '1';
		end if;
	end if;
end process ; -- pointer_process

---------------------------------------------------------------------------------------------------
wr_pointer_process : process(clk, s_invoke_init, words_stored_inc_en, d_in_copy)
begin
	if (rising_edge(clk)) then
		if (s_invoke_init = '1') then
			s_wr_pointer <= d_in_copy(8 downto 0);
		elsif (words_stored_inc_en = '1') then
			s_wr_pointer <= d_in_copy(24 downto 16);
		else
			s_wr_pointer <= s_wr_pointer;
		end if;
	end if;
end process ; -- pointer_process


---------------------------------------------------------------------------------------------------
compare_pointer_L : process(s_pointer)
begin
	if (s_pointer = std_logic_vector(to_unsigned(L, 9))) then
		cmp_pointer_l <= '1';
	else
		cmp_pointer_l <= '0';
	end if;
end process ; -- compare_pointer_L

---------------------------------------------------------------------------------------------------
compare_pointer_1 : process(s_pointer)
begin
	if (s_pointer = "000000001") then
		cmp_pointer_1 <= '1';
	else
		cmp_pointer_1 <= '0';
	end if ;
end process ; -- compare_pointer_1

---------------------------------------------------------------------------------------------------
--xor_a_process : process(clk, s_invoke_en, s_reg_a_out)
--begin
--	if (rising_edge(clk)) then
--		if (s_invoke_en = '1') then
--			--s_calc_res(15 downto 0) <= s_calc_res(15 downto 0) xor s_reg_a_out;
--			--if (and s_mem_sel = '1') then
--			calc_res_sel <= "01";
--		else
--			calc_res_sel <= "00";
--		end if;
--	end if;
--end process ; -- xor_a_process

---------------------------------------------------------------------------------------------------
--xor_b_process : process(clk, s_invoke_en, s_reg_b_out)
--begin
--	if (rising_edge(clk)) then
--		if (s_invoke_en = '1' and s_mem_sel = '1') then
--			s_calc_res(15 downto 0) <= s_calc_res(15 downto 0) xor s_reg_b_out;
--		end if;
--	end if;
--end process ; -- xor_b_process

---------------------------------------------------------------------------------------------------
result_store_low_15 : process(clk, calc_res_sel)
begin
	if (rising_edge(clk)) then
		case(calc_res_sel) is
		
			when "00" =>
				s_calc_res(15 downto 0) <= s_calc_res(15 downto 0);

			when "01" =>
				s_calc_res(15 downto 0) <= s_xor_res;

			when "10" =>
				s_calc_res(15 downto 0) <= s_mac_res(15 downto 0);
		
			when others =>
				s_calc_res(15 downto 0) <= x"0101";

		end case;
	end if;
end process ; -- result_store_low_15

---------------------------------------------------------------------------------------------------
result_store_hgih_48 : process(clk, calc_res_sel)
begin
	if (calc_result_reset = '1') then
		s_calc_res(63 downto 16) <= (others => '0');

	elsif (rising_edge(clk)) then
		case(calc_res_sel(1)) is
			when '0' =>
				s_calc_res(63 downto 16) <= s_calc_res(63 downto 16);

			when '1' =>
				s_calc_res(63 downto 16) <= s_mac_res(63 downto 16);

			when others =>
				s_calc_res(63 downto 16) <= x"011000000110";

		end case;
	end if;
end process ; -- result_store_hgih_48

---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here
-- signal <= some_sig;

with vector_d_sel select s_d_to_store <=
	s_ave_res(15 downto 0) when '1',
	d_in_copy(15 downto 0) when others;

with vector_addr_sel select s_addr_to_store <=
	s_wr_pointer when '1',
	d_in_copy(24 downto 16) when others;

with s_mem_sel select s_reg_out <=
	s_reg_b_out when '1',
	s_reg_a_out when others;

s_xor_res <= s_reg_out xor s_calc_res(15 downto 0);

--with calc_res_sel select s_calc_res(15 downto 0) <=
--	x"0000" when "00",
--	s_xor_res when "01",
--	x"1111" when others;


with s_packet_id select s_packet <=
	s_calc_res(15 downto 0) when "00",
	s_calc_res(31 downto 16) when "01",
	s_calc_res(47 downto 32) when "10",
	s_calc_res(63 downto 48) when "11",
	x"0000" when others;

with d_out_sel select s_data <=
	s_packet when '1',  -- data[ID]
	s_reg_b_out when others;  -- access granted

reg_a_ld <= '1' when vector_ld = '1' and s_mem_sel = '0' else
				'0';

reg_b_ld <= '1' when vector_ld = '1' and s_mem_sel = '1' else
				'0';


s_d_out <=
	"11" & 
	s_src_port(3 downto 0) &
	s_op_code(3 downto 0) &
	s_dest_port(3 downto 0) &
	s_packet_id(1 downto 0) &
	s_data(15 downto 0);

d_out <= s_d_out;

---------------------------------------------------------------------------------------------------
end architecture;