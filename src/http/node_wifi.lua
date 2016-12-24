require "common"
return function(connection, req, args)
   dofile("httpserver-header.lc")(connection, 200, 'html')

   connection:send([===[
      <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><link rel="stylesheet" href="main.css"/><title>ESP8266-Light: Wi-Fi Client Config</title></head><body>
   ]===])

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

   connection:send([===[</body></html>]===])
   -- print("Heap:" .. node.heap())
end
