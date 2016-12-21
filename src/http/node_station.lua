require "common";

return function (connection, req, args)
  dofile("httpserver-header.lc")(connection, 200, 'html')

  connection:send([===[
      <!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Access point config</title></head><body>
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
    <h1>Access point config</h1>
    <form method="POST">
     <table border="0">
      <tr><td>SSID:</td><td><input type="text" name="ssid" value="]===]..ssid..[===["/></td></tr>
      <tr><td>Pass:</td><td><input type="text" name="pass" value="]===]..pass..[===["/></td></tr>
     </table>
     <input type="submit" name="submit" value="Submit">
    </form>
   ]===])

  connection:send([===[</body></html>]===])
end
