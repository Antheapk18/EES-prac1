library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- need entity
entity serialComms is
port(
clk: in std_logic; -- this is 50 MHz clock on PIN_V11 
tx: out std_logic; -- just choose a random pin
rx_value: in std_logic);
end serialComms;

-- will start with behavioural logic but will need to change to structural
architecture UART of serialComms is
signal tx_value : std_logic_vector(7 downto 0) := "00000000";
signal rx_reg : std_logic_vector(7 downto 0) := "00000000";
signal tx_counter : integer := 0;
signal rx_counter : integer := 0;
signal baud_Txcounter: integer := 0;
signal baud_Rxcounter: integer :=0;
signal flag_receive : integer := 0;

begin

	receive_proc: process(flag_receive, clk)
	begin
	if (rising_edge(clk)) then
		if (baud_Rxcounter < 5208 ) then -- 9600 baud rate 
			baud_Rxcounter <= baud_Rxcounter + 1;
		else
			baud_Rxcounter <= 0;-- initialise counter again as reached max
			if (rx_counter = 0) then -- If start bit is received
				if(rx_value = '0') then
					rx_counter <= 1; -- received the start start bit
				end if;
			elsif (rx_counter = 9) then
				rx_counter <= 0; -- received the stop bit
					if (rx_reg = "01010011") then
					flag_receive <= 1;
					end if;
				rx_reg <= "00000000";
			else
				case rx_counter is
					when 1 => rx_reg(0) <= rx_value;
					when 2 => rx_reg(1) <= rx_value;
					when 3 => rx_reg(2) <= rx_value;
					when 4 => rx_reg(3) <= rx_value;
					when 5 => rx_reg(4) <= rx_value;
					when 6 => rx_reg(5) <= rx_value;
					when 7 => rx_reg(6) <= rx_value;
					when 8 => rx_reg(7) <= rx_value;
					when others => rx_reg <= "00000000";
				end case;
				rx_counter <= rx_counter + 1; -- ??
			end if;
		end if;
	end if;
	end process receive_proc;
			

	transmit_proc: process(flag_receive, clk) -- transmission
	begin
	tx_value <= "01010101"; -- 8 bit value to send - (ascii U)
	if (rising_edge(clk)) then
		if (baud_Txcounter < 5208 ) then -- 9600 baud rate 
			baud_Txcounter <= baud_Txcounter + 1;
		else
			baud_Txcounter <= 0;-- initialise counter again as reached max
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
					tx_counter <= 0; -- reset counter need a reset somewhere but not sure
				end if;
			end if;
		end if;
	end if; 
	end process transmit_proc;
end UART;