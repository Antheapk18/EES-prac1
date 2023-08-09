library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART is
port (
	clk, send_value, rx_bit : in std_logic;
	tx_data : in std_logic_vector(15 downto 0);
	tx_bit, value_sent : out std_logic;	
	received_byte : out std_logic_vector(7 downto 0)
	);
end UART;

-- Architecture for sending 16-bit values over UART

architecture archUART of UART is
	signal baud_clock, temp_value_sent, temp_tx_bit : std_logic := '0';
	signal temp_rx_reg : std_logic_vector(7 downto 0);
	signal temp_rx : std_logic := '1';	
	type clk_cycles is range 0 to 2604;
	type uart_bits is range 0 to 19;
	constant num_cycles : clk_cycles := 434; -- 57600 baud
begin
		
		-- Generate baud rate
		baud_generator : process (clk)
		variable cycle_counter : clk_cycles := 0;		
		begin
			if rising_edge(clk) then
				if (cycle_counter = num_cycles) then
					baud_clock <= not baud_clock;
					cycle_counter := 0;
				else
					cycle_counter := cycle_counter + 1;
				end if;
			end if;
		end process baud_generator;	
	


		
		tx_bit <= temp_tx_bit; 		
		
		value_sent <= temp_value_sent;
	
		
		
		serial_transmitter : process (baud_clock)
			variable bit_counter, end_of_byte : uart_bits := 0;
			variable num_bytes_sent, next_num_bytes_sent, block_counter : integer range 0 to 511 := 0; -- change to appropriate range
		begin
		
			if (send_value = '1') then	
			
				if (rising_edge(baud_clock)) then
					
					if (bit_counter = 0) then
						temp_tx_bit <= '0'; -- start bit of byte 1
						bit_counter := 1;
						temp_value_sent <= '0';				
						 
					elsif (bit_counter = 9) then
						temp_tx_bit <= '1'; -- stop bit of byte 1
						bit_counter := 10;
						temp_value_sent <= '0';						
												
					elsif (bit_counter = 10) then
						temp_tx_bit <= '0'; -- start bit of byte 2
						bit_counter := 11;
						temp_value_sent <= '0';
												
					elsif (bit_counter = 19) then
						temp_tx_bit <= '1'; -- stop bit of byte 2
						bit_counter := 0;	
						temp_value_sent <= '1';
												
					else
						case bit_counter is -- data bits
							when 1 => temp_tx_bit <= tx_data(0); 
							when 2 => temp_tx_bit <= tx_data(1);
							when 3 => temp_tx_bit <= tx_data(2);
							when 4 => temp_tx_bit <= tx_data(3);
							when 5 => temp_tx_bit <= tx_data(4); 
							when 6 => temp_tx_bit <= tx_data(5);
							when 7 => temp_tx_bit <= tx_data(6);
							when 8 => temp_tx_bit <= tx_data(7);
							when 11 => temp_tx_bit <= tx_data(8); 
							when 12 => temp_tx_bit <= tx_data(9);
							when 13 => temp_tx_bit <= tx_data(10);
							when 14 => temp_tx_bit <= tx_data(11);
							when 15 => temp_tx_bit <= tx_data(12); 
							when 16 => temp_tx_bit <= tx_data(13);
							when 17 => temp_tx_bit <= tx_data(14);
							when 18 => temp_tx_bit <= tx_data(15);
							when others => temp_tx_bit <= '0';
						end case;	
						
						bit_counter := bit_counter + 1;
						temp_value_sent <= '0';						
													
					end if;					
				
				end if; -- rising edge 					
				
			else
				temp_tx_bit <= '1'; -- idle  
				bit_counter := 0;	
				temp_value_sent <= '1';			
			end if;	-- transmit_en	
			
		end process serial_transmitter;
		
		
		
		
		
		
		temp_rx <= rx_bit; -- bits received on pin
		
		received_byte <= temp_rx_reg; -- contains received byte
		
		
		serial_receiver : process (baud_clock)
			variable bit_counter : uart_bits := 0;
		begin		
			if rising_edge(baud_clock) then				
				if (bit_counter = 0) then
					if (temp_rx = '0') then
						bit_counter := 1;	-- received the start bit
					end if;					
				elsif (bit_counter = 9) then					
					bit_counter := 0; -- received the stop bit
					temp_rx_reg <= "00000000";
				else
					case bit_counter is -- data bits
						when 1 => temp_rx_reg(0) <= temp_rx; 
						when 2 => temp_rx_reg(1) <= temp_rx;
						when 3 => temp_rx_reg(2) <= temp_rx;
						when 4 => temp_rx_reg(3) <= temp_rx;
						when 5 => temp_rx_reg(4) <= temp_rx; 
						when 6 => temp_rx_reg(5) <= temp_rx;
						when 7 => temp_rx_reg(6) <= temp_rx;
						when 8 => temp_rx_reg(7) <= temp_rx;
						when others => temp_rx_reg <= "00000000";
					end case;
					bit_counter := bit_counter + 1;
				end if;				
			end if;	
		end process serial_receiver;
		
		

end archUART;