# to automatically run this at boot, use the command: crontab -e
# then add this line at the bottom: @reboot /home/pi/gameboy/pizero/run.sh &

cd /home/pi/gameboy/pizero
../../pythonenv/bin/python joystick.py
sudo shutdown now