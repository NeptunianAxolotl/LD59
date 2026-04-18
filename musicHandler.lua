

local SoundHandler = require("soundHandler")
local soundFiles = util.LoadDefDirectory("resources/soundDefs")

local self = {}
local api = {}
local cosmos

local font = love.graphics.newFont(70)

-- First eligible tracks are used as start music
local trackData = require("defs/musicTracks")
local trackList = trackData.list

local currentTrack = {}
local trackRunning = false
local initialDelay = true
local trackParity = 1
local playingSounds = {}
local pitch = 1
local musicData = false

local DISABLED = true

function api.setPitch(newPitch)
	pitch = newPitch or 1
end

function api.StopCurrentTrack(delay)
	currentTrackRemaining = delay or 0
end

function api.SetCurrentTrackFadeTime(fadeTime)
	if trackRunning then
		for i = 1, #currentTrack do
			SoundHandler.SetSoundFade(currentTrack[i].sound, false, 1/fadeTime)
		end
	end
end

function api.Update(dt)
	if DISABLED then
		return
	end
	if self.needDtReset then
		Global.ResetMissingDt()
		self.needDtReset = false
	end
	if initialDelay then
		initialDelay = initialDelay - dt
		if initialDelay < 0 then
			initialDelay = false
			self.needDtReset = true
		else
			return
		end
	end
	
	local wantedTrack = GameHandler.GetDesiredTrack()
	for i = wantedTrack, wantedTrack + 1 do
		if trackList[i] and not playingSounds[i] then
			local pitch = trackData.PitchFunc and trackData.PitchFunc(i)
			playingSounds[i] = SoundHandler.PlaySound(trackList[i], i, 1, 1, false, true, ((trackData.WantTrack(cosmos, i) and 0.01) or 0), true, pitch, musicData)
		end
	end
	
	for i = 1, #playingSounds do
		playingSounds[i].want = ((trackData.WantTrack(cosmos, i) and 1) or 0)
	end
end

function api.Initialize(newCosmos)
	if DISABLED then
		return
	end
	musicData = love.filesystem.read("resources/sounds/music/LD57.wav")
	musicData = love.filesystem.newFileData(musicData, "resources/sounds/music/LD57.wav")
	self = {}
	cosmos = newCosmos
	initialDelay = 0
end

return api
