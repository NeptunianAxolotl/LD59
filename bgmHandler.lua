local DISABLED = false

local soundFiles = util.LoadDefDirectory("resources/musicDefs")

local self = {}
local api = {}
local cosmos

local bgmPoints = Global.BGM_POINTS_PER_LEVEL -- slewed
local immediateBgmPoints = Global.BGM_POINTS_PER_LEVEL -- raw

local funkLength = 63.998
local irishLength = 5.342
local turnLength = 10.688


local funkTable = {}
local irishTable = {}
local turnTable = {}

local timeUntilPhaseCheck = 0
local currentPhase = 2 -- 1 = Irish; 2 = Turn; 3 = Funk

function getCurrentPhaseTable()
    if currentPhase == 1
    then
      return irishTable
    elseif currentPhase == 2
    then
      return turnTable
    else
      return funkTable
    end
  end

function setLevels(table)
    local netVolume = Global.MUSIC_VOLUME
    local specificVolume = 1
    local musicTable = getCurrentPhaseTable()
    if (table ~= nil)
    then musicTable = table
    end
    
    for i = 1, 9 do
      specificVolume = netVolume * musicTable[i].volMult -- Assume full volume
      if bgmPoints / Global.BGM_POINTS_PER_LEVEL < i -- Level too low for this layer: zero volume
      then specificVolume = 0
      elseif bgmPoints / Global.BGM_POINTS_PER_LEVEL - i < 0 -- Level not high enough for full volume; scale according to points
      then specificVolume = specificVolume * (bgmPoints % Global.BGM_POINTS_PER_LEVEL) / Global.BGM_POINTS_PER_LEVEL
    end
    musicTable[i].source:setVolume(specificVolume)
    end
  end
  
  function loadSounds(name,layerNum)
     local def = soundFiles[name]
     local irishSource = love.audio.newSource("resources/music/" .. def.irishFile, "static")
     local turnSource = love.audio.newSource("resources/music/" .. def.turnFile, "static")
     local funkSource = love.audio.newSource("resources/music/" .. def.funkFile, "static")
     
     irishTable[layerNum] = {volMult = def.volMult, source = irishSource}
     turnTable[layerNum]  = {volMult = def.volMult, source = turnSource}
     funkTable[layerNum]  = {volMult = def.volMult, source = funkSource}
      
    end



function api.Update(dt)
	if DISABLED then
		return
	end
  
  immediateBgmPoints = immediateBgmPoints - dt * Global.BGM_POINT_DECREMENT_PER_SECOND
  if (immediateBgmPoints < Global.BGM_POINTS_PER_LEVEL)
  then
    immediateBgmPoints = Global.BGM_POINTS_PER_LEVEL -- Points floor - ensures layer 1 cannot turn off
  end
  
  if (math.abs(bgmPoints - immediateBgmPoints) <= dt * Global.BGM_SLEW_RATE_PER_SECOND) --If timestep would overshoot, land exactly
  then bgmPoints = immediateBgmPoints
    -- Otherwise, slew
  elseif (bgmPoints > immediateBgmPoints)
  then  bgmPoints = bgmPoints - dt * Global.BGM_SLEW_RATE_PER_SECOND
  elseif (bgmPoints < immediateBgmPoints)
  then bgmPoints = bgmPoints + dt * Global.BGM_SLEW_RATE_PER_SECOND
  end
  
  setLevels()
  
  timeUntilPhaseCheck = timeUntilPhaseCheck - dt * timeUntilPhaseCheck
  
  if(timeUntilPhaseCheck<=0)
    then
    local currentTable = getCurrentPhaseTable()
    
    -- Stop playback on the current tracks
    for i = 1, 9 do
      currentTable[i].source:stop()
    end
    
    -- Changeover: determine what track to play
    
    -- TODO: bind this to chaos, fixed to iterating linearly for testing
    if currentPhase == 3
    then currentPhase = 1
      else currentPhase = currentPhase + 1
    end
    
    -- Update the timers and set levels
    if currentTable == 3
    then timeUntilPhaseCheck = funkLength
    elseif currentTable == 1
    then timeUntilPhaseCheck = irishLength
    else timeUntilPhaseCheck = turnLength
    end
    
    currentTable = getCurrentPhaseTable()
    setLevels()
    
    for i = 1, 9 do
      currentTable[i].source:play()
    end
    
  end
	
end

function api.addPoints(mult)
    immediateBgmPoints = immediateBgmPoints + mult * Global.BGM_POINTS_PER_INTERACTION
  end
  
  function api.Stop()
    -- Stop all the currently-playing layers and set the phase-check clock to zero so it is ready to restart
    currentTable = getCurrentPhaseTable()
    for i = 1, 9 do
      currentTable[i].source.stop()
    end
    timeUntilPhaseCheck = 0
    DISABLED = true
  end
  
  function api.Start()
    -- uninhibit Update(), which will immediately restart the BGM
    DISABLED = false
  end

function api.Initialize(newCosmos)
	if DISABLED then
		return
	end
  
  -- Load all the sounds
  -- IDS: 1: BASS+PK5, 2: KIT, 3: SAX 1, 4: BRASS 1, 5: SAX 2, 6: BRASS 2, 7: BRASS 4, 8: BRASS 3, 9: ORGAN
  loadSounds("BASS-PK5",1)
  loadSounds("KIT",2)
  loadSounds("SAX 1",3)
  loadSounds("BRASS 1",4)
  loadSounds("SAX 2",5)
  loadSounds("BRASS 2",6)
  loadSounds("BRASS 4",7)
  loadSounds("BRASS 3",8)
  loadSounds("ORGAN",9)
  
end

return api
