-- PlayerClassColor: restyles Blizzard's own player frame, visual only.
--   * Health bar: flat raid-frame texture tinted with the player's class colour.
--   * Power bar: flat raid-frame texture tinted with the standard power colour.
-- It never reads secret values: the class and the power type are not secret, and
-- colours are constants. It only calls widget methods on the bars (no fields are
-- written on Blizzard frames) and leaves the vehicle art untouched.
-- /pcc prints a short diagnostic for the in-game test.

local HEALTH_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
local POWER_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"

local function p(msg) print("|cff66ccffPlayerClassColor|r " .. tostring(msg)) end

local function isSecret(v)
  return type(issecretvalue) == "function" and issecretvalue(v) == true
end

----------------------------------------------------------------------------------------
-- Locating Blizzard's bars (names differ between client versions)
----------------------------------------------------------------------------------------
local function contentMain()
  local content = PlayerFrame and PlayerFrame.PlayerFrameContent
  return content and content.PlayerFrameContentMain
end

local function getHealthBar()
  if type(PlayerFrame_GetHealthBar) == "function" then
    local bar = PlayerFrame_GetHealthBar()
    if bar then return bar, "PlayerFrame_GetHealthBar" end
  end
  local main = contentMain()
  if main and main.HealthBarsContainer and main.HealthBarsContainer.HealthBar then
    return main.HealthBarsContainer.HealthBar, "HealthBarsContainer.HealthBar"
  end
  if main and main.HealthBar then return main.HealthBar, "PlayerFrameContentMain.HealthBar" end
  return nil, "not found"
end

local function getPowerBar()
  if type(PlayerFrame_GetManaBar) == "function" then
    local bar = PlayerFrame_GetManaBar()
    if bar then return bar, "PlayerFrame_GetManaBar" end
  end
  local main = contentMain()
  if main and main.ManaBarArea and main.ManaBarArea.ManaBar then
    return main.ManaBarArea.ManaBar, "ManaBarArea.ManaBar"
  end
  return nil, "not found"
end

----------------------------------------------------------------------------------------
-- Colours
----------------------------------------------------------------------------------------
local function classColor()
  local _, classFile = UnitClass("player")
  if not classFile or isSecret(classFile) then return nil end
  if C_ClassColor and C_ClassColor.GetClassColor then
    local c = C_ClassColor.GetClassColor(classFile)
    if c then return c.r, c.g, c.b end
  end
  local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
  if c then return c.r, c.g, c.b end
  return nil
end

local function powerColor()
  local powerType, powerToken = UnitPowerType("player")
  if isSecret(powerType) or isSecret(powerToken) then return nil end
  local info = PowerBarColor and ((powerToken and PowerBarColor[powerToken]) or PowerBarColor[powerType])
  if info and info.r then return info.r, info.g, info.b end
  return 0, 0, 1
end

----------------------------------------------------------------------------------------
-- Applying the style
----------------------------------------------------------------------------------------
local applying = false   -- guards against our own calls re-triggering the hooks
local state = { health = "not applied", power = "not applied" }

local function inVehicle()
  return type(UnitHasVehiclePlayerFrameUI) == "function" and UnitHasVehiclePlayerFrameUI("player")
end

local function styleBar(bar, texture, r, g, b)
  applying = true
  bar:SetStatusBarTexture(texture)
  bar:SetStatusBarColor(r, g, b)
  applying = false
end

local function applyHealth()
  local bar = getHealthBar()
  if not bar then state.health = "bar not found"; return end
  if inVehicle() then state.health = "skipped (vehicle)"; return end
  local r, g, b = classColor()
  if not r then state.health = "no class colour"; return end
  styleBar(bar, HEALTH_TEXTURE, r, g, b)
  state.health = "applied"
end

local function applyPower()
  local bar = getPowerBar()
  if not bar then state.power = "bar not found"; return end
  if inVehicle() then state.power = "skipped (vehicle)"; return end
  local r, g, b = powerColor()
  if not r then state.power = "power type secret"; return end
  styleBar(bar, POWER_TEXTURE, r, g, b)
  state.power = "applied"
end

local function applyAll()
  applyHealth()
  applyPower()
end

----------------------------------------------------------------------------------------
-- Re-applying when Blizzard restores its own art (post-hooks only, no OnUpdate)
----------------------------------------------------------------------------------------
local hooked = {}

local function hookBar(bar, key, apply)
  if not bar or hooked[key] then return end
  local function reapply() if not applying then apply() end end
  hooksecurefunc(bar, "SetStatusBarTexture", reapply)
  hooksecurefunc(bar, "SetStatusBarColor", reapply)
  hooked[key] = true
end

local function hookGlobal(name, fn)
  if hooked[name] or type(_G[name]) ~= "function" then return end
  hooksecurefunc(name, fn)
  hooked[name] = true
end

local function installHooks()
  hookBar(getHealthBar(), "healthBar", applyHealth)
  hookBar(getPowerBar(), "powerBar", applyPower)
  hookGlobal("PlayerFrame_ToPlayerArt", applyAll)
  hookGlobal("PlayerFrame_UpdateArt", applyAll)
  hookGlobal("UnitFrameManaBar_UpdateType", function(bar)
    if bar == getPowerBar() then applyPower() end
  end)
end

----------------------------------------------------------------------------------------
-- Events
----------------------------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
f:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then installHooks() end
  applyAll()
end)

----------------------------------------------------------------------------------------
-- /pcc diagnostic
----------------------------------------------------------------------------------------
SLASH_PLAYERCLASSCOLOR1 = "/pcc"
SlashCmdList.PLAYERCLASSCOLOR = function()
  applyAll()
  local _, healthPath = getHealthBar()
  local _, powerPath = getPowerBar()
  p("health bar: " .. healthPath .. " -> " .. state.health)
  p("power bar: " .. powerPath .. " -> " .. state.power)
  local names = {}
  for k in pairs(hooked) do names[#names + 1] = k end
  table.sort(names)
  p("hooks: " .. (#names > 0 and table.concat(names, ", ") or "none"))
end
