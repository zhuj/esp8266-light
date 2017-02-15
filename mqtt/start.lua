-- XXX:don't use common.lua here

-- first, turn off GPIOs
pcall(function()
   -- gpio
   -- https://nodemcu.readthedocs.io/en/dev/en/modules/gpio/
   -- http://www.esp8266.com/wiki/lib/exe/fetch.php?media=schematic_esp-12e.png
   -- http://learn.acrobotic.com/uploads/esp8266_devkit_pinout.png
   local GPIOs = {
      GPIO0 = 3, -- PIN: firmware-update / factory-reset button
      GPIO1 = nil, -- PIN: U0TXD (don't use me)
      GPIO2 = 4, -- PIN: light pwm
      GPIO3 = nil, -- PIN: U0RXD (don't use me)
      GPIO4 = 2, -- ESP-01: unwired
      GPIO5 = 1, -- ESP-01: unwired
      GPIO6 = nil, -- XXX: flash (CLK)
      GPIO7 = nil, -- XXX: flash (MISO)
      GPIO8 = nil, -- XXX: flash (MOSI)
      GPIO9 = nil, -- XXX: flash (-WP)
      GPIO10 = nil, -- XXX: flash (-HOLD)
      GPIO11 = nil, -- XXX: flash (CS)
      GPIO12 = 6, -- ESP-01: unwired
      GPIO13 = 7, -- ESP-01: unwired
      GPIO14 = 5, -- ESP-01: unwired
      GPIO15 = 8, -- ESP-01: unwired
      GPIO16 = 0 -- ESP-01: unwired, D0(GPIO16) can only be used as gpio read/write
   }
   for _, port in pairs(GPIOs) do
      if (port ~= nil) then
         gpio.mode(port, gpio.OUTPUT)
         gpio.write(port, gpio.LOW)
      end
   end
end)

-- first, check boot reason
local _, reason = node.bootreason()
local ok = ({
   [0] = true, -- 0, power-on
   [1] = false, -- 1, hardware watchdog reset
   [2] = false, -- 2, exception reset
   [3] = false, -- 3, software watchdog reset
   [4] = true, -- 4, software restart
   [5] = true, -- 5, wake from deep sleep
   [6] = true -- 6, external reset
})[reason]

if (ok ~= true) then
   return
end

-- slow down freq
node.setcpufreq(node.CPU80MHZ)

-- try to compile all the code (if required)
local ok, err = pcall(dofile, "compile.lua")
if (not ok) then print("Error: ", err); end

-- try to start
local ok, err = pcall(dofile, 'esp8266-light-main.lc')
if (not ok) then print("Error: ", err); end

print('heap: ', node.heap())