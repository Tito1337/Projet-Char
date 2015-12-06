import sys
import time
sys.path.append(r'/home/pi/quick2wire-python-api/')
from quick2wire.i2c import I2CMaster, writing, reading

address = 0x08

with I2CMaster() as bus:
	def i2c_send(str):
		bus.transaction(writing(address, [ord(c) for c in str]))

	def i2c_receive(size):
		return bus.transaction(reading(address, size))

	i2c_send("Q2 A? C?\n")
	print(i2c_receive(31))
