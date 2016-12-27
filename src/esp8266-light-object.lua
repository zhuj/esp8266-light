require "common"

return function(port)

   -- set port as output
   gpio.mode(port, gpio.OUTPUT)

   -- setup new instance
   local light = {}
   light.port = port
   light.timer = tmr:create()

   local function _step(step)
      if (step == nil) then return 1; end
      return constrain(math.abs(step), 1, 1023)
   end

   local function _stop_timer(timer)
      if (timer) then
         timer:stop()
         timer:unregister()
      end
   end

   local function _pwm(port, clk)
      clk = constrain(clk, 0, 1023)
      if (clk > 0) then
         if ((pwm.getclock(port) > 0) and (pwm.getduty(port) > 0)) then
            pwm.setduty(port, clk)
         else
            pwm.setup(port, 500, clk)
            pwm.start(port)
         end
      else
         pwm.stop(port)
         pwm.close(port)
      end
   end

   function light:pwm(clk)
      _stop_timer(self.timer)
      _pwm(self.port, clk)
   end

   function light:stop()
      self:pwm(0)
      gpio.write(self.port, gpio.LOW)
   end

   function light:start()
      self:pwm(0)
      gpio.write(self.port, gpio.HIGH)
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
            _pwm(light.port, (a + i * step))
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


   function light:up(interval, step)
      step = _step(step)

      self:stop()
      _change(self, interval, 0, 1023, step, function()
         self:start()
      end)
   end

   function light:down(interval, step)
      step = _step(step)

      self:start()
      _change(self, interval, 1023, 0, step, function()
         self:stop()
      end)
   end


   function light:blink(interval, step)
      self:stop()
      step = _step(step)

      local holder = { light = self }
      holder.up = function()
         -- DEBUG: print("blink:up")
         _change(holder.light, interval, 0, 1023, step, holder.down)
      end
      holder.down = function()
         -- DEBUG: print("blink:down")
         _change(holder.light, interval, 1023, 0, step, holder.up)
      end

      holder.up()
   end

   -- clear the light
   light:stop()

   -- return the object
   return light
end
