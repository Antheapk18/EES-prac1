library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sigmoid_LUT is
port (
	clk : in std_logic;
	uart_rx : in std_logic;
	uart_tx : out std_logic
	);
end sigmoid_LUT;

architecture archPrac1 of sigmoid_LUT is
	signal send_value, temp_send_value, value_sent, send_LUT, sending : std_logic := '0';
	signal received_byte : std_logic_vector(7 downto 0);
	signal tx_data : std_logic_vector(15 downto 0) := "0000000000010101"; -- 16 bit values	 
	signal num_values_sent, temp_num_values_sent : integer range 0 to 65535 := 0; 
	type rx_buffer is array (0 to 2) of std_logic_vector(7 downto 0);
   signal receive_buffer : rx_buffer;
	 
	component UART is
	port (
		clk, send_value, rx_bit : in std_logic;
		tx_data : in std_logic_vector(15 downto 0);
		tx_bit, value_sent : out std_logic;	
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
			 tx_data => tx_data,
			 received_byte => received_byte
			 );
			 
			 
		LUT_inst : LUT port map
			(
			address => num_values_sent,
			data_val => tx_data
			);
			 
			 
			 
			 
		--send_value <= '0'; --'1' when received_byte = "01010011";
	
		
		send_value <= temp_send_value or not(value_sent) or send_LUT or sending;
		
		temp_send_value <= '0'; --'1' when received_byte = "01010011" else
								 --'1' when sending_LUT = '1' else
								 --'0'; -- for sending only one value from LUT
								 
		send_LUT <= '1' when received_byte = "01010011" else -- starts sending LUT						
						'0';
					  
		--tx_data <= lut_data(num_values_sent);--"0101001101001101"; -- loads data		
		
		num_values_sent <= temp_num_values_sent;
		
		sending <= '0' when (num_values_sent = 0) else -- continues sending LUT
					  '1' when (num_values_sent < 65536) else
					  '0';
					  
		
					
					
		
		address_inc : process (value_sent) -- load new data value		
		begin	
			
			if rising_edge(value_sent) then				
				temp_num_values_sent <= temp_num_values_sent + 1;
				
				if temp_num_values_sent = 65536 then
					temp_num_values_sent <= 0;
				end if;
						
			end if; 		
		
		end process address_inc;
		
		
		
		
		
		
		
		
		
		
		

end archPrac1;