require "common"
local html = dofile("esp8266-light-html.lua")
return html("Main", function(connection, req, args)
   connection:send([===[
 <h1>Hello World!</h1>
   <ul>
      <li><a href="index.html">Index</a>: This page (static)</li>
      <li><a href="node_wifi.html">Station Config</a>: Controls Wi-Fi Client</li>
      <li><a href="node_info.html">NodeMCU info</a>: Shows some basic NodeMCU</li>
 </ul>
   ]===])
end)
