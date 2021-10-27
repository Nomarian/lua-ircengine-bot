
-- IRCDIR also doesn't exist...

local QuitKey = os.getenv"QUITKEY" or orc(IRCDir .. "/quitkey","l") or "?quit"
local QuitMsg = os.getenv"QUITMSG" or orc(IRCDir .. "/quitmsg","l") or "QUIT!"

QuitMsg = QuitMsg:sub(1,400)  -- 512-#NICK+#USERNAME+#REALNAME+40
dbug("QUITKEY: " .. QuitKey)
dbug("QUITMSG: " .. QuitMsg)

return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
    if pm and message == QuitKey then
      self:QUIT(QuitMsg)
    end
  end
 }
}
