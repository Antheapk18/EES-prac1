import numpy as np
import math
import cmath

# We want to have an x range between -8 and 8 therefore we want 16 and we are working with 16 bits which is 65536
xRange = []
i = 0
while i < 65536:
    dec = 16 / (2 ** 16)
    xRange.append(-8 + dec * i)
    i = i + 1

# Assign input to 16 bits " _ <- 1/0 ___ <- 0-8 ____________ <- Fractional part < 4096"
# Therefore we have 65536 inputs each assigned to an x-axis value of the sigmoid function
# We can locate the input by saying input = xRange[0] which gives -8.0

# To find sigmoid results at output in 16 bits "________________ <- whole this is fractional part"
sigmoidOut = []
removeFrac = []
i = 0
while i < len(xRange):
    sigmoidOut.append(1 / (1 + np.exp(-xRange[i])))
    removeFrac.append(round(sigmoidOut[i] * 100000))
    i = i + 1

# Convert to binary
binOut = []
removeFracNew = []
i = 0
while i < len(xRange):
    if removeFrac[i] <= 65535:  # 16 bits for fractional <- if fraction bigger than 2^16, need to reduce from 5 to 4 digits
        binOut.append(bin(removeFrac[i]))
    else:
        #removeFracNew.append(round())
        binOut.append(bin(round(removeFrac[i] / 10)))
    i = i + 1
print(binOut)
# Gives binary output for sigmoid function



