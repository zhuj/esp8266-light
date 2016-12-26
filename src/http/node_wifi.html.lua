require "common"
local html = dofile("esp8266-light-html.lua")
return html("Wi-Fi Client Config", function(connection, req, args)

   if (req.method == "POST") then
      -- POST
      local rd = req.getRequestData()
      Config:write("stationPointConfig/ssid", rd.ssid)
      Config:write("stationPointConfig/pass", rd.pass)
      -- POST
   end

   local ssid = Config:read("stationPointConfig/ssid", '')
   local pass = Config:read("stationPointConfig/pass", '')

   connection:send([===[
    <h1>Wi-Fi Client Config</h1>
    <form method="POST">
     <table class="fields">
      <tr><td>SSID:</td><td><input type="text" name="ssid" value="]===] .. html_escape(ssid) .. [===["/></td></tr>
      <tr><td>Pass:</td><td><input type="text" name="pass" value="]===] .. html_escape(pass) .. [===["/></td></tr>
     </table>
     <input type="submit" name="submit" value="Submit">
    </form>
   ]===])

end)
