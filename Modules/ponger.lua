
-- 

return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
  --or MESSAGE:gsub(SETTINGS.NICK .. "%p%s?","")
    if MESSAGE == "ping" then
      self:PRIVMSG(origin, sender[1] .. ": PONG" )
    end
  end
 }
}

--[[ TODO
 botcommand hook
 Identify
  botname: ping
  .ping
--]]