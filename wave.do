view wave 
wave clipboard store
wave create -pattern none -portmode in -language vhdl /sigmoid_lut/clk 
wave create -pattern none -portmode in -language vhdl /sigmoid_lut/uart_rx 
wave create -pattern none -portmode out -language vhdl /sigmoid_lut/uart_tx 
wave create -pattern none -portmode out -language vhdl /sigmoid_lut/test 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 1000ns -dutycycle 50 -starttime 0ns -endtime 10000ns NewSig:/sigmoid_lut/clk 
wave modify -driver freeze -pattern constant -value 0 -starttime 0ns -endtime 10000ns NewSig:/sigmoid_lut/uart_rx 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 20ns -dutycycle 50 -starttime 0ns -endtime 10000ns NewSig:/sigmoid_lut/clk 
wave modify -driver expectedOutput -pattern constant -value 0 -starttime 0ns -endtime 10000ns NewSig:/sigmoid_lut/uart_tx 
{wave export -file {D:/4th year/EES 424/nataliePrac1/simulation/modelsim/tb} -starttime 0 -endtime 10000 -format vhdl -designunit sigmoid_lut} 
WaveCollapseAll -1
wave clipboard restore
