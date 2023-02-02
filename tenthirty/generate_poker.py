import random

poker = [i for i in range(52)]
i = 0

for num in poker:
    poker[i] = num//4 + 1
    i = i + 1
random.shuffle(poker)

for i in range(52):
    print(poker[i])
 