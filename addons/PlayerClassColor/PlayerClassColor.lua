-- PlayerClassColor: restyles Blizzard's own player frame as a raid-style box, visual only.
--   * Health bar: flat raid-frame texture tinted with the player's class colour.
--   * Power bar: flat raid-frame texture tinted with the standard power colour.
--   * Both bars are enlarged to fill the player frame (health on top, a thin power strip
--     below), and their clipping masks are made rectangular.
--   * Portrait and frame art are made transparent (never removed), the status glow is
--     hidden, and the addon draws its own dark background and thin border.
--   * Blizzard's threat flash keeps its logic but takes the raid aggro-border shape.
--   * The player name sits inside the health bar, in white, as in raid frames.
-- Everything else (class resources, icons, status text, threat flash) stays Blizzard's.
-- It never reads secret values: the class and the power type are not secret, and
-- colours are constants. It only calls widget methods on Blizzard regions (no fields
-- are written on Blizzard frames). Layout changes happen only out of combat; anything
-- Blizzard changes during combat is corrected on PLAYER_REGEN_ENABLED. In a vehicle,
-- Blizzard's look and layout are restored.
-- /pcc prints a short diagnostic for the in-game test.

local HEALTH_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
local POWER_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"
local WHITE = "Interface\\Buttons\\WHITE8x8"

local INSET = 2          -- gap between the Edit Mode selection box and our box
-- Raid frames' aggro highlight (CompactUnitFrame), used for Blizzard's threat flash.
local HIGHLIGHT_TEXTURE = "Interface\\RaidFrame\\Raid-FrameHighlights"
local AGGRO_COORDS = { 0.00781250, 0.55468750, 0.00781250, 0.27343750 }
local POWER_HEIGHT = 12  -- height of the power strip under the health bar

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

-- The health bar's own container (holds its texts and heal prediction), if it has one.
local function getHealthContainer(health)
  local parent = health and health:GetParent()
  if parent and parent ~= contentMain() and parent ~= PlayerFrame then return parent end
  return nil
end

local function getName()
  return (PlayerFrame and PlayerFrame.name) or PlayerName
end

local function getMasks(health, power)
  local container = getHealthContainer(health)
  local list = {}
  list[#list + 1] = (container and container.HealthBarMask) or (health and health.HealthBarMask)
  list[#list + 1] = power and power.ManaBarMask
  return list
end

-- Decorative regions made transparent. Information (threat flash, icons, level, class
-- resources) is deliberately left alone. The status glow only repeats the combat/rest
-- icons and outlines the old frame shape.
-- The rectangle the user sees in Edit Mode. PlayerFrame itself is larger than its art.
local function getBounds()
  if PlayerFrame and PlayerFrame.Selection then return PlayerFrame.Selection, "Edit Mode selection" end
  return PlayerFrame, "PlayerFrame"
end

-- Blizzard's threat flash (red/orange when mobs attack you). Kept, but reshaped.
local function getFlash()
  local container = PlayerFrame and PlayerFrame.PlayerFrameContainer
  return container and container.FrameFlash
end

-- Combat/rest glow around the old portrait. Blizzard pulses its alpha every frame while
-- auto-attacking, so it is hidden (re-hidden whenever Blizzard shows it) instead of made
-- transparent. The combat swords icon still shows the same state.
local function getStatusGlow()
  local main = contentMain()
  return main and main.StatusTexture
end

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
-- Saving and restoring Blizzard's anchors and masks (kept in our own tables)
----------------------------------------------------------------------------------------
local savedPoints = {}
local savedMasks = {}

local function savePoints(region)
  if not region or savedPoints[region] then return end
  local points = {}
  for i = 1, region:GetNumPoints() do points[i] = { region:GetPoint(i) } end
  savedPoints[region] = points
end

local function restorePoints(region)
  local points = region and savedPoints[region]
  if not points then return end
  region:ClearAllPoints()
  for _, pt in ipairs(points) do region:SetPoint(unpack(pt)) end
end

local function saveMask(mask)
  if not mask or savedMasks[mask] then return end
  local atlas = mask.GetAtlas and mask:GetAtlas()
  local points = {}
  for i = 1, mask:GetNumPoints() do points[i] = { mask:GetPoint(i) } end
  savedMasks[mask] = {
    atlas = atlas, texture = mask:GetTexture(), points = points,
    coords = mask.GetTexCoord and { mask:GetTexCoord() } or nil,
  }
end

local function restoreMask(mask)
  local saved = mask and savedMasks[mask]
  if not saved then return end
  if saved.atlas then mask:SetAtlas(saved.atlas) elseif saved.texture then mask:SetTexture(saved.texture) end
  if not saved.atlas and saved.coords and mask.SetTexCoord then mask:SetTexCoord(unpack(saved.coords)) end
  mask:ClearAllPoints()
  for _, pt in ipairs(saved.points) do mask:SetPoint(unpack(pt)) end
end

----------------------------------------------------------------------------------------
-- Applying the style
----------------------------------------------------------------------------------------
local applying = false   -- guards against our own calls re-triggering the hooks
local pendingLayout = false
local layoutApplied = false  -- our layout is on the bars (so a vehicle must restore it once)
local state = {
  health = "not applied", power = "not applied", box = "not applied",
  name = "not applied", layout = "not applied", glow = "not applied",
}

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

-- Bars fill the player frame: health on top, a thin power strip below. Out of combat only.
local function applyLayout()
  if InCombatLockdown() then pendingLayout = true; state.layout = "deferred (combat)"; return end
  pendingLayout = false
  local health, power = getHealthBar(), getPowerBar()
  if not health then state.layout = "bar not found"; return end
  local container = getHealthContainer(health)
  local masks = getMasks(health, power)

  if inVehicle() then
    -- Restore Blizzard's player layout once, then leave the vehicle art to Blizzard.
    if layoutApplied then
      applying = true
      restorePoints(container); restorePoints(health); restorePoints(power)
      for _, mask in ipairs(masks) do restoreMask(mask) end
      restoreMask(getFlash())
      applying = false
      layoutApplied = false
    end
    state.layout = "restored (vehicle)"
    return
  end

  applying = true

  savePoints(container); savePoints(health); savePoints(power)
  local bounds, boundsName = getBounds()
  local bottom = INSET + (power and (POWER_HEIGHT + 1) or 0)
  local top = container or health
  top:ClearAllPoints()
  top:SetPoint("TOPLEFT", bounds, "TOPLEFT", INSET, -INSET)
  top:SetPoint("BOTTOMRIGHT", bounds, "BOTTOMRIGHT", -INSET, bottom)
  if container then
    health:ClearAllPoints()
    health:SetAllPoints(container)
  end
  if power then
    power:ClearAllPoints()
    power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
    power:SetPoint("BOTTOMRIGHT", bounds, "BOTTOMRIGHT", -INSET, INSET)
  end
  -- Rectangular masks: the bars (and heal prediction / absorbs) are no longer clipped
  -- to the old frame shape.
  local count = 0
  for i, mask in ipairs(masks) do
    saveMask(mask)
    mask:SetTexture(WHITE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:ClearAllPoints()
    mask:SetAllPoints(i == 1 and health or power)
    count = count + 1
  end
  -- Threat flash: same show/hide and colour logic (Blizzard's), raid aggro-border shape.
  local flash = getFlash()
  if flash then
    saveMask(flash)
    flash:SetTexture(HIGHLIGHT_TEXTURE)
    flash:SetTexCoord(unpack(AGGRO_COORDS))
    flash:ClearAllPoints()
    flash:SetPoint("TOPLEFT", health, "TOPLEFT", -1, 1)
    flash:SetPoint("BOTTOMRIGHT", power or health, "BOTTOMRIGHT", 1, -1)
  end
  applying = false
  layoutApplied = true
  state.layout = "applied (" .. boundsName .. ", " .. (container and "container" or "bar only")
    .. ", " .. count .. " masks, flash " .. (flash and "reshaped" or "not found") .. ")"
end

-- Own background + border, drawn below every Blizzard piece of the player frame.
local box
local function getBox()
  if box then return box end
  box = CreateFrame("Frame", nil, PlayerFrame, "BackdropTemplate")
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
  local b = getBox()
  b:ClearAllPoints()
  b:SetPoint("TOPLEFT", health, "TOPLEFT", -1, 1)
  b:SetPoint("BOTTOMRIGHT", power or health, "BOTTOMRIGHT", 1, -1)
  b:SetFrameLevel(PlayerFrame:GetFrameLevel())
  b:Show()
  state.box = "applied, " .. #regions .. " decorations transparent"
end

local function applyGlow()
  local glow = getStatusGlow()
  if not glow then state.glow = "not found"; return end
  if inVehicle() then state.glow = "skipped (vehicle)"; return end
  applying = true
  glow:Hide()
  applying = false
  state.glow = "hidden"
end

local function applyName()
  local name, health = getName(), getHealthBar()
  if not name or not health then state.name = "not found"; return end
  if inVehicle() then state.name = "skipped (vehicle)"; return end
  applying = true
  name:ClearAllPoints()
  name:SetPoint("LEFT", health, "LEFT", 4, 0)
  name:SetJustifyH("LEFT")
  name:SetTextColor(1, 1, 1)
  name:SetShadowColor(0, 0, 0, 1)
  name:SetShadowOffset(1, -1)
  applying = false
  state.name = "applied"
end

local function applyAll()
  applyHealth()
  applyPower()
  applyLayout()
  applyBox()
  applyGlow()
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
  local health, power = getHealthBar(), getPowerBar()
  local barMethods = { "SetStatusBarTexture", "SetStatusBarColor" }
  hookMethods(health, "healthBar", barMethods, applyHealth)
  hookMethods(power, "powerBar", barMethods, applyPower)
  hookMethods(health, "healthLayout", { "SetPoint" }, applyLayout)
  hookMethods(getHealthContainer(health), "containerLayout", { "SetPoint" }, applyLayout)
  hookMethods(power, "powerLayout", { "SetPoint" }, applyLayout)
  hookMethods(getFlash(), "flash", { "SetAtlas", "SetTexture", "SetPoint" }, applyLayout)
  hookMethods(getStatusGlow(), "glow", { "Show", "SetShown" }, applyGlow)
  hookMethods(getName(), "name", { "SetPoint", "SetTextColor" }, applyName)
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
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
f:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then installHooks() end
  if event == "PLAYER_REGEN_ENABLED" then
    if pendingLayout then applyLayout(); applyBox() end
    return
  end
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
  p("layout: " .. state.layout)
  p("box: " .. state.box .. "; name: " .. state.name .. "; glow: " .. state.glow)
  local names = {}
  for k in pairs(hooked) do names[#names + 1] = k end
  table.sort(names)
  p("hooks: " .. (#names > 0 and table.concat(names, ", ") or "none"))
end
