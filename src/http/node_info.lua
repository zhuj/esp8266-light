local function sendAttr(connection, attr, val)
   if (val) then
      connection:send("<li><b>" .. attr .. ":</b> " .. val .. "<br></li>\n")
   end
end

return function(connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')
   connection:send('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><link rel="stylesheet" href="main.css"/></head><body><h1>Node info</h1><ul>')
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
   connection:send('</ul></body></html>')
   -- print("Heap:" .. node.heap())
end