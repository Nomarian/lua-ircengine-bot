#!/usr/local/bin/lua5.4

-- please look at usage() for usage
-- the gist is $1=url $2=channels

-------------------( Functions
function dbug() end
if os.getenv"DEBUG" then
 function dbug(s,x)
  x = x and io.write or print
  x(s)
 end
end
dbug"DEBUG has been turned on"
VERBOSITY=0
function V(n,s) if n<=VERBOSITY then print(s) end end

function usage()
 print([=[
  bot.lua [url [channels]]
  
  Environment variables (always take precedence)
  
    SERVER, PORT, CHANNELS, NICK, USERNAME, REALNAME
    MODULES, PASSWORD, BOTMODE
    
  Modules
    quit
      if a pm is sent with $QUITKEY then the bot will QUIT with a QUITMSG
      ENV: $QUITMSG, $QUITKEY
      Files
        $HOME/Net/IRC/quitmsg
        $HOME/Net/IRC/quitkey
  if BOTMODE is set, mode +B will be set
]=])
 os.exit(0)
end

-- returns whatever is in the file if it exists, nil if nothing
function orc(file,mode) -- open,read,close
 local f = io.open(file)
 if not f then return false end
 local s = f:read(mode or "a")
 f:close()
 return #s>0 and s -- #s==0 and false or s
end

-------------------) Functions



-- ProjDir is where we have the modules, though the modules should be in LUADIR
-- DIR
IRCDir = os.getenv"IRCDIR" or os.getenv"HOME" .. "/Net/IRC"
dbug("IRCDIR is " .. IRCDir)

ProjDir = os.getenv"ProjDir" or os.getenv"HOME" .. "/Proj/IRC/Bot"
dbug("PROJDIR is " .. ProjDir)
package.path = (
 ProjDir .. "/Callbacks/?.lua" .. ";" ..
 ProjDir .. "/Modules/?.lua" .. ";" ..
 package.path
)



------------------
local IRCe = require("irce")
print(IRCe._VERSION .. " running on " .. _VERSION)

local socket = require("socket")

--- Defaults ---
local SERVER,PORT,CHANNEL,PASS = "127.0.0.1",6669,"#" -- defaults
local NICK,USERNAME,REALNAME--, QuitKey, QuitMsg


do local a = os.getenv"BOTNAME" or os.getenv"USER" or os.getenv"LOGNAME" or "Bot"
 NICK = os.getenv"NICK" or a
 USERNAME = os.getenv"USERNAME" or NICK or a
 REALNAME = os.getenv"REALNAME" or NICK or a
 PASS = os.getenv"PASSWORD"
end


if arg[1] then
 PORT,CHANNEL = 6667,""
  if not arg[1]:match"^irc://" then
   arg[1] = "irc://" .. arg[1]
  end
  local t = require"socket.url".parse(arg[1])
  SERVER = t.host or SERVER
  PORT = t.port or PORT
  NICK = t.user or NICK
  PASS = t.password or PASS
  CHANNEL = arg[2] or os.getenv"CHANNELS" or CHANNEL
end



dbug("Server: " .. SERVER)
dbug("Port: " .. PORT)
dbug( ("Pass: %s"):format(PASS) )
dbug("Channels: " .. CHANNEL)
dbug("Nick: " .. NICK)
dbug("User: " .. USERNAME)
dbug("Realname: " .. REALNAME)

--- IRC object initialisation ---
local irc = IRCe.new()
IRCeObject = irc -- global


--- Globals ---
SETTINGS = {
 IRCDIR = IRCDir,
 PROJDIR = ProjDir,
 SERVER=SERVER,PORT=PORT,CHANNEL=CHANNEL,PASS=PASS,
 NICK=NICK,USERNAME=USERNAME,REALNAME=REALNAME,
 autojoin=CHANNEL
}

-- Path may change depending on your directory structure.
-- These should work for LuaRocks installations.
-- for v in ("base message channel"):gmatch"%g+" do irc:load_module(require("irce.modules"..v)) end
assert(irc:load_module(require("irce.modules.base")))
assert(irc:load_module(require("irce.modules.message")))
assert(irc:load_module(require("irce.modules.channel")))

-- load all modules in $MODULES
for s in (os.getenv"MODULES" or ""):gmatch"%a+" do
 dbug("Loading module: " .. s)
 assert( irc:load_module( require(s) ) )
end

--- Raw send function ---
local client = socket.tcp()

irc:set_send_func(function(self, message)
    return client:send(message)
end)

--- Callbacks ---(

 -- While below theres the standard sender callbacks, in the files theres the user callbacks
 
 callbacks = { privmsg = {} }
 
 arg[3] = arg[3] or os.getenv"PLUGINS"
 if arg[3] then
  for s in arg[3]:gmatch"%a+" do
   print("Loading callback: " .. s)
   require(s)
  end
 end
 
 irc:set_callback(IRCe.RAW, function(self, send, message)
 	print(("%s %s"):format(send and ">>>" or "<<<", message))
 end)
 
 irc:set_callback("CTCP", function(self, sender, origin, command, params, pm)
 	if command == "VERSION" then
 		assert(self:CTCP_REPLY(origin, "VERSION", "Lua IRC Engine"))
 	end
 end)
 
 irc:set_callback("001", function(self, ...)
  if os.getenv"BOTMODE" then assert(irc:MODE(NICK,"+B") ) end -- usermode B is for bots only
 	if CHANNEL then assert(irc:JOIN(CHANNEL)) end
 end)
 
 irc:set_callback("PRIVMSG", function(self, sender, origin, message, pm)
   MESSAGE = message:lower() -- to avoid lowering in every single command 
   --[[
   if
     (MESSAGE:find(NICK,1,true) and )
     )
   then
   
   end
   ]]
   for i,fn in ipairs(callbacks.privmsg) do
    if fn(self, sender, channel, list, kind, message) then break end
   end
  end
 )
 
 irc:set_callback("NAMES", function(self, sender, channel, list, kind, message)
 	print("---")
 	if not list then
 		print("No channel called " .. channel)
 	else
 		print(("Channel %s (%s):"):format(channel, kind))
 		print("-")
 		for _, nick in ipairs(list) do
       -- implement a userlist table in settings.server.channel.users
       -- will also need to be handled in join/part/kick/quit/killed callback
 			print(nick)
 		end
 	end
 	print("---")
 end)
 
 irc:set_callback("USERMODE", function(self, sender, operation, mode)
 	print(("User mode: %s%s"):format(operation, mode))
 end)
 
 irc:set_callback("CHANNELMODE", function(self, sender, operation, mode, param)
 	print(("Channel mode: %s%s %s"):format(operation, mode, param))
 end)
 
 --- Running ---
 --[[
 irc:set_callback("ERROR", function(self, one, two, ...)
   self:QUIT(two[1])
 end)
 ]]
--) Callbacks
--- Callbacks ---)

-------- Running
local function quit(s)
 print("EXITING" .. s and ": " .. s or "") client:close() os.exit()
end


local p = require"posix"
 -- should reload modules
 p.signal(p.SIGHUP, function (signo) quit"SIGHUP" end) 
 p.signal(p.SIGTERM, function (signo) quit"SIGTERM" end)
 p.signal(p.SIGINT, function (signo) quit"SIGINT" end)
 local SIGINFO=29 --siginfo is 29?, 30 in bsd, sigpwr is an alias in linux, raspbian doesn't have it
 p.signal(SIGINFO, function (signo) print(INFO) end)

 do
 client:settimeout(10)
 local line, err = client:connect(SERVER, PORT)
 if err then print("Connect error: " .. err) os.exit() end -- TODO: module cleanup
 
 -- modules should be loaded here
 
 irc:NICK(NICK)
 irc:USER(USERNAME, REALNAME)
 
 if SERVER=="127.0.0.1" or SERVER=="localhost" then
 client:settimeout(5)
  repeat
    local line,err = client:receive()
    irc:process(line)
  until err=="closed"
 else
  local ctimeout, timeout, maxtimeout = 0, 10, 200 -- usually 2 minutes after a unresponded ping
  client:settimeout(timeout)
  
  while
   line or -- server message received
   err=="timeout" -- the only error allowed is timeout
   and
   ctimeout<maxtimeout -- maxtimeout hasn't been reached
  do
   line,err = client:receive() -- if line is set, err is nil, if line is not set, err can be anything
   INFO = string.format("\n%s: [[%s]]\t[[%s]]",os.date"%T",line,err)
   
   irc:process(line)
   
   ctimeout = line and 0 or ctimeout+timeout
   if err and not (err=="closed" or err == "timeout") then print("WEIRD ERROR!: " .. err) end
  end
  
  if err~="closed" then print(err) client:close() end
 end
end
 
--[[ Todo
>>> PING :irc.rizon.io
<<< PONG :irc.rizon.io
>>> ERROR :Closing Link: adsl-72-50-6-134.prtc.net (Ping timeout: 240 seconds)

 Disconnect handling
 flood protection
 botmsg handler (basically privmsg but only activates when someone messages the bot
 later the bot will use args for each server
 (or better yet files)
 
 
 
 Signals
  reconnect, exit, reload modules
  sighup reloads modules
  sigterm unloads modules
  sigquit exits
  sigint safe quit (unload modules, exits)
  
 set a callback for PING that will reset TIMEOUT to 0
 if timeout reaches TIMEOUTMAX then the connection is determined as closed
 
--]]
