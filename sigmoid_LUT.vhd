library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sigmoid_LUT is
port (
	clk : in std_logic;
	uart_rx : in std_logic;
	uart_tx : out std_logic;
	test : out std_logic
	);
end sigmoid_LUT;

architecture archPrac1 of sigmoid_LUT is
	signal send_value, temp_send_value, send_LUT, temp_send_LUT, sending, received, prev_received, clear_buf, receive_flag : std_logic := '0';
	signal value_sent, value_sent_pulse : std_logic := '1';
	signal received_byte, high_byte, low_byte : std_logic_vector(7 downto 0);
	signal tx_data, temp_tx_data, address : std_logic_vector(15 downto 0) := "0000000000010101"; -- 16 bit values	 
	signal num_values_sent, temp_num_values_sent, num_vals, adrs : integer range 0 to 65536 := 0; 
	signal rx_counter, num_bytes_received : integer range 0 to 3;
	type rx_buffer is array (0 to 2) of std_logic_vector(7 downto 0);
   signal receive_buffer : rx_buffer;
	signal rx_buffer0, rx_buffer1, rx_buffer2 : std_logic_vector(7 downto 0);
	 
	component UART is
	port (
		clk, send_value, rx_bit : in std_logic;
		tx_data : in std_logic_vector(15 downto 0);
		tx_bit, value_sent, value_sent_pulse, received : out std_logic;	
		received_byte : out std_logic_vector(7 downto 0)
		);
	end component;
	
	
	component LUT is
	port (
		address : in integer range 0 to 65535;
		data_val : out std_logic_vector(15 downto 0)
		);
	end component;
	
	 
	 
begin
	
		UART_inst : UART port map 
			(
			 clk => clk, 
			 rx_bit => uart_rx,
			 tx_bit => uart_tx,
			 send_value => send_value,
			 value_sent => value_sent,
			 value_sent_pulse => value_sent_pulse,
			 tx_data => tx_data,
			 received_byte => received_byte,
			 received => received
			 );
			 
			 
		LUT_inst : LUT port map
			(
			address => num_values_sent,
			data_val => tx_data
			);
			 
			 
			 
			 
		
	
		
		send_value <= temp_send_value or not(value_sent) or send_LUT or sending;
		
		
					  
		--tx_data <= address;--"0100010001010011";-- loads data		
		
		num_values_sent <= temp_num_values_sent when (num_vals = 65536) else
								 adrs;
		
		sending <= '0' when (num_values_sent = 0) else -- continues sending LUT
					  '1' when (num_values_sent < num_vals and receive_flag = '1') else
					  '0';
					  
		send_LUT <= '1' when (rx_buffer2 = "01010011") else --(received_byte = "01010011" and rx_counter = 0) else  
						'0';
						
		num_vals <= 65536 when (rx_buffer2 = "01010011") else
						1 when (rx_buffer2 = "01000100");
						
	
		temp_send_value <= '1' when (rx_buffer2 = "01000100") else
								 '0';						 
								 
		
		address <= (rx_buffer0 & rx_buffer1) when (rx_buffer2 = "01000100");
		
		adrs <= to_integer(unsigned(address)) when (rx_buffer2 = "01000100") ;

								 
		
		clear_buf <= '1' when value_sent_pulse = '1' else -- clear the receive buffer after transmitting a value so that received command does not execute again 
						 '0';	
						 
		
		--test <= clear_buf;
		
		test <= sending;
		
		--num_bytes_received <= rx_counter;
		
		rx : process (received)	
			variable counter : integer range 0 to 3 := 0;
		begin
			if clear_buf = '1' then	
				
				rx_buffer2 <= "00000000";
				rx_buffer1 <= "00000000";
				rx_buffer0 <= "00000000";
				
			elsif rising_edge(received) then
				receive_flag <= '1'; -- set once when code is started otherwise latched values are not initialised
				rx_buffer2 <= rx_buffer1;
				rx_buffer1 <= rx_buffer0;
				rx_buffer0 <= received_byte;
				
				--rx_counter <= rx_counter + 1;
				counter := counter + 1;
				
				if counter = 3 then
					counter := 0;	
					-- rx_buffer0 and rx_buffer1 have not yet assumed their new values here in the process
					
				end if;	
				
			end if;		
		end process rx;
					
					
		
		
		
		
		address_inc : process (value_sent) -- load new data value		
		begin	
			
			if rising_edge(value_sent) then				
				temp_num_values_sent <= temp_num_values_sent + 1;
				
				if temp_num_values_sent = num_vals then
					temp_num_values_sent <= 0;
				end if;
						
			end if; 					
		
		end process address_inc;
		
		
		
		
		
		
		
		
		
		
		

end archPrac1;