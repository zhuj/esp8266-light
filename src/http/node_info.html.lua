-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver
-- Author: Marcos Kirsch

local function sendAttr(connection, attr, val)
   if (val) then
      connection:send("<li><b>" .. attr .. ":</b> " .. val .. "<br></li>\n")
   end
end

require "esp8266-light-html"

return function(connection, req)
   html_header(connection, "Wi-Fi Client Config")

   connection:send('<h1>Node info</h1><ul>')
   local majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
   sendAttr(connection, "NodeMCU version", majorVer .. "." .. minorVer .. "." .. devVer)
   sendAttr(connection, "chipid", chipid)
   sendAttr(connection, "flashid", flashid)
   sendAttr(connection, "flashsize", flashsize)
   sendAttr(connection, "flashmode", flashmode)
   sendAttr(connection, "flashspeed", flashspeed)
   sendAttr(connection, "node.heap()", node.heap())
   sendAttr(connection, 'Memory in use (KB)', collectgarbage("count"))
   if (wifi.sta) then
      sendAttr(connection, 'IP address', wifi.sta.getip())
      sendAttr(connection, 'MAC address', wifi.sta.getmac())
   end
   connection:send('</ul>')

   html_footer(connection)
end
