-- XXX:don't use common.lua here

-- first, check boot reason
local _, reason = node.bootreason()
local ok = ({
   [0] = true, -- 0, power-on
   [1] = false, -- 1, hardware watchdog reset
   [2] = false, -- 2, exception reset
   [3] = false, -- 3, software watchdog reset
   [4] = true, -- 4, software restart
   [5] = true, -- 5, wake from deep sleep
   [6] = true -- 6, external reset
})[reason]

if (ok ~= true) then
   return
end

-- slow down freq
node.setcpufreq(node.CPU80MHZ)

-- try to compile all the code (if required)
local ok, err = pcall(dofile, "compile.lua")
if (not ok) then print("Error: ", err); end

-- try to start
local ok, err = pcall(dofile, 'esp8266-light-main.lc')
if (not ok) then print("Error: ", err); end
