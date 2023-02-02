import random

poker = [0 for i in range(52)]

for j in range(13):
    for k in range(4):
        poker[4*j+k] = k + 4*(j + 1)

random.shuffle(poker)

for i in range(52):
    print(poker[i])
