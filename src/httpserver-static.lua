-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-static.lua
-- Part of nodemcu-httpserver, handles sending static files to client.
-- Author: Marcos Kirsch

return function(connection, req)

   local args = req.uri.args
   local mimeType = ({
      css = "text/css",
      gif = "image/gif",
      html = "text/html",
      ico = "image/x-icon",
      jpeg = "image/jpeg",
      jpg = "image/jpeg",
      js = "application/javascript",
      json = "application/json",
      png = "image/png",
      xml = "text/xml"
   })[args.ext] or "text/plain"

   -- header
   connection:send("HTTP/1.0 200 OK\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\n")
   if (args.isGzipped) then
      connection:send("Cache-Control: max-age=2592000\r\nContent-Encoding: gzip\r\n")
   else
      connection:send("Cache-Control: max-age=2592000\r\n")
   end
   connection:send("Connection: close\r\n\r\n")
   connection:flush(true)
   collectgarbage()

   -- Send file in little chunks
   local size = file.list()[args.file]
   if ((size == nil) or (size <= 0)) then
      return
   end

   -- Chunks larger than 1024 don't work.
   -- https://github.com/nodemcu/nodemcu-firmware/issues/1075
   local bytesSent = 0
   while (bytesSent < size) do
      collectgarbage()

      -- NodeMCU file API lets you open 1 file at a time.
      -- So we need to open, seek, close each time in order
      -- to support multiple simultaneous clients.
      local f = file.open(args.file)
      f:seek("set", bytesSent)
      local chunk = f:read(connection:possible())
      f:close()

      if ((not chunk) or #(chunk) <= 0) then
         break
      end

      connection:send(chunk)
      connection:flush(true)

      bytesSent = bytesSent + #(chunk)
      chunk = nil
   end
   collectgarbage()
end
