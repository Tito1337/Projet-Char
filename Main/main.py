import sys
import time
import re
sys.path.append(r'/home/pi/quick2wire-python-api/')
from quick2wire.i2c import I2CMaster, writing, reading

address = 0x08
position_R = 0
position_L = 0
sensor_A = 0
sensor_B = 0
sensor_C = 0
sensor_D = 0

with I2CMaster() as bus:
    def processCommand(s):
        global sensor_A, sensor_B, sensor_C, sensor_D
        a = [chr(c) for c in s[0]]
        s = "".join(a[0:a.index('\n')+1])
        qq = re.search("[gQ]([\d]+)\D", s)
        if(qq):
            query = int(qq.group(1))

            if(query == 1):
                rr = re.search("[rR]([\d\.\-]+)\D", s)
                if (rr):
                    position_R = float(rr.group(1))

                ll = re.search("[lL]([\d\.\-]+)\D", s)
                if (ll):
                    position_L = float(ll.group(1))

            elif(query == 2):
                aa = re.search("[aA]([\d\.\-]+)\D", s)
                if (aa):
                    sensor_A = float(aa.group(1))

                bb = re.search("[bB]([\d\.\-]+)\D", s)
                if (bb):
                    sensor_B = float(bb.group(1))

                cc = re.search("[cC]([\d\.\-]+)\D", s)
                if (cc):
                    sensor_C = float(cc.group(1))

                dd = re.search("[dD]([\d\.\-]+)\D", s)
                if (dd):
                    sensor_D = float(dd.group(1))


    def i2c_send(str):
        bus.transaction(writing(address, [ord(c) for c in str]))

    def i2c_receive(size):
        return bus.transaction(reading(address, size))

    if __name__ == '__main__':
        picam_file = open('/tmp/picam-output', 'r')
        while True:
            picam_string = picam_file.read()
            picam_file.seek(0)
            print(picam_string)
            time.sleep(0.5)