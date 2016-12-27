-- Author: Marcos Kirsch
-- Original code: https://github.com/marcoskirsch/nodemcu-httpserver
-- GNU General Public License, version 2

-- httpserver-request
-- Part of nodemcu-httpserver, parses incoming client requests.
-- Author: Marcos Kirsch

local function uriToFilename(uri)
   return "http/" .. string.sub(uri, 2, -1)
end

local function hex_to_char(x)
   return string.char(tonumber(x, 16))
end

local function uri_decode(input)
   return input:gsub("%+", " "):gsub("%%(%x%x)", hex_to_char)
end

local function parseArgs(args)
   local r = {}
   local i = 1
   if ((args == nil) or (args == "")) then return r end
   for arg in string.gmatch(args, "([^&]+)") do
      local name, value = string.match(arg, "(.*)=(.*)")
      if (name ~= nil) then r[name] = uri_decode(value) end
      i = i + 1
   end
   return r
end

local function parseFormData(body)
   local data = {}
   for kv in body.gmatch(body, "%s*&?([^=]+=[^&]+)") do
      local key, value = string.match(kv, "(.*)=(.*)")
      data[key] = uri_decode(value)
   end
   return data
end

local function getRequestData(payload)
   local mimeType = payload:match("Content%-Type: ([%w/-]+)")
   local bodyStart = payload:find("\r\n\r\n", 1, true)
   local body = payload:sub(bodyStart)
   if (mimeType == "application/json") then
      return cjson.decode(body)
   elseif (mimeType == "application/x-www-form-urlencoded") then
      return parseFormData(body)
   end
   return {}
end

local function parseUri(uri)
   local r = {}

   if (uri == nil) then return r end
   if (uri == "/") then uri = "/index.html" end

   local questionMarkPos = uri:find("?", 1, true)
   if (questionMarkPos == nil) then
      r.file = uri:sub(1, questionMarkPos)
      r.args = {}
   else
      r.file = uri:sub(1, questionMarkPos - 1)
      r.args = parseArgs(uri:sub(questionMarkPos + 1))
   end


   local ext = r.file:find("%.[^.]+$")
   if (ext) then
      ext = r.file:sub(1 + ext)
   end

   r.ext = ext
   r.isGzipped = (ext == 'gz')
   r.file = uriToFilename(r.file)
   return r
end

-- Parses the client's request. Returns a dictionary containing pretty much everything
-- the server needs to know about the uri.
return function (request)
   local _
   local r = {}
   _, _, r.method, r.request = request:find("^([A-Z]+) (.+) HTTP")
   r.uri = parseUri(r.request)
   r.requestData = getRequestData(request)
   return r
end
