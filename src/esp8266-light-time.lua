require "common"

return function(pool, callback)

      local WAIT_MIN = 1000*30        -- 30 sec
      local WAIT_MAX = WAIT_MIN*2*5   -- 5 min

      -- it resolves dns and time, then call a either 'ok' or 'fail' callback
      local function resolve(ok, fail)
         net.dns.resolve(pool, function(sk, ip)
            if (ip == nil) then
               print("Error: DNS failed!")
               fail()
            else
               -- Note that when the rtctime module is available, there is no need to explicitly call rtctime.set():
               -- this module takes care of doing so internally automatically, for best accuracy.
               sntp.sync(ip,
                  function(sec,usec,server)
                     print('SNTP: ', sec, usec, server)
                     ok()
                  end,
                  function(err)
                     print('Error: SNTP: failed: ', err)
                     fail()
                  end
               )
            end
         end)

      end

      -- function holder
      local errors = 0
      local timer = tmr.create()
      timer:register(1000, tmr.ALARM_AUTO, function()

            -- first, stop the timer (we will start them after)
            timer:stop()

            -- then resolve a time and call the callback
            resolve(
               -- ok
               function()
                  try(callback)
                  errors = 0

                  timer:interval(WAIT_MAX)
                  timer:start()
               end,
               -- fail
               function()
                  local wait = WAIT_MIN * errors
                  if (wait < WAIT_MAX) then
                     errors = errors + 1
                  end

                  if (wait < WAIT_MIN) then wait = WAIT_MIN end
                  if (wait > WAIT_MAX) then wait = WAIT_MAX end

                  timer:interval(wait)
                  timer:start()
               end)
      end)

      -- return the timer
      return timer
end
