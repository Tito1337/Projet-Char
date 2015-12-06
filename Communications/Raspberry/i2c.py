import sys
import time
sys.path.append(r'/home/pi/quick2wire-python-api/')
from quick2wire.i2c import I2CMaster, writing, reading

address = 0x08

def i2c_send(str):
	with I2CMaster() as bus:
		bus.transaction(writing(address, [ord(c) for c in str]))

def i2c_receive(size):
	with I2CMaster() as bus:
		return bus.transaction(reading(address, size))

i2c_send("hello")
print(i2c_receive(10))
