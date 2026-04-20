
local World = require("world")
SoundHandler = require("soundHandler")
BGMHandler = require("bgmHandler")
MainMenuHandler = require("mainMenuHandler")

local MapDefs = util.LoadDefDirectory("defs/maps")

local self = {}
local api = {}

-- Cosmos handles the world level, restarting the world,
-- and things that persist between worlds.

--------------------------------------------------
-- Get
--------------------------------------------------

function api.GetWorld()
	return World
end

--------------------------------------------------
-- Music
--------------------------------------------------

function api.ToggleMusic()
	self.musicEnabled = not self.musicEnabled
	if not self.musicEnabled then
		MusicHandler.StopCurrentTrack()
	end
end

function api.MusicEnabled()
	return self.musicEnabled
end

function api.GetMusicVolume()
	return self.musicVolume
end

function api.SetMusicVolume(volume)
	self.musicVolume = volume
	if volume <= 0 then
		self.musicEnabled = false
		return
	end
	self.musicEnabled = true
end

--------------------------------------------------
-- Resets etc
--------------------------------------------------

function api.RestartWorld()
	World.Initialize(api, self.curLevelData)
end

function api.LoadLevelByTable(levelTable)
	self.curLevelData = levelTable
	World.Initialize(api, self.curLevelData)
end

function api.SwitchLevel(goNext)
	local nameKey = (goNext and "nextLevel") or "prevLevel"
	local newLevelName = MapDefs[self.inbuiltLevelName][nameKey]
	if not newLevelName then
		return
	end
	self.inbuiltLevelName = newLevelName
	self.curLevelData = MapDefs[self.inbuiltLevelName]
	World.Initialize(api, self.curLevelData)
end

function api.TestSwitchLevel(goNext)
	local nameKey = (goNext and "nextLevel") or "prevLevel"
	local newLevelName = MapDefs[self.inbuiltLevelName][nameKey]
	if not newLevelName then
		return false
	end
	return true
end

function api.GetScrollSpeeds()
	return (self.grabInput and self.mouseScrollSpeed) or 0, self.keyScrollSpeed
end

function api.GetPersistentData()
	return self.persistentDataTable
end

function api.ToggleGrabInput()
	self.grabInput = not self.grabInput
	love.mouse.setGrabbed(self.grabInput)
end

function api.ScrollSpeedChange(change)
	self.mouseScrollSpeed = self.mouseScrollSpeed * change
	self.keyScrollSpeed = self.keyScrollSpeed * change
end

function api.DrawPhysicsEnabled()
	return self.drawDebug
end

function api.QuitGame()
	love.event.quit()
end

function api.DrawDebug()
	return self.drawDebug
end

function api.ToggleDebug()
	self.drawDebug = not self.drawDebug
end

function api.ToggleLocalisation()
	self.localisation = not self.localisation
end

function api.GetLocalisation()
	return self.localisation
end

--------------------------------------------------
-- Draw
--------------------------------------------------

function api.Draw()
	World.Draw()
end

function api.ViewResize(width, height)
	World.ViewResize(width, height)
end

function api.TakeScreenshot()
	love.filesystem.createDirectory("screenshots")
	print("working", love.filesystem.getWorkingDirectory())
	print("save", love.filesystem.getSaveDirectory())
	love.graphics.captureScreenshot("screenshots/screenshot_" .. math.floor(math.random()*100000) .. "_.png")
end

function api.GetRealTime()
	return self.realTime
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" then
		MainMenuHandler.ToggleMenu()
		return true
	end
	if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.RestartWorld()
		return true
	end
	if key == "d" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.ToggleDebug()
		return true
	end
	if key == "m" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.ToggleMusic()
		return true
	end
	if key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.TakeScreenshot()
		return true
	end
	if key == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.SwitchLevel(true)
		return true
	end
	if key == "p" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.SwitchLevel(false)
		return true
	end
	return World.KeyPressed(key, scancode, isRepeat)
end

function api.MousePressed(x, y, button)
	return World.MousePressed(x, y, button)
end

function api.MouseReleased(x, y, button)
	return World.MouseReleased(x, y, button)
end

function api.MouseMoved(x, y, dx, dy)
	World.MouseMoved(x, y, dx, dy)
end

--------------------------------------------------
-- Update and Initialize
--------------------------------------------------

function api.Update(dt, realDt)
	self.realTime = self.realTime + realDt
	BGMHandler.Update(realDt)
	SoundHandler.Update(realDt)
	World.Update(dt)
end

function api.Initialize()
	self = {
		realTime = 0,
		musicVolume = Global.MUSIC_VOLUME,
		inbuiltLevelName = Global.INIT_LEVEL,
		musicEnabled = true,
		drawDebug = Global.DRAW_DEBUG,
	}
	self.curLevelData = MapDefs[self.inbuiltLevelName]
	BGMHandler.Initialize(api)
	SoundHandler.Initialize(api)
	MainMenuHandler.Initialize(api)
	World.Initialize(api, self.curLevelData)
end

return api
