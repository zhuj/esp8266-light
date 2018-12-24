# To flash a 512KB esp8266 (e.g. esp-01) using the serial port use:

# 0x7c000  for 512 kB, modules like ESP-01, -03, -07 etc.
# 0xfc000  for 1 MB, modules like ESP8285, PSF-A85
# 0x1fc000 for 2 MB
# 0x3fc000 for 4 MB, modules like ESP-12E, NodeMCU devkit 1.0, WeMos D1 mini

# download esptool (if required)
[ -f esptool.py ] || wget -c https://github.com/espressif/esptool/raw/master/esptool.py
chmod +x esptool.py

./esptool.py --port /dev/ttyUSB0 erase_flash
#exit 0

#echo "reset it into a flash-mode manually"
#sleep 10 # reset with flash
#./esptool.py --port /dev/ttyUSB0 erase_flash
#sleep 2
#echo 

echo "reset it into a flash-mode manually"
sleep 10 # reset with flash
./esptool.py --port /dev/ttyUSB0 --baud 460800 write_flash \
 --flash_freq 40m --flash_mode dio --flash_size 32m \
 0x3fc000 esp_init_data_default_v08.bin \
 0x000000 nodemcu-master-18-modules-2018-12-17-13-33-24-integer.bin

sleep 10 # wait for complete




