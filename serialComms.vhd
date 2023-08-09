library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- need entity
entity serialComms is
port(
button: in std_logic; -- button 1 KEY[0] on PIN_AH17
clk: in std_logic; -- this is 50 MHz clock on PIN_V11 
tx: out std_logic); -- just choose a random pin
end serialComms;

-- will start with behavioural logic but will need to change to structural
architecture UART of serialComms is
signal tx_value : std_logic_vector(7 downto 0);
signal baud_ready: std_logic;

begin
	baud_proc: process(clk) -- baudrate generator
	variable baud_counter: integer := 0;
	begin
		if (rising_edge(clk)) then
			if (baud_counter < 433) then -- one less than 434
				baud_counter := baud_counter + 1;
				baud_ready <= '0'; -- baud not ready
			else
				baud_counter := 0; -- initialise counter again as reached max
				baud_ready <= '1'; -- baud ready
			end if; 
		end if; 
	end process baud_proc;
	
	transmit_proc: process(clk, button, baud_ready) -- transmission
	variable tx_counter : integer := 0;
	begin
	tx_value <= "11111111"; -- 8 bit value to send 
		if (button = '0') then 
			if (baud_ready = '1') then 
				if (rising_edge(clk)) then 
					if (tx_counter < 8) then 
						tx <= tx_value(tx_counter); -- send tx
						tx_counter := tx_counter + 1;
					else
						tx_counter := 0; -- reset tx_counter from 8 to 0
						baud_ready <= '0'; -- reset baud ready flag
					end if;
				end if; 
			end if;
		end if;
	end process transmit_proc;
end UART;