
return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
    if pm==false then return end
    local msg = MESSAGE
    if msg:match"linux" and not msg:match"gnu" then self:PRIVMSG(origin, sender[1] .. ": It's GNU/Linux" ) return end
    if msg:match"bsd" and not msg:match"gnu" then self:PRIVMSG(origin, sender[1] .. ": It's GNU/BSD/Linux" ) return end
  end
 }
}
