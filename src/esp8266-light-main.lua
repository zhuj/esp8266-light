require "common"

-- load light (global object)
light = doscript("esp8266-light-object")(GPIO2)
light:blink(50, 50)

-- main_timer
main_timer = doscript("esp8266-light-time")("pool.ntp.org", function()

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

   local selected = (hours:find('|'..hour..'|', 1, true) ~= nil)
   if (selected) then
      if (light.state ~= 'on') then
         light:up(100, 5)
      end
   else
      if (light.state ~= 'off') then
         light:down(50, 5)
      end
   end

   -- free all resources
   rtc = nil
   hour = nil
   hours = nil
   collectgarbage()
end)

-- reset callback
doscript("esp8266-light-reset")(GPIO0, light)

-- start wifi
doscript("esp8266-light-wifi-connect")(function(connect)

   -- stop the light
   light:stop()

   -- register mDNS
   mdns.register("light-" .. node.chipid(), {
      description = "Light @" .. node.chipid(),
      service = "http",
      port = 80
   })

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

