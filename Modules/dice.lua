
local irc = IRCeObject

callbacks.privmsg[#callbacks.privmsg+1] =
 function(self, sender, origin, message, pm)
  if cmd[1] == "dice" then  -- todo set global cmd

   assert( irc:PRIVMSG(origin, sender[1] .. ": PONG" ) )
   return true
  end
 return false
end
