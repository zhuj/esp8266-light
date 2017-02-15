-- XXX: don't use common.lua here
--
local compileAndRemoveIfNeeded = function(f)
   local status, err = pcall(function()
      if file.exists(f) then
         print('Compiling:', f)
         node.compile(f)
         file.remove(f)
      end
   end)
   if (not status) then
      print('Error: ', err)
   end
   collectgarbage()
end

-- common code
compileAndRemoveIfNeeded('common.lua')

-- main
compileAndRemoveIfNeeded('esp8266-light-wifi-connect.lua')
compileAndRemoveIfNeeded('esp8266-light-object.lua')
compileAndRemoveIfNeeded('esp8266-light-main.lua')

-- clean up
compileAndRemoveIfNeeded = nil
collectgarbage()
