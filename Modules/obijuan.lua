
return {
 hooks = {
  JOIN = function(self,state, sender, channel)
	local to = sender[1]==NICK and "" or sender[1] .. ": "
	self:PRIVMSG(channel, to .. "Hello There!")
  end
 }
}
