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

--
-- Network Interface for the s4noc
--


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.noc_types.all;

entity ni_ram_single is
  generic (
    NI_NUM : natural);
  port (
    clk           : in  std_logic;
    reset         : in  std_logic;
    -- Signals to/from the router
    tile_tx_f     : out network_link_forward;
    tile_rx_f     : in  network_link_forward;
    -- Signals to/from the tile
    processor_out : in  io_out_type;
    processor_in  : out io_in_type);

end ni_ram_single;

architecture behav of ni_ram_single is
  constant STATUS_REG_DIV : natural := natural(ceil(real(TOTAL_NI_NUM)/real(WORD_WIDTH)));

  signal count : unsigned(log2(TDM_PERIOD)-1 downto 0);  -- Count to
                                                         -- describe the
                                                         -- slot number.

  signal out_tx_status, out_rx_status : status_word;
  signal in_tx_status, in_rx_status   : status_word;

  signal tx_status_reg, next_tx_status_reg : status_word;
  signal rx_status_reg, next_rx_status_reg : status_word;

  signal tx_slot_dest, rx_slot_src     : status_int;
  signal x_rx_slot_src, x_tx_slot_dest : status_int;
  signal dest_addr, src_addr           : status_int;

  signal tx_slot_status   : std_logic;
  signal x_tx_slot_status : std_logic;

  signal read_rdy, next_read_rdy : std_logic;

  signal next_read_addr     : natural;
  signal processor_addr     : natural;
  signal processor_ram_wraddr : natural;
  signal processor_ram_rdaddr : natural;
  -- signal tx_data_valid  : std_logic;

  signal rd_data : tile_word;
  signal tx_data : tile_word;
  
begin  -- behav

-------------------------------------------------------------------------------
-- Counter for keeping track of the timeslot number
-------------------------------------------------------------------------------
  
  counter : process (clk)
  begin  -- process count
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then
        count <= (others => '0');
      else
        if count < TDM_PERIOD-1 then
          count <= count + to_unsigned(1, 1);
        else
          count <= (others => '0');
        end if;
      end if;
    end if;
  end process counter;

-------------------------------------------------------------------------------
-- Slot tables and registers.
-------------------------------------------------------------------------------

  ni_ST : entity work.ni_ST
    generic map (
      NI_NUM => NI_NUM)
    port map (
      count => count,
      dest  => dest_addr,
      src   => src_addr);

  slot_regs : process (clk)
  begin  -- process slot_regs
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then
        tx_slot_dest     <= 0;
        x_tx_slot_dest   <= 0;
        rx_slot_src      <= 0;
        x_rx_slot_src    <= 0;
        tx_slot_status   <= '0';
        x_tx_slot_status <= '0';
      else
        tx_slot_dest     <= x_tx_slot_dest;
        x_tx_slot_dest   <= dest_addr;
        x_tx_slot_status <= tx_status_reg(x_tx_slot_dest);
        tx_slot_status   <= x_tx_slot_status;
        rx_slot_src      <= x_rx_slot_src;
        x_rx_slot_src    <= src_addr;
      end if;
    end if;
  end process slot_regs;

-------------------------------------------------------------------------------
-- Serialize/deserialize or atomize/deatomize
-- Not needed for single clock domain
-------------------------------------------------------------------------------

  --serdes : entity work.serdes
  --  generic map (
  --    tile_width => WORD_WIDTH,
  --    ratio_clk  => NETWORK_PHITS_PR_FLIT)
  --  port map (
  --    fast_clk     => router_clk,
  --    slow_clk     => processor_clk,
  --    reset        => reset,
  --    out_phase    => out_phase,
  --    serial_in    => tile_rx_f.data,
  --    parallel_in  => tx_out_reg,
  --    serial_out   => tile_tx_f.data,
  --    parallel_out => i.rx);


-------------------------------------------------------------------------------
-- TX and RX buffer
-------------------------------------------------------------------------------
  processor_ram_wraddr <= to_integer(unsigned(processor_out.wraddr(log2(TOTAL_NI_NUM)-1 downto 0)));
  processor_ram_rdaddr <= to_integer(unsigned(processor_out.rdaddr(log2(TOTAL_NI_NUM)-1 downto 0)));
  
  TX_ram : entity work.dp_ram
    generic map (
      DATA_WIDTH => WORD_WIDTH,
      ADDR_WIDTH => log2(TOTAL_NI_NUM))
    port map (
      clk    => clk,
      addr_a => processor_ram_wraddr,
      addr_b => tx_slot_dest,
      data_a => processor_out.wrdata,
      data_b => (others => '0'),
      we_a   => processor_out.wr,
      we_b   => '0',
      q_a    => open,
      q_b    => tx_data);

--  RX_ram : entity work.dp_ram
--    generic map (
--      DATA_WIDTH => WORD_WIDTH,
--      ADDR_WIDTH => log2(TOTAL_NI_NUM))
--    port map (
--      clk    => clk,
--      addr_a => processor_ram_rdaddr,
--      addr_b => rx_slot_src,
--      data_a => (others => '0'),
--      data_b => tile_rx_f.data,
--      we_a   => '0',
--      we_b   => tile_rx_f.data_valid,
--      q_a    => rd_data,
--      q_b    => open);
		
	------------------------
	--  RX_buffer_bypass  --
	rd_data	<= tile_rx_f.data when tile_rx_f.data_valid = '1'
					else (others => '0');

-------------------------------------------------------------------------------
--  Router side of the block ram
-------------------------------------------------------------------------------

  tx_router : process (tx_slot_dest, x_tx_slot_status, tx_slot_status, tx_data)
  begin  -- process tx_router
    out_tx_status               <= (others => '0');
--    tx_data_valid <= '0';
    --if tx_slot_status = '1' then
    --  tx_data_valid               <= '1';
    --  out_tx_status(tx_slot_dest) <= '1';
    --end if;
    out_tx_status(tx_slot_dest) <= x_tx_slot_status;
    tile_tx_f.data_valid        <= tx_slot_status;
    if tx_slot_status = '1' then
      tile_tx_f.data <= tx_data;
    else
      tile_tx_f.data <= (others => '0');
    end if;
  end process tx_router;


  rx_router : process (rx_slot_src, tile_rx_f.data_valid)
  begin  -- process rx_router
    out_rx_status              <= (others => '0');
    out_rx_status(rx_slot_src) <= tile_rx_f.data_valid;
  end process rx_router;

-------------------------------------------------------------------------------
--  Writing the received word in this timeslot to the block ram


  --out_ch_regs : process (clk)
  --begin  -- process out_ch_regs
  --  if rising_edge(clk) then            -- rising clock edge
  --    if reset = '1' then
  --      tile_tx_f.data_valid <= '0';
  --    else
  --      tile_tx_f.data_valid <= tx_data_valid;
  --    end if;
  --  end if;
  --end process out_ch_regs;

-------------------------------------------------------------------------------
-- Processor side of the block ram
-------------------------------------------------------------------------------
  processor_addr <= to_integer(unsigned(processor_out.wraddr));

  in_ch : process (processor_out, tx_status_reg, rx_status_reg, processor_addr, rd_data, read_rdy)
  begin  -- process in_ch
    next_read_rdy       <= read_rdy;
    in_tx_status        <= (others => '0');
    in_rx_status        <= (others => '0');
    processor_in.rddata <= (others => '0');

    if processor_out.rd = '1' then
-------------------------------------------------------------------------------
      --  Reading from the rx channel
      if processor_addr < TOTAL_NI_NUM then
		  if rd_data(WORD_WIDTH-1) = '1' then
		    in_rx_status(processor_addr) <= '1';
          processor_in.rddata          <= rd_data;
		  elsif read_rdy = '1' then
          in_rx_status(processor_addr) <= '1';
          processor_in.rddata          <= rd_data;
          next_read_rdy                <= '0';
        else
          next_read_rdy <= '1';
        end if;
      end if;

-------------------------------------------------------------------------------
      -- Returning the tx_status register
      for i in 0 to STATUS_REG_DIV-2 loop
        if processor_addr = i+TOTAL_NI_NUM then
          processor_in.rddata <= tx_status_reg((i+1)*WORD_WIDTH-1 downto i*WORD_WIDTH);
        end if;
      end loop;  -- i
      if processor_addr = TOTAL_NI_NUM + STATUS_REG_DIV - 1 then
        processor_in.rddata((TOTAL_NI_NUM mod WORD_WIDTH)-1 downto 0) <= tx_status_reg(TOTAL_NI_NUM-1 downto TOTAL_NI_NUM-(TOTAL_NI_NUM mod WORD_WIDTH));
      end if;


-------------------------------------------------------------------------------
      -- Returning the rx status register
      for i in 0 to STATUS_REG_DIV-2 loop
        if processor_addr = i+TOTAL_NI_NUM+STATUS_REG_DIV then
          processor_in.rddata <= rx_status_reg((i+1)*WORD_WIDTH-1 downto i*WORD_WIDTH);
        end if;
      end loop;  -- i
      if processor_addr = TOTAL_NI_NUM + (2*STATUS_REG_DIV) - 1 then
        processor_in.rddata((TOTAL_NI_NUM mod WORD_WIDTH)-1 downto 0) <= rx_status_reg(TOTAL_NI_NUM-1 downto TOTAL_NI_NUM-(TOTAL_NI_NUM mod WORD_WIDTH));
      end if;
    end if;
-------------------------------------------------------------------------------
    -- Writing to the tx channel
    if processor_out.wr = '1' and processor_addr < TOTAL_NI_NUM
      and tx_status_reg(processor_addr) = '0' then
      in_tx_status(processor_addr) <= '1';
    end if;
    
  end process in_ch;

-------------------------------------------------------------------------------
-- Control logic & update of the status register
-------------------------------------------------------------------------------

  control : process (tx_status_reg, rx_status_reg, in_tx_status, out_tx_status, in_rx_status, out_rx_status)
  begin  -- process control
    next_rx_status_reg <= (others => '0');
    next_tx_status_reg <= (others => '0');
    for i in 0 to TOTAL_NI_NUM-1 loop
      -- Setting the next tx status register
      if in_tx_status(i) = '0' and out_tx_status(i) = '0' then
        next_tx_status_reg(i) <= tx_status_reg(i);
      elsif in_tx_status(i) = '1' then
        next_tx_status_reg(i) <= '1';
      elsif out_tx_status(i) = '1' then
        next_tx_status_reg(i) <= '0';
      end if;
      -- Setting the next rx status register
      if in_rx_status(i) = '0' and out_rx_status(i) = '0' then
        next_rx_status_reg(i) <= rx_status_reg(i);
      elsif out_rx_status(i) = '1' then
        next_rx_status_reg(i) <= '1';
      elsif in_rx_status(i) = '1' then
        next_rx_status_reg(i) <= '0';
      end if;
      
    end loop;  -- i

    next_rx_status_reg(NI_NUM) <= '1';
 --   next_tx_status_reg(NI_NUM) <= '0';
    
  end process control;

  status_registers : process (clk)
  begin  -- process transiton_registers
    if rising_edge(clk) then            -- rising clock edge
      if reset = '1' then
        tx_status_reg <= (others => '0');
        rx_status_reg <= (others => '0');
        read_rdy      <= '0';
      else
        tx_status_reg <= next_tx_status_reg;
        rx_status_reg <= next_rx_status_reg;
        read_rdy      <= next_read_rdy;
      end if;
    end if;
  end process status_registers;

end behav;
