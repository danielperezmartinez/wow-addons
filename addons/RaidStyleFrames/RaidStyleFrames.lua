-- RaidStyleFrames: restyles Blizzard's own unit frames as raid-style boxes, visual only.
-- Frames: player, pet, target and target of target. For each one:
--   * Health and power bars use the flat raid-frame textures and fill the frame's box
--     (health on top, a thin power strip below); their clipping masks become rectangles.
--   * Portrait and frame art are made transparent (never removed); pulsing status glows
--     are hidden; the addon draws its own dark background and thin border.
--   * Blizzard's threat flash keeps its logic but takes the raid aggro-border shape.
--   * The unit name sits inside the health bar, in white.
-- Health colours: player = class; pet = green; target / target of target = class for
-- players, reaction for NPCs, grey if tapped by others. Those unit facts are only used
-- when they are NOT secret. If they are, the official selection colour is handed to the
-- bar as is (only if the bar accepts it), otherwise a plain green is used. Secret values
-- are never compared, indexed or deduced.
-- Everything else (auras, cast bar, class resources, icons, level, status text) stays
-- Blizzard's. Only widget methods are called on Blizzard regions (no fields are written
-- on Blizzard frames). Layout changes happen only out of combat (deferred to
-- PLAYER_REGEN_ENABLED); colours may change in combat. In a vehicle the player frame
-- gets Blizzard's look and layout back.
-- /rsf (or /pcc) prints a short diagnostic for in-game tests; /rsf scan <frame> lists the
-- visible pieces of a frame by name.

local HEALTH_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
local POWER_TEXTURE = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"
local WHITE = "Interface\\Buttons\\WHITE8x8"
local HIGHLIGHT_TEXTURE = "Interface\\RaidFrame\\Raid-FrameHighlights"
local AGGRO_COORDS = { 0.00781250, 0.55468750, 0.00781250, 0.27343750 }

local INSET = 2                       -- gap between the frame's box and ours
local GREEN = { 0, 0.8, 0 }           -- pets, and fallback when no colour can be used
local TAPPED = { 0.5, 0.5, 0.5 }
local REACTION = {                    -- used only if FACTION_BAR_COLORS is missing
  hostile = { 0.9, 0.15, 0.15 }, neutral = { 0.95, 0.85, 0.1 }, friendly = { 0.2, 0.8, 0.2 },
}

local function p(msg) print("|cff66ccffRaidStyleFrames|r " .. tostring(msg)) end

local function isSecret(v)
  return type(issecretvalue) == "function" and issecretvalue(v) == true
end

-- Safe table walk over Blizzard frames (reads only).
local function path(root, ...)
  local t = root
  for i = 1, select("#", ...) do
    if type(t) ~= "table" then return nil end
    t = t[select(i, ...)]
  end
  return t
end

local function first(...)
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    if v then return v end
  end
  return nil
end

local function debugName(region)
  return (region and region.GetDebugName and region:GetDebugName()) or "?"
end

----------------------------------------------------------------------------------------
-- Colours
----------------------------------------------------------------------------------------
local function classColorOf(classFile)
  if C_ClassColor and C_ClassColor.GetClassColor then
    local c = C_ClassColor.GetClassColor(classFile)
    if c then return c.r, c.g, c.b end
  end
  local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
  if c then return c.r, c.g, c.b end
  return nil
end

local function reactionColor(reaction)
  local c = FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]
  if c then return c.r, c.g, c.b end
  if reaction <= 3 then c = REACTION.hostile elseif reaction == 4 then c = REACTION.neutral else c = REACTION.friendly end
  return c[1], c[2], c[3]
end

local function playerColor()
  local _, classFile = UnitClass("player")
  if not isSecret(classFile) and classFile then
    local r, g, b = classColorOf(classFile)
    if r then return r, g, b, "class" end
  end
  return nil, nil, nil, "class secret"
end

local function petColor()
  return GREEN[1], GREEN[2], GREEN[3], "fixed green"
end

-- Returns r, g, b, source. r/g/b may be secret only for source "selection (secret)".
local function unitColor(unit)
  local exists = UnitExists(unit)
  if not isSecret(exists) and not exists then return nil, nil, nil, "no unit" end
  local tapped = UnitIsTapDenied and UnitIsTapDenied(unit)
  if not isSecret(tapped) and tapped then
    return TAPPED[1], TAPPED[2], TAPPED[3], "tapped"
  end
  local isPlayer = UnitIsPlayer(unit)
  if not isSecret(isPlayer) then
    if isPlayer then
      local _, classFile = UnitClass(unit)
      if not isSecret(classFile) and classFile then
        local r, g, b = classColorOf(classFile)
        if r then return r, g, b, "class" end
      end
    else
      local reaction = UnitReaction(unit, "player")
      if not isSecret(reaction) and reaction then
        local r, g, b = reactionColor(reaction)
        return r, g, b, "reaction"
      end
    end
  end
  if UnitSelectionColor then
    local r, g, b = UnitSelectionColor(unit)
    if isSecret(r) or isSecret(g) or isSecret(b) then return r, g, b, "selection (secret)" end
    if r then return r, g, b, "selection" end
  end
  return nil, nil, nil, "none"
end

local function powerColorOf(unit)
  local powerType, powerToken = UnitPowerType(unit)
  if isSecret(powerType) or isSecret(powerToken) or powerType == nil then return nil end
  local info = PowerBarColor and ((powerToken and PowerBarColor[powerToken]) or PowerBarColor[powerType])
  if info and info.r then return info.r, info.g, info.b end
  return nil
end

----------------------------------------------------------------------------------------
-- Frame definitions (names differ between client versions, so every piece has fallbacks)
----------------------------------------------------------------------------------------
local function playerMain() return path(PlayerFrame, "PlayerFrameContent", "PlayerFrameContentMain") end
local function targetMain() return path(TargetFrame, "TargetFrameContent", "TargetFrameContentMain") end
local function totFrame() return first(TargetFrameToT, path(TargetFrame, "totFrame")) end

local skins = {
  {
    key = "player", unit = "player", powerHeight = 12, vehicle = true,
    frame = function() return PlayerFrame end,
    health = function()
      return first(type(PlayerFrame_GetHealthBar) == "function" and PlayerFrame_GetHealthBar() or nil,
        path(playerMain(), "HealthBarsContainer", "HealthBar"), path(PlayerFrame, "healthbar"))
    end,
    power = function()
      return first(type(PlayerFrame_GetManaBar) == "function" and PlayerFrame_GetManaBar() or nil,
        path(playerMain(), "ManaBarArea", "ManaBar"), path(PlayerFrame, "manabar"))
    end,
    name = function() return first(path(PlayerFrame, "name"), PlayerName) end,
    bounds = function() return first(path(PlayerFrame, "Selection"), PlayerFrame) end,
    decorations = function()
      local c = path(PlayerFrame, "PlayerFrameContainer")
      return { path(c, "FrameTexture"), path(c, "AlternatePowerFrameTexture"), path(c, "PlayerPortrait"),
        path(PlayerFrame, "PlayerFrameContent", "PlayerFrameContentContextual", "PlayerPortraitCornerIcon") }
    end,
    flash = function() return path(PlayerFrame, "PlayerFrameContainer", "FrameFlash") end,
    glow = function() return path(playerMain(), "StatusTexture") end,
    color = playerColor,
  },
  {
    key = "pet", unit = "pet", powerHeight = 6,
    frame = function() return PetFrame end,
    health = function() return first(path(PetFrame, "healthbar"), PetFrameHealthBar) end,
    power = function() return first(path(PetFrame, "manabar"), PetFrameManaBar) end,
    name = function() return first(path(PetFrame, "name"), PetName) end,
    bounds = function() return first(path(PetFrame, "Selection"), PetFrame) end,
    decorations = function()
      return { first(path(PetFrame, "portrait"), PetPortrait), first(path(PetFrame, "PetFrameTexture"), PetFrameTexture) }
    end,
    flash = function() return first(path(PetFrame, "Flash"), PetFrameFlash) end,
    glow = function() return first(path(PetFrame, "AttackModeTexture"), PetAttackModeTexture) end,
    color = petColor,
  },
  {
    key = "target", unit = "target", powerHeight = 10,
    frame = function() return TargetFrame end,
    health = function()
      return first(path(TargetFrame, "healthbar"), path(targetMain(), "HealthBarsContainer", "HealthBar"),
        path(targetMain(), "HealthBar"))
    end,
    power = function() return first(path(TargetFrame, "manabar"), path(targetMain(), "ManaBar")) end,
    name = function() return first(path(TargetFrame, "name"), path(targetMain(), "Name")) end,
    bounds = function() return first(path(TargetFrame, "Selection"), TargetFrame) end,
    decorations = function()
      local c = path(TargetFrame, "TargetFrameContainer")
      return { path(c, "FrameTexture"), path(c, "Portrait"), path(TargetFrame, "portrait"),
        path(targetMain(), "ReputationColor") }
    end,
    flash = function() return path(TargetFrame, "TargetFrameContainer", "Flash") end,
    glow = function() return nil end,
    color = function() return unitColor("target") end,
  },
  {
    key = "tot", unit = "targettarget", powerHeight = 5,
    frame = totFrame,
    health = function() return first(path(totFrame(), "healthbar"), path(totFrame(), "HealthBar")) end,
    power = function() return first(path(totFrame(), "manabar"), path(totFrame(), "ManaBar")) end,
    name = function() return first(path(totFrame(), "name"), path(totFrame(), "Name")) end,
    bounds = function() return totFrame() end,
    decorations = function()
      local f = totFrame()
      return { path(f, "FrameTexture"), first(path(f, "portrait"), path(f, "Portrait")) }
    end,
    flash = function() return nil end,
    glow = function() return nil end,
    color = function() return unitColor("targettarget") end,
  },
}

-- The health bar's own container (holds its texts and heal prediction), if it has one.
local function healthContainer(health)
  local parent = health and health:GetParent()
  if parent and debugName(parent):find("HealthBarsContainer", 1, true) then return parent end
  return nil
end

-- Returns the health mask and the power mask (either may be nil).
local function masksOf(health, power)
  local container = healthContainer(health)
  return first(path(container, "HealthBarMask"), path(health, "HealthBarMask"), path(health, "Mask")),
    first(path(power, "ManaBarMask"), path(power, "Mask"))
end

local function compact(list)
  local out = {}
  for i = 1, 8 do if list[i] then out[#out + 1] = list[i] end end
  return out
end

----------------------------------------------------------------------------------------
-- Saving and restoring Blizzard's anchors and textures (kept in our own tables)
----------------------------------------------------------------------------------------
local savedPoints, savedTex = {}, {}

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

local function saveTex(tex)
  if not tex or savedTex[tex] then return end
  local points = {}
  for i = 1, tex:GetNumPoints() do points[i] = { tex:GetPoint(i) } end
  savedTex[tex] = {
    atlas = tex.GetAtlas and tex:GetAtlas(), texture = tex:GetTexture(), points = points,
    coords = tex.GetTexCoord and { tex:GetTexCoord() } or nil,
  }
end

local function restoreTex(tex)
  local saved = tex and savedTex[tex]
  if not saved then return end
  if saved.atlas then tex:SetAtlas(saved.atlas) elseif saved.texture then tex:SetTexture(saved.texture) end
  if not saved.atlas and saved.coords and tex.SetTexCoord then tex:SetTexCoord(unpack(saved.coords)) end
  tex:ClearAllPoints()
  for _, pt in ipairs(saved.points) do tex:SetPoint(unpack(pt)) end
end

----------------------------------------------------------------------------------------
-- Applying the style
----------------------------------------------------------------------------------------
local applying = false   -- guards against our own calls re-triggering the hooks
local rt = {}            -- runtime state per skin
for _, skin in ipairs(skins) do
  rt[skin] = { state = { health = "-", power = "-", layout = "-", box = "-", name = "-", glow = "-" } }
end

local function inVehicle(skin)
  return skin.vehicle and type(UnitHasVehiclePlayerFrameUI) == "function"
    and UnitHasVehiclePlayerFrameUI("player")
end

local function applyHealth(skin)
  local s, bar = rt[skin].state, skin.health()
  if not bar then s.health = "not found"; return end
  if inVehicle(skin) then s.health = "vehicle"; return end
  local r, g, b, source = skin.color()
  applying = true
  bar:SetStatusBarTexture(HEALTH_TEXTURE)
  -- r may be secret (official selection colour): never compared, only handed to the bar.
  local hasColor = isSecret(r) or r ~= nil
  local ok = hasColor and pcall(bar.SetStatusBarColor, bar, r, g, b)
  if not ok then
    bar:SetStatusBarColor(GREEN[1], GREEN[2], GREEN[3])
    source = source .. " -> green"
  end
  applying = false
  s.health = source
end

local function applyPower(skin)
  local s, bar = rt[skin].state, skin.power()
  if not bar then s.power = "not found"; return end
  if inVehicle(skin) then s.power = "vehicle"; return end
  local r, g, b = powerColorOf(skin.unit)
  if not r then s.power = "no colour (left as is)"; return end
  applying = true
  bar:SetStatusBarTexture(POWER_TEXTURE)
  bar:SetStatusBarColor(r, g, b)
  applying = false
  s.power = "ok"
end

-- Bars fill the frame's box: health on top, a thin power strip below. Out of combat only.
local function applyLayout(skin)
  local r = rt[skin]
  if InCombatLockdown() then r.pending = true; r.state.layout = "deferred"; return end
  r.pending = false
  local health, power, bounds = skin.health(), skin.power(), skin.bounds()
  if not health or not bounds then r.state.layout = "not found"; return end
  local container = healthContainer(health)
  local healthMask, powerMask = masksOf(health, power)
  local masks = compact({ healthMask, powerMask })
  local flash = skin.flash()

  if inVehicle(skin) then
    -- Restore Blizzard's layout once, then leave the vehicle art to Blizzard.
    if r.layoutApplied then
      applying = true
      restorePoints(container); restorePoints(health); restorePoints(power)
      for _, mask in ipairs(masks) do restoreTex(mask) end
      restoreTex(flash)
      applying = false
      r.layoutApplied = false
    end
    r.state.layout = "vehicle"
    return
  end

  applying = true
  savePoints(container); savePoints(health); savePoints(power)
  local bottom = INSET + (power and (skin.powerHeight + 1) or 0)
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
  -- Rectangular masks: bars, heal prediction and absorbs are no longer clipped to the
  -- old frame shape.
  for _, pair in ipairs({ { healthMask, health }, { powerMask, power } }) do
    local mask, bar = pair[1], pair[2]
    if mask and bar then
      saveTex(mask)
      mask:SetTexture(WHITE, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
      mask:ClearAllPoints()
      mask:SetAllPoints(bar)
    end
  end
  if flash then
    saveTex(flash)
    flash:SetTexture(HIGHLIGHT_TEXTURE)
    flash:SetTexCoord(unpack(AGGRO_COORDS))
    flash:ClearAllPoints()
    flash:SetPoint("TOPLEFT", health, "TOPLEFT", -1, 1)
    flash:SetPoint("BOTTOMRIGHT", power or health, "BOTTOMRIGHT", 1, -1)
  end
  applying = false
  r.layoutApplied = true
  r.state.layout = (debugName(bounds):find("Selection", 1, true) and "edit box" or "frame")
    .. ", " .. (container and "container" or "bar") .. ", " .. #masks .. " masks, flash " .. (flash and "ok" or "-")
end

local function applyBox(skin)
  local r = rt[skin]
  local frame, health, power = skin.frame(), skin.health(), skin.power()
  local regions = compact(skin.decorations())
  if inVehicle(skin) then
    for _, region in ipairs(regions) do region:SetAlpha(1) end
    if r.box then r.box:Hide() end
    r.state.box = "vehicle"
    return
  end
  for _, region in ipairs(regions) do region:SetAlpha(0) end
  if not frame or not health then r.state.box = "not found"; return end
  if not r.box then
    r.box = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    r.box:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
    r.box:SetBackdropColor(0.08, 0.08, 0.08, 0.85)
    r.box:SetBackdropBorderColor(0, 0, 0, 1)
  end
  r.box:ClearAllPoints()
  r.box:SetPoint("TOPLEFT", health, "TOPLEFT", -1, 1)
  r.box:SetPoint("BOTTOMRIGHT", power or health, "BOTTOMRIGHT", 1, -1)
  r.box:SetFrameLevel(frame:GetFrameLevel())
  r.box:Show()
  r.state.box = #regions .. " art hidden"
end

local function applyGlow(skin)
  local s, glow = rt[skin].state, skin.glow()
  if not glow then s.glow = "-"; return end
  if inVehicle(skin) then s.glow = "vehicle"; return end
  applying = true
  glow:Hide()
  applying = false
  s.glow = "hidden"
end

local function applyName(skin)
  local s, name, health = rt[skin].state, skin.name(), skin.health()
  if not name or not health then s.name = "not found"; return end
  if inVehicle(skin) then s.name = "vehicle"; return end
  applying = true
  name:ClearAllPoints()
  name:SetPoint("LEFT", health, "LEFT", 4, 0)
  name:SetPoint("RIGHT", health, "RIGHT", -4, 0)
  name:SetJustifyH("LEFT")
  name:SetTextColor(1, 1, 1)
  name:SetShadowColor(0, 0, 0, 1)
  name:SetShadowOffset(1, -1)
  applying = false
  s.name = "ok"
end

local function applySkin(skin)
  applyHealth(skin)
  applyPower(skin)
  applyLayout(skin)
  applyBox(skin)
  applyGlow(skin)
  applyName(skin)
end

local function applyAll()
  for _, skin in ipairs(skins) do applySkin(skin) end
end

local function skinOf(key)
  for _, skin in ipairs(skins) do if skin.key == key then return skin end end
end

local function skinForFrame(frame)
  for _, skin in ipairs(skins) do if skin.frame() == frame then return skin end end
end

local function skinForPowerBar(bar)
  for _, skin in ipairs(skins) do if skin.power() == bar then return skin end end
end

----------------------------------------------------------------------------------------
-- Re-applying when Blizzard restores its own art (post-hooks only, no OnUpdate)
----------------------------------------------------------------------------------------
local hooked, hookCount = {}, 0

local function hookMethods(obj, methods, apply)
  if not obj then return end
  for _, method in ipairs(methods) do
    local id = tostring(obj) .. method
    if not hooked[id] and type(obj[method]) == "function" then
      hooksecurefunc(obj, method, function() if not applying then apply() end end)
      hooked[id] = true
      hookCount = hookCount + 1
    end
  end
end

local function hookGlobal(name, fn)
  if hooked[name] or type(_G[name]) ~= "function" then return end
  hooksecurefunc(name, fn)
  hooked[name] = true
  hookCount = hookCount + 1
end

local function installHooks()
  for _, skin in ipairs(skins) do
    local health, power = skin.health(), skin.power()
    local barMethods = { "SetStatusBarTexture", "SetStatusBarColor" }
    hookMethods(health, barMethods, function() applyHealth(skin) end)
    hookMethods(power, barMethods, function() applyPower(skin) end)
    local layout = function() applyLayout(skin) end
    hookMethods(health, { "SetPoint" }, layout)
    hookMethods(healthContainer(health), { "SetPoint" }, layout)
    hookMethods(power, { "SetPoint" }, layout)
    hookMethods(skin.flash(), { "SetAtlas", "SetTexture", "SetPoint" }, layout)
    hookMethods(skin.glow(), { "Show", "SetShown" }, function() applyGlow(skin) end)
    hookMethods(skin.name(), { "SetPoint", "SetTextColor" }, function() applyName(skin) end)
  end
  local player = skinOf("player")
  hookGlobal("PlayerFrame_ToPlayerArt", function() applySkin(player) end)
  hookGlobal("PlayerFrame_ToVehicleArt", function() applySkin(player) end)
  hookGlobal("PlayerFrame_UpdateArt", function() applySkin(player) end)
  hookGlobal("UnitFrameManaBar_UpdateType", function(bar)
    local skin = skinForPowerBar(bar)
    if skin then applyPower(skin) end
  end)
  hookGlobal("UnitFrame_Update", function(frame)
    local skin = skinForFrame(frame)
    if skin then applySkin(skin) end
  end)
  local target = skinOf("target")
  hookMethods(TargetFrame, { "CheckClassification" }, function() applySkin(target) end)
end

----------------------------------------------------------------------------------------
-- Events
----------------------------------------------------------------------------------------
local function recolorTargets()
  applyHealth(skinOf("target")); applyPower(skinOf("target"))
  applyHealth(skinOf("tot")); applyPower(skinOf("tot"))
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterUnitEvent("UNIT_TARGET", "target")
f:RegisterUnitEvent("UNIT_FACTION", "target", "targettarget")
f:RegisterUnitEvent("UNIT_PET", "player")
f:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player", "pet", "target")
f:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    installHooks()
    applyAll()
  elseif event == "PLAYER_REGEN_ENABLED" then
    for _, skin in ipairs(skins) do
      if rt[skin].pending then applyLayout(skin); applyBox(skin) end
    end
  elseif event == "PLAYER_TARGET_CHANGED" or event == "UNIT_TARGET" or event == "UNIT_FACTION" then
    recolorTargets()
  elseif event == "UNIT_PET" then
    applySkin(skinOf("pet"))
  elseif event == "UNIT_DISPLAYPOWER" then
    for _, skin in ipairs(skins) do applyPower(skin) end
  else
    applyAll()
  end
end)

----------------------------------------------------------------------------------------
-- /rsf diagnostic (also /pcc, the old command)
----------------------------------------------------------------------------------------
-- Diagnostics never measure a bar's fill: its size follows the (secret) value, and
-- deducing secrets from widget sizes is forbidden (docs/normas.md, section 3).
local function size(region)
  if not region then return "-" end
  local w, h = region:GetWidth(), region:GetHeight()
  if isSecret(w) or isSecret(h) then return "secret" end
  return math.floor((w or 0) + 0.5) .. "x" .. math.floor((h or 0) + 0.5)
end

-- Frame sizes of the bars (not their fill), to spot a bar that did not follow the layout.
local function sizeInfo(skin)
  local health, power, name = skin.health(), skin.power(), skin.name()
  local text = "hp " .. size(health) .. "; mp " .. size(power) .. "; name " .. size(name)
  if skin.key == "pet" then
    text = text .. "; same bar " .. tostring(path(PetFrame, "healthbar") == PetFrameHealthBar)
  end
  return text
end

-- /rsf scan <frame>: lists the visible textures and status bars of a frame by name and
-- atlas, to find the right pieces. Reads names only; no sizes, values or colours.
local MAX_SCAN_LINES = 30

local function shortName(region, root)
  local name = debugName(region)
  local rootName = debugName(root)
  if name:sub(1, #rootName) == rootName then name = name:sub(#rootName + 2) end
  return name ~= "" and name or "?"
end

local function scan(skin)
  local root = skin.frame()
  if not root then p("scan " .. skin.key .. ": frame not found"); return end
  local own = rt[skin].box
  local lines, seen = 0, {}
  local function describe(region)
    local kind = region:GetObjectType()
    local extra = ""
    if kind == "Texture" then
      local atlas = region.GetAtlas and region:GetAtlas()
      if atlas and not isSecret(atlas) then extra = " atlas=" .. atlas end
    end
    return shortName(region, root) .. " [" .. kind .. "]" .. extra
  end
  local function visit(frame, depth)
    if not frame or seen[frame] or frame == own or depth > 8 or lines >= MAX_SCAN_LINES then return end
    seen[frame] = true
    if frame:GetObjectType() == "StatusBar" and frame:IsVisible() then
      lines = lines + 1
      p("  " .. describe(frame))
    end
    for _, region in ipairs({ frame:GetRegions() }) do
      if lines >= MAX_SCAN_LINES then break end
      local alpha = region:GetAlpha()
      if region:GetObjectType() == "Texture" and region:IsVisible() and (isSecret(alpha) or alpha > 0) then
        lines = lines + 1
        p("  " .. describe(region))
      end
    end
    for _, child in ipairs({ frame:GetChildren() }) do visit(child, depth + 1) end
  end
  p("scan " .. skin.key .. " (visible pieces, max " .. MAX_SCAN_LINES .. "):")
  visit(root, 0)
end

SLASH_RAIDSTYLEFRAMES1 = "/rsf"
SLASH_RAIDSTYLEFRAMES2 = "/pcc"
SlashCmdList.RAIDSTYLEFRAMES = function(msg)
  local cmd, arg = (msg or ""):match("^(%S*)%s*(%S*)")
  if cmd == "scan" then
    local skin = skinOf(arg ~= "" and arg or "target")
    if skin then scan(skin) else p("usage: /rsf scan player|pet|target|tot") end
    return
  end
  applyAll()
  for _, skin in ipairs(skins) do
    local s = rt[skin].state
    p(skin.key .. ": colour " .. s.health .. "; power " .. s.power .. "; name " .. s.name)
    p("   layout " .. s.layout .. "; box " .. s.box .. "; glow " .. s.glow)
    p("   size " .. sizeInfo(skin))
  end
  p("hooks: " .. hookCount .. (InCombatLockdown() and " (in combat)" or ""))
end
