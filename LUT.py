# -*- coding: utf-8 -*-
"""
Created on Wed Aug  2 13:32:14 2023

@author: natal
"""
import serial
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(-8,8,65536) # x mapped to 65536 values - the location in the array is the integer value

# Generate 16-bit lookup table data
sigmoid = []
for n in range(65536): # step through all combinations of inputs
    xn = x[n]
    s = 1/(1+np.exp(-xn)) # the answer is in the form 0.1234... 
    # binary fractions up to 16 bits 
    bits = ""
    for p in range(16):
        ans = s*2
        s = ans%1 # fractional part 0.1234...
        #bits.append(int(ans))
        bits = bits + str(int(ans))        
    sigmoid.append(bits)
   
    # Convert to 16 binary digits
    # if round(s*100000) > 65535:
    #     s = round(s*10000)
    # else:
    #     s = round(s*100000)
    # sigmoid.append(s)
    
# Now save this in a way I can copy and paste it into VHDL
text_file = open("sigmoid_LUT.txt", "w")
my_file = open("LUT_values.txt", "w")

# split equal outputs into arrays
inputs = "|0"
p = 0
for n in range(65536):
    text_file.write(str(n) + " => \"" + sigmoid[n] + "\",\n" )
    my_file.write(sigmoid[n] + "\n")
    
    



# inputs = "|0"
# p = 0
# for n in range(1,65535):
#     if sigmoid[n] == sigmoid[n-1]:
#         inputs = inputs + "|" +str(n)
#         p = p+1
#     else:
#         if p == 0: # unique output
#             text_file.write("when " + str(n) + " => sigmoid <= \"" + sigmoid[n-1] + "\";\n" )
#             inputs = ""
#         else: # end of a sequence of equal outputs
#             text_file.write("when " + inputs[1:len(inputs)] + " => sigmoid <= \"" + sigmoid[n-1] + "\";\n" )
#             inputs = "|"+str(n) # start a new sequence of inputs
#             p = 0
            
        
    
text_file.close()