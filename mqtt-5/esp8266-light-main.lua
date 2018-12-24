require "common"

--

adc.force_init_mode(adc.INIT_ADC)

--

GPIO4 = 2
light4 = doscript("esp8266-light-object")(GPIO4)
GPIO4 = nil

GPIO5 = 1
light5 = doscript("esp8266-light-object")(GPIO5)
GPIO5 = nil

GPIO12 = 6
light12 = doscript("esp8266-light-object")(GPIO12)
GPIO12 = nil

GPIO13 = 7
light13 = doscript("esp8266-light-object")(GPIO13)
GPIO13 = nil

GPIO14 = 5
light14 = doscript("esp8266-light-object")(GPIO14)
GPIO14 = nil

light4:stop()
light5:stop()
light12:stop()
light13:stop()
light14:stop()

--

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
local p4 = mqtt_prefix .. "/" .. tpid .. "/pwm/4"
local p5 = mqtt_prefix .. "/" .. tpid .. "/pwm/5"
local p12 = mqtt_prefix .. "/" .. tpid .. "/pwm/12"
local p13 = mqtt_prefix .. "/" .. tpid .. "/pwm/13"
local p14 = mqtt_prefix .. "/" .. tpid .. "/pwm/14"

-- on message receive event
m:on("message", function(client, topic, data)
  print('Message: topic=' .. topic .. ", data=" .. data)
  if (topic == p4) then
    local v = tonumber(data)
    if (v <= 0) then light4:stop()
    elseif (v >= 1024) then light4:start()
    else light4:pwm(v)
    end
  elseif (topic == p5) then
    local v = tonumber(data)
    if (v <= 0) then light5:stop()
    elseif (v >= 1024) then light5:start()
    else light5:pwm(v)
    end
  elseif (topic == p12) then
    local v = tonumber(data)
    if (v <= 0) then light12:stop()
    elseif (v >= 1024) then light12:start()
    else light12:pwm(v)
    end
  elseif (topic == p13) then
    local v = tonumber(data)
    if (v <= 0) then light13:stop()
    elseif (v >= 1024) then light13:start()
    else light13:pwm(v)
    end
  elseif (topic == p14) then
    local v = tonumber(data)
    if (v <= 0) then light14:stop()
    elseif (v >= 1024) then light14:start()
    else light14:pwm(v)
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
local timer = tmr:create()
timer:alarm(90000, tmr.ALARM_AUTO, function()
  val = adc.read(0)
  m:publish(mqtt_prefix .. "/light/" .. tpid, val, 0, 0)
end)


--
function handle_mqtt_connect(client)
  print('Connectied to MQTT...')
  client:publish(mqtt_prefix .. "/ping", "online=" .. tpid, 0, 0)
  client:subscribe({ [p4]=0, [p5]=0, [p12]=0, [p13]=0, [p14]=0 })
end

--
function handle_mqtt_error(client, reason)
  print("failed reason: " .. reason)
  tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

--
function do_mqtt_disconnect()
  m:close()
end

--
function do_mqtt_connect()
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
