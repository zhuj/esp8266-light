require "esp8266-light-html"
return function(connection, req)
   html_header(connection, "Main")
   connection:send([=[
    <h1>Hello World!</h1>
      <ul>
         <li><a href="index.html">Index</a>: This page (static)</li>
         <li><a href="config_wifi.html">Wi-Fi Config</a>: Controls Wi-Fi client</li>
         <li><a href="config_light.html">Light Config</a>: Controls light activity</li>
         <li><a href="node_info.html">NodeMCU info</a>: Shows some basic NodeMCU</li>
    </ul>
   ]=])
   html_footer(connection)
end
