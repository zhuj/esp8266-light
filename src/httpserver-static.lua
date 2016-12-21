-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function (connection, req, args)
   --print("Begin sending:", args.file)
   --print("node.heap(): ", node.heap())
   dofile("httpserver-header.lc")(connection, 200, args.ext, args.isGzipped)
   -- Send file in little chunks
   local continue = true
   local size = file.list()[args.file]
   local bytesSent = 0
   -- Chunks larger than 1024 don't work.
   -- https://github.com/nodemcu/nodemcu-firmware/issues/1075
   local chunkSize = 1024
   while continue do
      collectgarbage()

      -- NodeMCU file API lets you open 1 file at a time.
      -- So we need to open, seek, close each time in order
      -- to support multiple simultaneous clients.
      local f = file.open(args.file)
      f:seek("set", bytesSent)
      local chunk = f:read(chunkSize)
      f:close()

      connection:send(chunk)
      bytesSent = bytesSent + #chunk
      chunk = nil
      --print("Sent: " .. bytesSent .. " of " .. size)
      if bytesSent == size then continue = false end
   end
   --print("Finished sending: ", args.file)
end
