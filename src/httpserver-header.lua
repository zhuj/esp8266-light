-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-header.lua
-- Part of nodemcu-httpserver, knows how to send an HTTP header.
-- Author: Marcos Kirsch

return function (connection, code, extension, isGzipped, isCached)

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
   })[extension] or "text/plain"

   local status = ({
      [200]="OK",
      [400]="Bad Request",
      [404]="Not Found"
   })[code] or "Not Implemented"

   connection:send("HTTP/1.0 " .. code .. " " .. status .. "\r\nServer: nodemcu-httpserver\r\nContent-Type: " .. mimeType .. "\r\n")
   if (isGzipped) then
      connection:send("Cache-Control: max-age=2592000\r\nContent-Encoding: gzip\r\n")
   elseif (isCached) then
      connection:send("Cache-Control: max-age=2592000\r\n")
   else
      connection:send("Cache-Control: private, no-store\r\n")
   end
   connection:send("Connection: close\r\n\r\n")

end
