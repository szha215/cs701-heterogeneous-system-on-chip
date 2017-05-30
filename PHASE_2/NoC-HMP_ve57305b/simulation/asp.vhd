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
	constant N : positive := 16
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

type states is (IDLE, 
					STORE_R_INIT, STORE_R,
					STORE_INIT, STORE_WAIT, STORE_DATA,
					XOR_A_INIT, XOR_B_INIT, XOR_P_START, XOR_P, XOR_RES,
					AVE_A_INIT, AVE_B_INIT, AVE_P_START, AVE_P_RD, AVE_P_WR,
					MAC_INIT, MAC_P_START, MAC_P, MAC_RES,
					SEND_ACC, SEND_DATA, SEND_PAUSE);

signal CS, NS	: states := IDLE;

signal d_in_copy	: std_logic_vector(31 downto 0) := (others => '0');

type data_vector is array (0 to N - 1) of std_logic_vector(15 downto 0);
signal s_A, s_B : data_vector := (others => (others =>'0'));

-- Control signals 
signal packet_sent_inc_en	: std_logic := '0';

-- loads
signal op_ld, start_addr_ld, end_addr_ld, src_port_ld, dest_port_ld, reg_a_ld, reg_b_ld, vector_ld, words_to_send_ld	: std_logic := '0';

-- resets
signal words_stored_reset, packet_sent_reset, ave_filter_reset, calc_result_reset	: std_logic := '0';

-- select lines
signal d_packet_sel, calc_res_sel, mem_sel_sel, rd_pointer_sel, wr_pointer_sel 	: std_logic_vector(1 downto 0) := (others => '0');
signal d_out_sel, vector_addr_sel, vector_d_sel, words_to_send_sel	: std_logic := '0';

-- comparators from datapath
signal cmp_store, cmp_sent, cmp_pointer_L, cmp_pointer_1, cmp_wr_pointer_0, cmp_rd_pointer_end : std_logic := '0';


-- Datapath
-- from d_in
signal s_op_code	: std_logic_vector(3 downto 0) := (others => '0');
signal s_start_addr, s_end_addr		: std_logic_vector(8 downto 0) := (others => '0');
signal s_mem_sel		: std_logic := '0';

-- to d_in
signal s_packet_id		: std_logic_vector(1 downto 0) := (others => '0');
signal s_packet, s_data	: std_logic_vector(15 downto 0) := (others => '0');
signal s_d_out				: std_logic_vector(31 downto 0) := (others => '0');
signal s_src_port, s_dest_port	: std_logic_vector(3 downto 0) := (others => '0');

-- pointers
signal s_pointer, s_wr_pointer : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0) := (others => '0');

-- store
signal s_addr_to_store	: std_logic_vector(8 downto 0) := (others => '0');
signal s_d_to_store	:std_logic_vector(15 downto 0) := (others => '0');

-- outputs of things
signal s_reg_a_out, s_reg_b_out	: std_logic_vector(15 downto 0) := (others => '0');
signal s_calc_res, s_mult_res, s_mac_res	: std_logic_vector(47 downto 0) := (others => '0');
signal s_xor_res, s_reg_out, s_ave_res	: std_logic_vector(15 downto 0) := (others => '0');

-- counters
signal s_words_sent, s_words_to_send		: std_logic_vector(1 downto 0) := (others => '0');  -- max 4 packets
signal s_words_stored, s_words_to_store	: std_logic_vector(8 downto 0) := (others => '0');

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
		--window_size	: positive := 4;
		data_width	: positive := 16
	);
	port (
		clk			: in std_logic;
		reset			: in std_logic;
		window_size	: in std_logic_vector(3 downto 0);
		data			: in std_logic_vector(data_width - 1 downto 0);

		avg			: out std_logic_vector(data_width - 1 downto 0)
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
		--init_file	: string;
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
		res_witdh		=> 48,
		result_lowbit	=> 0
	)
	port map(
		a		=> s_reg_a_out,
		b		=> s_reg_b_out,
		res	=> s_mult_res
	);

aveage_block : average_filter
	generic map(
		--window_size	=> L,
		data_width	=> 16
	)
	port map(
		clk		=> clk,
		reset		=> ave_filter_reset,
		window_size => s_end_addr(3 downto 0),
		data		=> s_reg_out,
	
		avg		=> s_ave_res
	);

-- ALT RAM
ram_a : altsyncram
	generic map (
		address_aclr_b => "CLEAR0",
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_b => "BYPASS",
		--init_file => "ram_a.mif",
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
		address_a => s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
		data_a => s_d_to_store,
		wren_a => reg_a_ld,
		aclr0	=> '0',
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
		--init_file => "ram_b.mif",
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
		address_a => s_addr_to_store(integer(ceil(log2(real(N)))) - 1 downto 0),
		data_a => s_d_to_store,
		wren_a => reg_b_ld,
		aclr0	=> '0',
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
	case CS is
		when IDLE =>
			if (valid = '1' and d_in(31 downto 30) = "11") then
				case (d_in(25 downto 22)) is
					when "0000" =>
						NS <= STORE_R_INIT;

					when "0001" =>
						NS <= STORE_INIT;

					when "0010" =>
						NS <= XOR_A_INIT;

					when "0011" =>
						NS <= XOR_B_INIT;

					when "0100" =>
						NS <= MAC_INIT;

					when "0101" =>
						NS <= AVE_A_INIT;

					when "0110" =>
						NS <= AVE_B_INIT;

					when others =>
						NS <= IDLE;
				end case;

			else
				NS <= IDLE;
			end if;

		when STORE_R_INIT =>
			NS <= STORE_R;

		when STORE_R =>
			if (cmp_wr_pointer_0 = '1') then
				NS <= SEND_ACC;
			else
				NS <= STORE_R;
			end if;

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

		when XOR_A_INIT =>
			NS <= XOR_P_START;

		when XOR_B_INIT =>
			NS <= XOR_P_START;

		when XOR_P_START =>
			NS <= XOR_P;

		when XOR_P =>
			if (cmp_rd_pointer_end = '1') then
				NS <= XOR_RES;
			else
				NS <= XOR_P;
			end if;

		when XOR_RES =>
			NS <= SEND_DATA;

		when MAC_INIT =>
			NS <= MAC_P_START;

		when MAC_P_START =>
			NS <= MAC_P;

		when MAC_P =>
			if (cmp_rd_pointer_end = '1') then
				NS <= MAC_RES;
			else
				NS <= MAC_P;
			end if;

		when MAC_RES =>
			NS <= SEND_DATA;

		when AVE_A_INIT =>
			NS <= AVE_P_START;

		when AVE_B_INIT =>
			NS <= AVE_P_START;

		when AVE_P_START =>
			NS <= AVE_P_RD;

		when AVE_P_RD =>
			if (cmp_pointer_L = '1') then
				NS <= AVE_P_WR;
			else
				NS <= AVE_P_RD;
			end if;

		when AVE_P_WR =>
			if (cmp_pointer_1 = '1') then
				NS <= SEND_ACC;
			else
				NS <= AVE_P_WR;
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
			report "STATE TRANSITION: BAD STATE" severity failure;
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
	mem_sel_sel <= "00";
	src_port_ld <= '0';

	vector_ld <= '0';
	vector_d_sel <= '0';
	words_stored_reset <= '0';

	rd_pointer_sel <= "00";
	wr_pointer_sel <= "00";
	vector_addr_sel <= '1';

	busy <= '0';
	res_ready <= '0';

	calc_result_reset <= '0';
	calc_res_sel <= "00";

	words_to_send_ld <= '0';
	words_to_send_sel <= '0';
	packet_sent_reset <= '0';
	packet_sent_inc_en <= '0';
	d_out_sel <= '1';

	ave_filter_reset <= '0';

	case CS is
		when IDLE =>
			words_stored_reset <= '1';
			packet_sent_reset <= '1';

			ave_filter_reset <= '1';

			calc_result_reset <= '1';

			words_to_send_sel <= '0';
			words_to_send_ld <= '1';

		when STORE_R_INIT =>
			start_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "11";

			busy <= '1';

		when STORE_R =>
			wr_pointer_sel <= "01";

			vector_d_sel <= '0';
			vector_addr_sel <= '1';

			busy <= '1';

		when STORE_INIT =>
			op_ld <= '1';
			
			start_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "11";

			vector_addr_sel <= '0';

		when STORE_WAIT =>
			vector_addr_sel <= '0';

		when STORE_DATA =>
			rd_pointer_sel <= "01";
			vector_ld <= '1';

			vector_addr_sel <= '0';

			busy <= '1';

		when XOR_A_INIT =>
			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "01";

			rd_pointer_sel <= "11";

			calc_result_reset <= '1';
			calc_res_sel <= "00";

			busy <= '1';

		when XOR_B_INIT =>
			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "10";

			rd_pointer_sel <= "11";

			calc_result_reset <= '1';
			calc_res_sel <= "00";

			busy <= '1';

		when XOR_P_START =>
			rd_pointer_sel <= "01";

			calc_result_reset <= '1';
			calc_res_sel <= "00";

			busy <= '1';

		when XOR_P =>
			rd_pointer_sel <= "01";

			calc_result_reset <= '0';
			calc_res_sel <= "01";

			busy <= '1';

		when XOR_RES =>
			rd_pointer_sel <= "00";
			calc_res_sel <= "01";

			busy <= '1';

		when MAC_INIT =>
			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';

			rd_pointer_sel <= "11";

			calc_result_reset <= '1';
			calc_res_sel <= "10";

			busy <= '1';

		when MAC_P_START =>
			rd_pointer_sel <= "01";

			calc_result_reset <= '1';
			calc_res_sel <= "10";

			busy <= '1';
			
		when MAC_P =>
			rd_pointer_sel <= "01";

			calc_result_reset <= '0';
			calc_res_sel <= "10";

			busy <= '1';

		when MAC_RES =>
			rd_pointer_sel <= "00";
			calc_res_sel <= "10";

			words_to_send_ld <= '1';
			words_to_send_sel <= '1';
			busy <= '1';

		when AVE_A_INIT =>
			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "01";

			rd_pointer_sel <= "11";
			wr_pointer_sel <= "00";

			ave_filter_reset <= '1';

			vector_addr_sel <= '1';

			busy <= '1';
			
		when AVE_B_INIT =>
			op_ld <= '1';
			start_addr_ld <= '1';
			end_addr_ld <= '1';
			src_port_ld <= '1';
			mem_sel_sel <= "10";

			rd_pointer_sel <= "11";
			wr_pointer_sel <= "00";

			ave_filter_reset <= '1';

			vector_addr_sel <= '1';

			busy <= '1';
			
		when AVE_P_START =>
			ave_filter_reset <= '1';

			rd_pointer_sel <= "01";
			wr_pointer_sel <= "00";

			vector_addr_sel <= '1';
			busy <= '1';

		when AVE_P_RD =>
			rd_pointer_sel <= "01";
			wr_pointer_sel <= "00";

			calc_res_sel <= "00";
			busy <= '1';
			
		when AVE_P_WR =>
			rd_pointer_sel <= "01";
			wr_pointer_sel <= "01";

			vector_d_sel <= '1';
			vector_ld <= '1';

			calc_res_sel <= "00";

			busy <= '1';
			
		when SEND_ACC =>
			d_out_sel <= '0';

			busy <= '1';
			res_ready <= '1';

		when SEND_DATA =>
			d_out_sel <= '1';

			busy <= '1';
			res_ready <= '1';

		when SEND_PAUSE =>
			busy <= '1';
			packet_sent_inc_en <= '1';

		when others =>			
			report "STATE OUTPUT: BAD STATE" severity failure;
			
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
start_addr_process : process(clk, start_addr_ld, d_in_copy, s_start_addr)
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
mem_sel_process : process(clk, mem_sel_sel)
begin
	if (rising_edge(clk)) then
		case(mem_sel_sel) is
		
			when "00" =>
				s_mem_sel <= s_mem_sel;

			when "01" =>
				s_mem_sel <= '0';

			when "10" =>
				s_mem_sel <= '1';

			when "11" =>
				s_mem_sel <= d_in_copy(17);

			when others =>
				s_mem_sel <= '0';
		end case ;
	end if;
end process ; -- mem_sel_process

---------------------------------------------------------------------------------------------------
words_stored_process : process(clk, rd_pointer_sel, words_stored_reset)
begin
	if (words_stored_reset = '1') then
			s_words_stored <= (others => '0');
	elsif (rising_edge(clk)) then
		if (rd_pointer_sel = "01") then
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

---------------------------------------------------------------------------------------------------
to_send_process : process(clk, words_to_send_ld, words_to_send_sel)
begin
	if (rising_edge(clk)) then
		if (words_to_send_ld = '1') then
			case(words_to_send_sel) is
				when '1' =>
					--s_words_to_send <= "11";
					s_words_to_send <= "10";

				when others =>
					s_words_to_send <= "00";
			end case ;
		else
			s_words_to_send <= s_words_to_send;
		end if;
	end if;
end process ; -- to_send_process

---------------------------------------------------------------------------------------------------
sent_counter_process : process(clk, packet_sent_reset, packet_sent_inc_en)
begin
	if (rising_edge(clk)) then
		if (packet_sent_reset = '1') then
			s_words_sent <= (others => '0');
		elsif (packet_sent_inc_en = '1') then
			s_words_sent <= s_words_sent + '1';
		end if;
	end if ;
end process ; -- sent_counter_process

---------------------------------------------------------------------------------------------------
packet_id_process : process(clk, packet_sent_reset, packet_sent_inc_en)
begin
	if (rising_edge(clk)) then
		if (packet_sent_reset = '1') then
			s_packet_id <= (others => '0');
		elsif (packet_sent_inc_en = '1') then
			s_packet_id <= s_packet_id + '1';
		else 
			s_packet_id <= s_packet_id;
		end if;
	end if;
end process ; -- packet_id_process

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
compare_rd_pointer_end_addr : process(s_pointer, s_end_addr)
begin
	if (s_pointer = s_end_addr) then
		cmp_rd_pointer_end <= '1';
	else
		cmp_rd_pointer_end <= '0';
	end if;
end process ; -- compare_rd_pointer_end_addr

---------------------------------------------------------------------------------------------------
rd_pointer_process : process(clk, rd_pointer_sel, d_in_copy)
begin
	if (rising_edge(clk)) then
		case(rd_pointer_sel) is
			when "00" =>
				s_pointer <= s_pointer;

			when "01" =>
				s_pointer <= s_pointer + '1';

			when "10" =>
				s_pointer <= d_in_copy(integer(ceil(log2(real(N)))) + 15 downto 16);

			when "11" =>	
				s_pointer <= d_in_copy(integer(ceil(log2(real(N)))) - 1 downto 0);

			when others =>
				s_pointer <= s_pointer;

		end case;
	end if;
end process ; -- rd_pointer_process

---------------------------------------------------------------------------------------------------
wr_pointer_process : process(clk, wr_pointer_sel, d_in_copy)
begin
	if (rising_edge(clk)) then
		case(wr_pointer_sel) is
			when "00" =>
				s_wr_pointer <= s_wr_pointer;

			when "01" =>
				s_wr_pointer <= s_wr_pointer + '1';

			when "10" =>
				s_wr_pointer <= d_in_copy(integer(ceil(log2(real(N)))) + 15 downto 16);

			when "11" =>	
				s_wr_pointer <= d_in_copy(integer(ceil(log2(real(N)))) - 1 downto 0);

			when others =>
				s_wr_pointer <= s_wr_pointer;

		end case;
	end if;
end process ; -- wr_pointer_process

---------------------------------------------------------------------------------------------------
compare_pointer_L : process(s_pointer)
begin
	if (s_pointer = s_end_addr(s_pointer'length - 1 downto 0)) then
		cmp_pointer_L <= '1';
	else
		cmp_pointer_L <= '0';
	end if;
end process ; -- compare_pointer_L

---------------------------------------------------------------------------------------------------
compare_pointer_1 : process(s_pointer)
begin
	if (s_pointer = ((integer(ceil(log2(real(N)))) - 1 downto 1 => '0') & '1')) then
		cmp_pointer_1 <= '1';
	else
		cmp_pointer_1 <= '0';
	end if ;
end process ; -- compare_pointer_1

---------------------------------------------------------------------------------------------------
compare_wr_pointer_0 : process(s_wr_pointer)
begin
	if (s_wr_pointer = std_logic_vector(to_unsigned(N - 1, s_wr_pointer'length))) then
		cmp_wr_pointer_0 <= '1';
	else
		cmp_wr_pointer_0 <= '0';
	end if;
end process ; -- compare_wr_pointer_0

---------------------------------------------------------------------------------------------------
result_store_low_15 : process(clk, calc_res_sel, calc_result_reset)
begin
	if (calc_result_reset = '1') then
		s_calc_res(15 downto 0) <= (others => '0');
	elsif (rising_edge(clk)) then
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
result_store_high_48 : process(clk, calc_res_sel, calc_result_reset)
begin
	if (calc_result_reset = '1') then
		s_calc_res(47 downto 16) <= (others => '0');

	elsif (rising_edge(clk)) then
		case(calc_res_sel(1)) is
			when '0' =>
				s_calc_res(47 downto 16) <= s_calc_res(47 downto 16);

			when '1' =>
				s_calc_res(47 downto 16) <= s_mac_res(47 downto 16);

			when others =>
				s_calc_res(47 downto 16) <= x"00000110";

		end case;
	end if;
end process ; -- result_store_high_48

---------------------------------------------------------------------------------------------------
-- concurrent signal assignments here

s_xor_res <= s_reg_out xor s_calc_res(15 downto 0);

s_mac_res <= s_mult_res + s_calc_res;

with vector_d_sel select s_d_to_store <=
	s_ave_res(15 downto 0) when '1',
	d_in_copy(15 downto 0) when others;

with vector_addr_sel select s_addr_to_store <=
	((8 downto s_wr_pointer'length => '0') & s_wr_pointer) when '1',
	d_in_copy(24 downto 16) when others;

with s_mem_sel select s_reg_out <=
	s_reg_b_out when '1',
	s_reg_a_out when others;

with s_packet_id select s_packet <=
	s_calc_res(15 downto 0) when "00",
	s_calc_res(31 downto 16) when "01",
	s_calc_res(47 downto 32) when "10",
	x"0000" when others;

with d_out_sel select s_data <=
	s_packet when '1',  -- data[ID]
	x"0001" when others;  -- access granted

reg_a_ld <= '1' when (vector_ld = '1' and s_mem_sel = '0') else
				'0';

reg_b_ld <= '1' when (vector_ld = '1' and s_mem_sel = '1') else
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