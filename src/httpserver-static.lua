-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function (connection, req, args)
   --print("Begin sending:", args.file)
   --print("node.heap(): ", node.heap())
   dofile("httpserver-header.lua")(connection, 200, args.ext, args.isGzipped, true)

   -- Send file in little chunks
   local continue = true
   local size = file.list()[args.file]
   if (size == nil) then
      return
   end

   local bytesSent = 0
   -- Chunks larger than 1024 don't work.
   -- https://github.com/nodemcu/nodemcu-firmware/issues/1075
   local chunkSize = 500
   while (bytesSent < size) do
      collectgarbage()

      -- NodeMCU file API lets you open 1 file at a time.
      -- So we need to open, seek, close each time in order
      -- to support multiple simultaneous clients.
      local f = file.open(args.file)
      f:seek("set", bytesSent)
      local chunk = f:read(chunkSize)
      f:close()

      if (not chunk) then
         return
      end

      connection:send(chunk)
      connection:flush(true)

      bytesSent = bytesSent + #chunk
      chunk = nil
   end
   collectgarbage()
end
