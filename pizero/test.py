# https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#spi-overview
# enable SPI by:
#     uncommenting the dtparam=spi=on in /boot/firmware/config.txt
#     then reboot

# for testing the loopback, connect physical pins 19 and 21 on the 40-pin header
#     see https://pinout.xyz/pinout/spi

# spi python module is installed by default on RaspPi OS
import spidev
import RPi.GPIO as GPIO
from time import sleep

gpioPin = 17
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(gpioPin, GPIO.OUT)

spi = spidev.SpiDev()
spi.open(0, 0) # corresponds to /dev/spidev0.0
spi.max_speed_hz = 5000000 # 5MHz
spi.lsbfirst = False # we always want MSB first
spi.bits_per_word = 8
spi.mode = 0b00 # mode 0, clock polarity = 0 and clock phase = 0, clock idles low, data latched on rising edge

data = 0x01

try:
    while True:
        GPIO.output(gpioPin, GPIO.HIGH)
        sleep(1)
        GPIO.output(gpioPin, GPIO.LOW)
        sleep(1)

        #data_to_send = [0xFF, 0x0F, 0xF0]
        #print("Will send: ", [hex(b) for b in data_to_send])
        #response = spi.xfer(data_to_send)
        # data_to_send gets modified in place, so we would need to keep a copy of it if we print it here
        #print("Sent: ", [hex(b) for b in data_to_send])
        #print("Received: ", [hex(b) for b in response])

        # it expects a list of values
        data_to_send = [data]
        print("Will send: ", hex(data_to_send[0]))
        spi.writebytes(data_to_send)
        data = (data * 2) % 256
        if (data == 0):
            data = 1

except KeyboardInterrupt:
    GPIO.cleanup()
    spi.close()
