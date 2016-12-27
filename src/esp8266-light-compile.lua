--
local compileAndRemoveIfNeeded = function(f)
   pcall(function()
      if file.exists(f) then
         print('Compiling:', f)
         node.compile(f)
         file.remove(f)
         collectgarbage()
      end
   end)
end

-- common code
compileAndRemoveIfNeeded('common.lua')
compileAndRemoveIfNeeded('time-zones.lua')

-- esp8266-light
compileAndRemoveIfNeeded('esp8266-light-html.lua')
compileAndRemoveIfNeeded('esp8266-light-main.lua')
compileAndRemoveIfNeeded('esp8266-light-object.lua')
compileAndRemoveIfNeeded('esp8266-light-reset.lua')
compileAndRemoveIfNeeded('esp8266-light-time.lua')
compileAndRemoveIfNeeded('esp8266-light-wifi-connect.lua')

-- http server
compileAndRemoveIfNeeded('httpserver.lua')
compileAndRemoveIfNeeded('httpserver-connection.lua')
compileAndRemoveIfNeeded('httpserver-error.lua')
compileAndRemoveIfNeeded('httpserver-header.lua')
compileAndRemoveIfNeeded('httpserver-request.lua')
compileAndRemoveIfNeeded('httpserver-static.lua')

-- http folder
for fn, sz in pairs(file.list()) do
   if (fn:find('^http%/.*%.lua$') == 1) then
      compileAndRemoveIfNeeded(fn)
   end
end

-- clean up
compileAndRemoveIfNeeded = nil
collectgarbage()
