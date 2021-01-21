----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.01.2021 23:34:12
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
    
);
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is

    -- stati
    type state_type is (START, COLUMN_REQUEST, ROW_REQUEST, DATA_REQUEST, DATA_FROM_RAM, ELABORATION, DATA_TO_RAM, WAITING, WAITING_INITIAL, FINISH, CALC_DIMENSION, WAITING2, ELABORATION2,ELABORATION3,ELABORATION4, ELABORATION5, PREPARATION_TO_WRITE);
    
    -- segnali
    signal current_state :  state_type;
    signal next_state : state_type;
    --signal next_wait_state : state_type;
    
    signal dimension : std_logic_vector(15 downto 0) ;
    signal end_dimension : std_logic_vector(15 downto 0) ;
    signal contatore : std_logic_vector(15 downto 0);
    signal N_COL : integer;
    signal N_RIG : integer;
    signal vertical_dimension : std_logic_vector(7 downto 0);
    signal horizontal_dimension : std_logic_vector(7 downto 0);
    
    -- ram sbagliata
    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal ram : ram_type;
    signal max_number : std_logic_vector(7 downto 0):= "00000000";
    signal min_number : std_logic_vector(7 downto 0) := "11111111";
    signal shift_level : std_logic_vector(7 downto 0) := "00000000";
    signal temp_pixel : std_logic_vector(15 downto 0) := "0000000000000000";
    signal delta : std_logic_vector(7 downto 0) := "00000000";
    signal temp_pixel2 : std_logic_vector(15 downto 0) := "0000000000000000";
   -- sistemare con "others"
    
begin

    process(i_clk, i_rst)
    begin
        -- reset
        if i_rst = '1' then
            current_state <= START; -- vedere se modificare in seguito
            o_done <= '0';
        -- eventi sul clock
        elsif rising_edge(i_clk) then
            case current_state is
                when START =>
                    if i_start = '1' then
                        o_we <= '0';
                        o_en <= '1';
                        
                        -- indirizzi di memoria partono da 0
                        o_address <= (others => '0');
                        
                        dimension <= (others => '0');
                        contatore <= (others => '0');
                        
                        current_state <= WAITING_INITIAL;
                        next_state <= COLUMN_REQUEST;
                    end if;
                    
                when COLUMN_REQUEST =>
                    vertical_dimension <= i_data;
                    -- dati salvati nella ram fittizia all'indirizzo indicato da "contatore"
                    ram(conv_integer(contatore)) <= i_data;
                    o_we <= '0';
                    o_en <= '1';
                    o_address <= (0 => '1', others => '0');
                    next_state <= ROW_REQUEST;
                    current_state <= WAITING_INITIAL;
                    contatore <= contatore + 1;
                    
                -- necessità di attendere un periodo di clock in più
                when WAITING_INITIAL =>
                     current_state <= next_state;
                    
                when ROW_REQUEST =>
                    ram(conv_integer(contatore)) <= i_data;
                    horizontal_dimension <= i_data;
                    current_state <= CALC_DIMENSION;
                    contatore <= contatore + 1;
                    
                when CALC_DIMENSION =>
                    -- salvo il prodotto di numero colonne e numero righe in un vector unsigned di dimensione 8 bit
                    dimension <= STD_LOGIC_VECTOR( "00000000" & TO_UNSIGNED(conv_integer(horizontal_dimension)*conv_integer(vertical_dimension), 8));
                    current_state <= DATA_REQUEST;
               
                when DATA_REQUEST =>
                    -- salvo in un vector di 16 bit l'indirizzo finale della ram che si avrà dopo la scrittura dell'immagine
                    end_dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(2*(conv_integer(dimension)) + 2, 16));
                        --end_dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(dimension) + conv_integer(dimension) + 2, 16));  --  oppure +1   );
                    if (conv_integer(dimension) + 2  = conv_integer(contatore)) then
                        current_state <= ELABORATION4;
                        contatore <= "0000000000000010";
                        o_en <= '0';
                        -- necessario fare la doppia conversione qua sotto???
                        -- calcolo del delta value
                        delta <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(max_number) - conv_integer(min_number), 8));                       
                    else 
                        o_we <= '0';
                        o_en <= '1';
                        current_state <= DATA_FROM_RAM;
                        next_state <= DATA_REQUEST;
                    end if;
                    
                -- calcolo shift_level (funzione "floor")
                -- perché non usi direttamente floor?
                when ELABORATION4 =>
                    if((conv_integer(delta)) = 0)then
                        shift_level <= "00001000";
                    elsif(((conv_integer(delta))) <= 2 and (conv_integer(delta)) >= 1) then
                        shift_level <= "00000111";
                    elsif((conv_integer(delta)) <= 6 and (conv_integer(delta)) >= 3) then
                        shift_level <= "00000110";
                    elsif((conv_integer(delta)) <= 14 and (conv_integer(delta)) >= 7) then
                        shift_level <= "00000101";
                    elsif((conv_integer(delta)) <= 30 and (conv_integer(delta)) >= 15) then
                        shift_level <= "00000100";
                    elsif((conv_integer(delta)) <= 62 and (conv_integer(delta)) >= 31) then
                        shift_level <= "00000011";
                    elsif((conv_integer(delta)) <= 126 and (conv_integer(delta)) >= 63) then
                        shift_level <= "00000010";
                    elsif((conv_integer(delta)) <= 254 and (conv_integer(delta)) >= 127) then                     
                        shift_level <= "00000001";
                    elsif((conv_integer(delta)) = 255) then
                        shift_level <= "10000000";
                    end if;
                  
                current_state <= ELABORATION;
                           
               -- lettura pixel
                when DATA_FROM_RAM =>
                    o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                    current_state <= WAITING;
                    
                -- calcolo nuovo valore del pixel: differenza tra valore corrente e valore minimo
                when ELABORATION =>
                   temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(ram(conv_integer(contatore))) - conv_integer(min_number)), 16));
                   current_state <= ELABORATION5;

                -- calcolo nuovo valore del pixel: shift dei bit di "shift_level"
                -- usare la funzione apposita
                WHEN ELABORATION5 =>
                    if((conv_integer(shift_level)) = 0) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)), 16));
                    elsif(((conv_integer(shift_level))) = 1) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*2), 16));
                    elsif((conv_integer(shift_level)) = 2) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*4), 16));
                    elsif((conv_integer(shift_level)) = 3) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*8), 16));
                    elsif((conv_integer(shift_level)) = 4) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*16), 16));
                    elsif((conv_integer(shift_level)) = 5) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*32), 16));
                    elsif((conv_integer(shift_level)) = 6) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*64), 16));
                    elsif((conv_integer(shift_level)) = 7) then                     
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*128), 16));
                    elsif((conv_integer(shift_level)) = 8) then
                        temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*256), 16));
                    end if;
                
                    -- temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(temp_pixel)*(2**(conv_integer(shift_level))) ) ,16 )) ;
                    --*(2**(conv_integer(shift_level));
                
                    current_state <=  ELABORATION2;

                -- controllo sul nuovo valore (< 256) e 
                when ELABORATION2 =>
                    if(conv_integer(temp_pixel) >= 255) then
                        temp_pixel <= "0000000011111111";
                    end if;
                 
                    if(conv_integer(dimension) + 2  <= conv_integer(contatore)) then
                        current_state <= PREPARATION_TO_WRITE;
                        contatore <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(dimension) + 1 , 16));
                    else 
                        o_address <= (others => '0');
                        current_state <= ELABORATION3;
                    end if;
                   
                -- ma scrive prima nella ram "locale" e poi lo fa davvero in un altro stato?
                when ELABORATION3 =>
                    ram(conv_integer(contatore) + conv_integer(dimension)) <= temp_pixel(7 downto 0);
                    current_state <= ELABORATION;
                    contatore <= contatore + 1;
                     
                -- necessità di due cicli di clock per ricevere il dato
                when WAITING =>
                    current_state <= WAITING2;
                    
                when WAITING2 => 
                    ram(conv_integer(contatore)) <= i_data;
                    contatore <= contatore + 1;
                    -- ricerca del valore massimo e del valore minimo                 
                    if(conv_integer(min_number) > conv_integer(i_data)) then
                        min_number <= i_data;
                    end if;
                    if(conv_integer(max_number) < conv_integer(i_data)) then
                        max_number <= i_data;
                    end if;
                    current_state <= next_state;
                   
                -- effettiva scrittura sulla ram
                WHEN PREPARATION_TO_WRITE =>
                    if (conv_integer(end_dimension) +2  > conv_integer(contatore)) then
                        o_we <= '1';
                        o_en <= '1';
                        o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                        o_data <=  STD_LOGIC_VECTOR(UNSIGNED(ram(conv_integer(contatore+1))));       
                        -- o_data <= "00000000";
                        current_state <= DATA_TO_RAM;
                    else  
                        o_done <= '1';
                        o_we <= '1';
                        o_en <= '0';
                        current_state <= FINISH;
                    end if;
                    
                when DATA_TO_RAM =>
                    contatore <= contatore + 1;
                    current_state <= PREPARATION_TO_WRITE;
                    
                when FINISH =>
                    if i_start = '0' then
                        o_done <= '0';
                        current_state <= START;
                    end if;
            end case;

        end if;
    end process;

end Behavioral;





--architecture Behavioral of project_reti_logiche is
--    type state_type is (S0, S1, S2, S3); 
--    signal next_state, current_state: state_type;
--    signal current_done: integer;
--begin

-- state_reg: process(i_clk, i_rst)
--  begin
--    if i_rst='1' then
--      current_state <= S0; -- vedere se modificare in seguito
--      current_done <= 0;  -- vedere se ridondante
--    elsif rising_edge(i_clk) then
--        case current_state is
--              when S0 =>
--                if i_start ='1' then
--                  current_state <= next_state;
--                end if;
--              when S1 =>
--                   if current_done = 1 then
--                  current_state <= next_state;
--                  end if;
--              when S2 =>
--                if i_start ='0' then
--                    current_state <= next_state;
--                end if;
--             when S3 =>
--               if current_done = 0 then
--                    current_state <= next_state;
--              end if;
--        end case;
--    end if;
--  end process;

--lambda: process(current_state)
--  begin
--    case current_state is
--      when S0 =>
--          next_state <= S1;
--      when S1 =>
--          next_state <= S2;
--      when S2 =>
--          next_state <= S2;
--      when S3 =>
--          next_state <= S0;
--    end case;
--  end process;
  
--delta: process(current_state)
--    begin
--      case current_state is
--        when S0 =>
--         -- aspetto start
         
--        when S1 =>
--         -- eseguo il codice (elaborazione)
         
--        when S2 =>
--         --aspetto start
--        when S3 =>
--         --metto giù done 
--         o_done <= '0';
--         current_done <= 0;
--      end case;
--    end process;  


--end Behavioral;
