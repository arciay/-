local _,ns = ...
ns.ADDUIEVENT("PLAYER_ENTERING_WORLD", function()



end)

--[[掏出武器
  if event == "PLAYER_MOUNT_DISPLAY_CHANGED"   then
        ToggleSheath()
    elseif event == "PLAYER_STARTED_MOVING" then
        if GetSheathState() == 1 then
            ToggleSheath()
        end
    end
]]

local SpellTable = {
	[446534] = true,--测试

    [2006]   = true,  -- 牧师复活术
	[212036]  = true, -- 牧师群活
	
    [7328]   = true,  -- 骑士救赎
	[212056] = true,  -- 骑士群活宽恕
	[391054] = true,  -- 骑士战复代祷
	
	[361227]  = true, -- 奶龙生还
	[361178]  = true, -- 奶龙群体生还

    [50769]  = true,  -- 德鲁伊起死回生
    [20484]  = true,  -- 德鲁伊复生
	[212040] = true,  -- 德鲁伊新生群活

    [2008]   = true,  -- 萨满先祖之魂
    [212048] = true,  -- 萨满群活先祖视界
}

-- 创建施法条框体
local CastBar = CreateFrame("StatusBar", "CustomCastBar", UIParent)
CastBar:SetSize(250, 24)
CastBar:SetPoint("CENTER",0,250)
CastBar:SetStatusBarTexture(130937)
CastBar:SetStatusBarColor(1,0.5,0,1)
CastBar:Hide()

-- 背景
local bg = CastBar:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0.6)

-- 图标
CastBar.icon = CastBar:CreateTexture(nil, "ARTWORK")
CastBar.icon:SetSize(24, 24)
CastBar.icon:SetPoint("RIGHT", CastBar, "LEFT", -4, 0)

-- 法术名文本（内部左侧）
CastBar.spellText = CastBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
CastBar.spellText:SetPoint("LEFT", 4, 0)
CastBar.spellText:SetJustifyH("LEFT")

-- 时间文本（右侧）
CastBar.timeText = CastBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
CastBar.timeText:SetPoint("RIGHT", -4, 0)
CastBar.timeText:SetJustifyH("RIGHT")

-- 施法者名字（左下角）
CastBar.casterNameText = CastBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
CastBar.casterNameText:SetPoint("TOPLEFT", CastBar, "BOTTOMLEFT", 4, -2)
CastBar.casterNameText:SetJustifyH("LEFT")

-- 目标名字（右下角）
CastBar.targetNameText = CastBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
CastBar.targetNameText:SetPoint("TOPRIGHT", CastBar, "BOTTOMRIGHT", -4, -2)
CastBar.targetNameText:SetJustifyH("RIGHT")

-- 定时器
local startTime, endTime = 0, 0

local function OnUpdate(self, elapsed)
    local now = GetTime()
    if now >= endTime then
        CastBar:Hide()
        self:SetScript("OnUpdate", nil)
        return
    end

    local duration = endTime - startTime
    local current = now - startTime
    local remaining = endTime - now

    CastBar:SetMinMaxValues(0, duration)
    CastBar:SetValue(current)
    CastBar.timeText:SetFormattedText("%.1f", remaining)
end


-- 施法开始事件处理
local function OnCastStart(unit)
    if not UnitInParty(unit) and unit ~= "player" then return end

    local spellName, _, spellTexture, start, ends, _, _, _, spellID = UnitCastingInfo(unit)
    if SpellTable[spellName] or SpellTable[spellID] then
        startTime = start / 1000
        endTime = ends / 1000

        CastBar:SetMinMaxValues(0, endTime - startTime)
        CastBar:SetValue(0)
        CastBar.spellText:SetText(spellName)
        CastBar.timeText:SetText("")
        CastBar.icon:SetTexture(spellTexture or "")
		CastBar.casterNameText:SetText(ns.ADDUICOLOR(UnitName(unit),unit))
		local unittarget = unit.."target"
		CastBar.targetNameText:SetText(ns.ADDUICOLOR(UnitName(unittarget),unittarget))

        CastBar:Show()
        CastBar:SetScript("OnUpdate", OnUpdate)
    end
end

-- 注册事件
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_SPELLCAST_START")
f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
f:RegisterEvent("UNIT_SPELLCAST_STOP")
f:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_SPELLCAST_START" then
        OnCastStart(unit)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_STOP" then
        CastBar:Hide()
        CastBar:SetScript("OnUpdate", nil)
    end
end)
