require "esp8266-light-html"
return function(connection, req)
   html_header(connection, "Light Config")

   if (req.method == "POST") then
      -- POST
      local rd = req.requestData
      config_write("light/timezone", rd.timezone)
      config_write("light/timezone-dst", rd.timezone_dst)

      local hours = ''
      for h=0,23 do
         if (rd['h' .. h] ~= nil) then
            hours = hours .. '|' .. h
         end
      end
      config_write("light/hours", hours..'|')
      -- POST

      -- refresh the light
      if (main_timer ~= nil) then
         main_timer:interval(5000) -- 5 seconds wait
      end
   end

   local timezone = config_read("light/timezone", '')
   local timezone_dst = config_read("light/timezone-dst", '')
   local hours = config_read("light/hours", '')

   connection:send([=[
    <h1>Wi-Fi Client Config</h1>
    <form method="POST">
     <table class="fields">
    ]=])

   -- timezone
   connection:send([=[<tr><td>TimeZone:</td><td><select name="timezone">]=])
   for k, _ in pairs(doscript("time-zones")) do
      local ek = html_escape(k)
      local selected = ((k == timezone) and "selected" or "")
      connection:send([=[<option ]=] .. selected .. [=[ value="]=]..ek..[=[">]=] .. ek .. [=[</option>]=])
   end
   connection:send([=[</select>]=])

   -- timezone_dst
   connection:send([=[<select name="timezone_dst">]=])
   for _, k in pairs({'GMT', 'DST'}) do
      local selected = ((k == timezone_dst) and "selected" or "")
      connection:send([=[<option ]=] .. selected .. [=[ value="]=].. k ..[=[">]=] .. k .. [=[</option>]=])
   end
   connection:send([=[</select></td></tr>]=])

   -- active hours
   connection:send([=[<tr><td>Active:</td><td>]=])
   for h=0,23 do
      local selected = (hours:find('|'..h..'|', 1, true) ~= nil)
      local checked = (selected and "checked" or "")
      connection:send(
         [=[<div class="h-]=] .. h .. [=["><input type="checkbox" ]=] .. checked .. [=[ value="1" name="h]=] .. h .. [=[">]=] .. h .. [=[:00 - ]=] .. h ..[=[:59</input></div>]=]
      )
   end
   connection:send([=[</td></tr>]=])

   connection:send([=[
     </table>
     <input type="submit" name="submit" value="Submit">
    </form>
   ]=])

   html_footer(connection)
end
