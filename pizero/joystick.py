import pygame
import spidev
import RPi.GPIO as GPIO
import time

###################################################################################################

# initialize GPIO
gpioPin = 17
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(gpioPin, GPIO.OUT)

# initialize SPI
spi = spidev.SpiDev()
spi.open(0, 0) # corresponds to /dev/spidev0.0
spi.max_speed_hz = 5000000 # 5MHz
spi.lsbfirst = False # we always want MSB first
spi.bits_per_word = 8
spi.mode = 0b00 # mode 0, clock polarity = 0 and clock phase = 0, clock idles low, data latched on rising edge

###################################################################################################

XBOX_360_DOWN = 14
XBOX_360_UP = 13
XBOX_360_LEFT = 11
XBOX_360_RIGHT = 12
XBOX_360_START = 7
XBOX_360_BACK = 6
XBOX_360_A = 0
XBOX_360_B = 1
XBOX_360_X = 2
XBOX_360_Y = 3
XBOX_360_LEFT_BUMPER = 4
XBOX_360_RIGHT_BUMPER = 5

GAME_BOY_BIT_DOWN = 7
GAME_BOY_BIT_UP = 6
GAME_BOY_BIT_LEFT = 5
GAME_BOY_BIT_RIGHT = 4
GAME_BOY_BIT_START = 3
GAME_BOY_BIT_SELECT = 2
GAME_BOY_BIT_B = 1
GAME_BOY_BIT_A = 0

###################################################################################################

def convertXbox360ButtontoGameBoyBit(button):
    if button == XBOX_360_DOWN:
        return GAME_BOY_BIT_DOWN
    elif button == XBOX_360_UP:
        return GAME_BOY_BIT_UP
    elif button == XBOX_360_LEFT:
        return GAME_BOY_BIT_LEFT
    elif button == XBOX_360_RIGHT:
        return GAME_BOY_BIT_RIGHT
    elif button == XBOX_360_START:
        return GAME_BOY_BIT_START
    elif button == XBOX_360_BACK:
        return GAME_BOY_BIT_SELECT
    elif button == XBOX_360_A or button == XBOX_360_Y:
        return GAME_BOY_BIT_A
    elif button == XBOX_360_B or button == XBOX_360_X:
        return GAME_BOY_BIT_B
    else:
        return -1

###################################################################################################

def clear_bit(currentButtons, bit_position):
    mask = (~(1 << bit_position)) & 0xFF
    currentButtons = currentButtons & mask
    return currentButtons

###################################################################################################

def set_bit(currentButtons, bit_position):
    mask = (1 << bit_position) & 0xFF
    currentButtons = currentButtons | mask
    return currentButtons

###################################################################################################

def read_joystick():
    # Get the first joystick
    joystick = pygame.joystick.Joystick(0)
    joystick.init()

    print(f"Initialized Joystick: {joystick.get_name()}")

    currentButtons = 0xff
    prevButtons = 0x00
    prevToggleTime = time.time()

    leftBumperPressed = False
    rightBumperPressed = False

    while True:
        # Process events.
        # .get() does not block, it will just return an 
        # empty list of events if no buttons were pressed
        for event in pygame.event.get():
            if event.type == pygame.JOYBUTTONDOWN:
                #print(f"Button {event.button} pressed")
                bit = convertXbox360ButtontoGameBoyBit(event.button)
                if bit >= 0:
                    currentButtons = clear_bit(currentButtons, bit)
                if event.button == XBOX_360_LEFT_BUMPER:
                    leftBumperPressed = True
                if event.button == XBOX_360_RIGHT_BUMPER:
                    rightBumperPressed = True
            elif event.type == pygame.JOYBUTTONUP:
                #print(f"Button {event.button} released")
                bit = convertXbox360ButtontoGameBoyBit(event.button)
                if bit >= 0:
                    currentButtons = set_bit(currentButtons, bit)
                if event.button == XBOX_360_LEFT_BUMPER:
                    leftBumperPressed = False
                if event.button == XBOX_360_RIGHT_BUMPER:
                    rightBumperPressed = False

        if leftBumperPressed and rightBumperPressed:
            print("both bumpers pressed")
            raise KeyboardInterrupt
        
        if (currentButtons != prevButtons):
            # send over SPI bus
            # TODO: remove print statement
            print(f"sending {bin(currentButtons)} over SPI")
            data_to_send = [currentButtons]
            spi.writebytes(data_to_send)
            prevButtons = currentButtons
        
        # Small delay to prevent burning CPU cycles
        time.sleep(0.01)

        # toggle status LED
        if (time.time() - prevToggleTime) > 1:
            GPIO.output(gpioPin, not GPIO.input(gpioPin))
            prevToggleTime = time.time()

###################################################################################################

try:
    # Initialize Pygame and the joystick module
    pygame.init()

    while True:
        pygame.joystick.init()
        # Check for available joysticks
        if pygame.joystick.get_count() == 0:
            print("No joysticks found. Please connect one.")
            pygame.joystick.quit()
            time.sleep(2)
        else:
            break

    read_joystick()

except KeyboardInterrupt:
    print("Exiting...")
finally:
    # Reboot and shutdown hang for a long time if the following are not cleaned up properly.
    # On reboot maybe the BCM chip is still initialized so shutdown seems best option.
    GPIO.cleanup()
    spi.close()
    pygame.joystick.quit()
    pygame.quit()
