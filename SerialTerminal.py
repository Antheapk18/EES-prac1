import numpy as np
import math
import cmath
import serial
import matplotlib.pyplot as plt

serialPort = serial.Serial('COM3', 9600)  # access Com3 at baud rate 9600
serialPort.flush()  # flush the serial port
data = []

send = 83
byte_value = send.to_bytes(1, 'big')  # 1 byte and big means big endian
serialPort.write(byte_value)  # Send "S" to start sending data from FPGA

while serialPort.in_waiting == 0:
    x = 1
    #  stay here while nothing being received
# Receive data
n = 0
i = 0
while i < (2*65535):  
    if serialPort.in_waiting > 0:
        byte = serialPort.read(1)  # Read one byte
        data.append(byte)          # Append the byte to the data array
        i += 1                      # Increment the counter
        n += 1                      # Increment the index for processing

serialPort.close()
print(len(data))

# Combine two bytes into one and convert to fractional decimal
decimal_data = []  # Initialize an array to store the decimal values

processing_index = 0  # Initialize an index for processing
for n in range(0, len(data), 2):
    byte1 = data[processing_index][0]  # Access the first byte
    byte2 = data[processing_index + 1][0]  # Access the second byte
    byteTotal = byte1 << 8 | byte2  # Combine the bytes using bitwise shift
    decimal_value = byteTotal / (2 ** 15)  # Convert to fractional decimal
    decimal_data.append(decimal_value)
    
    processing_index += 2  # Increment the processing index by 2 for every pair of bytes


print(decimal_data)

# Plot the decimal values
x = np.linspace(-8, 8, len(decimal_data))  # Adjust the range if needed
plt.plot(x, decimal_data)
plt.xlabel('x')
plt.ylabel('Decimal Values')
plt.title('Decimal Values from Serially Received Data')
plt.show()

# # Specify the file path
# file_path = 'data.txt'

# # Save the binary array to the text file
# with open(file_path, 'w') as file:
#     for byteTotal in binary_data:
#         file.write(byteTotal + '\n')

# print(f"Binary data saved to '{file_path}'.")
