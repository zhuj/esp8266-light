require "esp8266-light-html"
return function(connection, req)
   html_header(connection, "Light Config")

   if (req.method == "POST") then
      -- POST
      local rd = req.requestData
      config_write("light/timezone", rd.timezone)

      local hours = ''
      for h=0,23 do
         if (rd['h' .. h] ~= nil) then
            hours = hours .. '|' .. h
         end
      end
      config_write("light/hours", hours..'|')
      -- POST
   end

   local timezone = config_read("light/timezone", '')
   local hours = config_read("light/hours", '')

   connection:send([=[
    <h1>Wi-Fi Client Config</h1>
    <form method="POST">
     <table class="fields">
    ]=])

   -- timezone
   connection:send([=[<tr><td>TimeZone:</td><td><select name="timezone">]=])
   for k,v in pairs(doscript("time-zones")) do
      local ek = html_escape(k)
      connection:send([=[<option ]=])
      if (k == timezone) then
         connection:send([=[ selected ]=])
      end
      connection:send([=[ value="]=]..ek..[=[">]=] .. ek .. [=[</option>]=])
   end
   connection:send([=[</select></td></tr>]=])

   -- active hours
   connection:send([=[<tr><td>Active:</td><td>]=])
   for h=0,23 do
      local selected = (hours:find('|'..h..'|', 1, true) ~= nil)
      connection:send([=[<div class="h-]=] .. h .. [=["><input type="checkbox" ]=])
      if (selected) then
         connection:send([=[ checked ]=])
      end
      connection:send([=[value="1" name="h]=] .. h .. [=[">]=] .. h .. [=[:00 - ]=] .. h ..[=[:59</input></div>]=])
   end
   connection:send([=[</td></tr>]=])


   connection:send([=[
     </table>
     <input type="submit" name="submit" value="Submit">
    </form>
   ]=])

   html_footer(connection)
end
