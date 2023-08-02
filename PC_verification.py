# -*- coding: utf-8 -*-
"""
Created on Sat Jul 29 22:20:23 2023

@author: natal
"""

import serial

serialPort = serial.Serial("COM7", 115200)
#serialPort.set_buffer_size(rx_size = 200000, tx_size = 200000);
serialPort.flush()

n = 0
data = []

send = 83
byte_value = send.to_bytes(1, 'big');


serialPort.write(byte_value) # Send "S" to start sending data from FPGA

while (serialPort.in_waiting == 0):
    hey = 1

while len(data) < (2*65536):
    while (serialPort.in_waiting > 0):
        data.append(serialPort.read(1))
        n = n + 1    


serialPort.close()

# Generate 16-bit lookup table data
for n in range(2**(15)):
    hey = 0
    # add fixed point after 12 bits
    #fixed = 
    
    # Work out sigmoid
    
    # Convert to fixed point
    