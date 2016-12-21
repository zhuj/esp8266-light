require "common"

-- first, turn off GPIOs
try(function()
   local GPIOs = { GPIO0, GPIO2, GPIO4, GPIO5, GPIO12, GPIO13, GPIO14, GPIO15, GPIO16 }
   for idx, port in pairs(GPIOs) do
      if (port ~= nil) then
         gpio.mode(port, gpio.OUTPUT)
         gpio.write(port, gpio.LOW)
      end
   end
end)

-- first, check boot reason

-- rawcode:
-- 1, power-on
-- 2, reset (software?)
-- 3, hardware reset via reset pin
-- 4, WDT reset (watchdog timeout)
-- reason:
-- 0, power-on
-- 1, hardware watchdog reset
-- 2, exception reset
-- 3, software watchdog reset
-- 4, software restart
-- 5, wake from deep sleep
-- 6, external reset

local reasons = { r0=true, r4=true, r5=true, r6=true }
rawcode, reason = node.bootreason()
if (reasons['r'..reason] == true) then

   -- try to compile httpserver (if required)
   try(function()
      dofile("httpserver-compile.lua")
   end)

   -- try to start
   try(function()
      dofile('esp8266-light-main.lua')
   end)

end
