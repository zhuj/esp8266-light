-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-connection
-- Part of nodemcu-httpserver, provides a buffered connection object that can handle multiple
-- consecutive send() calls, and buffers small payloads to send once they get big.
-- For this to work, it must be used from a coroutine and owner is responsible for the final
-- flush() and for closing the connection.
-- Author: Philip Gladstone, Marcos Kirsch

return function(connection)
   local newInstance = {}
   newInstance.connection = connection
   newInstance.data = ""

   function newInstance:flush(yield)
      local sz = #(self.data)
      if (sz > 0) then
         self.connection:send(self.data)
         self.data = ""
         collectgarbage()
         if (yield) then
            coroutine.yield()
            collectgarbage()
         end
      end
      return sz
   end

   function newInstance:possible()
      local flushthreshold = 500
      return math.max(1, flushthreshold - #(self.data))
   end

   function newInstance:send(payload)
      if (payload == nil) then
         return
      end

      while (true) do

         -- first, check for emptiness
         local sz = #(payload)
         if (sz <= 0) then
            collectgarbage()
            return
         end

         -- then, check if the data fits
         local possible = self:possible()
         if (sz <= possible) then
            if (#(self.data) > 0) then
               self.data = self.data .. payload
            else
               self.data = payload
            end
            payload = nil
            collectgarbage()
            if (sz == possible) then
               self:flush(true)
            end
            return
         end

         -- othwewise, split the string
         local piece = payload:sub(1, possible)
         payload = payload:sub(possible + 1)

         if (#(self.data) > 0) then
            self.data = self.data .. piece
         else
            self.data = piece
         end
         piece = nil

         -- and flush it (with yield)
         self:flush(true)
      end

   end

   return newInstance
end
