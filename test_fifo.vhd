library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_fifo is
end test_fifo;

architecture b1 of test_fifo is 
    
    -- component declaration for the unit under test (uut)
    component fifo
        generic (
            constant data_width  : positive := 8;
            constant fifo_depth : positive := 64
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
    
    --inputs
    signal t_clk      : std_logic := '0';
    signal t_reset      : std_logic := '0';
    signal t_d_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal t_rd_en   : std_logic := '0';
    signal t_wr_en  : std_logic := '0';
    
    --outputs
    signal t_d_out  : std_logic_vector(7 downto 0);
    signal t_empty    : std_logic;
    signal t_full     : std_logic;
    
    -- clock period definitions
    constant t_clk_period : time := 10 ns;

begin

    t_fifo: fifo
        port map (
            clk     => t_clk,
            reset   => t_reset,
            d_in    => t_d_in,
            wr_en   => t_wr_en,
            rd_en   => t_rd_en,
            d_out   => t_d_out,
            full    => t_full,
            empty   => t_empty
        );
    
    -- clock process definitions
    t_clk_process :process
    begin
        t_clk <= '0';
        wait for t_clk_period/2;
        t_clk <= '1';
        wait for t_clk_period/2;
    end process;
    
    -- reset process
    t_reset_proc : process
    begin
    wait for t_clk_period * 5;
        
        t_reset <= '1';
        
        wait for t_clk_period * 5;
        
        t_reset <= '0';
        
        wait;
    end process;
    
    -- write process
    t_wr_proc : process
        variable counter : unsigned (7 downto 0) := (others => '0');
    begin       
        wait for t_clk_period * 20;

        for i in 1 to 32 loop
            counter := counter + 1;
            
            t_d_in <= std_logic_vector(counter);
            
            wait for t_clk_period * 1;
            
            t_wr_en <= '1';
            
            wait for t_clk_period * 1;
        
            t_wr_en <= '0';
        end loop;
        
        wait for t_clk_period * 20;
        
        for i in 1 to 32 loop
            counter := counter + 1;
            
            t_d_in <= std_logic_vector(counter);
            
            wait for t_clk_period * 1;
            
            t_wr_en <= '1';
            
            wait for t_clk_period * 1;
            
            t_wr_en <= '0';
        end loop;
        
        wait;
    end process;
    
    -- read process
    t_rd_proc : process
    begin
        wait for t_clk_period * 20;
        
        wait for t_clk_period * 40;
            
        t_rd_en <= '1';
        
        wait for t_clk_period * 60;
        
        t_rd_en <= '0';
        
        wait for t_clk_period * 256 * 2;
        
        t_rd_en <= '1';
        
        wait;
    end process;

end b1;