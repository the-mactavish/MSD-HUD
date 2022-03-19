MSD.HUD = MSD.HUD or {}

local HUD = MSD.HUD

HUD.IconSize = 32
HUD.BarSize = 0
HUD.WepBarSize = 0
HUD.AnimatedBars = {}
HUD.TextBars = {}

HUD.AnimatedBars[1] = {
	icon_bg = MSD.Icons48.heart_outline,
	icon = MSD.Icons48.heart,
	max_icon = MSD.Icons48.heart_flash,
	no_icon = MSD.Icons48.heart_broken,
	smooth = 0,
	value = function()
		return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
	end
}

HUD.AnimatedBars[2] = {
	icon_bg = MSD.Icons48.armor_outline,
	icon = MSD.Icons48.armor,
	max_icon = MSD.Icons48.armor_flash,
	no_icon = MSD.Icons48.armor_broken,
	smooth = 0,
	value = function()
		return LocalPlayer():Armor() / LocalPlayer():GetMaxArmor()
	end
}

HUD.TextBars[1] = {
	check = function()
		return DarkRP and true or false
	end,
	icon = MSD.Icons48.briefcase,
	text = function()
		return LocalPlayer():getDarkRPVar("job") or ""
	end
}

HUD.TextBars[2] = {
	check = function()
		return DarkRP and true or false
	end,
	icon = MSD.Icons48.cash,
	text = function()
		local money = LocalPlayer():getDarkRPVar("money") or 0
		local sal = LocalPlayer():getDarkRPVar("salary") or 0
		return string.Comma(money) .. "$" .. (sal > 0 and " + " .. string.Comma(sal) .. "$" or "")
	end
}

function HUD.DrawBar(x, y)

	local b = math.max(MSD.Config.Rounded, 5) + 10
	local iy = y + 5

	draw.RoundedBox(MSD.Config.Rounded, x, y, HUD.BarSize, HUD.IconSize + 10, MSD.Theme["d"])
	draw.RoundedBoxEx(MSD.Config.Rounded, x, y, math.max(MSD.Config.Rounded, 5), HUD.IconSize + 10, MSD.Config.MainColor["p"], true, false, true, false)

	for id, e in pairs(HUD.AnimatedBars) do
		if e.check and not e.check() then continue end

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

		if e.no_icon or value > 0 then
			b = b + HUD.IconSize + 5
			b = b + 5 + math.max( draw.SimpleText( math.max(math.Round(value * 100), 0) .. "%", "MSDFont.22", x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1), 45)
		end
	end

	for id, e in pairs(HUD.TextBars) do
		if e.check and not e.check() then continue end

		MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, e.icon, color_white)
		b = b + HUD.IconSize + 5
		b = b + 5 + draw.SimpleText( e.text(), "MSDFont.22", x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1)
	end
	-- if DarkRP then

	-- 	MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.briefcase, MSD.Text["d"])
	-- 	b = b + HUD.IconSize + 5
	-- 	b = b + 5 + draw.SimpleText( LocalPlayer():getDarkRPVar("job") or "", "MSDFont.22", x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1)

	-- 	local money = LocalPlayer():getDarkRPVar("money") or 0
	-- 	MSD.DrawTexturedRect(x + b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.cash, MSD.Text["d"])
	-- 	b = b + HUD.IconSize + 5
	-- 	b = b + 5 + draw.SimpleText( string.Comma(money) .. " $", "MSDFont.22", x + b, y + 5 + HUD.IconSize / 2, MSD.Text["l"], 0, 1)

	-- end


	HUD.BarSize = b + 10
end

function HUD.DrawWeaponBar(x, y)
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) then return end
	if LocalPlayer():InVehicle() then return end

	local clip = wep:Clip1() or 0
	local maxammo = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
	if (wep:GetClass() == "weapon_physcannon") then return false end
	if not clip or clip < 0 then return false end

	local rb = math.max(MSD.Config.Rounded, 5)
	local b = rb + 10
	local iy = y + 5

	draw.RoundedBox(MSD.Config.Rounded, x - HUD.WepBarSize, y, HUD.WepBarSize, HUD.IconSize + 10, MSD.Theme["d"])
	draw.RoundedBoxEx(MSD.Config.Rounded, x - rb , y, rb, HUD.IconSize + 10, MSD.Config.MainColor["p"], false, true, false, true)

	b = b + math.max( draw.SimpleText( maxammo, "MSDFont.22", x - b, y + 5 + HUD.IconSize / 2, color_white, TEXT_ALIGN_RIGHT, 1 ), 35)
	b = b + HUD.IconSize
	MSD.DrawTexturedRect(x - b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.ammo, MSD.Text["d"])

	b = b + 10 + math.max( draw.SimpleText( clip, "MSDFont.32", x - b - 10, y + 5 + HUD.IconSize / 2, color_white, TEXT_ALIGN_RIGHT, 1 ), 40)
	b = b + HUD.IconSize
	MSD.DrawTexturedRect(x - b, iy, HUD.IconSize, HUD.IconSize, MSD.Icons48.magazine, MSD.Text["d"])

	HUD.WepBarSize = b + 10
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

function notification.AddInventory(text, type, time)
	table.insert(inventory, {
		x = 0,
		y = 0,
		w = 10,
		h = 10 + HUD.IconSize,
		s = sub,
		text = text,
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
		draw.RoundedBox(MSD.Config.Rounded, v.x - (v.w - (v.progress * v.w)), v.y - (k - 1) * (v.h + 5), v.w, v.h, MSD.ColorAlpha(MSD.Theme["d"], 155 * v.progress))
		v.w = draw.SimpleText( v.text, "MSDFont.22", v.x - (v.w - (v.progress * v.w)) + 20 + HUD.IconSize, (v.y - (k - 1) * (v.h + 5)) + HUD.IconSize / 2 + 5, color_white, TEXT_ALIGN_LEFT, 1 ) + 25 + HUD.IconSize

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
	-- function GAMEMODE:HUDWeaponPickedUp(wep)
	-- 	if not (IsValid(wep) and IsValid(LocalPlayer())) or (not LocalPlayer():Alive()) then return end
	-- 	local name = wep.GetPrintName and wep:GetPrintName() or wep:GetClass() or "Unknown Weapon Name"
	-- 	notification.AddInventory(name, 1, 5, true)
	-- end

	-- function GAMEMODE:HUDItemPickedUp(itemname)
	-- 	if (not IsValid(LocalPlayer()) or not LocalPlayer():Alive()) then return end
	-- 	notification.AddInventory(language.GetPhrase(itemname), 2, 5, true)
	-- end

	-- function GAMEMODE:HUDAmmoPickedUp(itemname, amount)
	-- 	if (not IsValid(LocalPlayer()) or not LocalPlayer():Alive()) then return end
	-- 	notification.AddInventory(language.GetPhrase(itemname .. "_ammo") .. " " .. amount, 3, 5, true)
	-- end

	function GAMEMODE.DrawDeathNotice()
	end
end)
