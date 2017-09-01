require "common"

local stationPointConfig = {}
stationPointConfig.ssid = config_read("stationPointConfig/ssid", nil)
stationPointConfig.pwd = config_read("stationPointConfig/pass", nil)
stationPointConfig.auto = true

if (stationPointConfig.ssid and stationPointConfig.pwd) then
   print('ssid: [' .. stationPointConfig.ssid .. ']')
   print('pass: [' .. stationPointConfig.pwd .. ']')
end

-- Tell the chip to connect to the access point
wifi.setmode(wifi.STATION)
wifi.sta.config(stationPointConfig)
print('Mode: ', wifi.getmode())
print('CMAC: ', wifi.sta.getmac())

stationPointConfig = nil
collectgarbage()
print('chip: ', node.chipid())
print('heap: ', node.heap())

return function(cb_connect, cb_disconnect)
   wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
      print("STA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
   end)
   wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
      print("STA - DHCP TIMEOUT")
   end)
   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
      tmr.create():alarm(1000, tmr.ALARM_SINGLE, cb_connect)
      print("STA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
   end)
   wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
      tmr.create():alarm(1000, tmr.ALARM_SINGLE, cb_disconnect)
      print("STA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
      for key,val in pairs(wifi.eventmon.reason) do
         if val == T.reason then
            print("\tDisconnect reason: "..val.."("..key..")")
            break
         end
      end
   end)
end
