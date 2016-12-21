require "common"

return function(port)

      -- set port as output
      gpio.mode(port, gpio.OUTPUT)

      -- setup new instance
      local light = {}
      light.port = port
      light.timer = tmr:create()

      local function _stop_timer(timer)
         if (timer) then
            timer:stop()
            timer:unregister()
         end
      end

      function light:pwm(clk)
         clk = constrain(clk, 0, 1023)
         if (clk > 0) then
            pwm.setup(self.port, 500, clk)
            pwm.start(self.port)
         else
            pwm.stop(self.port)
            pwm.close(self.port)
         end
      end

      function light:stop()
         _stop_timer(self.timer)
         self:pwm(0)
         gpio.write(self.port, gpio.LOW)
      end

      function light:start()
         _stop_timer(self.timer)
         self:pwm(0)
         gpio.write(self.port, gpio.HIHG)
      end


      local function _change(light, interval, a, b, step, callback)
         _stop_timer(light.timer)

         step = math.max(1, math.abs(step))
         a = constrain(a, 0, 1023)
         b = constrain(b, 0, 1024)

         if (a < b) then
            step = step
         elseif (a > b) then
            step = -step
         else
            return
         end

         local i = 0
         local j = math.abs((b - a) / step)

         -- DEBUG: print("_change:start:", a, b, step, i, j)
         light.timer:alarm(interval, tmr.ALARM_AUTO, function()
            if (i < j) then
               -- DEBUG: print("_change:click:", a, b, step, i, j, (a + i*step))
               light:pwm(a + i*step)
               i = i + 1
            else
               -- DEBUG: print("_change:finish:", callback)
               _stop_timer(light.timer)
               if (callback ~= nil) then
                  callback()
               end
            end
         end)
      end


      function light:up(interval)
         self:stop()
         _change(self, interval, 0, 1023, 20, nil)
         self:start()
      end

      function light:down(interval)
         self:start()
         _change(self, interval, 1023, 0, 20, nil)
         self:stop()
      end


      function light:blink(interval)
         self:stop()

         local holder = { light = self }

         holder.up = function()
            -- DEBUG: print("blink:up")
            _change(holder.light, interval, 0, 1023, 20, holder.down)
         end
         holder.down = function()
            -- DEBUG: print("blink:down")
            _change(holder.light, interval, 1023, 0, 20, holder.up)
         end

         holder.up()
      end

      -- clear the light
      light:stop()

      -- return the object
      return light
end
