require "common"

--
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

-- configs
local mqtt_server = config_read("mqtt/server", nil)
local mqtt_client = config_read("mqtt/client", "lamp-client-")
local mqtt_prefix = config_read("mqtt/prefix", "/lamp")

-- init mqtt client with keepalive timer 120sec
local m = mqtt.Client(mqtt_client .. tpid, 120, nil, nil)
local p = mqtt_prefix .. "/" .. tpid .. "/pwm"

-- on message receive event
m:on("message", function(client, topic, data)
  if (topic == p) then
    local v = tonumber(data)
    if (v <= 0) then light:stop()
    elseif (v >= 1024) then light:start()
    else light:pwm(v)
    end
  end
end)

-- lwt (it's a part of connect message)
m:lwt(
  mqtt_prefix .. "/lwt",
  "offline=" .. tpid,
  0, 0
)

--
local function handle_mqtt_connect(client)
  print('Connectied to MQTT...')
  client:publish(mqtt_prefix .. "/ping", "online=" .. tpid, 0, 0)
  client:subscribe(p, 0)
end

--
local function handle_mqtt_error(client, reason)
  print("failed reason: " .. reason)
  tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

--
local function do_mqtt_disconnect()
  m:close()
end

--
local function do_mqtt_connect()
  do_mqtt_disconnect()
  m:connect(
    mqtt_server, 1883, 0,
    handle_mqtt_connect,
    handle_mqtt_error
  )
end

--
doscript("esp8266-light-wifi-connect")(
  do_mqtt_connect,
  do_mqtt_disconnect
)
