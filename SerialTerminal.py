import numpy as np
import math
import cmath
import serial
import matplotlib.pyplot as plt

# Code snippet ChatGPT
serialPort = serial.Serial('COM4', 9600)  # access Com4 at baud rate 9600
serialPort.flush()  # flush the serial port
data = []
send = 83
byte_value = send.to_bytes(1, 'big')  # 1 byte and big means big endian
serialPort.write(byte_value)  # Send "S" to start sending data from FPGA

# n = 10
# while n < 10:
#     data.append(serialPort.read(1))
#     n = n + 1
# serialPort.close()
while serialPort.in_waiting == 0:
    x = 1
    #  stay here while nothing being received
# Receive data
n = 0
while len(data) < 10:
    while serialPort.in_waiting > 0:
        data.append(serialPort.read(1))  # Reads in 10 byte of data <- identifies start and stop bits
serialPort.close()
print(data)