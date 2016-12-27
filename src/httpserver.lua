-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver
-- Author: Marcos Kirsch

require "common"

-- Starts web server in the specified port.
return function (port)

   local s = net.createServer(net.TCP, 2) -- 2 seconds client timeout
   s:listen(port, function (connection)

      -- This variable holds the thread (actually a Lua coroutine) used for sending data back to the user.
      -- We do it in a separate thread because we need to send in little chunks and wait for the onSent event
      -- before we can send more, or we risk overflowing the mcu's buffer.
      local connectionThread

      local function startServing(serveFunction, connection, req)
         connectionThread = coroutine.create(function(f, bufferedConnection, req)
            doscript(f)(bufferedConnection, req)

            -- The bufferedConnection may still hold some data that hasn't been sent. Flush it before closing.
            if (bufferedConnection:flush() <= 0) then
               connection:close()
               connectionThread = nil
            end

            -- clean all
            bufferedConnection = nil
            collectgarbage()
         end)

         local status, err = coroutine.resume(
            connectionThread,
            serveFunction,
            doscript("httpserver-connection")(connection),
            req
         )

         if (not status) then
            print("Error: " .. err)
            connection:close()
            connectionThread = nil
         end

         -- clean up after all
         collectgarbage()
      end

      local function handleRequest(connection, req)
         collectgarbage()
         local method = req.method
         local uri = req.uri
         local serveFunction

         if #(uri.file) > 32 then
            -- nodemcu-firmware cannot handle long filenames.
            uri.args = {code = 400, errorString = "Bad Request"}
            serveFunction = "httpserver-error"
         else
            -- check for static resources first
            local fileExists = file.exists(uri.file, "r")

            -- check for pre-gziped files (.gz)
            if (not fileExists) then
               fileExists = file.exists(uri.file .. ".gz", "r")
               if (fileExists) then
                  uri.file = uri.file .. ".gz"
                  uri.isGzipped = true
               end
            end

            -- check for lua scripts
            if (not fileExists) then
               fileExists = file.exists(uri.file .. ".lua", "r")
               if (fileExists) then
                  uri.isScript = true
               end
            end
            if (not fileExists) then
               fileExists = file.exists(uri.file .. ".lc", "r")
               if (fileExists) then
                  uri.isScript = true
               end
            end

            -- process file
            if (not fileExists) then
               uri.args = {code = 404, errorString = "Not Found"}
               serveFunction = "httpserver-error"

            elseif (uri.isScript) then
               serveFunction = uri.file
               if (not serveFunction) then
                  uri.args = {code = 500, errorString = "Error"}
                  serveFunction = "httpserver-error"
               end

            else
               local allowStatic = { GET=true }
               if (allowStatic[method] == true) then
                  uri.args = {file = uri.file, ext = uri.ext, isGzipped = uri.isGzipped}
                  serveFunction = "httpserver-static"
               else
                  uri.args = {code = 405, errorString = "Method not supported"}
                  serveFunction = "httpserver-error"
               end

            end
         end

         collectgarbage()
         startServing(serveFunction, connection, req)
      end

      local function isBodyComplete(body)
         local cl = body:find("Content-Length: ", 1, true)
         if (cl) then
            cl = tonumber(body:match("%d+", cl+16))
            if (cl > #(body) - (body:find("\r\n\r\n", 1, true)+4) + 1) then
               return false
            end
         end
         return true
      end

      local body
      local function onReceive(connection, payload)

         -- Some browsers send the POST data in multiple chunks.
         -- Collect data packets until the size of HTTP body meets the Content-Length stated in header
         if (body ~= nil) then
            payload = body .. payload
            body = nil
            collectgarbage()
         end
         if (not isBodyComplete(payload)) then
            body = payload -- save it for the next time
            return
         end

         -- collect all garbage
         collectgarbage()

         -- parse payload and decide what to serve.
         local req = doscript("httpserver-request")(payload)
         print(req.method .. ": " .. req.request)

         -- collect all garbage
         req.request = nil
         payload = nil
         collectgarbage()

         local allowRequest = { GET=true, POST=true, PUT=true }
         if (allowRequest[req.method] == true) then
            handleRequest(connection, req)
         else
            local fileServeFunction = "httpserver-error"
            req.uni.args = {code = 501, errorString = "Not Implemented"}
            startServing(fileServeFunction, connection, req)
         end

         -- collect all garbage
         collectgarbage()
      end

      local function onSent(connection)
         collectgarbage()
         if (connectionThread) then
            local connectionThreadStatus = coroutine.status(connectionThread)
            if (connectionThreadStatus == "suspended") then
               -- Not finished sending file, resume.
               local status, err = coroutine.resume(connectionThread)
               if (not status) then
                  print("Error: " .. err)
                  connection:close()
                  body = nil
                  connectionThread = nil
                  collectgarbage()
               end
            elseif (connectionThreadStatus == "dead") then
               -- We're done sending file.
               connection:close()
               body = nil
               connectionThread = nil
               collectgarbage()
            end
         end
      end

      local function onDisconnect(connection)
         body = nil
         connectionThread = nil
         collectgarbage()
      end

      connection:on("receive", onReceive)
      connection:on("sent", onSent)
      connection:on("disconnection", onDisconnect)

   end)

   -- false and nil evaluate as false
   local ip = wifi.sta.getip()
   if (not ip) then ip = wifi.ap.getip() end
   if (not ip) then ip = "unknown IP" end
   print("nodemcu-httpserver running at http://" .. ip .. ":" ..  port)
   return s

end
