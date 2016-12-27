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

         -- @TODO here is the place I have to check time and turn the light on or off
         print("Info: Hour: ", hour)

         -- free all resources
         tm = nil
         hour = nil
         collectgarbage()
      end)
      timer:start()
   end

   -- indicate that we have no connection
   if (not connect) then
      light:blink(100, 20)
   end

end)

