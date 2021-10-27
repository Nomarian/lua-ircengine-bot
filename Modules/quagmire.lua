
--[=[ Todo
 lpeg
 use words instead of a context free match
 (surround with %s?)
 breathing room, wait 10 lines to say giggity again
 say giggity every x lines or randomly?

this is a false positive
https://www.newsweek.com/exclusive-how-amateur-sleuths-broke-wuhan-lab-story-embarrassed-media-1596958
 
local lpeg = require'lpeg'
local P,S,R = lpeg.P,lpeg.S,lpeg,R

local pat = P"jackoff" + P"jack"
-- plural and singulars
for s in ("cock|ball|blow|suck|nipple|sex"):gmatch"%a+" do
 local p = lpeg.P(s) + lpeg.P(s .. "s")
 pat = pat + p

 local function anywhere (p) return lpeg.P{ p + 1 * lpeg.V(1) } end

 for patt in pattern:gmatch"[^%|]+" do
  if s:match(patt) then return true end
 end
 return false

end

 lpeg.match(pattern,s)
 
 gsub - ?
--]=]

local quagmiredb = {}
do
-- single
 for word in ([[
  bulbous	spunk	penis	penises		ass	asses	asscrack penne pene schlong bathwater massage whip
  hot		penetrate	penetrative		boobies penetration  bdsm toy dildo banana
  69 balls boobs tits 
 ]]):gmatch"%g+" do quagmiredb[word] = true end
 
 
-- plural
 for word in ([[
  fist	erection	butt	nipple	blow
  cock	johnson		vulva	wiener	spank ball
 ]]):gmatch"%g+" do
  quagmiredb[word] = true
  quagmiredb[word .. "s"] = true -- plural
 end
 
 --[[
 multiple words space or dash
--]]
 
end

-- returns true if it should reply with giggity
local function giggity(s)
 if s:match"[Hh][Tt][Tt][Pp][Ss]?://" then return false end

 for word in s:gmatch"%w+" do
  if quagmiredb[word] then return true end
 end
    
 if
  s:match"pull[%- ]?out" or s:match"nose[%- ]?hairs?" or s:match"penetrat" or s:match"pene" or
  s:match"jack[%- ]?off" or s:match"sixty[%- ]?nine" or s:match"sex" or s:match"jerk[%- ]?off"
 then
  return true
 end
end

return {
 hooks = {
  PRIVMSG = function(self,state, sender, origin, message, pm)
	 if pm==false and giggity( message:lower() ) then self:PRIVMSG(origin,"Giggity") end
  end
 }
}

