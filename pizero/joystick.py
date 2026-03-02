import pygame
import time

def read_joystick():
    # Initialize Pygame and the joystick module
    pygame.init()
    pygame.joystick.init()

    # Check for available joysticks
    if pygame.joystick.get_count() == 0:
        print("No joysticks found. Please connect one.")
        return

    # Get the first joystick
    joystick = pygame.joystick.Joystick(0)
    joystick.init()

    print(f"Initialized Joystick: {joystick.get_name()}")

    try:
        while True:
            # Process events
            for event in pygame.event.get():
                if event.type == pygame.JOYBUTTONDOWN:
                    print(f"Button {event.button} pressed")
                elif event.type == pygame.JOYBUTTONUP:
                    print(f"Button {event.button} released")
            
            # Small delay to prevent burning CPU cycles
            time.sleep(0.01)

    except KeyboardInterrupt:
        print("Exiting...")
    finally:
        pygame.joystick.quit()
        pygame.quit()

if __name__ == "__main__":
    read_joystick()

