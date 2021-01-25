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
    type state_type is (START, COLUMN_REQUEST, ROW_REQUEST, DATA_REQUEST, DATA_FROM_RAM, ELABORATION,  WAITING, FINISH, WAITING_MAX_MIN, ELABORATION2,ELABORATION3,ELABORATION4,  PREPARATION_TO_WRITE,  GET_DATA);
    
    -- segnali
    signal current_state :  state_type;
    signal next_state : state_type;
    --signal next_wait_state : state_type;
    
    signal dimension : std_logic_vector(15 downto 0) ;
   -- signal end_dimension : std_logic_vector(15 downto 0) ;
    signal contatore : std_logic_vector(15 downto 0);

    signal max_number : std_logic_vector(7 downto 0):= (others => '0');
    signal min_number : std_logic_vector(7 downto 0) := (others => '1');
    signal shift_level : std_logic_vector(7 downto 0) := (others => '0');
    signal temp_pixel : std_logic_vector(15 downto 0) := (others => '0');
    signal delta : std_logic_vector(7 downto 0) := (others => '0');

    
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
                        current_state <= WAITING;
                        next_state <= COLUMN_REQUEST;
                        max_number <= (others => '0');
                        min_number <= (others => '1');
                    end if;
                    
                when COLUMN_REQUEST =>
                    dimension <= "00000000"  & i_data;                  
                    o_we <= '0';
                    o_en <= '1';
                    o_address <= (0 => '1', others => '0');
                    next_state <= ROW_REQUEST;
                    current_state <= WAITING;
                    contatore <= contatore + 1;
                    
                -- necessità di attendere un periodo di clock in più
                when WAITING =>
                    current_state <= next_state;    
                    
                when ROW_REQUEST =>                  
                   -- dimension <= dimension * i_data;  
                    dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(dimension) * conv_integer(i_data), 16));  
                    current_state <= DATA_REQUEST;
                    contatore <= contatore + 1;
                    
               
                when DATA_REQUEST =>
                    if(conv_integer(dimension)= 0) then
                        current_state <= FINISH;
                    else
                        -- salvo in un vector di 16 bit l'indirizzo finale della ram che si avrà dopo la scrittura dell'immagine
                        --end_dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(2*(conv_integer(dimension)) + 2, 16));
                        --end_dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(dimension) + conv_integer(dimension) + 2, 16));  --  oppure +1   );
                        if (conv_integer(dimension) + 2  = conv_integer(contatore)) then
                            current_state <= ELABORATION;
                            contatore <= (1 => '1', others => '0');
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
                    end if;
                    
                    
                -- lettura pixel
                when DATA_FROM_RAM =>
                    o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                    current_state <= WAITING;
                    next_state <= WAITING_MAX_MIN;
                -- calcolo nuovo valore del pixel: differenza tra valore corrente e valore minimo
                    
                    
                -- necessità di due cicli di clock per ricevere il dato
                  
                         
                when WAITING_MAX_MIN => 
                    -- ram(conv_integer(contatore)) <= i_data;
                    contatore <= contatore + 1;
                    -- ricerca del valore massimo e del valore minimo                 
                    if(conv_integer(min_number) > conv_integer(i_data)) then
                        min_number <= i_data;
                    end if;
                    if(conv_integer(max_number) < conv_integer(i_data)) then
                        max_number <= i_data;
                    end if;
                    current_state <= DATA_REQUEST;
        
                -- calcolo shift_level (funzione "floor")
                -- perché non usi direttamente floor?
                when ELABORATION =>
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
                  
                current_state <= GET_DATA;



                when GET_DATA =>
                    --VEDERE SE LA DIMENSIONE è ZERO 
                    o_we <= '0';
                    o_en <= '1';
                    o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                    current_state <= WAITING;
                    next_state <= ELABORATION2;


                when ELABORATION2 =>
                   temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(i_data) - conv_integer(min_number)), 16));
                   current_state <= ELABORATION3;

                -- calcolo nuovo valore del pixel: shift dei bit di "shift_level"
                -- usare la funzione apposita
                when ELABORATION3 =>
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
                
                    current_state <=  ELABORATION4;

                -- controllo sul nuovo valore (< 256) e 
                when ELABORATION4 =>
                    if(conv_integer(temp_pixel) >= 255) then
                        temp_pixel <= "0000000011111111";
                    end if;
                 
                   
                    current_state <= PREPARATION_TO_WRITE;
                    -- ma scrive prima nella ram "locale" e poi lo fa davvero in un altro stato?

                -- effettiva scrittura sulla ram
                when PREPARATION_TO_WRITE =>
                    if (conv_integer(dimension)+ conv_integer(dimension) + 2 > conv_integer(contatore) + conv_integer(dimension)) then
                        o_we <= '1';
                        o_en <= '1';
                        o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore)+ conv_integer(dimension));
                     --   o_data <=  STD_LOGIC_VECTOR(UNSIGNED(temp_pixel(7 downto 0))); 
                        o_data <=  temp_pixel(7 downto 0);
                        -- o_data <= "00000000";
                      --  current_state <= finish;
                    
                      
                        if(conv_integer(dimension)+ conv_integer(dimension) + 2 = conv_integer(contatore) + conv_integer(dimension) +1) then
                        
                            current_state <= FINISH;
                        else
                            current_state <= GET_DATA;
                            contatore <= contatore + 1;
                        end if;
                      
                    end if;                 
                    
                when FINISH =>
                 
                    if i_start = '0' then
                        o_done <= '0';
                        current_state <= START;
                    else
                        o_done <= '1';
                        o_we <= '1';
                        o_en <= '0';
                    end if;
            end case;

        end if;
    end process;

end Behavioral;
