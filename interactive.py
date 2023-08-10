import serial
import numpy as np
import matplotlib.pyplot as plt

inputs = "P"
while inputs != "N":

    inputs = input("Enter \"S\" to transmit entire LUT from FPGA, \"D\" to look up only a specific sigmoid value from the LUT or \"N\" to exit.\n")

    if inputs == "S":

        serialPort = serial.Serial("COM7", 57600)
        #serialPort.set_buffer_size(rx_size = 200000, tx_size = 200000);
        serialPort.flush()

        n = 0
        data = []

        byte_value = bytearray([83,83,83])

        serialPort.write(byte_value) # Send "Sxx" to start sending data from FPGA


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
                #sigmoid.append(int(comb))
                

        file = open("C:/Users/natal/OneDrive/Documents/2023/EES424/Prac 1/LUT_values.txt", "r")
        sigmoid_ref = []
        for n in range(65536): 
            ln = file.readline()
            sig = 0
            for p in range(1,17): # from 1 to 16
                sig = sig + 2**(-p)*int(ln[p-1])
            sigmoid_ref.append(sig)
            #sigmoid_ref.append(int(ln[0:16]))

        error = np.subtract(sigmoid_ref,sigmoid)

        print("Maximum error: " + str(max(error)))
        print("Minimum error: " + str(min(error)))

        plt.figure(1)
        plt.plot(error)
        #plt.show()

        x = np.linspace(-8,8,65536)

        plt.figure(2)
        plt.plot(x,sigmoid)
        plt.plot(x,sigmoid_ref)
        plt.show()


    elif (inputs == "D"): # read only one data value from the LUT
        #value = "P"
        #while value != "N":
        value = input("Enter an x-value or enter \"N\" to exit.\n")
        xvalue = float(value)
        #print(xvalue)

        # Determine index in LUT with closest x value
        x = np.linspace(-8,8,65536)
        diff = abs(x-xvalue)
        idx = np.where(diff == min(diff))
        idx = idx[0]
        #print(idx)
        high_byte = np.floor(idx/256)
        high_byte = int(high_byte[0])
        #print(high_byte)
        low_byte = idx % 256
        low_byte = low_byte[0]
        #print(low_byte)

        serialPort = serial.Serial("COM7", 57600)
        #serialPort.set_buffer_size(rx_size = 200000, tx_size = 200000);
        serialPort.flush()

        n = 0
        data = []

        byte_value = bytearray([68,low_byte,high_byte])

        serialPort.write(byte_value) # Send "Dxx" to start sending data from FPGA


        while (serialPort.in_waiting == 0):
            hey = 1

        while len(data) < 2: 
            while (serialPort.in_waiting > 0):
                data.append(serialPort.read(1))
                n = n + 1  
                
        serialPort.close()

        hex_data = []
        for n in range(len(data)):
            hex_data.append(hex(int.from_bytes(data[n], 'big')))
        #print(hex_data)

        # Convert received byte to decimal sigmoid value
        sigmoid = []
        for n in range(len(data)):
            if n%2 == 0: # even numbers 
                byte_1 = int.from_bytes(data[n], 'big')
                byte_1 = format(byte_1, '08b')
                byte_2 = int.from_bytes(data[n+1], 'big')
                byte_2 = format(byte_2, '08b')
                comb = byte_2+byte_1
                print(comb)
                sig = 0
                for p in range(1,17): # from 1 to 16
                    sig = sig + 2**(-p)*int(comb[p-1])
                sigmoid.append(sig)  
                #sigmoid.append(int(comb))

        print(sigmoid)



    
