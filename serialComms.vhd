library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialComms is
    Port (
        clk     : in  std_logic;
        button  : in  std_logic;
        tx      : out std_logic
    );
end entity serialComms;

architecture Behavioral of serialComms is
    signal tx_value       : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_data_ready  : std_logic := '0';
    signal tx_bit_counter : integer range 0 to 10 := 0;
    signal tx_busy        : std_logic := '0';
    
    constant BAUD_RATE    : integer := 9600;  -- Desired Baud Rate (e.g., 9600 bps)
    constant CLOCK_FREQ   : integer := 50000000; -- FPGA Clock Frequency (e.g., 50 MHz)

begin
    -- Baud rate generator
    process(clk)
        variable baud_counter : integer range 0 to CLOCK_FREQ / BAUD_RATE - 1 := 0;
    begin
        if rising_edge(clk) then
            if baud_counter = 0 then
                tx_data_ready <= '1'; -- Ready to transmit data when baud_counter reaches 0
            else
                tx_data_ready <= '0'; -- Hold data until baud_counter reaches 0
            end if;
            
            baud_counter := (baud_counter + 1) mod (CLOCK_FREQ / BAUD_RATE);
        end if;
    end process;
    
    -- Transmitter process
    process(clk)
    begin
        if rising_edge(clk) then
            if button = '1' then
                tx_busy <= '1'; -- Start transmitting data when the button is pressed
                tx_bit_counter <= 0; -- Reset the bit counter
                tx_value <= "11001010"; -- Set your 8-bit data to be transmitted here (e.g., "11001010")
            end if;
            
            if tx_data_ready = '1' and tx_busy = '1' then
                if tx_bit_counter = 0 then
                    tx <= '0'; -- Start bit (low)
                elsif tx_bit_counter < 9 then
                    tx <= tx_value(tx_bit_counter - 1); -- Transmit the current bit
                else
                    tx <= '1'; -- Stop bit (high)
                end if;
                
                if tx_bit_counter = 10 then
                    tx_busy <= '0'; -- Data transmission is complete
                else
                    tx_bit_counter <= tx_bit_counter + 1; -- Move to the next bit
                end if;
            else
                tx <= '1'; -- Hold the line high when not transmitting
            end if;
        end if;
    end process;
end architecture Behavioral;



--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--
---- need entity
--entity serialComms is
--port(
--button: in std_logic; -- button 1 KEY[0] on PIN_AH17
--clk: in std_logic; -- this is 50 MHz clock on PIN_V11 
--tx: out std_logic); -- just choose a random pin
--end serialComms;
--
---- will start with behavioural logic but will need to change to structural
--architecture UART of serialComms is
--signal tx_value : std_logic_vector(7 downto 0);
--signal baud_ready: std_logic := '0';
--
--begin
--	baud_proc: process(clk) -- baudrate generator
--	variable baud_counter: integer := 0;
--	begin
--		if (rising_edge(clk)) then
--			if (baud_counter < 433) then -- one less than 434
--				baud_counter := baud_counter + 1;
--				baud_ready <= '0'; -- baud not ready
--			else
--				baud_counter := 0; -- initialise counter again as reached max
--				baud_ready <= '1'; -- baud ready
--			end if; 
--		end if; 
--	end process baud_proc;
--	
--	transmit_proc: process(clk, button) -- transmission
--	variable tx_counter : integer := 0;
--	begin
--	tx_value <= "11111111"; -- 8 bit value to send 
--		if (button = '0') then 
--			if (baud_ready = '1') then 
--				if (rising_edge(clk)) then 
--					if (tx_counter < 8) then 
--						tx <= tx_value(tx_counter); -- send tx
--						tx_counter := tx_counter + 1;
--					else
--						tx_counter := 0; -- reset tx_counter from 8 to 0
--						baud_ready <= '0'; -- reset baud ready flag
--					end if;
--				end if; 
--			end if;
--		end if;
--	end process transmit_proc;
--end UART;