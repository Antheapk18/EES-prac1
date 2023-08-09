library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- need entity
entity prac_16bits is
port(
-- switch : in std_logic; -- PIN_L10
clk: in std_logic; -- this is 50 MHz clock on PIN_V11 
rx : in std_logic; -- PIN_AH27
-- LED: out std_logic; -- PIN_W15 - LED[0]
tx: out std_logic); -- just choose a random PIN_AG28
end prac_16bits;

-- will start with behavioural logic but will need to change to structural
architecture UART of prac_16bits is
signal tx_value : std_logic_vector(7 downto 0) := "00000000";
signal tx_value2 : std_logic_vector(7 downto 0) := "00000000";
signal rx_value : std_logic_vector(7 downto 0) := "00000000";
signal tx_counter : integer := 0;
signal rx_counter : integer := 0;
signal baud_counter: integer := 0;
signal baudReceive_counter: integer := 0;
signal flag_receive :integer := 0; -- flag to be set when allowed to transmit data back

begin

-- receive
	receive_proc: process(clk)
	begin 
	if (rising_edge(clk)) then
		if (baudReceive_counter < 5208 ) then -- 9600 baud rate 
			baudReceive_counter <= baud_counter + 1;
		else
			baudReceive_counter <= 0;-- initialise counter again as reached max
			-- check if first bit is 0
			if (rx_counter = 0) then 
				if (rx = '0') then 
				rx_counter <= 1;
				end if;
			elsif (0 < rx_counter and rx_counter < 9) then 
				case (rx_counter) is 
					when 1 => rx_value(0) <= rx;
					when 2 => rx_value(1) <= rx;
					when 3 => rx_value(2) <= rx;
					when 4 => rx_value(3) <= rx;
					when 5 => rx_value(4) <= rx;
					when 6 => rx_value(5) <= rx;
					when 7 => rx_value(6) <= rx;
					when 8 => rx_value(7) <= rx;
					when others => rx_value(7) <= '0';
				end case;
				rx_counter <= rx_counter + 1; -- increment counter
			elsif (rx_counter = 9) then 
				if (rx = '1') then 
					rx_counter <= 0; -- reset the counter -- reached end of recieve
					if (rx_value = "01010011") then 
						flag_receive <= 1; -- S recived correctly
					else
						flag_receive <= 0; -- S not recived correctly 
					end if;
				end if;
			end if;	
		end if;
	end if;
	end process receive_proc;
	
-- transmission 
	transmit_proc: process(flag_receive, clk) -- transmission
	begin
	tx_value <= "01010101"; -- 8 bit value to send - (ascii U)
	tx_value2 <= "01000001"; -- ascii A
	if (rising_edge(clk)) then
		if (baud_counter < 5208 ) then -- 9600 baud rate 
			baud_counter <= baud_counter + 1;
		else
			baud_counter <= 0;-- initialise counter again as reached max
			if (flag_receive = 1) then
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
					tx_counter <= 10; -- reset counter need a reset somewhere but not sure
				elsif (tx_counter = 10) then 
					tx <= '0'; -- start bit of second byte
					tx_counter <= 11;
				elsif (10 < tx_counter and tx_counter < 19) then 
					case (tx_counter) is 
						when 11 => tx <= tx_value2(0);
						when 12 => tx <= tx_value2(1);
						when 13 => tx <= tx_value2(2);
						when 14 => tx <= tx_value2(3);
						when 15 => tx <= tx_value2(4);
						when 16 => tx <= tx_value2(5);
						when 17 => tx <= tx_value2(6);
						when 18 => tx <= tx_value2(7);
					   when others => tx <= '0';
					end case;
					tx_counter <= tx_counter + 1;
				elsif(tx_counter = 19) then 
					tx <= '1'; -- stop bit
					tx_counter <= 0; -- reset counter
				end if;
			end if;
		end if;
	end if; 
	end process transmit_proc;
end UART;