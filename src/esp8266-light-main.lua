require "common"

-- load light (global object)
light = dofile("esp8266-light-object.lua")(GPIO2)
light:blink(50, 50)

-- reset callback
dofile("esp8266-light-reset.lua")(GPIO0, light)

-- start wifi
dofile("esp8266-light-wifi-connect.lua")(function(connect)

      -- stop the light
      light:stop()

      -- register mDNS
      mdns.register(
         "light-"..node.chipid(),
         { description="Light @"..node.chipid(), service="http", port=80 }
      )

      -- start http server
      dofile("httpserver.lc")(80)

      -- sntp (if connected)
      if (connect) then
         local timer = dofile("esp8266-light-time.lua")("pool.ntp.org", function()

               -- get time
               local tm = rtctime.epoch2cal(rtctime.get())
               local hour = tm['hour']

               -- @TODO here is the place I have to check time and turn the light on or off
               print("Info: Hour: ", hour)

         end)
         timer:start()
      end

end)

