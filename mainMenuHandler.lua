
local self = {}
local api = {}

local menuOptions = {
	"Quit",
	"Restart Game",
	"Skip Task",
	"Fullscreen",
	"Music Volume",
	"SFX Volume",
	"Drive on the Right",
	--"Brutal",
}
local menuTooltip = {
	Brutal = function ()
		return "NOT IMPLEMENTED"
	end,
}
local menuSliders = {
	["Music Volume"] = {
		drawFunc = function ()
			return self.cosmos.GetMusicVolume()/2
		end,
		changeFunc = function (frac)
			self.cosmos.SetMusicVolume(frac*2)
		end,
	},
	["SFX Volume"] = {
		drawFunc = function ()
			return self.cosmos.GetSoundVolume()/2
		end,
		changeFunc = function (frac)
			self.cosmos.SetSoundVolume(frac*2)
		end,
	},
}

if Global.DEV_TOOLS_ENABLED then
	menuOptions[#menuOptions + 1] = "Money++"
	menuOptions[#menuOptions + 1] ="Disable Tutorial"
	menuOptions[#menuOptions + 1] = "God Mode"
end

local function UpdateSliderDrag()
	local slider = self.sliderHeld and menuSliders[self.sliderHeld] and menuSliders[self.sliderHeld]
	if not (slider and slider.extents) then
		return
	end
	local mousePos = self.cosmos.GetWorld().GetMousePositionInterface()
	slider.changeFunc(math.max(0, math.min(1, (mousePos[1] - slider.extents.x) / slider.extents.width)))
	return true
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.MouseReleased(x, y, button)
	self.sliderHeld = false
end

function api.MouseMoved(x, y, dx, dy)
	return UpdateSliderDrag()
end

function api.MousePressed(x, y, button)
	self.sliderHeld = false
	if menuSliders[self.hoveredMenuAction] then
		self.sliderHeld = self.hoveredMenuAction
		UpdateSliderDrag()
	elseif self.hoveredMenuAction == "Menu" then
		api.ToggleMenu()
	elseif self.hoveredMenuAction == "Quit" then
		self.cosmos.QuitGame()
	elseif self.hoveredMenuAction == "Restart Game" then
		self.cosmos.RestartWorld()
	elseif self.hoveredMenuAction == "Fullscreen" then
		self.fullscreen = not self.fullscreen
		love.window.setFullscreen(self.fullscreen)
	elseif self.hoveredMenuAction == "Brutal" then
		self.cosmos.ToggleBrutal()
	elseif self.hoveredMenuAction == "Drive on the Right" then
		menuOptions[5] = "Drive on the Left"
		self.cosmos.ToggleLocalisation()
	elseif self.hoveredMenuAction == "Drive on the Left" then
		menuOptions[5] = "Drive on the Right"
		self.cosmos.ToggleLocalisation()
	elseif self.hoveredMenuAction == "Skip Task" then
		GameHandler.AdvanceLevel(true)
	elseif self.menuOpen then
		self.menuOpen = false
		return true
	end
	return self.menuOpen
end

function api.ToggleMenu()
	self.menuOpen = not self.menuOpen
end

function api.IsMenuOpen()
	return self.menuOpen
end

function api.DrawInterface()
	self.hoveredMenuAction = false
	local mousePos = self.cosmos.GetWorld().GetMousePositionInterface()
	
	local padding = 40
	local sx, sy = Global.WINDOW_X - 135 - padding, 1000
	local overX = Global.WINDOW_X - 350 - padding
	if self.cosmos.GetLocalisation() then
		sx = padding
		overX = padding
	end
	
	self.hoveredMenuAction = InterfaceUtil.DrawButton(sx, sy, 135, 60, mousePos, "Menu", false, false, false, false, 2, 8) or self.hoveredMenuAction
	
	if not self.menuOpen then
		return
	end
	local offset = Global.WINDOW_Y * 0.4 + 80*6
	for i = 1, #menuOptions do
		local slider = menuSliders[menuOptions[i]]
		if slider and not slider.extents then
			slider.extents = {x = overX + 20, width = 350}
		end
		local hovered = InterfaceUtil.DrawButton(overX, offset, 350, 60, mousePos, menuOptions[i], false, false, false, false, 2, 8, false, false, slider and slider.drawFunc())
		if hovered then
			self.hoveredMenuAction = hovered
		end
		offset = offset - 80
	end
end

function api.Initialize(cosmos)
	self = {
		cosmos = cosmos,
		menuOpen = false,
		fullscreen = true,
	}
end

return api
