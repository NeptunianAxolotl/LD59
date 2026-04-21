local DISABLED = false

local soundFiles = util.LoadDefDirectory("resources/musicDefs")

local self = {}
local api = {}
local cosmos

local bgmPoints = Global.BGM_POINTS_PER_LEVEL -- slewed
local immediateBgmPoints = Global.BGM_POINTS_PER_LEVEL -- raw

local chaosPoints = 0

local funkLength = 63.998
local irishLength = 5.342
local turnLength = 10.688

local bangTable = {}
local crashTable = {}

local funkCount = 0

local funkTable = {}
local irishTable = {}
local turnTable = {}

local timeUntilPhaseCheck = 0
local currentPhase = 0 -- 1 = Irish; 2 = Turn; 3 = Funk

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
    local netVolume = self.cosmos.GetMusicVolume()
    local specificVolume = 1
    local musicTable = getCurrentPhaseTable()
    if (table ~= nil)
    then musicTable = table
    end
    
    for i = 1, 9 do
      specificVolume = netVolume * musicTable[i].volMult -- Assume full volume
      if bgmPoints / Global.BGM_POINTS_PER_LEVEL < i - 1 -- Level too low for this layer: zero volume
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
     
     irishSource:setLooping(true)
     turnSource:setLooping(true)
     funkSource:setLooping(true)
     
     irishTable[layerNum] = {volMult = def.volMult, source = irishSource}
     turnTable[layerNum]  = {volMult = def.volMult, source = turnSource}
     funkTable[layerNum]  = {volMult = def.volMult, source = funkSource}
      
    end



function api.Update(dt)
	if DISABLED then
		return
	end
  
  
  --print("chaos points",chaosPoints)
  chaosPoints = chaosPoints - dt * Global.BGM_CHAOS_POINTS_DECREMENT_PER_SECOND
  
  if chaosPoints < 0 or chaosPoints > 50 * Global.BGM_CHAOS_POINTS_PER_CRASH -- reset if out of bounds
  then chaosPoints = 0
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
  
  timeUntilPhaseCheck = timeUntilPhaseCheck - dt
  
  if(timeUntilPhaseCheck<=0)
    then
    local currentTable = getCurrentPhaseTable()
    
    -- Changeover: determine what track to play
    -- 1 = Irish; 2 = Turn; 3 = Funk
    if currentPhase == 3
    then funkCount = funkCount + 1
    else funkCount = 0
  end
  
  -- Determine chaos
  -- if above high threshold: high chaos
  -- if below low threshold: low chaos
  -- if playing irish and above low threshold: high chaos
  -- if playing funk and below high threshold: low chaos
  -- if in turn between low and high thresholds: low chaos (prefer deescalation)
    local highChaos = false
    
    if chaosPoints >= Global.BGM_CHAOS_POINTS_HIGH_CHAOS_THRESHOLD
    then highChaos = true
    elseif chaosPoints <= Global.BGM_CHAOS_POINTS_LOW_CHAOS_THRESHOLD
    then highChaos = false
    elseif currentPhase == 1 and chaosPoints >= Global.BGM_CHAOS_POINTS_LOW_CHAOS_THRESHOLD
    then highChaos = true
    elseif currentPhase == 3 and chaosPoints <= Global.BGM_CHAOS_POINTS_HIGH_CHAOS_THRESHOLD
    then highChaos = false
    end
    
    -- high chaos: play irish unless playing funk, in which case play turn
    -- low chaos: play funk, with turn after every two funks, unless playing irish, in which case play turn
    
    local newPhase = 0
    
    if highChaos
    then 
      if currentPhase ~= 3
        then newPhase = 1
        else newPhase = 2
      end
    else
      if currentPhase == 1
      then newPhase = 2
      else newPhase = 3
      end
    end
    
    if funkCount > 1
    then newPhase = 2
    end
    
    
    -- Stop playback on the current tracks if different
    if newPhase ~= currentPhase
    then
      for i = 1, 9 do
        currentTable[i].source:stop()
      end
      currentPhase = newPhase
      setLevels()
      currentTable = getCurrentPhaseTable()
      for i = 1, 9 do
        currentTable[i].source:play()
      end
    end
    
    -- Update the timers and set levels
    if currentPhase == 3
    then timeUntilPhaseCheck = funkLength
    elseif currentPhase == 1
    then timeUntilPhaseCheck = irishLength
    else timeUntilPhaseCheck = turnLength
    end
    
    
    
    
  end
	
end

-- the audio crash handler
function api.addPoints(mult)
    immediateBgmPoints = immediateBgmPoints + mult * Global.BGM_POINTS_PER_INTERACTION
  end
  
function api.RegisterCollision()
	chaosPoints = chaosPoints + Global.BGM_CHAOS_POINTS_PER_CRASH
  -- this is very very not the place to do this but I'm hacking this together quickly lol
  local crashNum = math.random(1,10)
  local bangNum = math.random(1,10)
  
  local crash = crashTable[crashNum]
  local bang = bangTable[bangNum]
  
  bang:stop()
  crash:stop()
  bang:setVolume(self.cosmos.GetSoundVolume()*0.1)
  crash:setVolume(self.cosmos.GetSoundVolume()*0.1)
  crash:setPitch( 0.9 + math.random() / 5)
  
  --bang:play()
  --crash:play()
  
end
  
  function api.Stop()
    -- Stop all the currently-playing layers and set the phase-check clock to zero so it is ready to restart
    currentTable = getCurrentPhaseTable()
    for i = 1, 9 do
      currentTable[i].source:stop()
    end
    timeUntilPhaseCheck = 0
    currentPhase = 0
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
  
	self.cosmos = newCosmos
  
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
  
  -- crash/bang sounds
  for i = 1, 10 do
    crashTable[i] = love.audio.newSource("resources/sounds/crash " .. i .. ".ogg", "static")
    bangTable[i] = love.audio.newSource("resources/sounds/bang " .. i .. ".ogg", "static")
  end
  
  
end

return api
