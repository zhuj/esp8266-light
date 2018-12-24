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
function config_read(option, def)
   return try(function()
      local value = def
      local fd = file.open("config/" .. option, "r")
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
      local fd = file.open("config/" .. option, "w+")
      if fd then
         fd:writeline(trim_to_empty(value))
         fd:close()
         fd = nil
         collectgarbage()
         print("config_write: " .. option .. " = [" .. value .. "]")
      end
   end)
end
