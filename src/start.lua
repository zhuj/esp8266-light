-- first, turn off GPIOs
pcall(function()
   local GPIOs = { GPIO0, GPIO2, GPIO4, GPIO5, GPIO12, GPIO13, GPIO14, GPIO15, GPIO16 }
   for idx, port in pairs(GPIOs) do
      if (port ~= nil) then
         gpio.mode(port, gpio.OUTPUT)
         gpio.write(port, gpio.LOW)
      end
   end
end)

-- first, check boot reason
local _, reason = node.bootreason()
local ok = ({
   [0] = true,  -- 0, power-on
   [1] = false, -- 1, hardware watchdog reset
   [2] = false, -- 2, exception reset
   [3] = false, -- 3, software watchdog reset
   [4] = true,  -- 4, software restart
   [5] = true,  -- 5, wake from deep sleep
   [6] = true   -- 6, external reset
})[reason]

if (ok ~= true) then
   return
end

-- try to compile httpserver (if required)
local ok, err = pcall(function()
   dofile("esp8266-light-compile.lua")
end)
if (not ok) then print("Error: ", err); end

-- try to start
local ok, err = pcall(function()
   require "common"
   doscript('esp8266-light-main')
end)
if (not ok) then print("Error: ", err); end