--
function constrain(x, a, b)
   a, b = math.min(a, b), math.max(a, b)
   if (x < a) then return a; end
   if (x > b) then return b; end
   return x
end

--
function _stop_timer(timer)
   if (timer) then
      timer:stop()
      timer:unregister()
   end
end

--
function _pwm(port, clk)
   clk = constrain(clk, 0, 1023)
   if (clk > 0) then
      if ((pwm.getclock(port) > 0) and (pwm.getduty(port) > 0)) then
         pwm.setduty(port, clk)
      else
         pwm.setup(port, 250, clk)
         pwm.start(port)
      end
   else
      pwm.stop(port)
      pwm.close(port)
   end
end

return function(port)

   -- set port as output
   gpio.mode(port, gpio.OUTPUT)

   -- setup new instance
   local light = {}
   light.state = ''
   light.port = port
   light.timer = tmr:create()

   function light:pwm(clk)
      _stop_timer(self.timer)
      _pwm(self.port, clk)
      self.state = 'pwm'
   end

   function light:stop()
      self:pwm(0)
      gpio.write(self.port, gpio.LOW)
      self.state = 'off'
   end

   function light:start()
      self:pwm(0)
      gpio.write(self.port, gpio.HIGH)
      self.state = 'on'
   end

   function light:_change(interval, a, b, step, callback)
      _stop_timer(self.timer)

      step = ((step == nil) and 1 or constrain(math.abs(step), 1, 1023))
      a = constrain(a, 0, 1023)
      b = constrain(b, 0, 1023)

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
      self.timer:alarm(interval, tmr.ALARM_AUTO, function()
         if (i < j) then
            -- DEBUG: print("_change:click:", a, b, step, i, j, (a + i*step))
            _pwm(self.port, (a + i * step))
            i = i + 1
         else
            -- DEBUG: print("_change:finish:", callback)
            _stop_timer(self.timer)
            if (callback ~= nil) then
               callback(self, interval, step)
               callback = nil
            end
         end
      end)

      self.state = 'pwm'
   end


   function light:up(interval, step)
      self:stop()
      self:_change(interval, 0, 1023, step, self.start)
   end

   function light:down(interval, step)
      self:start()
      self:_change(interval, 1023, 0, step, self.stop)
   end

   function light:blink(interval, step)
      self:_change(interval, 0, 1023, step, self.blink_down)
   end

   function light:blink_down(interval, step)
      self:_change(interval, 1023, 0, step, self.blink)
   end

   -- clear the light
   light:stop()

   -- return the object
   return light
end
