require "common"

local GPIO2 = 4 -- PIN: light pwm
light = doscript("esp8266-light-object")(GPIO2)
GPIO2 = nil

light:start()

local tpid = (function()
   local id = trim_to_nil(wifi.ap.getmac())
   if (id ~= nil) then id = id:gsub(":", {[":"]=""}):sub(7)
   else id = node.chipid() end
   return "esp-" .. id:lower()
end)()
print('tpid: ', tpid)

doscript("esp8266-light-wifi-connect")(function(connect)

  -- init mqtt client with keepalive timer 120sec
  local m = mqtt.Client("vx-lamp-client-" .. tpid, 120, nil, nil)
  local p = "/lamp/"..tpid.."/pwm"

  -- on publish message receive event
  m:on("message", function(client, topic, data) 
    if (topic == p) then
      local v = tonumber(data)
      if (v <= 0) then light:stop()
      elseif (v >= 1024) then light:start()
      else light:pwm(v)
      end
    end
  end)

  -- let's connect
  m:connect(
    "10.0.0.1", 1883, 0, 1,
    function(client)

      print('Connectied to MQTT...')

      m:publish(
        "/lamp/ping",
        "tpid=" .. tpid,
        0, 0
      )

     m:subscribe(p, 0)
   end,
   function(client, reason) print("failed reason: "..reason) end
)



end)
