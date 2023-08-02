library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART is
port (
	clk : in std_logic;
	uart_rx : in std_logic;
	uart_tx : out std_logic;
	test : out std_logic);
end UART;

architecture myUART of UART is
	signal baud_clock, transmit_en, temp_en, next_temp_en, reset, next_reset : std_logic := '0';
	signal rx_data, temp_rx_reg : std_logic_vector(7 downto 0);
	signal tx_data : std_logic_vector(15 downto 0); -- 16 bit values
	signal temp_tx_bit : std_logic;
	signal temp_rx, tx_end, temp_end, temp_test : std_logic := '1'; 
	type clk_cycles is range 0 to 2604;
	type uart_bits is range 0 to 19;
	type num_values_in_LUT is range 0 to 65536;
	constant num_cycles : clk_cycles := 217; --2604
	begin
	
		-- Load data to transmit 
		tx_data <= "0100000101000010"; -- assign fixed data bits for now
	
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
		

		--idle_before_start : process (baud_clock)
		--variable idle_bits : uart_bits := 0;
		--begin
			--if rising_edge(baud_clock) then
				--if (idle_bits = 9) then
					--temp_en <= '1';					
				--else
					--temp_en <= '0';
					--idle_bits := idle_bits + 1;				 
				--end if;			
			--end if;		
		--end process idle_before_start;
		
				
		
		serial_transmitter : process (baud_clock)
		variable bit_counter, end_of_byte : uart_bits := 0;
		variable num_bytes_sent, next_num_bytes_sent, block_counter : integer := 0; -- change to appropriate range
		begin
			if (transmit_en = '1') then			
				
					if (rising_edge(baud_clock)) then
						reset <= next_reset; -- FSM like
		
						if (bit_counter = 0) then
							temp_tx_bit <= '0'; -- start bit
							bit_counter := 1;							
						elsif (bit_counter = 9) then
							temp_tx_bit <= '1'; -- stop bit
							bit_counter := 10;	
	
							--if reset = '1' then
								--num_bytes_sent := 0;
								--block_counter := block_counter + 1;
							--else
								--num_bytes_sent := num_bytes_sent+1;		
							--end if;
							
						elsif (bit_counter = 10) then
							temp_tx_bit <= '0'; -- start bit of byte 2
							bit_counter := 11;
						elsif (bit_counter = 19) then
							temp_tx_bit <= '1'; -- stop bit of byte 2
							bit_counter := 0;	
	
							if reset = '1' then
								num_bytes_sent := 0;
								block_counter := block_counter + 1;
							else
								num_bytes_sent := num_bytes_sent+1;		
							end if;
							
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
						end if;	
						
						
			
						if (num_bytes_sent < 511) then  
							temp_end <= '0'; 
							temp_test <= '1';
							next_reset <= '0';
						elsif (num_bytes_sent = 511 ) then 							
							temp_end <= '0';														
							next_reset <= '1'; -- FSM type code 
							temp_test <= '0';							
						else
							temp_test <= '1';
							temp_end <= '1';						
						end if;
						
						if (block_counter = 128) then
							temp_end <= '1';
						end if;
					
					end if; -- rising edge 
					
					
					
						
					
				
			else
				temp_tx_bit <= '1'; -- idle  
				bit_counter := 0;
				block_counter := 0;
				--temp_end <= '0';
				num_bytes_sent := 0;
				next_reset <= '0';
			end if;	-- transmit_en	
			
		end process serial_transmitter;
		
		uart_tx <= temp_tx_bit;
		
		temp_rx <= uart_rx;
		
		test <= reset;
		
		tx_end <= temp_end;
		
		transmit_en <= temp_en or (not(temp_end));
		
		
		serial_receiver : process (baud_clock)
		variable bit_counter : uart_bits := 0;
		begin		
			if rising_edge(baud_clock) then
				temp_en <= '0';
				if (bit_counter = 0) then
					if (temp_rx = '0') then
						bit_counter := 1;	-- received the start bit
					end if;
					if (next_temp_en = '1') then
						temp_en <= '1';
						next_temp_en <= '0';
					end if;
				elsif (bit_counter = 9) then					
					bit_counter := 0; -- received the stop bit
					if (temp_rx_reg = "01010011") then -- send "S" from PC to start transmission
						next_temp_en <= '1';
					--elsif (temp_rx_reg = "01010000") then -- send "P" from PC to stop transmission (need to add extra 'if' in tx process)
						--temp_en <= '0';
					end if;
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
		
		rx_data <= temp_rx_reg;
		
		
		
		

end myUART;