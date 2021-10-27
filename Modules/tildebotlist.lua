
-- description varies so its inherited from env

local desc = os.getenv"BOTDESC" or Settings.Description or "I don't do much..."

return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
    if message:lower() == "!botlist" then
      local mail = "nmz@tilde.team"
      local msg = sender[1] .. ":"
      if pm then msg = "Hi!" end
      self:PRIVMSG(origin,
        ("%s %s | Contact: %s"):format(msg, desc, mail)
      )
    end
  end
 }
}