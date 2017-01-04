require "esp8266-light-html"

return function(connection, req)
   html_header(connection, "Wi-Fi Client Config")

   if (req.method == "POST") then
      -- POST
      local rd = req.requestData
      config_write("stationPointConfig/ssid", rd.ssid)
      config_write("stationPointConfig/pass", rd.pass)
      -- POST
   end

   local ssid = config_read("stationPointConfig/ssid", '')
   local pass = config_read("stationPointConfig/pass", '')

   connection:send([=[
    <h1>Wi-Fi Client Config</h1>
    <form method="POST">
     <table class="fields">
      <tr><td>SSID:</td><td><input type="text" name="ssid" value="]=] .. html_escape(ssid) .. [=["/></td></tr>
      <tr><td>Pass:</td><td><input type="text" name="pass" value="]=] .. html_escape(pass) .. [=["/></td></tr>
     </table>
     <input type="submit" name="submit" value="Submit">
    </form>
   ]=])

   html_footer(connection)
end
