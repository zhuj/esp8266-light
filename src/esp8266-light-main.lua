require "common"

-- load light (global object)
local GPIO2 = 4 -- PIN: light pwm
light = doscript("esp8266-light-object")(GPIO2)
GPIO2 = nil

-- reset callback
local GPIO0 = 3 -- PIN: firmware-update / factory-reset button
doscript("esp8266-light-reset")(GPIO0, light)
GPIO0 = nil

-- main_timer
main_timer = doscript("esp8266-light-time")(function()

   -- get time
   local rtc = rtctime.get()
   if (rtc <= 0) then
      return
   end

   local hour = rtctime.epoch2cal(rtc)['hour']
   if (hour == nil) then
      return
   end

   local tz = config_read("light/timezone", nil)
   if (tz ~= nil) then
      local dst = ('DST' == config_read("light/timezone-dst", nil)) and 2 or 1
      print("Info: Timezone: ", tz, "dst: ", dst)
      tz = doscript("time-zones")[tz]
      if (tz ~= nil) then
         hour = (hour + tz[dst]) % 24 -- Wow! Lua works with negative modulas! nice!
      end
      dst = nil
      tz = nil
   end

   print("Info: Hour: ", hour)

   local hours = config_read("light/hours", '')
   print("Info: Hours: ", hours)

   local selected = (hours:find('|' .. hour .. '|', 1, true) ~= nil)
   if (selected) then
      if (light.state ~= 'on') then
         light:up(100, 8)
      end
   else
      if (light.state ~= 'off') then
         light:down(50, 8)
      end
   end

   -- free all resources
   rtc = nil
   hour = nil
   hours = nil
   collectgarbage()
end)

-- start wifi
light:blink(20, 20) -- blink on initialization
doscript("esp8266-light-wifi-connect")(function(connect)

   -- stop the light
   light:stop()

   -- register mDNS
   local mdns_id = trim_to_nil((connect) and wifi.sta.getmac() or wifi.ap.getmac())
   if (mdns_id ~= nil) then mdns_id = mdns_id:gsub(":", {[":"]=""}):sub(7)
   else mdns_id = node.chipid() end

   local mdns_name = "light-" .. mdns_id

   print("Info: mDNS: " .. mdns_name .. ".local")
   mdns.register(mdns_name, {
      description = "Light @" .. mdns_id,
      service = "http",
      port = 80
   })
   mdns_name = nil
   mdns_id = nil

   -- start http server
   doscript("httpserver")(80)

   if (connect) then
      -- sntp (if connected)
      main_timer:start()
   else
      -- indicate that we have no connection
      light:blink(100, 20)
   end
end)

