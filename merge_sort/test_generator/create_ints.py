import random

with open("8000_ints.txt", "a") as f:

    for i in range(8000):
        f.write(str(random.randint(10000, 50000)))
        f.write('\n')

