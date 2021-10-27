

local surl = require "socket.url"
local exclude = {}

do
-- must be in lowercase
-- no www!
-- no scheme either (https http is removed!)
  print"Excluding host:"
  local n = 20
 -- this is a list of hosts to exclude, its divided by whitespace
 -- you can exclude youtube if you want
 for x in ([[
    localhost
    dsldevice.lan
  ]]):gmatch"%g+" do
    io.write(" " .. x) -- would be nice to print it columnated
    n = n + #x
    if n>80 then print() n=0 end
    exclude[x] = true
  end
  print()
end

-- flood protector (run every x seconds)
local t1 = os.time()
local waitseconds = math.tointeger(os.getenv"NETWAIT") or 10
if SETTINGS.SERVER=="127.0.0.1" or SETTINGS.SERVER=="localhost" then
 waitseconds = 0
end

require"getTitle"

local function grabtitle(url)
 local s
 if (os.time()-t1) > waitseconds then -- for flood protection
 -- fetch the title using script
  s = getTitle(url)
  dbug("Fetched url")
 else
  dbug("Not fetching, (wait time not completed)")
 end
 t1 = os.time()
 return s and #s>0 and s:sub(1,200)
end


return { hooks = { PRIVMSG = function(self,state, sender, origin, message, pm)
  if pm then return end -- No private messages
  
  -- simple because urls could have multiples ., also ip,s also domains,
  local url = message:match"[Hh][Tt][Tt][Pp][Ss]?://%g+"
  if not url then return end
  dbug("Url found: " .. url)
  local t = surl.parse(url)
  
  if
    t and t.host and -- parse was successful, t.host exists (maybe redundant?)
    t.host:match"%a%w*%.%a%a%a?%a?$" -- end in a domain name, NO IP ADDRESSES! .country and .info is fine
    and
    not exclude[ t.host:lower():gsub("^www%.","") ] -- excluding urls (and remove www)
  then
    local title = grabtitle(url)
    if title then self:PRIVMSG(origin, "Title: " .. title ) end
  end
  
end}}



--[=[
 Todo
  chunksend?
  rewrite http-title in lua for speed?
  configure it so it works on some channels and not others?
  
 spam defense
 when people join, spam and throw links and leave
 a hook for joins, put the sender in the trusted
 also in /names 

]=]