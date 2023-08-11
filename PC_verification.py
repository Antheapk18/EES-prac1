import numpy as np
import serial
import matplotlib.pyplot as plt
import struct

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

# Convert decimal values to their corresponding fractional binary representations
binaryArr = []
for decimal_value in y_16bit_decimal:
    fractional_part = decimal_value
    
    # Convert fractional part to 15-bit binary representation
    frac_part_binary = format(int(fractional_part * (2 ** 15)), '015b')
    
    binary_value = '0' + frac_part_binary  # Add leading '0' for the integer bit
    binaryArr.append(binary_value)

i=0
# Save binaryArr into a file named "LUT_values.txt"
with open("data.txt", "w") as file:
    for binary_value in binaryArr:
        file.write(str(i) + ' => "' + str(binary_value) + '",' + "\n")
        i += 1

# # Read binary values from "LUT_values.txt" and convert them back to decimal
# decimal_values = []
# with open("LUT_values.txt", "r") as file:
#     for line in file:
#         binary_value = line.strip()
#         # Convert binary value back to fractional decimal (between 0 and 1)
#         frac_part = int(binary_value[1:], 2) / (2 ** 15)
#         decimal_value = frac_part
#         decimal_values.append(decimal_value)

# # Plot the decimal values
# plt.plot(x, decimal_values)
# plt.xlabel('x')
# plt.ylabel('Decimal Values')
# plt.title('Decimal Values from Binary Representations of Sigmoid')
# plt.show()

