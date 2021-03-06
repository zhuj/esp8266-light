require "common"

return function(callback)

   -- function holder
   local errors = 0
   local timer = tmr.create()
   timer:register(1000, tmr.ALARM_AUTO, function()

      -- first, stop the timer (we will start them after all)
      timer:stop()

      -- Note that when the rtctime module is available, there is no need to explicitly call rtctime.set():
      -- this module takes care of doing so internally automatically, for best accuracy.
      sntp.sync("pool.ntp.org",
         function(sec, usec, server)
            print('SNTP: ', sec, usec, server)
            try(callback)
            errors = 0

            timer:interval(1000 * 60 * 5) -- 5 min
            timer:start()
         end,
         function(err)
            local WAIT_MIN = 1000 * 5 -- 5 sec
            local WAIT_MAX = 1000 * 60 * 5 -- 5 min

            print('Error: SNTP: failed: ', err)
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
