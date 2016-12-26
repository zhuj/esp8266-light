require "common"
return function (title, callback)
   return function(connection, req, args)
      dofile("httpserver-header.lua")(connection, 200, "html", false)
      collectgarbage()
      connection:send([===[<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<link rel="stylesheet" href="main.css"/>
<title>ESP8266-Light: ]===] .. title .. [===[</title>
</head><body>]===])
      callback(connection, req, args)
      connection:send([===[<br/><br/>
<div class="footer">Heap: ]===] .. node.heap() .. [===[</div>
</body></html>]===])
   end
end
