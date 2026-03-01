import serial
import time

ser = serial.Serial("/dev/ttyACM0", 115200, timeout=2)

startTime = time.time()
ser.write(b"g") # send the grab/go command

rom = b""
while True:
    newData = ser.read(256)

    # when there's no more data we will read 0 bytes
    if (len(newData) == 0):
        break
    rom = rom + newData

stopTime = time.time()
duration = int(stopTime - startTime)

# Write the rom to a file
filename = "game.gb"
with open(filename, "wb") as file:
    file.write(rom)

print(f"{len(rom)} bytes of ROM data written to file {filename}")
print(f"capture took {duration} seconds")
