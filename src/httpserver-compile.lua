-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- Part of nodemcu-httpserver, compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.
-- Author: Marcos Kirsch

require "common"

local compileAndRemoveIfNeeded = function(f)
   try(function()
      if file.exists(f) then
         print('Compiling:', f)
         node.compile(f)
         file.remove(f)
         collectgarbage()
      end
   end)
end

compileAndRemoveIfNeeded('httpserver.lua')
compileAndRemoveIfNeeded('httpserver-b64decode.lua')
compileAndRemoveIfNeeded('httpserver-connection.lua')
compileAndRemoveIfNeeded('httpserver-error.lua')
compileAndRemoveIfNeeded('httpserver-header.lua')
compileAndRemoveIfNeeded('httpserver-request.lua')
compileAndRemoveIfNeeded('httpserver-static.lua')

compileAndRemoveIfNeeded = nil
collectgarbage()

