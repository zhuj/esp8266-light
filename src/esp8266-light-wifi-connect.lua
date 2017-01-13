require "common"

local wifiConfig = {}

-- wifi.STATION         -- station: join a WiFi network
-- wifi.SOFTAP          -- access point: create a WiFi network
-- wifi.wifi.STATIONAP  -- both station and access point
wifiConfig.mode = wifi.SOFTAP -- both station and access point

local ssid = (function()
   local id = trim_to_nil(wifi.ap.getmac())
   if (id ~= nil) then id = id:gsub(":", {[":"]=""}):sub(7)
   else id = node.chipid() end
   return "ESP-" .. id
end)()

wifiConfig.accessPointConfig = {}
wifiConfig.accessPointConfig.ssid = ssid -- Name of the SSID you want to create
wifiConfig.accessPointConfig.pwd = ssid -- WiFi password - at least 8 characters
print('AP: [' .. wifiConfig.accessPointConfig.ssid .. ']')
ssid = nil

wifiConfig.accessPointIpConfig = {}
wifiConfig.accessPointIpConfig.ip = "192.168.0.1"
wifiConfig.accessPointIpConfig.netmask = "255.255.255.0"
wifiConfig.accessPointIpConfig.gateway = "192.168.0.1"

wifiConfig.stationPointConfig = {}
wifiConfig.stationPointConfig.ssid = config_read("stationPointConfig/ssid", nil)
wifiConfig.stationPointConfig.pwd = config_read("stationPointConfig/pass", nil)

if (wifiConfig.stationPointConfig.ssid and wifiConfig.stationPointConfig.pwd) then
   wifiConfig.mode = wifi.STATIONAP -- both station and access point
   print('ssid: [' .. wifiConfig.stationPointConfig.ssid .. ']')
   print('pass: [' .. wifiConfig.stationPointConfig.pwd .. ']')
end

-- Tell the chip to connect to the access point

wifi.setmode(wifiConfig.mode)
print('set (mode=' .. wifi.getmode() .. ')')

if (wifiConfig.mode == wifi.SOFTAP) or (wifiConfig.mode == wifi.STATIONAP) then
   print('AP MAC: ', wifi.ap.getmac())
   try(function()
      wifi.ap.config(wifiConfig.accessPointConfig)
      wifi.ap.setip(wifiConfig.accessPointIpConfig)
   end)
end
if (wifiConfig.mode == wifi.STATION) or (wifiConfig.mode == wifi.STATIONAP) then
   print('Client MAC: ', wifi.sta.getmac())
   try(function()
      wifi.sta.config(wifiConfig.stationPointConfig.ssid, wifiConfig.stationPointConfig.pwd, 1)
   end)
end

print('chip: ', node.chipid())
print('heap: ', node.heap())

wifiConfig = nil
collectgarbage()

return function(callback)

   -- Connect to the WiFi access point.
   -- Once the device is connected, you may start the HTTP server.

   if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then

      local joinCounter = 0
      local joinMaxAttempts = 5

      local timer = tmr.create()
      timer:alarm(5000, tmr.ALARM_AUTO, function()
         local ip = wifi.sta.getip()
         if (ip == nil) and (joinCounter < joinMaxAttempts) then

            -- not connected
            print('Connecting to WiFi Access Point ...')
            joinCounter = joinCounter + 1
            return
         end

         -- stop the timer
         timer:stop()
         timer:unregister()
         timer = nil

         -- set wifi mode
         if (joinCounter >= joinMaxAttempts) then
            print('Failed to connect to WiFi Access Point.')
            wifi.setmode(wifi.SOFTAP) -- force transform it to softap
         else
            print('Connectied to WiFi Access Point, IP: ' .. ip)
            wifi.setmode(wifi.STATION) -- force transform it to station
         end

         -- clean up
         joinCounter = nil
         joinMaxAttempts = nil
         collectgarbage()

         -- call given callback
         callback(wifi.sta.getip() ~= nil)
      end)

   else

      -- call given callback
      callback(false)
   end
end
