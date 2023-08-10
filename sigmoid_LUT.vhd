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
	signal prev_value_sent, value_sent, value_sent_pulse : std_logic := '1';
	signal received_byte, high_byte, low_byte : std_logic_vector(7 downto 0);
	signal tx_data, temp_tx_data, address : std_logic_vector(15 downto 0) := "0000000000010101"; -- 16 bit values	 
	signal num_values_sent, temp_num_values_sent, num_vals, adrs, LUT_address : integer range 0 to 65536 := 0; 
	signal rx_counter, num_bytes_received : integer range 0 to 3;
	type rx_buffer is array (0 to 2) of std_logic_vector(7 downto 0);
   signal receive_buffer : rx_buffer;
	signal rx_buffer0, rx_buffer1, rx_buffer2 : std_logic_vector(7 downto 0);
	
	type state_type is (ST0,ST1,ST2); 
	signal PS,NS : state_type := ST0;
	 
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
			address => LUT_address,--num_values_sent,
			data_val => tx_data
			);
			 
			 
			 

		
		
		test <= '1' when PS = ST1 else
				  '0'; 
		
		
		sync_proc : process (clk, NS)
		begin
			if rising_edge(clk) then
				PS <= NS;
			end if;
		end process sync_proc;
		
		
		
		comb_proc : process (PS, num_values_sent, value_sent, rx_buffer2)
		begin
			case PS is
				when ST0 =>
				
					send_value <= '0';
				
					if rx_buffer2 = "01010011" then -- received "S"
						NS <= ST1; -- send LUT
						
						send_value <= '1';
						LUT_address <= 0;
					elsif rx_buffer2 = "01000100" then -- received "D"
						NS <= ST2; -- send one value
						
						send_value <= '1';
						address <= (rx_buffer0 & rx_buffer1);		
						LUT_address <= to_integer(unsigned(address));
					else
						NS <= ST0;
						send_value <= '0';
						LUT_address <= 0;
						
					end if;
					
					clear_buf <= '0';
					
				when ST1 =>
				
					send_value <= '1'; 					
					
					LUT_address <= num_values_sent;
					
					if (num_values_sent = 65536) then						
						NS <= ST0;
						clear_buf <= '0';
					else 
						NS <= ST1;
						clear_buf <= '1';
					end if;						
					
					 
					
					
				when ST2 =>
				
					--address <= (rx_buffer0 & rx_buffer1);		
					--LUT_address <= to_integer(unsigned(address));
					
					send_value <= '1';
					
					if value_sent = '1' then
						NS <= ST0;
						clear_buf <= '0';
					else
						NS <= ST2;
						clear_buf <= '1';
					end if;	
		
					
					
				when others =>
					NS <= ST0;
			end case;
		end process comb_proc;
		
		
		
		
		
		rx : process (received, clear_buf)	
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
				
				counter := counter + 1;
				
				if counter = 3 then
					counter := 0;	
					-- rx_buffer0 and rx_buffer1 have not yet assumed their new values here in the process
					
				end if;	
				
			end if;		
		end process rx;
					
					
		
		num_values_sent <= temp_num_values_sent;
		
		
		address_inc : process (value_sent) -- increment LUT adress
		begin	
		
		if PS = ST1 then
			
			if rising_edge(value_sent) then				
				
				if temp_num_values_sent = 65536 then
					temp_num_values_sent <= 0;
				else
					temp_num_values_sent <= temp_num_values_sent + 1;
				end if;
						
			end if; 
		else
			temp_num_values_sent <= 0;
			
		end if;			
		
		end process address_inc;
		
		
		
		
		
		
		
		
		
		
		

end archPrac1;