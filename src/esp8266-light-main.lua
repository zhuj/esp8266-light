require "common"

-- load light (global object)
light = doscript("esp8266-light-object")(GPIO2)
light:blink(50, 50)

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

   -- sntp (if connected)
   if (connect) then
      local timer = doscript("esp8266-light-time")("pool.ntp.org", function()

         -- get time
         local tm = rtctime.epoch2cal(rtctime.get())
         local hour = tm['hour']
         if (hour == nil) then
            return
         end

         local tz = config_read("light/timezone", nil)
         if (tz ~= nil) then
            print("Info: Timezone: ", tz)
            tz = doscript("time-zones")[tz]
            if (tz ~= nil) then
               hour = (hour + tz[3]) % 24 -- Wow! Lua works with negative modulas! nice!
            end
            tz = nil
         end

         print("Info: Hour: ", hour)

         local hours = config_read("light/hours", '')
         print("Info: Hours: ", hours)

         local selected = (hours:find('|'..hour..'|', 1, true) ~= nil)
         if (selected) then
            if (light.state ~= 'on') then
               light:up(150, 5)
            end
         else
            if (light.state ~= 'off') then
               light:down(150, 5)
            end
         end

         -- free all resources
         tm = nil
         hour = nil
         hours = nil
         collectgarbage()
      end)
      timer:start()
   end

   -- indicate that we have no connection
   if (not connect) then
      light:blink(100, 20)
   end

end)

