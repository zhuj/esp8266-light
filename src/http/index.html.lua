require "esp8266-light-html"
return function(connection, req)
   html_header(connection, "Main")
   connection:send([===[
    <h1>Hello World!</h1>
      <ul>
         <li><a href="index.html">Index</a>: This page (static)</li>
         <li><a href="node_wifi.html">Wi-Fi Config</a>: Controls Wi-Fi Client</li>
         <li><a href="node_info.html">NodeMCU info</a>: Shows some basic NodeMCU</li>
    </ul>
   ]===])
   html_footer(connection)
end
