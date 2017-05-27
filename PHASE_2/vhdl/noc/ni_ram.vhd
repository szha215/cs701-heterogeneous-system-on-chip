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
use work.noc_types.all;

entity ni_ram is
  generic (
    NI_NUM        : natural);           -- The slot table length should be
  -- modified to fit the NoC.
  port (
    router_clk    : in  std_logic;
    processor_clk : in  std_logic;
    reset         : in  std_logic;
    -- Signals to/from the router
    tile_tx_f     : out network_link_forward;
    tile_rx_f     : in  network_link_forward;
    -- Signals to/from the tile
    processor_out : in  io_out_type;
    processor_in  : out io_in_type);

end ni_ram;

architecture behav of ni_ram is
  signal count : unsigned(log2(TDM_PERIOD)-1 downto 0);  -- Count to
                                                            -- describe the
                                                            -- slot number.

  signal out_tx_status, out_rx_status : status_word;
  signal in_tx_status, in_rx_status   : status_word;

  signal tx_status_reg, next_tx_status_reg : status_word;
  signal rx_status_reg, next_rx_status_reg : status_word;
  signal x_out_rx_status, x_out_tx_status  : status_word;
  signal x_in_rx_status, x_in_tx_status    : status_word;

  signal tx_slot_dest, rx_slot_src : status_int;
  signal dest_addr, src_addr       : status_int;

  signal tx_out_reg, tx_out_mux : tile_word;
  signal tx_slot_status         : std_logic;

  signal out_phase : std_logic;

  type   shift_reg is array (3 downto 0) of std_logic;
  signal reg_tx_data_valid : shift_reg;

  signal i, o : ram_side;
  
  signal we_a_temp, we_b_temp	: std_logic;
  
begin  -- behav

-------------------------------------------------------------------------------
-- Counter for keeping track of the timeslot number
-------------------------------------------------------------------------------
  
  counter : process (processor_clk, reset)
  begin  -- process count
    if rising_edge(processor_clk) then  -- rising clock edge
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

  slot_regs : process (processor_clk, reset)
  begin  -- process slot_regs
    if rising_edge(processor_clk) then  -- rising clock edge
      if reset = '1' then
        tx_slot_dest   <= 0;
        rx_slot_src    <= 0;
        tx_slot_status <= '0';
      else
        tx_slot_dest   <= dest_addr;
        tx_slot_status <= tx_status_reg(dest_addr);
        rx_slot_src    <= src_addr;
      end if;
    end if;
  end process slot_regs;

-------------------------------------------------------------------------------
-- Serialize/deserialize or atomize/deatomize
-------------------------------------------------------------------------------

  serdes : entity work.serdes
    generic map (
      tile_width => WORD_WIDTH,
      ratio_clk  => NETWORK_PHITS_PR_FLIT)
    port map (
      fast_clk     => router_clk,
      slow_clk     => processor_clk,
      reset        => reset,
      out_phase    => out_phase,
      serial_in    => tile_rx_f.data,
      parallel_in  => tx_out_reg,
      serial_out   => tile_tx_f.data,
      parallel_out => i.rx);


-------------------------------------------------------------------------------
-- Dual portet block ram.
-------------------------------------------------------------------------------
	
  we_a_temp <= i.ram_wr and i.ram_en;
  we_b_temp <= o.ram_wr and o.ram_en;
  dp_ram : entity work.dp_ram
    generic map (
      DATA_WIDTH => WORD_WIDTH,
      ADDR_WIDTH => log2(TOTAL_NI_NUM))
    port map (
      clk    => router_clk,
      addr_a => i.ram_addr,
      addr_b => o.ram_addr,
      data_a => i.tx,
      data_b => i.rx,

      we_a => we_a_temp,		
      we_b => we_b_temp,
      q_a  => o.rx,
      q_b  => o.tx);

-------------------------------------------------------------------------------
--  Router side of the block ram
-------------------------------------------------------------------------------

  out_ch : process (out_phase, tx_slot_dest, rx_slot_src , tx_status_reg, rx_status_reg, tile_rx_f, reg_tx_data_valid, tx_slot_status, o)
  begin  -- process tx_ch
    o.ram_en   <= '0';
    o.ram_addr <= 0;
    o.ram_wr   <= '0';
    o.tx_en    <= '0';
    o.rx_en    <= '0';

    out_tx_status        <= (others => '0');
    out_rx_status        <= (others => '0');
    reg_tx_data_valid(1) <= reg_tx_data_valid(2);
    reg_tx_data_valid(3) <= '0';
-------------------------------------------------------------------------------
--  Reading transmit word to send in this timeslot
    if out_phase = '1' and tx_slot_status = '1' then
      o.ram_addr                  <= tx_slot_dest;
      o.ram_en                    <= '1';
      o.tx_en                     <= '1';
      o.ram_wr                    <= '0';
      reg_tx_data_valid(1)        <= '1';
      reg_tx_data_valid(3)        <= '1';
      out_tx_status(tx_slot_dest) <= '1';
-------------------------------------------------------------------------------
--  Writing the received word in this timeslot to the block ram
    elsif out_phase = '0' and rx_status_reg(rx_slot_src) = '0' then
      o.ram_addr                 <= rx_slot_src + TOTAL_NI_NUM;
      o.ram_en                   <= tile_rx_f.data_valid;
      o.rx_en                    <= tile_rx_f.data_valid;
      o.ram_wr                   <= '1';
      out_rx_status(rx_slot_src) <= tile_rx_f.data_valid;
    end if;

    if reg_tx_data_valid(0) = '1' then
      tx_out_mux <= o.tx;
    else
      tx_out_mux <= (others => '0');
    end if;
  end process out_ch;

  out_ch_regs : process (router_clk, reset)
  begin  -- process out_ch_regs
    if rising_edge(router_clk) then     -- rising clock edge
      if reset = '1' then
        tile_tx_f.data_valid <= '0';
        reg_tx_data_valid(0) <= '0';
        reg_tx_data_valid(2) <= '0';
        tx_out_reg           <= (others => '0');
        out_phase            <= '1';
      else
        out_phase            <= not out_phase;
        tx_out_reg           <= tx_out_mux;
        tile_tx_f.data_valid <= reg_tx_data_valid(0);
        reg_tx_data_valid(0) <= reg_tx_data_valid(1);
        reg_tx_data_valid(2) <= reg_tx_data_valid(3);
      end if;
    end if;
  end process out_ch_regs;

-------------------------------------------------------------------------------
-- Processor side of the block ram
-------------------------------------------------------------------------------

  in_ch : process (out_phase, processor_out, tx_status_reg, rx_status_reg, o)
    variable processor_addr : integer;
  begin  -- process in_ch
    processor_addr := to_integer(unsigned(processor_out.wraddr));

    i.ram_en            <= '0';
    i.tx_en             <= '0';
    i.rx_en             <= '0';
    i.ram_addr          <= 0;
    i.ram_wr            <= '0';
    in_tx_status        <= (others => '0');
    in_rx_status        <= (others => '0');
    processor_in.rddata <= (others => '0');

-------------------------------------------------------------------------------
    --  Reading from the rx channel
    if processor_out.rd = '1' and processor_addr < TOTAL_NI_NUM then
      i.ram_addr <= processor_addr + TOTAL_NI_NUM;
      if out_phase = '1' then
        i.ram_wr                     <= '0';
        i.ram_en                     <= '1';
        i.rx_en                      <= '1';
        in_rx_status(processor_addr) <= '1';
      end if;
      processor_in.rddata <= o.rx;
-------------------------------------------------------------------------------
      -- Returning the tx_status register
    elsif processor_out.rd = '1' and processor_addr >= TOTAL_NI_NUM
      and processor_addr < TOTAL_NI_NUM+TOTAL_NI_NUM/WORD_WIDTH then
      processor_in.rddata <= tx_status_reg((processor_addr-TOTAL_NI_NUM+1)*WORD_WIDTH-1 downto (processor_addr-TOTAL_NI_NUM)*WORD_WIDTH);  -- TODO fix: return the correct
-------------------------------------------------------------------------------
      -- Returning the rx status register
    elsif processor_out.rd = '1' and processor_addr >= TOTAL_NI_NUM+TOTAL_NI_NUM/WORD_WIDTH
      and processor_addr < TOTAL_NI_NUM+2*TOTAL_NI_NUM/WORD_WIDTH then

      processor_in.rddata <= rx_status_reg((processor_addr-TOTAL_NI_NUM)*WORD_WIDTH-1 downto (processor_addr-TOTAL_NI_NUM-1)*WORD_WIDTH);
    end if;
-------------------------------------------------------------------------------
    -- Writing to the tx channel
    if out_phase = '0' and processor_out.wr = '1' and processor_addr < TOTAL_NI_NUM
      and tx_status_reg(processor_addr) = '0' then

      i.ram_addr <= processor_addr;
      i.ram_wr   <= '1';
      i.ram_en   <= '1';
      i.tx_en    <= '1';
      i.tx       <= processor_out.wrdata;

      in_tx_status(processor_addr) <= '1';
    else
      i.tx <= (others => '0');
    end if;
    
  end process in_ch;

-------------------------------------------------------------------------------
-- Control logic & update of the status register
-------------------------------------------------------------------------------

  control : process (tx_status_reg, rx_status_reg, x_in_tx_status, x_out_tx_status, x_in_rx_status, x_out_rx_status)
  begin  -- process control
    next_rx_status_reg <= (others => '0');
    next_tx_status_reg <= (others => '0');
    for i in 0 to TOTAL_NI_NUM-1 loop
      -- Setting the next tx status register
      if x_in_tx_status(i) = '0' and x_out_tx_status(i) = '0' then
        next_tx_status_reg(i) <= tx_status_reg(i);
      elsif x_in_tx_status(i) = '1' then
        next_tx_status_reg(i) <= '1';
      elsif x_out_tx_status(i) = '1' then
        next_tx_status_reg(i) <= '0';
      end if;
      -- Setting the next rx status register
      if x_in_rx_status(i) = '0' and x_out_rx_status(i) = '0' then
        next_rx_status_reg(i) <= rx_status_reg(i);
      elsif x_out_rx_status(i) = '1' then
        next_rx_status_reg(i) <= '1';
      elsif x_in_rx_status(i) = '1' then
        next_rx_status_reg(i) <= '0';
      end if;
      
    end loop;  -- i

    next_rx_status_reg(NI_NUM) <= '1';
    next_tx_status_reg(NI_NUM) <= '0';
    
  end process control;

  status_registers : process (processor_clk, reset)
  begin  -- process transiton_registers
    if rising_edge(processor_clk) then  -- rising clock edge
      if reset = '1' then
        tx_status_reg <= (others => '0');
        rx_status_reg <= (others => '0');
      else
        tx_status_reg <= next_tx_status_reg;
        rx_status_reg <= next_rx_status_reg;
      end if;
    end if;
  end process status_registers;

  transition_register : process (router_clk, reset)
  begin  -- process status_register
    if rising_edge(router_clk) then     -- rising clock edge
      if reset = '1' then
        x_out_tx_status <= (others => '0');
        x_out_rx_status <= (others => '0');
        x_in_tx_status  <= (others => '0');
        x_in_rx_status  <= (others => '0');
      else
        if o.tx_en = '1' then           -- Enable on updating the status update
                                        -- register
          x_out_tx_status <= out_tx_status;
        elsif processor_clk = '1' then  -- reseting the status update register
          x_out_tx_status <= (others => '0');
        end if;
        if i.tx_en = '1' then           -- Updating the status update register
          x_in_tx_status <= in_tx_status;
        elsif processor_clk = '1' then  -- Reseting the register
          x_in_tx_status <= (others => '0');
        end if;
        if o.rx_en = '1' then           -- Updating the status update register
          x_out_rx_status <= out_rx_status;
        elsif processor_clk = '1' then  -- Reseting the status update register
          x_out_rx_status <= (others => '0');
        end if;
        if i.rx_en = '1' then           -- Updating the status update register
          x_in_rx_status <= in_rx_status;
        elsif processor_clk = '1' then  -- Reseting the status update register
          x_in_rx_status <= (others => '0');
        end if;
        
      end if;
    end if;
  end process transition_register;

end behav;
