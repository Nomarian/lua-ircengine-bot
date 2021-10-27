
-- TODO
-- maybe reorganize for favorite quotes?
-- maybe activate on any GoT reference?

local quotes,quotesL = {}, 1
do -- test if file exist else exit?
 local quotefile = IRCDir .. "Data/bobbyb"
 local f = io.open(quotefile)
 for line in f:lines() do
  quotes[quotesL],quotesL = line, quotesL+1
 end f:close()
 if #quotes==0 then error"Quotesdb is empty?" os.exit() end
end

return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
    if pm==false and message:match"[Bb]obby%-?[Bb]" then
      self:PRIVMSG(origin, quotes[math.random(1,quotesL)]  ) end
  end
 }
}