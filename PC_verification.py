# -*- coding: utf-8 -*-
"""
Created on Sat Jul 29 22:20:23 2023

@author: natal
"""

import serial
import numpy as np
import matplotlib.pyplot as plt

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

while len(data) < (2*65536): #2*65536
    while (serialPort.in_waiting > 0):
        data.append(serialPort.read(1))
        n = n + 1  
        
serialPort.close()

# convert received data from bytes to decimal values
     
sigmoid = []
for n in range(len(data)):
    if n%2 == 0: # even numbers 
        byte_1 = int.from_bytes(data[n], 'big')
        byte_1 = format(byte_1, '08b')
        byte_2 = int.from_bytes(data[n+1], 'big')
        byte_2 = format(byte_2, '08b')
        comb = byte_2+byte_1
        sig = 0
        for p in range(1,17): # from 1 to 16
            sig = sig + 2**(-p)*int(comb[p-1])
        sigmoid.append(sig)     
        

file = open("LUT_values.txt", "r")
sigmoid_ref = []
for n in range(65536): 
    ln = file.readline()
    sig = 0
    for p in range(1,17): # from 1 to 16
        sig = sig + 2**(-p)*int(ln[p-1])
    sigmoid_ref.append(sig)

# Generate LUT data stored on FPGA

# x = np.linspace(-8,8,65536) # x mapped to 65536 values - the location in the array is the integer value

# # Generate 16-bit lookup table data
# sigmoid_ref = []
# for n in range(65536): # step through all combinations of inputs
#     xn = x[n]
#     s = 1/(1+np.exp(-xn)) # the answer is in the form 0.1234... 
#     # binary fractions up to 16 bits 
#     bits = ""
#     sig = 0
#     for p in range(16):
#         ans = s*2
#         s = ans%1 # fractional part 0.1234...        
#         bits = bits + str(int(ans)) 
#         sig = sig + 2**(-(p+1))*int(ans)
#     sigmoid_ref.append(sig)
    
# Convert strings to decimal values

error = np.subtract(sigmoid_ref,sigmoid)
#error = sigmoid_ref[50283] - np.array(sigmoid);
    
plt.plot(error)
    
    
    
    