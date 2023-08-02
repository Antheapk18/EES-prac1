import numpy as np
import serial
import matplotlib.pyplot as plt
import struct

# serialPort = serial.Serial("COM7", 115200)
# #serialPort.set_buffer_size(rx_size = 200000, tx_size = 200000);
# serialPort.flush()

# n = 0
# data = []

# send = 83
# byte_value = send.to_bytes(1, 'big');


# serialPort.write(byte_value) # Send "S" to start sending data from FPGA

# while (serialPort.in_waiting == 0):
#     hey = 1

# while len(data) < (2*65536):
#     while (serialPort.in_waiting > 0):
#         data.append(serialPort.read(1))
#         n = n + 1    


# serialPort.close()

# # Generate 16-bit lookup table data
# for n in range(2**(15)):
#     hey = 0
    # add fixed point after 12 bits
    #fixed = 
    
    # Work out sigmoid
    
    # Convert to fixed point

#============================IVANA=================

#math for sigmoid function to get y values from -8 to 8
x = np.linspace(-8,8,65536)

# Assuming you have some function 'f' that generates 'y' values based on 'x':
def f(x):
    # Example function: y = x^2
    return 1/(1+np.exp(-x))

# Calculate 'y' values using the function 'f'
y_64bit = f(x)

# Convert the 64-bit 'y' value to a 16-bit decimal representation
y_16bit_decimal = np.array([y_64bit], dtype=np.float16)[0]

# print(y_16bit_decimal)
binaryArr = []
i = 0 
while i <= len(y_16bit_decimal)-1:
    binaryArr.append(np.binary_repr(np.float16(y_16bit_decimal[i]).view(np.uint16), width=16))
    i = i+1
print(binaryArr)
#======CONVERT DECIMAL TO BINARY==========================

#===========might use for input===========
# # Assuming you have a 64-bit 'y' value (replace this with your actual value)
# y_64bit = y[5]

# # Step 1: Separate integer and fractional parts
# abs_y = abs(y_64bit)
# integer_part = int(abs_y)
# fractional_part = int((abs_y - integer_part) * (2**13))

# # Step 2: Convert the integer part to a 3-bit representation
# integer_3bit = np.clip(integer_part, 0, 2**3 - 1)

# # Step 3: Convert the fractional part to a 12-bit representation
# fractional_13bit = np.clip(fractional_part, 0, 2**13 - 1)

# # Combine the 16-bit parts (integer_3bit, fractional_12bit) into a 16-bit value
# y_16bit = (integer_3bit << 12) | fractional_13bit

# print(y_16bit)








    