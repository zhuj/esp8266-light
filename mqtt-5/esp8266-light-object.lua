--
function constrain(x, a, b)
   a, b = math.min(a, b), math.max(a, b)
   if (x < a) then return a; end
   if (x > b) then return b; end
   return x
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

   function light:pwm(clk)
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

   -- clear the light
   light:stop()

   -- return the object
   return light
end
