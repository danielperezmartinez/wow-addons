-- PlayerClassColor: restyles Blizzard's own player frame as a raid-style box, visual only.
--   * Health bar: flat raid-frame texture tinted with the player's class colour.
--   * Power bar: flat raid-frame texture tinted with the standard power colour.
--   * Portrait and frame art are made transparent (never hidden or removed), and the
--     addon draws its own dark background and thin border around both bars.
--   * The player name is moved inside the health bar, as in raid frames.
-- Everything else (class resources, icons, status text, threat flash) stays Blizzard's.
-- It never reads secret values: the class and the power type are not secret, and
-- colours are constants. It only calls widget methods on Blizzard regions (no fields
-- are written on Blizzard frames) and restores Blizzard's look while in a vehicle.
-- /pcc prints a short diagnostic for the in-game test.

local HEALTH_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
local POWER_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"
local WHITE = "Interface\\Buttons\\WHITE8x8"

local function p(msg) print("|cff66ccffPlayerClassColor|r " .. tostring(msg)) end

local function isSecret(v)
  return type(issecretvalue) == "function" and issecretvalue(v) == true
end

----------------------------------------------------------------------------------------
-- Locating Blizzard's pieces (names differ between client versions)
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

local function getName()
  return (PlayerFrame and PlayerFrame.name) or PlayerName
end

-- Decorative regions made transparent in the player art. Information (threat flash,
-- rest/combat glow, icons, level, class resources) is deliberately left alone.
local function decorations()
  local list = {}
  local container = PlayerFrame and PlayerFrame.PlayerFrameContainer
  if container then
    list[#list + 1] = container.FrameTexture
    list[#list + 1] = container.AlternatePowerFrameTexture
    list[#list + 1] = container.PlayerPortrait
  end
  local content = PlayerFrame and PlayerFrame.PlayerFrameContent
  local contextual = content and content.PlayerFrameContentContextual
  if contextual then list[#list + 1] = contextual.PlayerPortraitCornerIcon end
  return list
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
local state = { health = "not applied", power = "not applied", box = "not applied", name = "not applied" }

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

-- Own background + border, drawn behind both bars. Created once, never touches Blizzard.
local box
local function getBox(health)
  if box then return box end
  box = CreateFrame("Frame", nil, health:GetParent(), "BackdropTemplate")
  box:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
  box:SetBackdropColor(0.08, 0.08, 0.08, 0.85)
  box:SetBackdropBorderColor(0, 0, 0, 1)
  return box
end

local function applyBox()
  local health, power = getHealthBar(), getPowerBar()
  local regions = decorations()
  if inVehicle() then
    for _, region in ipairs(regions) do region:SetAlpha(1) end
    if box then box:Hide() end
    state.box = "skipped (vehicle)"
    return
  end
  for _, region in ipairs(regions) do region:SetAlpha(0) end
  if not health then state.box = "bar not found"; return end
  local b = getBox(health)
  b:ClearAllPoints()
  b:SetPoint("TOPLEFT", health, "TOPLEFT", -1, 1)
  b:SetPoint("BOTTOMRIGHT", power or health, "BOTTOMRIGHT", 1, -1)
  b:SetFrameLevel(math.max(health:GetFrameLevel() - 1, 0))
  b:Show()
  state.box = "applied, " .. #regions .. " decorations transparent"
end

local function applyName()
  local name, health = getName(), getHealthBar()
  if not name or not health then state.name = "not found"; return end
  if inVehicle() then state.name = "skipped (vehicle)"; return end
  applying = true
  name:ClearAllPoints()
  name:SetPoint("LEFT", health, "LEFT", 4, 0)
  name:SetJustifyH("LEFT")
  applying = false
  state.name = "applied"
end

local function applyAll()
  applyHealth()
  applyPower()
  applyBox()
  applyName()
end

----------------------------------------------------------------------------------------
-- Re-applying when Blizzard restores its own art (post-hooks only, no OnUpdate)
----------------------------------------------------------------------------------------
local hooked = {}

local function hookMethods(obj, key, methods, apply)
  if not obj or hooked[key] then return end
  local function reapply() if not applying then apply() end end
  for _, method in ipairs(methods) do hooksecurefunc(obj, method, reapply) end
  hooked[key] = true
end

local function hookGlobal(name, fn)
  if hooked[name] or type(_G[name]) ~= "function" then return end
  hooksecurefunc(name, fn)
  hooked[name] = true
end

local function installHooks()
  local barMethods = { "SetStatusBarTexture", "SetStatusBarColor" }
  hookMethods(getHealthBar(), "healthBar", barMethods, applyHealth)
  hookMethods(getPowerBar(), "powerBar", barMethods, applyPower)
  hookMethods(getName(), "name", { "SetPoint" }, applyName)
  hookGlobal("PlayerFrame_ToPlayerArt", applyAll)
  hookGlobal("PlayerFrame_ToVehicleArt", applyAll)
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
  p("box: " .. state.box .. "; name: " .. state.name)
  local names = {}
  for k in pairs(hooked) do names[#names + 1] = k end
  table.sort(names)
  p("hooks: " .. (#names > 0 and table.concat(names, ", ") or "none"))
end
