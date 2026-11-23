-- ProbeAuras: throwaway probe for the Midnight API (secret values) on retail / Forever.
-- Records, in and out of combat, what C_UnitAuras, C_Spell and C_CooldownViewer return,
-- which fields are secret, and which widget setters accept those values.
-- Results: SavedVariables ProbeAurasDB (WTF/Account/<ACCOUNT>/SavedVariables/ProbeAuras.lua).
-- Never store secret values: only text descriptions ("SECRET:number", "ok", "error: ...").

local ADDON = ...
local MAX_SNAPSHOTS = 12

ProbeAurasDB = ProbeAurasDB or {}

local function p(msg) print("|cff66ccffProbeAuras|r " .. tostring(msg)) end

----------------------------------------------------------------------------------------
-- Value description (secret-safe)
----------------------------------------------------------------------------------------
local hasSecretAPI = type(issecretvalue) == "function"

local function isSecret(v)
  if not hasSecretAPI then return false end
  local ok, r = pcall(issecretvalue, v)
  return ok and r == true
end

-- Returns a plain string. Never compares, indexes or does arithmetic on a secret.
local function describe(v, depth)
  depth = depth or 0
  if isSecret(v) then return "SECRET:" .. type(v) end
  local t = type(v)
  if t == "nil" then return "nil" end
  if t == "number" or t == "boolean" then return t .. ":" .. tostring(v) end
  if t == "string" then return "string:" .. (#v > 60 and v:sub(1, 60) .. "..." or v) end
  if t == "table" then
    if depth >= 2 then return "table:{...}" end
    if type(canaccesstable) == "function" then
      local ok, r = pcall(canaccesstable, v)
      if ok and not r then return "table:INACCESSIBLE" end
    end
    local parts, n = {}, 0
    local ok = pcall(function()
      for k, val in pairs(v) do
        n = n + 1
        if n > 25 then parts[#parts + 1] = "..."; break end
        parts[#parts + 1] = tostring(k) .. "=" .. describe(val, depth + 1)
      end
    end)
    if not ok then return "table:ERROR_ITERATING" end
    return "{" .. table.concat(parts, ", ") .. "}"
  end
  return t
end

-- Turns a table into {field = description}. Used for AuraData, SpellCooldownInfo, etc.
local function describeFields(tbl)
  if type(tbl) ~= "table" or isSecret(tbl) then return describe(tbl) end
  local out = {}
  pcall(function()
    for k, v in pairs(tbl) do out[tostring(k)] = describe(v, 1) end
  end)
  return out
end

local function errText(e)
  e = tostring(e or "?")
  return (e:gsub("^.-:%d+: ", ""))
end

-- Calls fn in pcall; returns "ok" or "error: <msg>".
local function try(fn, ...)
  if type(fn) ~= "function" then return "missing" end
  local ok, e = pcall(fn, ...)
  return ok and "ok" or ("error: " .. errText(e))
end

-- What happens when Lua operates on the value? (only run if it is secret)
local function opTests(v)
  if not isSecret(v) then return nil end
  return {
    compare_eq = try(function() return v == v end),
    compare_lt = try(function() return v < v end),
    bool_test = try(function() if v then return 1 end end),
    concat = try(function() return "x" .. v end),
    tostring = try(function() return tostring(v) end),
    format_s = try(function() return string.format("%s", v) end),
    arith = try(function() return v + 0 end),
    table_key = try(function() local t = {}; t[v] = true end),
  }
end

----------------------------------------------------------------------------------------
-- Widget test frame (visible, so the user can also see what renders)
----------------------------------------------------------------------------------------
local W
local function widgets()
  if W then return W end
  local f = CreateFrame("Frame", "ProbeAurasFrame", UIParent, "BackdropTemplate")
  f:SetSize(260, 120); f:SetPoint("CENTER", 0, 220)
  f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)
  if f.SetBackdrop then
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" }); f:SetBackdropColor(0, 0, 0, 0.6)
  end
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", 4, -4); title:SetText("ProbeAuras widget test (drag me)")

  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetSize(40, 40); icon:SetPoint("TOPLEFT", 6, -22)
  local cd = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
  cd:SetAllPoints(icon)
  local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  fs:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, 0); fs:SetWidth(200); fs:SetJustifyH("LEFT")
  local fs2 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  fs2:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
  local function mkbar(y, r, g, b)
    local bar = CreateFrame("StatusBar", nil, f)
    bar:SetSize(240, 14); bar:SetPoint("BOTTOMLEFT", 8, y)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar"); bar:SetStatusBarColor(r, g, b)
    return bar
  end
  W = { frame = f, icon = icon, cd = cd, fs = fs, fs2 = fs2, bar = mkbar(30, 0.2, 0.8, 0.2), bar2 = mkbar(10, 0.8, 0.6, 0.1) }
  return W
end

local function callMethod(obj, name, ...)
  return try(obj[name], obj, ...)
end

-- Reads a method from a duration object (table or userdata) and calls it.
local function durMethod(dur, m)
  local okm, fn = pcall(function() return dur[m] end)
  if not okm or type(fn) ~= "function" then return "missing" end
  local okc, val = pcall(fn, dur)
  return okc and describe(val) or ("error: " .. errText(val))
end

-- Feeds aura fields to every widget setter and records the result.
local function widgetTestsAura(unit, aura)
  local w = widgets()
  local r = {}
  r["FontString:SetText(name)"] = callMethod(w.fs, "SetText", aura.name)
  r["FontString:SetFormattedText('%s x%s', name, applications)"] =
    callMethod(w.fs, "SetFormattedText", "%s x%s", aura.name, aura.applications)
  r["FontString:SetText(applications)"] = callMethod(w.fs2, "SetText", aura.applications)
  r["Texture:SetTexture(icon)"] = callMethod(w.icon, "SetTexture", aura.icon)
  r["StatusBar:SetMinMaxValues(0,duration)"] = callMethod(w.bar, "SetMinMaxValues", 0, aura.duration)
  r["StatusBar:SetValue(duration)"] = callMethod(w.bar, "SetValue", aura.duration)
  r["Cooldown:SetCooldownFromExpirationTime(exp,dur)"] =
    callMethod(w.cd, "SetCooldownFromExpirationTime", aura.expirationTime, aura.duration)
  r["Cooldown:SetCooldown(exp,dur) (start wrong on purpose)"] =
    callMethod(w.cd, "SetCooldown", aura.expirationTime, aura.duration)
  r["Frame:SetAlphaFromBoolean(isFromPlayerOrPlayerPet)"] =
    callMethod(w.frame, "SetAlphaFromBoolean", aura.isFromPlayerOrPlayerPet, 1, 0.5)
  w.frame:SetAlpha(1)

  -- Duration objects
  local getDur = C_UnitAuras and (C_UnitAuras.GetAuraDuration or C_UnitAuras.GetUnitAuraDuration)
  if getDur and aura.auraInstanceID then
    local ok, dur = pcall(getDur, unit, aura.auraInstanceID)
    r["GetAuraDuration -> "] = ok and describe(dur) or ("error: " .. errText(dur))
    if ok and dur then
      r["Cooldown:SetCooldownFromDurationObject(dur)"] = callMethod(w.cd, "SetCooldownFromDurationObject", dur)
      r["StatusBar:SetTimerDuration(dur)"] = callMethod(w.bar2, "SetTimerDuration", dur)
      for _, m in ipairs({ "GetRemainingDuration", "GetTotalDuration", "GetElapsedDuration", "IsZero" }) do
        r["dur:" .. m .. "()"] = durMethod(dur, m)
      end
    end
  else
    r["GetAuraDuration"] = "missing"
  end
  if C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount and aura.auraInstanceID then
    local ok, s = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, aura.auraInstanceID, 2, 99)
    r["GetAuraApplicationDisplayCount -> "] = ok and describe(s) or ("error: " .. errText(s))
    if ok then r["FontString:SetText(displayCount)"] = callMethod(w.fs2, "SetText", s) end
  end
  return r
end

local function widgetTestsSpell(spellID, cdInfo)
  local w = widgets()
  local r = {}
  if type(cdInfo) == "table" then
    r["Cooldown:SetCooldown(startTime,duration)"] = callMethod(w.cd, "SetCooldown", cdInfo.startTime, cdInfo.duration)
    r["StatusBar:SetMinMaxValues(0,duration)"] = callMethod(w.bar, "SetMinMaxValues", 0, cdInfo.duration)
    r["FontString:SetText(duration)"] = callMethod(w.fs2, "SetText", cdInfo.duration)
    r["Region:SetShown(isActive)"] = callMethod(w.icon, "SetShown", cdInfo.isActive)
    w.icon:Show()
  end
  if C_Spell and C_Spell.GetSpellCooldownDuration then
    local ok, dur = pcall(C_Spell.GetSpellCooldownDuration, spellID)
    r["C_Spell.GetSpellCooldownDuration -> "] = ok and describe(dur) or ("error: " .. errText(dur))
    if ok and dur then
      r["Cooldown:SetCooldownFromDurationObject(dur)"] = callMethod(w.cd, "SetCooldownFromDurationObject", dur)
      r["dur:GetRemainingDuration()"] = durMethod(dur, "GetRemainingDuration")
    end
  end
  if C_Spell and C_Spell.GetSpellTexture then
    local ok, tex = pcall(C_Spell.GetSpellTexture, spellID)
    r["C_Spell.GetSpellTexture -> "] = ok and describe(tex) or ("error: " .. errText(tex))
  end
  return r
end

----------------------------------------------------------------------------------------
-- Collectors
----------------------------------------------------------------------------------------
local function collectAuras(unit, filter, out, doWidgets)
  local list = {}
  out[unit .. "|" .. filter] = list
  if not (C_UnitAuras and C_UnitAuras.GetUnitAuras) then list.error = "C_UnitAuras.GetUnitAuras missing"; return end
  local ok, auras = pcall(C_UnitAuras.GetUnitAuras, unit, filter)
  if not ok then list.error = errText(auras); return end
  list.containerIsSecret = isSecret(auras)
  local count = 0
  local okIter, err = pcall(function()
    for i, aura in ipairs(auras) do
      count = count + 1
      if count > 8 then break end
      local entry = { fields = describeFields(aura) }
      if i == 1 then
        entry.ops_on_spellId = opTests(aura.spellId)
        entry.ops_on_duration = opTests(aura.duration)
        if doWidgets then entry.widgets = widgetTestsAura(unit, aura) end
      end
      list[#list + 1] = entry
    end
  end)
  if not okIter then list.iterError = errText(err) end
  list.count = count
end

local function collectSingleLookups(out, spellID)
  local r = {}
  out.singleLookups = r
  if not C_UnitAuras then return end
  local fn = C_UnitAuras.GetPlayerAuraBySpellID
  if fn then
    local ok, v = pcall(fn, spellID)
    r["GetPlayerAuraBySpellID(" .. spellID .. ")"] = ok and describe(v) or ("error: " .. errText(v))
  end
  fn = C_UnitAuras.GetUnitAuraBySpellID
  if fn then
    local ok, v = pcall(fn, "player", spellID)
    r["GetUnitAuraBySpellID(player," .. spellID .. ")"] = ok and describe(v) or ("error: " .. errText(v))
  end
  if C_UnitAuras.GetAuraDataByIndex then
    local ok, d = pcall(C_UnitAuras.GetAuraDataByIndex, "player", 1, "HELPFUL")
    r["GetAuraDataByIndex(player,1,HELPFUL)"] = ok and describe(d) or ("error: " .. errText(d))
  end
end

-- Cooldown Manager: categories, cooldown infos and the visible viewer frames.
-- Returns the spellIDs from the Essential and Utility categories.
local function collectCooldownViewer(out)
  local ids, cdm = {}, {}
  out.cooldownViewer = cdm
  if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet) then
    cdm.error = "C_CooldownViewer missing"; return ids
  end
  local cats = (Enum and Enum.CooldownViewerCategory) or { Essential = 0, Utility = 1, TrackedBuff = 2, TrackedBar = 3 }
  for catName, catVal in pairs(cats) do
    local ok, set = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, catVal)
    local entry = { value = catVal, set = ok and describe(set) or ("error: " .. errText(set)), items = {} }
    cdm[tostring(catName)] = entry
    if ok and type(set) == "table" and not isSecret(set) then
      for n, cooldownID in ipairs(set) do
        if n > 10 then break end
        local okI, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cooldownID)
        entry.items[#entry.items + 1] = okI and describeFields(info) or ("error: " .. errText(info))
        if okI and type(info) == "table" and info.spellID and not isSecret(info.spellID)
          and (catVal == cats.Essential or catVal == cats.Utility) then
          ids[#ids + 1] = info.spellID
        end
      end
    end
  end

  local frames = {}
  cdm.frames = frames
  for _, fname in ipairs({ "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer" }) do
    local f = _G[fname]
    local fr = { exists = f ~= nil }
    frames[fname] = fr
    if f then
      fr.shown = describe(f:IsShown())
      local items
      if f.GetItemFrames then
        local ok, v = pcall(f.GetItemFrames, f); if ok and type(v) == "table" then items = v end
      end
      if not items then items = { f:GetChildren() } end
      fr.itemCount = #items
      local first = items[1]
      if first then
        local info = {}
        for _, m in ipairs({ "GetCooldownID", "GetSpellID", "GetBaseSpellID", "GetAuraSpellID",
          "GetAuraSpellInstanceID", "IsShown" }) do
          if type(first[m]) == "function" then
            local ok, v = pcall(first[m], first)
            info[m .. "()"] = ok and describe(v) or ("error: " .. errText(v))
          end
        end
        for _, k in ipairs({ "cooldownID", "auraInstanceID", "auraDataUnit", "Icon", "Cooldown", "Bar",
          "Applications", "ChargeCount" }) do
          local v = first[k]
          info["." .. k] = type(v) == "table" and "present(table)" or describe(v)
        end
        fr.firstItem = info
      end
    end
  end
  return ids
end

local function collectSpells(out, ids, doWidgets)
  local r = {}
  out.spells = r
  local seen, n = {}, 0
  for _, id in ipairs(ids) do
    if not seen[id] then
      seen[id] = true
      n = n + 1
      local e = {}
      r[tostring(id)] = e
      if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, id)
        e.name = (ok and type(info) == "table") and describe(info.name) or "n/a"
      end
      if C_Spell and C_Spell.GetSpellCooldown then
        local ok, info = pcall(C_Spell.GetSpellCooldown, id)
        e.GetSpellCooldown = ok and describeFields(info) or ("error: " .. errText(info))
        if ok and type(info) == "table" then
          e.ops_on_duration = opTests(info.duration)
          if doWidgets and n <= 2 then e.widgets = widgetTestsSpell(id, info) end
        end
      end
      if C_Spell and C_Spell.GetSpellCharges then
        local ok, info = pcall(C_Spell.GetSpellCharges, id)
        e.GetSpellCharges = ok and describeFields(info) or ("error: " .. errText(info))
      end
    end
  end
end

local API_NAMES = {
  "issecretvalue", "canaccessvalue", "canaccesstable", "issecrettable", "scrubsecretvalues", "secretwrap",
  "C_UnitAuras.GetUnitAuras", "C_UnitAuras.GetAuraDataByIndex", "C_UnitAuras.GetAuraDataByAuraInstanceID",
  "C_UnitAuras.GetPlayerAuraBySpellID", "C_UnitAuras.GetUnitAuraBySpellID", "C_UnitAuras.GetAuraDuration",
  "C_UnitAuras.GetUnitAuraDuration", "C_UnitAuras.GetAuraApplicationDisplayCount",
  "C_UnitAuras.GetUnitAuraInstanceIDs", "C_Spell.GetSpellCooldown", "C_Spell.GetSpellCooldownDuration",
  "C_Spell.GetSpellCharges", "C_Spell.GetSpellChargeDuration", "C_CooldownViewer.GetCooldownViewerCategorySet",
  "C_CooldownViewer.GetCooldownViewerCooldownInfo", "C_DurationUtil.CreateDuration", "C_CurveUtil.CreateCurve",
  "C_CurveUtil.CreateColorCurve", "C_RestrictedActions.IsInRestrictedState", "C_Secrets.GetSpellAuraSecrecy",
  "C_Secrets.GetSpellCooldownSecrecy",
}

local function environment()
  local version, build, buildDate, toc = GetBuildInfo()
  local env = {
    version = version, build = build, buildDate = buildDate, interface = toc,
    WOW_PROJECT_ID = WOW_PROJECT_ID,
    loadedToc = C_AddOns and C_AddOns.GetAddOnMetadata(ADDON, "X-Probe-Toc") or "?",
    projectConstants = {}, api = {},
  }
  for k, v in pairs(_G) do
    if type(k) == "string" and k:find("^WOW_PROJECT_") and type(v) == "number" then env.projectConstants[k] = v end
  end
  for _, path in ipairs(API_NAMES) do
    local ns, fn = path:match("^(.-)%.(.+)$")
    local v
    if ns then v = _G[ns] and _G[ns][fn] else v = _G[path] end
    env.api[path] = type(v)
  end
  return env
end

----------------------------------------------------------------------------------------
-- Snapshot
----------------------------------------------------------------------------------------
local extraSpells = {}

local function snapshot(label, doWidgets)
  local s = {
    label = label, time = date("%Y-%m-%d %H:%M:%S"),
    inCombat = InCombatLockdown(), affectingCombat = describe(UnitAffectingCombat("player")),
    instance = describe({ IsInInstance() }),
  }
  if C_RestrictedActions and C_RestrictedActions.IsInRestrictedState then
    local ok, v = pcall(C_RestrictedActions.IsInRestrictedState); s.restricted = ok and describe(v) or errText(v)
  end
  local okAll, err = pcall(function()
    collectAuras("player", "HELPFUL", s, doWidgets)
    collectAuras("player", "HARMFUL", s, false)
    if UnitExists("target") then collectAuras("target", "HARMFUL|PLAYER", s, false) end
    local ids = collectCooldownViewer(s)
    ids[#ids + 1] = 61304 -- global cooldown, documented as never secret
    for _, id in ipairs(extraSpells) do ids[#ids + 1] = id end
    collectSingleLookups(s, ids[1])
    collectSpells(s, ids, doWidgets)
  end)
  if not okAll then s.fatal = errText(err) end

  local db = ProbeAurasDB
  db.snapshots = db.snapshots or {}
  table.insert(db.snapshots, s)
  while #db.snapshots > MAX_SNAPSHOTS do table.remove(db.snapshots, 1) end
  db.env = environment()

  local nAuras = s["player|HELPFUL"] and s["player|HELPFUL"].count or 0
  p(("snapshot '%s' (combat=%s, buffs=%s)%s"):format(label, tostring(s.inCombat), tostring(nAuras),
    s.fatal and (" |cffff4444FATAL: " .. s.fatal .. "|r") or ""))
end

----------------------------------------------------------------------------------------
-- Events and slash command
----------------------------------------------------------------------------------------
local auto = true
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    ProbeAurasDB = ProbeAurasDB or {}
    ProbeAurasDB.env = environment()
    local e = ProbeAurasDB.env
    p(("loaded. interface=%s build=%s project=%s toc=%s. /probe help"):format(
      tostring(e.interface), tostring(e.build), tostring(e.WOW_PROJECT_ID), tostring(e.loadedToc)))
  elseif event == "PLAYER_REGEN_DISABLED" and auto then
    C_Timer.After(1.5, function() snapshot("auto-in-combat", true) end)
  elseif event == "PLAYER_REGEN_ENABLED" and auto then
    C_Timer.After(1.0, function() snapshot("auto-after-combat", true) end)
  end
end)

SLASH_PROBEAURAS1 = "/probe"
SlashCmdList.PROBEAURAS = function(msg)
  local cmd, rest = (msg or ""):match("^(%S*)%s*(.-)$")
  cmd = cmd:lower()
  if cmd == "snap" then
    snapshot(rest ~= "" and rest or "manual", true)
  elseif cmd == "add" then
    for id in rest:gmatch("%d+") do extraSpells[#extraSpells + 1] = tonumber(id) end
    p("extra spells: " .. table.concat(extraSpells, ","))
  elseif cmd == "auto" then
    auto = not auto; p("auto snapshots: " .. tostring(auto))
  elseif cmd == "clear" then
    ProbeAurasDB.snapshots = {}; p("snapshots cleared")
  elseif cmd == "hide" then
    if W then W.frame:Hide() end
  elseif cmd == "show" then
    widgets().frame:Show()
  else
    p("/probe snap [label] - snapshot now (also automatic when entering/leaving combat)")
    p("/probe add <spellID ...> - extra spells to check   /probe auto - toggle automatic snapshots")
    p("/probe clear | show | hide.  Then /reload or log out to write SavedVariables.")
  end
end
