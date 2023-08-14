LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb  IS 
END ; 
 
ARCHITECTURE tb_arch OF tb IS
  SIGNAL test   :  STD_LOGIC  ; 
  SIGNAL uart_rx   :  STD_LOGIC  ; 
  SIGNAL clk   :  STD_LOGIC  ; 
  SIGNAL uart_tx   :  STD_LOGIC  ; 
  COMPONENT sigmoid_LUT  
    PORT ( 
      test  : out STD_LOGIC ; 
      uart_rx  : in STD_LOGIC ; 
      clk  : in STD_LOGIC ; 
      uart_tx  : out STD_LOGIC ); 
  END COMPONENT ; 
BEGIN
  DUT  : sigmoid_LUT  
    PORT MAP ( 
      test   => test  ,
      uart_rx   => uart_rx  ,
      clk   => clk  ,
      uart_tx   => uart_tx   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 10 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 10 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 499
	loop
	    clk  <= '1'  ;
	   wait for 10 ns ;
	    clk  <= '0'  ;
	   wait for 10 ns ;
-- 9990 ns, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 10 ns ;
-- dumped values till 10 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 0 ns, End Time = 10 us, Period = 0 ns
  Process
	Begin
	 uart_rx  <= '0'  ;
	wait for 20 ns ;
	 uart_rx  <= '0'  ;
	wait for 20 ns ;
	 uart_rx <= '1' ;
	wait for 20 ns ;
	 uart_rx <= '0' ;
	wait for 20 ns ;
	 uart_rx <= '1' ;
	wait for 20 ns ;
	 uart_rx <= '0' ;
	wait for 20 ns ;
	 uart_rx <= '0' ;
	wait for 20 ns ;
	 uart_rx <= '1' ;
	wait for 20 ns ;
	 uart_rx <= '1' ;
	wait for 20 ns ;
	 uart_rx <= '1' ;
	wait;
 End Process;


-- "Constant Pattern"
---- Start Time = 0 ns, End Time = 10 us, Period = 0 ns
--  Process
--	Begin
--	 if uart_tx  /= ('0'  ) then 
--		report " test case failed" severity error; end if;
--	wait for 10 us ;
---- dumped values till 10 us
--	wait;
-- End Process;
END;
