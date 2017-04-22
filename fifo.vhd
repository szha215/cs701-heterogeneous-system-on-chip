library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
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
end fifo;

architecture behaviour of fifo is
    type arr is array (0 to fifo_depth - 1) of std_logic_vector (data_width - 1 downto 0);
    signal queue : arr;
begin

    -- queue pointer process
    fifo_proc : process (clk)

        -- linked list pointers
        variable head : natural range 0 to fifo_depth - 1;
        variable tail : natural range 0 to fifo_depth - 1;
        
        variable looped : boolean;

    begin
        if reset = '1' then
            head := 0;
            tail := 0;
            
            looped := false;
            
            full  <= '0';
            empty <= '1';
        elsif rising_edge(clk) then
            if (rd_en = '1') then
                if ((looped = true) or (head /= tail)) then
                    -- update data output
                    d_out <= queue(tail);
                    
                    -- update tail pointer as needed
                    if (tail = fifo_depth - 1) then
                        tail := 0;
                        
                        looped := false;
                    else
                        tail := tail + 1;
                    end if;
                    
                    
                end if;
            end if;
                
            if (wr_en = '1') then
                if ((looped = false) or (head /= tail)) then
                    -- write data to queue
                    queue(head) <= d_in;
                    
                    -- increment head pointer as needed
                    if (head = fifo_depth - 1) then
                        head := 0;
                        
                        looped := true;
                    else
                        head := head + 1;
                    end if;
                end if;
            end if;
                
            -- update empty and full flags
            if (head = tail) then
                if looped then
                    full <= '1';
                else
                    empty <= '1';
                end if;
            else
                empty   <= '0';
                full    <= '0';
            end if;
        end if;
    end process;
        
end behaviour;