----------------------------------------------------------------------------------
-- Company: Politecnico di Milano
-- Engineers: Gerosa Andrea, Longaretti Lorenzo
-- 
-- Create Date: 11.01.2021 23:34:12
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: Progetto di Reti Logiche
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


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
    type state_type is (START, DATA_REQUEST, WAITING, MAX_MIN_CALC, SHIFT_LEVEL_CALC, TEMP_PIXEL_CALC, TEMP_PIXEL_SHIFT, GREATER_THAN_255_CHECK, PREPARATION_TO_WRITE, GET_DATA, FINISH);
    
    -- segnali
    signal current_state :  state_type;
    signal next_state : state_type;
    
    signal dimension : std_logic_vector(15 downto 0) ;
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
            current_state <= START;
            o_done <= '0';
        -- eventi sul clock
        elsif rising_edge(i_clk) then
            case current_state is
            
                when START =>
                    if i_start = '1' then
                        o_we <= '0';
                        o_en <= '1';
                        
                        -- indirizzi di memoria partono da 0
                        -- richiesta numero colonne
                        o_address <= (others => '0');
                        
                        dimension <= (others => '0');
                        contatore <= (others => '0');
                        current_state <= WAITING;
                        next_state <= DATA_REQUEST;
                        max_number <= (others => '0');
                        min_number <= (others => '1');
                    end if;
                    
                -- necessità di attendere un periodo di clock in più
                when WAITING =>
                    current_state <= next_state;    
                    
                when DATA_REQUEST =>
                    -- richiesta numero righe
                    if(conv_integer(contatore) = 0) then 
                        dimension <= "00000000" & i_data;                 
                        o_we <= '0';
                        o_en <= '1';
                        o_address <= (0 => '1', others => '0');
                        
                        current_state <= WAITING;
                        contatore <= contatore + 1;
                    
                    -- calcolo dimensione immagine                    
                    elsif(conv_integer(contatore) = 1) then 
                        dimension <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(dimension) * conv_integer(i_data), 16));  
                        contatore <= contatore + 1;
                    
                    -- immagine con dimensione 0                 
                    elsif(conv_integer(dimension) = 0 and conv_integer(contatore) >= 2) then
                        current_state <= FINISH;
                    
                    -- immagine valida    
                    elsif(conv_integer(dimension) > 0 and conv_integer(contatore) >= 2) then
                        -- salvo in un vector di 16 bit l'indirizzo finale della ram che si avrà dopo la scrittura dell'immagine
                        if (conv_integer(dimension) + 2  = conv_integer(contatore)) then
                            current_state <= SHIFT_LEVEL_CALC;
                            contatore <= (1 => '1', others => '0');

                            -- calcolo del delta value
                            delta <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_integer(max_number) - conv_integer(min_number), 8));                       
                        else 
                            o_we <= '0';
                            o_en <= '1';
                            
                            -- prima richiesta pixel
                            o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                            current_state <= WAITING;
                            next_state <= MAX_MIN_CALC;
                        end if;
                    end if;
                   

                -- ricerca del valore massimo e del valore minimo                      
                when MAX_MIN_CALC => 
                    contatore <= contatore + 1;              
                    if(conv_integer(min_number) > conv_integer(i_data)) then
                        min_number <= i_data;
                    end if;
                    if(conv_integer(max_number) < conv_integer(i_data)) then
                        max_number <= i_data;
                    end if;
                    current_state <= DATA_REQUEST;
        
                -- calcolo shift_level (funzione "floor")
                when SHIFT_LEVEL_CALC =>
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
                        shift_level <= "00000000";
                    end if;
                  
                    current_state <= GET_DATA;

                -- seconda richiesta pixel
                when GET_DATA =>
                    o_we <= '0';
                    o_en <= '1';
                    o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore));
                    current_state <= WAITING;
                    next_state <= TEMP_PIXEL_CALC;

                -- calcolo nuovo valore del pixel: differenza tra valore corrente e valore minimo
                when TEMP_PIXEL_CALC =>
                   temp_pixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((conv_integer(i_data) - conv_integer(min_number)), 16));
                   current_state <= TEMP_PIXEL_SHIFT;

                -- calcolo nuovo valore del pixel: shift dei bit di "shift_level"
                when TEMP_PIXEL_SHIFT =>
                    temp_pixel <= STD_LOGIC_VECTOR(shift_left(TO_UNSIGNED(conv_integer(temp_pixel), 16), conv_integer(shift_level)));
                    current_state <=  GREATER_THAN_255_CHECK;

                -- controllo sul nuovo valore (< 256)
                when GREATER_THAN_255_CHECK =>
                    if(conv_integer(temp_pixel) >= 255) then
                        temp_pixel <= "0000000011111111";
                    end if;
                 
                    current_state <= PREPARATION_TO_WRITE;

                -- scrittura sulla ram
                when PREPARATION_TO_WRITE =>
                    if (conv_integer(dimension) + conv_integer(dimension) + 2 > conv_integer(contatore) + conv_integer(dimension)) then
                        o_we <= '1';
                        o_en <= '1';
                        o_address <= STD_LOGIC_VECTOR(UNSIGNED(contatore) + conv_integer(dimension));
                        o_data <=  temp_pixel(7 downto 0);
                    
                        if(conv_integer(dimension) + conv_integer(dimension) + 2 = conv_integer(contatore) + conv_integer(dimension) + 1) then
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
