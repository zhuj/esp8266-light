require "common"

function html_header(connection, title)
   connection:send("HTTP/1.0 200 OK\r\nServer: nodemcu-httpserver\r\nContent-Type: text/html\r\nCache-Control: private, no-store\r\nConnection: close\r\n\r\n")
   connection:send([===[<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<link rel="stylesheet" href="main.css"/>
<title>ESP8266-Light: ]===] .. html_escape(title) .. [===[</title>
</head><body>]===])
   connection:flush(true)
end

function html_footer(connection)
   connection:flush(true)
   connection:send([===[<br/><br/>
<div class="footer">Heap: ]===] .. node.heap() .. [===[</div>
</body></html>]===])
end
