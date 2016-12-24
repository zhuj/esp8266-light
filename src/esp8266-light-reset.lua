return function(port, light)

      local timer = tmr.create()

      gpio.mode(port, gpio.INPUT)
      gpio.trig(port, 'down', function()

            print("Reset: start factory reset approvement...")

            local function stop()
               light:stop()
               timer:stop()
               timer:unregister()
            end

            -- stop the previous one and start it again
            stop()
            light:blink(10, 50)

            -- start waiting
            local cnt = 0

            -- wait for 10 seconds, if button is still pressed
            timer:register(500, tmr.ALARM_AUTO, function()
               if (gpio.read(port) == 1) then stop(); end

               cnt = cnt + 1
               print("Reset: factory reset", cnt)

               if (cnt > 20) then
                  -- stop all
                  stop()

                  -- reset config
                  Config:write("stationPointConfig/ssid", nil)
                  Config:write("stationPointConfig/pass", nil)
                  Config:write("light/hours", nil)

                  -- restart
                  node.restart()

               end
            end)

            -- start
            timer:start()

      end)
end
