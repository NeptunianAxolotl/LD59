local megaHugeFont
local hugeFont
local bigFont
local medFont
local smallFont
local smallerFont

local externalFunc = {}
local _size = 1

function externalFunc.SetSize(size)
	if not bigFont then
		externalFunc.Load()
	end
	if size == -1 then
		love.graphics.setFont(megaHugeFont)
		_size = -1
	elseif size == 0 then
		love.graphics.setFont(hugeFont)
		_size = 0
	elseif size == 1 then
		love.graphics.setFont(bigFont)
		_size = 1
	elseif size == 2 then
		love.graphics.setFont(medFont)
		_size = 2
	elseif size == 3 then
		love.graphics.setFont(smallFont)
		_size = 3
	elseif size == 4 then
		love.graphics.setFont(smallerFont)
		_size = 4
	end
end

function externalFunc.GetFont()
	if _size == 1 then
		return bigFont
	elseif _size == 2 then
		return medFont
	else
		return smallFont
	end
end

local FONT = "FreeSansBold.ttf"
--local FONT = "RBNo3.1-Book.otf" -- https://freefontsfamily.com/rbno3-font-free-download/

function externalFunc.Load()
	megaHugeFont  = love.graphics.newFont('include/fonts/' .. FONT, 96)
	hugeFont  = love.graphics.newFont('include/fonts/' .. FONT, 64)
	bigFont   = love.graphics.newFont('include/fonts/' .. FONT, 48)
	medFont   = love.graphics.newFont('include/fonts/' .. FONT, 32)
	smallFont = love.graphics.newFont('include/fonts/' .. FONT, 24)
	smallerFont = love.graphics.newFont('include/fonts/' .. FONT, 18)
end

return externalFunc