library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

---------------------------------------------------------------------------------------------------
entity ani is
	generic(
		constant tdm_slot_width	: positive := 4;
		constant data_width		: positive := 32;
		constant in_depth			: positive := 16;
		constant out_depth		: positive := 8
	);
	port(
		-- control inputs
		clk		: in std_logic;
		reset		: in std_logic;
		tdm_slot : in std_logic_vector(tdm_slot_width - 1 downto 0);

		-- incoming from NoC to ASP
		d_from_noc	: in std_logic_vector(data_width - 1 downto 0);
		d_to_asp		: out std_logic_vector(data_width - 1 downto 0);
		asp_valid	: out std_logic;

		-- outgoing from ASP to NoC
		asp_busy			: in std_logic;
		asp_res_ready	: in std_logic;
		d_from_asp		: in std_logic_vector(data_width - 1 downto 0);
		d_to_noc			: out std_logic_vector(data_width - 1 downto 0)
	);
end entity ani;

---------------------------------------------------------------------------------------------------
architecture behaviour of ani is
-- type, signal declarations

	signal s_inc_rd_en, s_inc_wr_en, s_inc_empty, s_inc_full		: std_logic := '0';
	signal s_inc_q_buf	: std_logic_vector(data_width - 1 downto 0) := (others => '0');

	signal s_out_rd_en, s_out_wr_en, s_out_empty, s_out_full		: std_logic := '0';
	signal s_out_q_buf	: std_logic_vector(data_width - 1 downto 0) := (others => '0');


---------------------------------------------------------------------------------------------------
-- component declarations
	component fifo is
		generic (
			constant data_width : positive := 8;
			constant fifo_depth : positive := 256
		);
		port ( 
			clk     : in  std_logic;
			reset   : in  std_logic;
			wr_en   : in  std_logic;
			d_in    : in  std_logic_vector (data_width - 1 downto 0);
			rd_en   : in  std_logic;

			d_out   : out std_logic_vector (data_width - 1 downto 0);
			empty   : out std_logic;
			full    : out std_logic
		);
	end component;

	component mega_fifo is
		port
		(
			aclr		: in std_logic ;
			clock		: in std_logic ;
			data		: in std_logic_vector (31 downto 0);
			rdreq		: in std_logic ;
			wrreq		: in std_logic ;
			empty		: out std_logic ;
			full		: out std_logic ;
			q			: out std_logic_vector (31 downto 0)
		);
	end component;
---------------------------------------------------------------------------------------------------
begin
-- component wiring

	--incoming_fifo : fifo
	--	generic map(
	--		data_width	=> data_width,
	--		fifo_depth	=> in_depth
	--	)
	--	port map(
	--		clk 	=> clk,
	--		reset => reset,
	--		wr_en	=> s_inc_wr_en,
	--		d_in	=> d_from_noc,
	--		rd_en => s_inc_rd_en,
	--		d_out => d_to_asp,
	--		empty => s_inc_empty,
	--		full  => s_inc_full
	--	);

	incoming_fifo : mega_fifo
		port map(
			clock	=> clk,
			aclr	=> reset,
			data	=> s_inc_q_buf,
			rdreq	=> s_inc_rd_en,
			wrreq	=> s_inc_wr_en,
			empty	=> s_inc_empty,
			full	=> s_inc_full,
			q		=> d_to_asp
		);

	outgoing_fifo : fifo
		generic map(
			data_width	=> data_width,
			fifo_depth	=> out_depth
		)
		port map(
			clk 	=> clk,
			reset => reset,
			wr_en	=> s_inc_wr_en,
			d_in	=> d_from_asp,
			rd_en => s_out_rd_en,
			d_out => d_to_noc,
			empty => s_out_empty,
			full  => s_out_full
		);	

---------------------------------------------------------------------------------------------------
--from_noc : process(clk, d_from_noc)
--variable v_inc_wr_en : boolean := false;
--begin
--	if (rising_edge(clk)) then
--		if (v_inc_wr_en = '1') then
--			s_inc_wr_en <= '0';
--		elsif (d_from_noc(31) = '1') then  -- valid bit
--			report "wirte enable";
--			s_inc_wr_en <= '1';
--		end if;
--	end if;
--end process;

---------------------------------------------------------------------------------------------------
update_inc_q_buf : process (d_from_noc)
begin
	if (d_from_noc(31) = '1') then
		s_inc_q_buf <= d_from_noc;
		s_inc_wr_en <= '1';
	else
		s_inc_q_buf <= (others => '0');
		s_inc_wr_en <= '0';
	end if;

end process;

---------------------------------------------------------------------------------------------------
push_to_asp : process (clk)
	variable pushed : boolean := false;
begin
	if (rising_edge(clk)) then
		if (pushed = false and s_inc_empty = '0' and asp_busy = '0') then
			s_inc_rd_en <= '1';
			asp_valid <= '1';
			pushed := true;
		else
			s_inc_rd_en <= '0';
			asp_valid <= '0';
			pushed := false;
		end if;
	end if;

end process;

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- combinational logic

--s_inc_wr_en <= '1' when d_from_noc(31) = '1' else
--					'0';

--s_inc_rd_en <= '1' when asp_busy = '0' and s_inc_empty = '0' else
--					'0';

--asp_valid	<= '1' when asp_busy = '0' and s_inc_empty = '0' else
--					'0';

end architecture;