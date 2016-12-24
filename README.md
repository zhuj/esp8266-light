# esp8266-light
ESP8266 (ESP-01) controlled light

### Current status picture

There will be the picture of the project status (will be updated each time I have something new to show):

![this](https://github.com/zhuj/esp8266-light/raw/master/docs/esp8266-light-prototype-02.jpg "Prototype #2")



### Code usages

#### NodeMCU

NodeMCU is an [eLua](http://www.eluaproject.net/) based firmware for the [ESP8266 WiFi SOC from Espressif](http://espressif.com/en/products/esp8266/).

* Home: https://nodemcu.readthedocs.io/en/dev/
* Code: https://github.com/nodemcu/nodemcu-firmware/
* License: MIT

#### nodemcu-httpserver

A (very) simple web server written in Lua for the ESP8266 running the NodeMCU firmware.

* Author: [Marcos Kirsch](https://github.com/marcoskirsch)
* Original code: https://github.com/marcoskirsch/nodemcu-httpserver
* License: GPLv2

#### nodemcu-uploader.py

A simple tool for uploading files to the filesystem of an ESP8266 running NodeMCU as well as some other useful commands.

* Author: [Peter Magnusson](https://github.com/kmpm)
* Original code: https://github.com/kmpm/nodemcu-uploader
* Forked code: https://github.com/marcoskirsch/nodemcu-uploader
* License: MIT

#### esptool.py

A Python-based, open source, platform independent, utility to communicate with the ROM bootloader in Espressif ESP8266.

* Author: Angus Gratton
* Original code: https://github.com/espressif/esptool
* License: GPLv2
