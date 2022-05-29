local ScreenScale = ScreenScale
local math = math
local LocalPlayer = LocalPlayer
local string = string
local Material = Material
local surface = surface
local render = render
local ScrW = ScrW
local ScrH = ScrH
local draw = draw
local MSD = MSD
local pairs = pairs
local FrameTime = FrameTime
local isfunction = isfunction
local IsValid = IsValid
local Color = Color
local table = table
local CurTime = CurTime
local ipairs = ipairs
local notification = notification
local hook = hook
local GetConVar = GetConVar
local language = language

MSD.HUD = MSD.HUD or {}

local HUD = MSD.HUD

HUD.IconSize = ScreenScale(12) -- Scales hud to your screen. You can set a fixed value if you want (not recomended), just replace the ScreenScale(12) with 32 and it will set icons to a fixed value.
HUD.FondSize = math.Clamp(math.Round(HUD.IconSize / 4 + 12), 12, 52) -- Fond size for MSD can varry from 12 to 52.

HUD.BarSize = 0
HUD.WepBarSize = 0
HUD.Bars = {}

function HUD.AddAnimatedBar(tbl)
	table.insert(HUD.Bars, tbl)
end

function HUD.AddTextBar(tbl)
	tbl.type = "text"
	table.insert(HUD.Bars, tbl)
end

--[[---------- HOW TO ADD CUSTOM BARS ------------
	Animated Bars

	HUD.AddAnimatedBar({  -- Order of adding will effect order of bars
		check = function() return true end, -- add it only if you need to check for something, if false or nil is returned by this function will hide the bar element
		icon_bg = Material("path/to/your/icon.png", "smooth"), -- Background icon, you will see it if % is lower than 100
		icon = Material("path/to/your/icon.png", "smooth"), -- Main icon
		max_icon = Material("path/to/your/icon.png", "smooth"), -- This icon will be shown if % is higher that 100
		no_icon = Material("path/to/your/icon.png", "smooth"), -- This icon will be shown if % is 0 or less. If set to nil or removed, will hide the bar element if value is 0
		smooth = 0, -- Add to smooth the transaction from 0 to 100, If set to false, nil or removed, will be ignored
		value = function() -- value function, must return a value from 0 to 1 (representing %)
			return LocalPlayer():Health() / LocalPlayer():GetMaxHealth() -- example, current player health divided to maximum player health
		end
	})

	Text Bars
	HUD.AddTextBar({ -- Order of adding will effect order of bars
		check = function() return true end, -- add it only if you need to check for something, if false or nil is returned by this function will hide the bar element
		icon = Material("path/to/your/icon.png", "smooth"), -- Icon material
		text = function() -- if text set to false, nil or removed will only show the icon
			return "My text goes here :)" -- Retur a sting of  your custom text
		end
	})
]]------------------------------------------------

HUD.AddAnimatedBar({
	icon_bg = MSD.Icons48.heart_outline,
	icon = MSD.Icons48.heart,
	max_icon = MSD.Icons48.heart_flash,
	no_icon = MSD.Icons48.heart_broken,
	smooth = 0,
	value = function()
		return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
	end
})

HUD.AddAnimatedBar({
	icon_bg = MSD.Icons48.armor_outline,
	icon = MSD.Icons48.armor,
	max_icon = MSD.Icons48.armor_flash,
	--no_icon = MSD.Icons48.armor_broken,
	smooth = 0,
	value = function()
		return LocalPlayer():Armor() / LocalPlayer():GetMaxArmor()
	end
})

HUD.AddAnimatedBar({
	check = function()
		if DarkRP and LocalPlayer():getDarkRPVar("Energy") then
			return true
		end
		return false
	end,
	icon_bg = MSD.Icons48.food_outline,
	icon = MSD.Icons48.food,
	max_icon = MSD.Icons48.food,
	no_icon = MSD.Icons48.food_off,
	no_text = false,
	smooth = 0,
	value = function()
		return LocalPlayer():getDarkRPVar("Energy") / 100
	end
})

HUD.AddTextBar({
	check = function()
		return DarkRP and true or false
	end,
	icon = MSD.Icons48.briefcase,
	text = function()
		return LocalPlayer():getDarkRPVar("job") or ""
	end
})

HUD.AddTextBar({
	check = function()
		return DarkRP and true or false
	end,
	icon = MSD.Icons48.cash,
	text = function()
		local money = LocalPlayer():getDarkRPVar("money") or 0
		local sal = LocalPlayer():getDarkRPVar("salary") or 0
		return string.Comma(money) .. "$" .. (sal > 0 and " + " .. string.Comma(sal) .. "$" or "")
	end
})

HUD.AddTextBar({
	check = function()
		if DarkRP and LocalPlayer():getDarkRPVar("HasGunlicense") then
			return true
		end
		return false
	end,
	icon = MSD.Icons48.file_document,
})

HUD.AddTextBar({
	check = function()
		if MRS and MRS.GetNWdata(LocalPlayer(), "Group") then
			return true
		end
		return false
	end,
	icon = function()
		local group = MRS.GetNWdata(LocalPlayer(), "Group")
		local rank = MRS.GetNWdata(LocalPlayer(), "Rank")
		if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then return MSD.Icons48.cansel end
		if rank > 0 then
			rank = MRS.Ranks[group].ranks[rank]
		end
		if rank ~= 0 and rank.icon[1] and rank.icon[1] ~= "" then
			return MRS.GetRankIcon(rank.icon)
		end
		return MSD.Icons48.file_document
	end,
	text = function()
		local group = MRS.GetNWdata(LocalPlayer(), "Group")
		local rank = MRS.GetNWdata(LocalPlayer(), "Rank")
		if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then return "None" end
		return MRS.Ranks[group].ranks[rank].name
	end
})

local blur = Material("pp/blurscreen")

function HUD.Blur(x, y, w, h)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 4) * 4)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		render.SetScissorRect(x, y, x + w, y + h, true)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function HUD.DrawBG(x, y, w, h, alpha)
	alpha = alpha or 1
	if MSD.Config.Blur then
		HUD.Blur(x, y, w, h)
		draw.RoundedBox(MSD.Config.Rounded, x, y, w, h, MSD.ColorAlpha(color_black, (250 - MSD.Config.BgrColor.r) * alpha))
	else
		local cl = MSD.Config.BgrColor
		if MSD.Config.BgrColor.r > 70 then
			cl = MSD.ColorAlpha(color_black, 255 - MSD.Config.BgrColor.r)
		end
		draw.RoundedBox(MSD.Config.Rounded, x, y, w, h, MSD.ColorAlpha(cl, cl.a * alpha))
	end
end

function HUD.DrawBar(x, y)

	local b = math.max(MSD.Config.Rounded, 5) + 10
	local iy = y + 5

	HUD.DrawBG(x, y, HUD.BarSize, HUD.IconSize + 10)
	draw.RoundedBoxEx(MSD.Config.Rounded, x, y, math.max(MSD.Config.Rounded, 5), HUD.IconSize + 10, MSD.Config.MainColor["p"], true, false, true, false)

	if MSD.Config.HUDShowIcon then
		MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, MSD.ImgLib.GetMaterial(MSD.Config.HUDIcon), color_white)
		b = b + HUD.IconSize + 5
		if MSD.Config.HUDText and MSD.Config.HUDText ~= "" then
			b = b + 5 + draw.SimpleText( MSD.Config.HUDText, "MSDFont." .. HUD.FondSize, x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1)
		end
	end

	for id, e in pairs(HUD.Bars) do
		if e.check and not e.check() then continue end

		if e.type == "text" then
			MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, isfunction(e.icon) and e.icon() or e.icon, color_white)
			b = b + HUD.IconSize + 5
			if e.text then
				b = b + 5 + draw.SimpleText( e.text(), "MSDFont." .. HUD.FondSize, x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1)
			end
			continue
		end

		local value = e.value()
		if e.smooth then
			e.smooth = math.Approach(e.smooth, value, FrameTime() * 2)
			value = e.smooth
		end

		if value <= 1 and value > 0 then
			MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, e.icon_bg, MSD.Text["d"])

			local ip = math.Clamp(HUD.IconSize - HUD.IconSize * value, 0, HUD.IconSize)

			render.SetScissorRect(x + b, iy + ip, x + b + HUD.IconSize, iy + HUD.IconSize, true )
				MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, e.icon, color_white)
			render.SetScissorRect(0, 0, 0, 0, false )
		elseif value > 1 then
			MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, e.max_icon, color_white)
		elseif e.no_icon and value <= 0 then
			MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, e.no_icon, MSD.Text["a"])
		end

		if ( e.no_icon or value > 0 ) then
			b = b + HUD.IconSize + 5
			if not e.no_text then
				b = b + 5 + math.max( draw.SimpleText( math.max(math.Round(value * 100), 0) .. "%", "MSDFont." .. HUD.FondSize, x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1), 45)
			end
		end
	end

	HUD.BarSize = b + 10
end

function HUD.DrawWeaponBar(x, y)
	local wep = LocalPlayer():GetActiveWeapon()
	HUD.WeaponBar = - HUD.IconSize
	if not IsValid(wep) then return end
	if LocalPlayer():InVehicle() then return end

	local clip = wep:Clip1() or 0
	local maxammo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
	if (wep:GetClass() == "weapon_physcannon") then return false end
	if not clip or clip < 0 then return false end

	local rb = math.max(MSD.Config.Rounded, 5)
	local b = rb + 10
	local iy = y + 5

	HUD.DrawBG(x - HUD.WepBarSize, y, HUD.WepBarSize, HUD.IconSize + 10)
	draw.RoundedBoxEx(MSD.Config.Rounded, x - rb , y, rb, HUD.IconSize + 10, MSD.Config.MainColor["p"], false, true, false, true)

	b = b + math.max( draw.SimpleText( maxammo, "MSDFont." .. HUD.FondSize, x - b, y + 5 + HUD.IconSize / 2, color_white, TEXT_ALIGN_RIGHT, 1 ), 35)
	b = b + HUD.IconSize
	MSD.DrawTexturedRect(x - b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.ammo, MSD.Text["d"])

	b = b + 10 + math.max( draw.SimpleText( clip, "MSDFont." .. math.Clamp(HUD.FondSize + 10, 12, 52), x - b - 10, y + 5 + HUD.IconSize / 2, color_white, TEXT_ALIGN_RIGHT, 1 ), 40)
	b = b + HUD.IconSize
	MSD.DrawTexturedRect(x - b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.magazine, MSD.Text["d"])

	HUD.WepBarSize = b + 10
	HUD.WeaponBar = 0
end

local notifications = {}
local inventory = {}

local note_style = {
	[NOTIFY_ERROR] = {icon = MSD.Icons48.cross, color = Color(204, 15, 40)},
	[NOTIFY_UNDO] = {icon = MSD.Icons48.back, color = Color(54, 139, 230)},
	[NOTIFY_HINT] = {icon = Material("mqs/map_markers/r3.png", "smooth"), color = Color(0, 123, 255)},
	[NOTIFY_GENERIC] = {icon = MSD.Icons48.cog, color = Color(226, 147, 0)},
	[NOTIFY_CLEANUP] = {icon = MSD.Icons48.box_open, color = Color(128, 189, 255)},
	["loading"] = {icon = MSD.Icons48.reload, color = Color(95, 219, 13)},
	["weapon"] = {icon = Material("mqs/icons/pistol.png", "smooth"), color = Color(226, 147, 0)},
	["ammo"] = {icon = MSD.Icons48.ammo, color = Color(0, 123, 255)},
	["item"] = {icon = MSD.Icons48.box_open, color = Color(161, 216, 88)}
}

function notification.AddLegacy(text, type, time, id)
	return table.insert(notifications, {
		x = 10,
		y = ScrH() - (20 + HUD.IconSize) * 2,
		w = 100,
		h = 10 + HUD.IconSize,
		s = sub,
		progress = 0,
		text = text,
		id = id or #notifications + 1,
		type = type,
		time = CurTime() + time,
	})
end

function notification.AddInventory(text, type, time, amount)
	if type == "ammo" then
		for k, v in pairs(inventory) do
			if v.type ~= type then continue end
			if v.text ~= text then continue end
			v.amount = v.amount + amount
			v.time = CurTime() + time
			return
		end
	end

	table.insert(inventory, {
		x = ScrW(),
		y = ScrH() - (20 + HUD.IconSize) * 2,
		w = 100,
		h = 10 + HUD.IconSize,
		s = sub,
		progress = 0,
		text = text,
		amount = amount,
		type = type,
		time = CurTime() + time,
	})
end

function notification.Kill(id)
	for k, v in ipairs(notifications) do
		if v.id == id then
			v.time = 0
		end
	end
end

function notification.AddProgress(id, text, frac)
	for k, v in ipairs(notifications) do
		if v.id == id then
			v.fraction = frac
			return
		end
	end
	lid = notification.AddLegacy(text, "loading", 9999, id)
	notifications[lid].fraction = frac or 0
end

function HUD.DrawNotifications()
	for k, v in ipairs(notifications) do
		local is = math.max(MSD.Config.Rounded, 5)
		local n_locor = note_style[v.type] and note_style[v.type].color or color_white
		HUD.DrawBG(v.x - (v.w - (v.progress * v.w)), v.y - (k - 1) * (v.h + 5), v.w, v.h, v.progress)
		v.w = draw.SimpleText( v.text, "MSDFont." .. HUD.FondSize, v.x - (v.w - (v.progress * v.w)) + 20 + HUD.IconSize, (v.y - (k - 1) * (v.h + 5)) + HUD.IconSize / 2 + 5, color_white, TEXT_ALIGN_LEFT, 1 ) + 25 + HUD.IconSize

		if note_style[v.type] then
			if v.type == "loading" then
				MSD.DrawTexturedRectRotated(math.cos(CurTime() * 2) * 360, v.x - (v.w - (v.progress * v.w)) + 15 + HUD.IconSize / 2, (v.y - (k - 1) * (v.h + 5)) + 5 + HUD.IconSize / 2, HUD.IconSize, HUD.IconSize, note_style[v.type].icon, note_style[v.type].color)
			else
				MSD.DrawTexturedRect(v.x - (v.w - (v.progress * v.w)) + 15, (v.y - (k - 1) * (v.h + 5)) + 5, HUD.IconSize, HUD.IconSize, note_style[v.type].icon, note_style[v.type].color)
			end
		end

		if v.fraction and v.fraction > 0 then
			draw.RoundedBoxEx(MSD.Config.Rounded, v.x - (v.w - (v.progress * v.w)), (v.y - (k - 1) * (v.h + 5)) + v.h - is, v.w * v.fraction, is, MSD.ColorAlpha(n_locor, 255 * v.progress), false, false, true, true)
		else
			draw.RoundedBoxEx(MSD.Config.Rounded, v.x - (v.w - (v.progress * v.w)), v.y - (k - 1) * (v.h + 5), is, v.h, MSD.ColorAlpha(n_locor, 255 * v.progress), true, false, true, false)
		end

		if v.time > CurTime() then
			v.progress = math.Approach(v.progress, 1, FrameTime() * 5)
		else
			v.progress = math.Approach(v.progress, 0, FrameTime() * 4)
		end

		if v.progress <= 0 and v.time < CurTime() then
			table.remove(notifications, k)
		end
	end

	for k, v in ipairs(inventory) do
		local is = math.max(MSD.Config.Rounded, 5)
		local n_locor = note_style[v.type] and note_style[v.type].color or color_white
		HUD.DrawBG(v.x - (v.progress * v.w) - 10, v.y - (k - 1) * (v.h + 5), v.w, v.h, v.progress)
		v.w = draw.SimpleText( v.text .. " " .. (v.amount or ""), "MSDFont." .. HUD.FondSize, v.x - (v.progress * v.w) + 10 + HUD.IconSize - is, (v.y - (k - 1) * (v.h + 5)) + HUD.IconSize / 2 + 5, color_white, TEXT_ALIGN_LEFT, 1 ) + 25 + HUD.IconSize

		if note_style[v.type] then
			MSD.DrawTexturedRect(v.x - (v.progress * v.w) + 5 - is, (v.y - (k - 1) * (v.h + 5)) + 5, HUD.IconSize, HUD.IconSize, note_style[v.type].icon, note_style[v.type].color)
		end

		draw.RoundedBoxEx(MSD.Config.Rounded, v.x + (v.w - (v.progress * v.w)) - is - 10, v.y - (k - 1) * (v.h + 5), is, v.h, MSD.ColorAlpha(n_locor, 255 * v.progress), true, false, true, false)

		if v.time > CurTime() then
			v.progress = math.Approach(v.progress, 1, FrameTime() * 5)
		else
			v.progress = math.Approach(v.progress, 0, FrameTime() * 4)
		end

		if v.progress <= 0 and v.time < CurTime() then
			table.remove(inventory, k)
		end
	end
end

hook.Add("HUDPaint", "MSD.HUD.HUDPaint", function()
	if not IsValid(LocalPlayer()) and GetConVar("cl_drawhud"):GetInt() == 0 then return end

	HUD.DrawNotifications()

	local y = ScrH() - (20 + HUD.IconSize)
	HUD.DrawBar(10, y)
	HUD.DrawWeaponBar(ScrW() - 10, y)
end)

function HUD.UpdateHookInfo()
	local hideElements = {
		["CHudHealth"] = true,
		["CHudBattery"] = true,
		["CHudAmmo"] = true,
		["CHudSecondaryAmmo"] = true,
		["CHudDamageIndicator"] = true,
		["DarkRP_HUD"] = true,
		["DarkRP_EntityDisplay"] = true,
		["DarkRP_LocalPlayerHUD"] = true,
		["DarkRP_Hungermod"] = true,
		["DarkRP_Agenda"] = true,
		["DarkRP_LockdownHUD"] = true,
		["DarkRP_ArrestedHUD"] = true,
	}

	hook.Add("HUDShouldDraw", "MSD.HUD.HUDShouldDraw", function(name)
		if hideElements[name] then return false end
	end)
end

HUD.UpdateHookInfo()

hook.Add("PostGamemodeLoaded", "MSD.HUD.PostGamemodeLoaded", function()
	function GAMEMODE:HUDWeaponPickedUp(wep)
		if not (IsValid(wep) and IsValid(LocalPlayer())) or (not LocalPlayer():Alive()) then return end
		local name = wep.GetPrintName and wep:GetPrintName() or wep:GetClass() or "Unknown Weapon Name"
		notification.AddInventory(name, "weapon", 5)
	end

	function GAMEMODE:HUDItemPickedUp(itemname)
		if (not IsValid(LocalPlayer()) or not LocalPlayer():Alive()) then return end
		notification.AddInventory(language.GetPhrase(itemname), "item", 5)
	end

	function GAMEMODE:HUDAmmoPickedUp(itemname, amount)
		if (not IsValid(LocalPlayer()) or not LocalPlayer():Alive()) then return end
		notification.AddInventory(language.GetPhrase(itemname .. "_ammo"), "ammo", 5, amount)
	end

	function GAMEMODE.DrawDeathNotice()
	end
end)
