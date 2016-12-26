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
--compileAndRemoveIfNeeded('common.lua')

-- http server
--compileAndRemoveIfNeeded('httpserver.lua')
--compileAndRemoveIfNeeded('httpserver-connection.lua')
--compileAndRemoveIfNeeded('httpserver-error.lua')
--compileAndRemoveIfNeeded('httpserver-header.lua')
--compileAndRemoveIfNeeded('httpserver-request.lua')
--compileAndRemoveIfNeeded('httpserver-static.lua')

-- clean up
compileAndRemoveIfNeeded = nil
collectgarbage()
