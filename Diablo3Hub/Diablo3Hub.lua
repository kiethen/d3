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
	bMerge = false,
}

RegisterCustomData("Diablo3Hub.tAnchor")
RegisterCustomData("Diablo3Hub.bMerge")
local tCustomModeName = {"血球", "蓝球", "血蓝球"}

function Diablo3Hub.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	Diablo3Hub.UpdateAnchor(this)
	for i = 1, 3, 1 do
		if this.index and this.index == i then
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
		if frame.index == 3 then
			frame:SetAbsPos(500, 500)
		else
			frame:SetAbsPos(500 + (frame.index - 1) * 180, 500)
		end
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
	if index == 3 then
		local handle = frame:Lookup("", "")
		for k, v in ipairs({"Left", "Right"}) do
			local hCircle = handle:Lookup("Handle_" .. v):Lookup("Handle_" .. v .. "Circle")
			local hWater = hCircle:Lookup("Handle_" .. v .. "Water")
			local aniCircle = hCircle:Lookup("Animate_" .. v .. "Circle")
			local aniWater = hWater:Lookup("Animate_" .. v .. "Water")

			local tArtwork = Diablo3Hub.tArtwork

			aniCircle:SetAnimate(tArtwork["aniCircle"][k], 0, -1)
			aniWater:SetAnimate(tArtwork["aniWater"][k], 0, -1)

			aniCircle:SetAnimateType(7)
			aniCircle:SetAlpha(200)
			aniWater:Hide()
		end
	else
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

		aniCircle:SetAnimate(tArtwork["aniCircle"][index], 0, -1)
		aniWater:SetAnimate(tArtwork["aniWater"][index], 0, -1)

		--[[aniCircle:SetImagePath(tArtwork["aniCircle"][index])
		aniWater:SetImagePath(tArtwork["aniWater"][index])

		aniCircle:SetGroup(0)
		aniCircle:SetLoopCount(-1)
		aniWater:SetGroup(0)
		aniWater:SetLoopCount(-1)]]

		aniCircle:SetAnimateType(7)
		aniCircle:SetAlpha(200)

		aniWater:Hide()
	end
end

function Diablo3Hub.UpdateHFData(frame)
	local player = GetClientPlayer()
	local dwForceID = player.dwForceID
	if frame.index == 1 then	--血球
		if player.nMaxLife > 0 then
			local fHealth = player.nCurrentLife / player.nMaxLife
			local szPer = string.format("%d%%", fHealth * 100)
			local szVal = string.format("%d/%d", player.nCurrentLife, player.nMaxLife)
			Diablo3Hub.UpdateCircle(frame, fHealth, szPer, szVal)
		end
	elseif frame.index == 2 then	--蓝球
		if dwForceID == 7 then	--唐门
			if player.nMaxEnergy > 0 then
				local fPer = player.nCurrentEnergy / player.nMaxEnergy
				local szPer = string.format("%d%%", fPer * 100)
				local szVal = string.format("%d/%d", player.nCurrentEnergy, player.nMaxEnergy)
				Diablo3Hub.UpdateCircle(frame, fPer, szPer, szVal)
			end
		elseif dwForceID == 8 then	--藏剑
			if player.nMaxRage > 0 then
				local fRage = player.nCurrentRage / player.nMaxRage
				local szPer = string.format("%d%%", fRage * 100)
				local szVal = string.format("%d/%d", player.nCurrentRage, player.nMaxRage)
				Diablo3Hub.UpdateCircle(frame, fRage, szPer, szVal)
			end
		elseif dwForceID == 10 then	--明教
			local fPer = math.max(player.nCurrentSunEnergy / player.nMaxSunEnergy, player.nCurrentMoonEnergy / player.nMaxMoonEnergy)
			local szValS = string.format("日 %d/%d", player.nCurrentSunEnergy / 100, player.nMaxSunEnergy / 100)
			local szValM = string.format("月 %d/%d", player.nCurrentMoonEnergy / 100, player.nMaxMoonEnergy / 100)
			if player.nSunPowerValue == 1 then
				szValS, fPer = "满日", 1
			elseif player.nMoonPowerValue == 1 then
				szValM, fPer = "满月", 1
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
	elseif frame.index == 3 then
		if player.nMaxLife > 0 then
			local fHealth = player.nCurrentLife / player.nMaxLife
			local szPer = string.format("%d%%", fHealth * 100)
			local szVal = string.format("%d/%d", player.nCurrentLife, player.nMaxLife)
			Diablo3Hub.UpdateMergeCircle(frame, fHealth, szPer, szVal, "Left")
		end

		if dwForceID == 7 then	--唐门
			if player.nMaxEnergy > 0 then
				local fPer = player.nCurrentEnergy / player.nMaxEnergy
				local szPer = string.format("%d%%", fPer * 100)
				local szVal = string.format("%d/%d", player.nCurrentEnergy, player.nMaxEnergy)
				Diablo3Hub.UpdateMergeCircle(frame, fPer, szPer, szVal, "Right")
			end
		elseif dwForceID == 8 then	--藏剑
			if player.nMaxRage > 0 then
				local fRage = player.nCurrentRage / player.nMaxRage
				local szPer = string.format("%d%%", fRage * 100)
				local szVal = string.format("%d/%d", player.nCurrentRage, player.nMaxRage)
				Diablo3Hub.UpdateMergeCircle(frame, fRage, szPer, szVal, "Right")
			end
		elseif dwForceID == 10 then	--明教
			local fPer = math.max(player.nCurrentSunEnergy / player.nMaxSunEnergy, player.nCurrentMoonEnergy / player.nMaxMoonEnergy)
			local szValS = string.format("日 %d/%d", player.nCurrentSunEnergy / 100, player.nMaxSunEnergy / 100)
			local szValM = string.format("月 %d/%d", player.nCurrentMoonEnergy / 100, player.nMaxMoonEnergy / 100)
			if player.nSunPowerValue == 1 then
				szValS, fPer = "满日", 1
			elseif player.nMoonPowerValue == 1 then
				szValM, fPer = "满月", 1
			end
			Diablo3Hub.UpdateMergeCircle(frame, fPer, szValS, szValM, "Right")
		else
			if player.nMaxMana > 0 and player.nMaxMana ~= 1 then
				local fMana = player.nCurrentMana / player.nMaxMana
				local szPer = string.format("%d%%", fMana * 100)
				local szVal = string.format("%d/%d", player.nCurrentMana, player.nMaxMana)
				Diablo3Hub.UpdateMergeCircle(frame, fMana, szPer, szVal, "Right")
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

function Diablo3Hub.UpdateMergeCircle(frame, fp, szPer, szVal, szPos)
	local handle = frame:Lookup("", "")
	local hCircle = handle:Lookup("Handle_" .. szPos):Lookup("Handle_" .. szPos .. "Circle")
	local hWater = hCircle:Lookup("Handle_" .. szPos .. "Water")
	local aniCircle = hCircle:Lookup("Animate_" .. szPos .. "Circle")
	local aniWater = hWater:Lookup("Animate_" .. szPos .. "Water")

	local cW, cH = aniCircle:GetSize()
	local cX, cY = aniCircle:GetRelPos()
	local wW, wH = hWater:GetSize()
	local wX, wY = hWater:GetRelPos()
	local h = wH * fp
	local a = (h + (wY - cY)) / cH
		--Output(a)
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
end

function Diablo3Hub.GetMenu()
	local menu = {
		szOption = "DIABLO3血槽",
		{
			szOption = "合并血蓝球",
			bCheck = true,
			bChecked = Diablo3Hub.bMerge,
			fnAction = function()
				Diablo3Hub.bMerge = not Diablo3Hub.bMerge
				Diablo3Hub.TogglePanel(Diablo3Hub.bMerge)
			end,
		}
	}
	return menu
end

function Diablo3Hub.TogglePanel(bMerge)
	if not bMerge then
		--打开风格1界面
		for index = 1, 2, 1 do
			local frame = Station.Lookup("Normal/Diablo3Hub" .. index)
			if not frame then
				frame = Wnd.OpenWindow("Interface\\Diablo3Hub\\Diablo3Hub.ini", "Diablo3Hub" .. index)
				frame.index = index
				frame.OnFrameDragEnd = Diablo3Hub.OnFrameDragEnd
				frame.OnEvent = Diablo3Hub.OnEvent
				local _this = this
				this = frame
				Diablo3Hub.OnFrameCreate()
				this = _this
			end
		end
		--关闭风格2界面
		local frame = Station.Lookup("Normal/Diablo3HubMerge")
		if frame then
			Wnd.CloseWindow("Diablo3HubMerge")
		end
	else
		--打开风格2界面
		local frame = Station.Lookup("Normal/Diablo3HubMerge")
		if not frame then
			frame = Wnd.OpenWindow("Interface\\Diablo3Hub\\Diablo3HubMerge.ini", "Diablo3HubMerge")
			frame.index = 3
			frame.OnFrameDragEnd = Diablo3Hub.OnFrameDragEnd
			frame.OnEvent = Diablo3Hub.OnEvent
			local _this = this
			this = frame
			Diablo3Hub.OnFrameCreate()
			this = _this
		end
		--关闭风格1界面
		for index = 1, 2, 1 do
			local frame = Station.Lookup("Normal/Diablo3Hub" .. index)
			if frame then
				Wnd.CloseWindow("Diablo3Hub" .. index)
			end
		end
	end
end

RegisterEvent("LOGIN_GAME", function()
 	local tMenu = {
 		function()
 			return {Diablo3Hub.GetMenu()}
 		end,
 	}
 	Player_AppendAddonMenu(tMenu)
	Diablo3Hub.TogglePanel(false)
end)


