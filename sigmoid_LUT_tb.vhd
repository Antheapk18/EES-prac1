library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
end testbench;

architecture behavior of testbench is
	component sigmoid_LUT is
	port (
		clk : in std_logic;
		uart_rx : in std_logic;
		uart_tx : out std_logic;
		test : out std_logic
		);
	end component;

	signal clock_sig, rx_bits, tx_bits, test, baud_clock, temp_tx_bit : std_logic := '1';
	
	begin
		
		clock : process
		begin
			clock_sig <= '0';
			wait for  10 ns;
			clock_sig <= '1';
			wait for 10 ns;
		end process;
		
		
		baud_generator : process (clock_sig) -- 01010011
			variable counter : integer range 0 to 434 := 0;
		begin
			if rising_edge(clock_sig) then
				if (counter = 434) then
					baud_clock <= not baud_clock;
					counter := 0;
				else
					counter := counter + 1;
				end if;			
			end if;
		end process;
		
		rx_bits <= temp_tx_bit;
		
		tb : process (baud_clock)
			variable bit_counter : integer range 0 to 29 := 0;
		begin
			if rising_edge(baud_clock) then
				if (bit_counter = 0) then
						temp_tx_bit <= '0'; -- start bit of byte 1
						bit_counter := 1;		
						 
				elsif (bit_counter = 9) then
					temp_tx_bit <= '1'; -- stop bit of byte 1
					bit_counter := 10;
											
				elsif (bit_counter = 10) then
					temp_tx_bit <= '0'; -- start bit of byte 2
					bit_counter := 11;
											
				elsif (bit_counter = 19) then
					temp_tx_bit <= '1'; -- stop bit of byte 2
					bit_counter := 20;
					
				elsif (bit_counter = 20) then
					temp_tx_bit <= '0'; -- start bit of byte 3
					bit_counter := 21;
											
				elsif (bit_counter = 29) then
					temp_tx_bit <= '1'; -- stop bit of byte 3
					bit_counter := 29; -- stop sending bits	
											
				else
					case bit_counter is -- data bits
						when 1 => temp_tx_bit <= '0'; 
						when 2 => temp_tx_bit <= '1';
						when 3 => temp_tx_bit <= '0';
						when 4 => temp_tx_bit <= '1';
						when 5 => temp_tx_bit <= '0'; 
						when 6 => temp_tx_bit <= '0';
						when 7 => temp_tx_bit <= '1';
						when 8 => temp_tx_bit <= '1';
						when 11 => temp_tx_bit <= '0'; 
						when 12 => temp_tx_bit <= '1';
						when 13 => temp_tx_bit <= '0';
						when 14 => temp_tx_bit <= '1';
						when 15 => temp_tx_bit <= '0'; 
						when 16 => temp_tx_bit <= '0';
						when 17 => temp_tx_bit <= '1';
						when 18 => temp_tx_bit <= '1';
						when 21 => temp_tx_bit <= '0'; 
						when 22 => temp_tx_bit <= '1';
						when 23 => temp_tx_bit <= '0';
						when 24 => temp_tx_bit <= '1';
						when 25 => temp_tx_bit <= '0'; 
						when 26 => temp_tx_bit <= '0';
						when 27 => temp_tx_bit <= '1';
						when 28 => temp_tx_bit <= '1';
						when others => temp_tx_bit <= '0';
					end case;	
					
					bit_counter := bit_counter + 1;					
													
					end if;	
			end if;
		
		end process;		
		
		
		inst: sigmoid_LUT port map (clk => clock_sig, uart_rx => rx_bits, uart_tx => tx_bits, test => test);
end;