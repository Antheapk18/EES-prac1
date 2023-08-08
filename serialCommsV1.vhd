library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- need entity
entity serialCommsV1 is
port(
-- switch: in std_logic; 
switch : in std_logic;
clk: in std_logic; -- this is 50 MHz clock on PIN_V11 
tx: out std_logic); -- just choose a random pin
end serialCommsV1;

-- will start with behavioural logic but will need to change to structural
architecture UART of serialCommsV1 is
signal tx_value : std_logic_vector(7 downto 0) := "00000000";
signal tx_counter : integer := 0;
signal baud_counter: integer := 0;

begin
	transmit_proc: process(switch, clk) -- transmission
	begin
	tx_value <= "01010101"; -- 8 bit value to send - (ascii U)
	if (rising_edge(clk)) then
		if (baud_counter < 5208 ) then -- 9600 baud rate 
			baud_counter <= baud_counter + 1;
		else
			baud_counter <= 0;-- initialise counter again as reached max
			if (switch = '1') then
				if (tx_counter = 0) then 
					tx <= '0'; -- start bit
					tx_counter <= 1;
				elsif (0 < tx_counter and tx_counter < 9) then
					case (tx_counter) is 
						when 1 => tx <= tx_value(0);
						when 2 => tx <= tx_value(1);
						when 3 => tx <= tx_value(2);
						when 4 => tx <= tx_value(3);
						when 5 => tx <= tx_value(4);
						when 6 => tx <= tx_value(5);
						when 7 => tx <= tx_value(6);
						when 8 => tx <= tx_value(7);
					   when others => tx <= '0';
					end case;
					tx_counter <= tx_counter + 1;
				elsif (tx_counter = 9) then 
					tx <= '1'; -- stop bit
					tx_counter <= 0; -- reset counter need a reset somewhere but not sure
				end if;
			end if;
		end if;
	end if; 
	end process transmit_proc;
end UART;