-- gpio
-- https://nodemcu.readthedocs.io/en/dev/en/modules/gpio/
-- http://www.esp8266.com/wiki/lib/exe/fetch.php?media=schematic_esp-12e.png
-- http://learn.acrobotic.com/uploads/esp8266_devkit_pinout.png

GPIO0   = 3   -- PIN: firmware-update / factory-reset button
GPIO1   = nil -- PIN: U0TXD (don't use me)
GPIO2   = 4   -- PIN: light pwm
GPIO3   = nil -- PIN: U0RXD (don't use me)
GPIO4   = 2   -- ESP-01: unwired
GPIO5   = 1   -- ESP-01: unwired
GPIO6   = nil -- XXX: flash (CLK)
GPIO7   = nil -- XXX: flash (MISO)
GPIO8   = nil -- XXX: flash (MOSI)
GPIO9   = 11  -- XXX: flash (-WP)   (QIO?)
GPIO10  = 12  -- XXX: flash (-HOLD) (QIO?)
GPIO11  = nil -- XXX: flash (CS)
GPIO12  = 6   -- ESP-01: unwired
GPIO13  = 7   -- ESP-01: unwired
GPIO14  = 5   -- ESP-01: unwired
GPIO15  = 8   -- ESP-01: unwired
GPIO16  = 0   -- ESP-01: unwired, D0(GPIO16) can only be used as gpio read/write

--
function try(what)
   local status, err = pcall(what)
   if (not status) then
      print('Error: ', err)
      return nil
   end
   return err
end

--
function doscript(script)
   if (file.exists(script .. '.lc')) then
      return dofile(script .. '.lc')
   end
   return dofile(script .. '.lua')
end

--
function trim_to_nil(s)
   if (not s) then return nil; end
   s = (s:gsub("^%s*(.-)%s*$", "%1"))
   if (s:len() <= 0) then return nil; end
   return s
end

--
function trim_to_empty(s)
   if (not s) then return ''; end
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--
function constrain(x, a, b)
   a, b = math.min(a, b), math.max(a, b)
   if (x < a) then return a; end
   if (x > b) then return b; end
   return x
end

--
function html_escape(s)
   if (s == nil) then return ''; end
   return (string.gsub(s, "[}{\">/<'&]", {
      ["&"] = "&amp;",
      ["<"] = "&lt;",
      [">"] = "&gt;",
      ['"'] = "&quot;",
      ["'"] = "&#39;",
      ["/"] = "&#47;"
   }))
end

--
function config_read(option, def)
   return try(function()
      local value = def
      local fd = file.open("config/"..option, "r")
      if fd then
         value = trim_to_nil(fd:readline())
         fd:close()
         fd = nil
         collectgarbage()
      end
      if (value == nil) then return def; end
      return value
   end)
end

--
function config_write(option, value)
   return try(function()
      local fd = file.open("config/"..option, "w+")
      if fd then
         fd:writeline(trim_to_empty(value))
         fd:close()
         fd = nil
         collectgarbage()
         print("config_write: " .. option .. " = [" .. value .. "]")
      end
   end)
end
