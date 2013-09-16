Diablo3Hub = {
	tAnchor = {},
	tArtwork = {
		["imgCircleBg"] = {10, 9},	-- yellow, green
		["aniCircle"] = {
			"ui/Image/Common/SprintYellowPower1.UITex",
			"ui/Image/Common/SprintGreenPower1.UITex"
		},
		["aniWater"] = {
			"ui/Image/Common/SprintYellowPower2.UITex",
			"ui/Image/Common/SprintGreenPower2.UITex"
		},
		["imgHighLight"] = {18, 17},
	},
	nScale = 1,
}

RegisterCustomData("Diablo3Hub.tAnchor")

local tCustomModeName = {"ÑªÇò", "À¶Çò"}
local szIniFile = "Interface\\Diablo3Hub\\Diablo3Hub.ini"

function Diablo3Hub.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	Diablo3Hub.UpdateAnchor(this)
	for i = 1, 2, 1 do
		if this.index == i then
			UpdateCustomModeWindow(this, tCustomModeName[i])
			Diablo3Hub.Init(this, i)
		end
	end
end

function Diablo3Hub.OnFrameDragEnd()
	this:CorrectPos()
	Diablo3Hub.tAnchor[this.index] = GetFrameAnchor(this)
end

function Diablo3Hub.UpdateAnchor(frame)
	local anchor = Diablo3Hub.tAnchor[frame.index]
	if anchor then
		frame:SetPoint(anchor.s, 0, 0, anchor.r, anchor.x, anchor.y)
	else
		frame:SetAbsPos(500 + (frame.index - 1) * 180, 500)
	end
	frame:CorrectPos()
end


function Diablo3Hub.OnEvent(event)
	if event == "UI_SCALED" or (event == "CUSTOM_DATA_LOADED" and arg0 == "Role")then
		Diablo3Hub.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "PLAYER_STATE_UPDATE" then
		if arg0 == UI_GetClientPlayerID() then
			Diablo3Hub.UpdateHFData(this)
		end
	end
end

function Diablo3Hub.Init(frame, index)
	local handle = frame:Lookup("", "")
	local imgCircleBg = handle:Lookup("Image_CircleBg")
	local hCircle = handle:Lookup("Handle_Circle")
	local imgHighLight = hCircle:Lookup("Image_HighLight")
	local hWater = hCircle:Lookup("Handle_Water")
	local aniCircle = hCircle:Lookup("Animate_Circle")
	local aniWater = hWater:Lookup("Animate_Water")

	local tArtwork = Diablo3Hub.tArtwork

	imgCircleBg:SetFrame(tArtwork["imgCircleBg"][index])
	imgHighLight:SetFrame(tArtwork["imgHighLight"][index])
	aniCircle:SetImagePath(tArtwork["aniCircle"][index])
	aniWater:SetImagePath(tArtwork["aniWater"][index])

	aniCircle:SetGroup(0)
	aniCircle:SetLoopCount(-1)
	aniWater:SetGroup(0)
	aniWater:SetLoopCount(-1)

	aniCircle:SetAnimateType(7)
	aniCircle:SetAlpha(150)

	aniWater:Hide()
	--aniCircle:SetPercentage(0.5)
end

function Diablo3Hub.UpdateHFData(frame)
	local player = GetClientPlayer()
	local dwForceID = player.dwForceID
	if frame.index == 1 then	--ÑªÇò
		if player.nMaxLife > 0 then
			local fHealth = player.nCurrentLife / player.nMaxLife
			local szPer = string.format("%d%%", fHealth * 100)
			local szVal = string.format("%d/%d", player.nCurrentLife, player.nMaxLife)
			Diablo3Hub.UpdateCircle(frame, fHealth, szPer, szVal)
		end
	elseif frame.index == 2 then	--À¶Çò
		if dwForceID == 7 then	--ÌÆÃÅ
			if player.nMaxEnergy > 0 then
				local fPer = player.nCurrentEnergy / player.nMaxEnergy
				local szPer = string.format("%d%%", fPer * 100)
				local szVal = string.format("%d/%d", player.nCurrentEnergy, player.nMaxEnergy)
				Diablo3Hub.UpdateCircle(frame, fPer, szPer, szVal)
			end
		elseif dwForceID == 8 then	--²Ø½£
			if player.nMaxRage > 0 then
				local fRage = player.nCurrentRage / player.nMaxRage
				local szPer = string.format("%d%%", fRage * 100)
				local szVal = string.format("%d/%d", player.nCurrentRage, player.nMaxRage)
				Diablo3Hub.UpdateCircle(frame, fRage, szPer, szVal)
			end
		elseif dwForceID == 10 then	--Ã÷½Ì
			local fPer = math.max(player.nCurrentSunEnergy / player.nMaxSunEnergy, player.nCurrentMoonEnergy / player.nMaxMoonEnergy)
			local szValS = string.format("ÈÕ %d/%d", player.nCurrentSunEnergy / 100, player.nMaxSunEnergy / 100)
			local szValM = string.format("ÔÂ %d/%d", player.nCurrentMoonEnergy / 100, player.nMaxMoonEnergy / 100)
			if player.nSunPowerValue == 1 then
				szValS, fPer = "ÂúÈÕ", 1
			elseif player.nMoonPowerValue == 1 then
				szValM, fPer = "ÂúÔÂ", 1
			end
			Diablo3Hub.UpdateCircle(frame, fPer, szValS, szValM)
		else
			if player.nMaxMana > 0 and player.nMaxMana ~= 1 then
				local fMana = player.nCurrentMana / player.nMaxMana
				local szPer = string.format("%d%%", fMana * 100)
				local szVal = string.format("%d/%d", player.nCurrentMana, player.nMaxMana)
				Diablo3Hub.UpdateCircle(frame, fMana, szPer, szVal)
			end
		end
	end
end

function Diablo3Hub.UpdateCircle(frame, fp, szPer, szVal)
	local handle = frame:Lookup("", "")
	local imgCircleBg = handle:Lookup("Image_CircleBg")
	local hCircle = handle:Lookup("Handle_Circle")
	local imgHighLight = hCircle:Lookup("Image_HighLight")
	local hWater = hCircle:Lookup("Handle_Water")
	local aniCircle = hCircle:Lookup("Animate_Circle")
	local aniWater = hWater:Lookup("Animate_Water")
	local hPer = hCircle:Lookup("Text_Per")
	local hValue = hCircle:Lookup("Text_Value")

	local cW, cH = aniCircle:GetSize()
	local cX, cY = aniCircle:GetRelPos()
	local wW, wH = hWater:GetSize()
	local wX, wY = hWater:GetRelPos()
	local h = wH * fp
	local a = (h + (wY - cY)) / cH
	aniCircle:SetPercentage(a)
	local b = cH * a
	local c = cH - b - (wY - cY)
	local d = aniWater:GetRelPos()
	local e, f = aniWater:GetSize()
	aniWater:SetRelPos(d, c - f / 2)
	hWater:FormatAllItemPos()
	if fp == 1 then
		aniWater:Hide()
	else
		aniWater:Show()
	end
	hPer:SetText(szPer)
	hValue:SetText(szVal)
end

function Diablo3Hub.IsPanelOpened()
	local frame = Station.Lookup("Normal/Diablo3Hub")
	if frame and frame:IsVisible() then
		return true
	end
	return false
end

function Diablo3Hub.OpenPanel()
	local frame = nil
	if not Diablo3Hub.IsPanelOpened() then
		frame = Wnd.OpenWindow("Interface/Diablo3Hub/Diablo3Hub.ini", "Diablo3Hub")
	end
end

function Diablo3Hub.ClosePanel()
	if Diablo3Hub.IsPanelOpened() then
		Wnd.CloseWindow("Diablo3Hub")
	end
end

do
	for index = 1, 2, 1 do
		local frame = Station.Lookup("Normal/Diablo3Hub" .. index)
		if not frame then
			frame = Wnd.OpenWindow(szIniFile, "Diablo3Hub" .. index)
			frame.index = index
			frame.OnFrameDragEnd = Diablo3Hub.OnFrameDragEnd
			frame.OnEvent = Diablo3Hub.OnEvent
			local _this = this
			this = frame
			Diablo3Hub.OnFrameCreate()
			this = _this
		end
	end
end
