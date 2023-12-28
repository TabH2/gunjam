local player = PlayerPedId(PlayerId())
local netID = NetworkGetNetworkIdFromEntity(player)
jammed = false
jammedList = {}
local ReviveTimerShow = false
local UnJamTime = 3
local emotet = false
local emotec = false
local gunJamNotified = false

Blacklist = {
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_BZGAS",
	"WEAPON_MOLOTOV",
	"WEAPON_SNOWBALL",
	"WEAPON_BALL",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_FLARE",
	"WEAPON_PETROLCAN",
	"WEAPON_HAZARDCAN",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_STICKYBOMB",
	"WEAPON_GRENADE",
	"WEAPON_TEARGAS",
	"WEAPON_PROXMINE",
	"WEAPON_MOLOTOV",
	"WEAPON_PIPEBOMB",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_RPG",
	"WEAPON_MINIGUN",
	"WEAPON_FIREWORK",
	"WEAPON_RAILGUN",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_RAYMINIGUN",
	"WEAPON_RAYPISTOL",
	"WEAPON_LLPUMPSHOTGUN",
	"WEAPON_HOSE"
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = GetPlayerPed(-1)
        local weapon = GetSelectedPedWeapon(PlayerPedId())
        if IsPedShooting(ped) and not IsPedArmed(ped, 1) and not isBlacklisted(weapon) then
			-- check for weapon type
			print(GetPedAmmoTypeFromWeapon(ped, GetCurrentPedWeapon(ped, true)))
            random = math.random(1, 20)
            if random >= 15 then
				table.insert(jammedList, GetSelectedPedWeapon(ped))
                TriggerServerEvent("Server:SoundToRadius", netID, 3, "jamed", 0.3)
				Notify("~b~Gunjam~w~: Your gun has ~g~jammed~w~, hold ~r~E~w~ unjam it.")
            end
        end
        if findJammedWeapon() and not IsPedArmed(ped, 1) then
			DisablePlayerFiring(ped, true)
			jammed = true
        end
    end
end)

function emote()
	ExecuteCommand("e knucklecrunch")
end

function emotec()
	ExecuteCommand("e c")
end

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1000)
		if findJammedWeapon() then
			if IsControlPressed(0, 51) then
				if not emotet then
					emote()
				end
				UnJamShow = true
				if not gunJamNotified then
					Notify("~b~Gunjam~w~: Your gun will be ~r~unjammed~w~ in 3 seconds.")
				end
				gunJamNotified = true
				emotet = true
			elseif IsControlReleased(0, 51) then
				UnJamShow = false
				UnJamTime = 3
				if emotet then
					emotec()
				end
				emotet = false
				gunJamNotified = false
			end
		end
	end
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1000)
		if UnJamShow == true then
			if UnJamTime > 1 then
				UnJamTime = UnJamTime -1
			elseif UnJamTime == 1 then
				UnJamTime = 3
				Citizen.Wait(1000)
				unjam()
				UnJamShow = false
				emotet = false
			end
		end
	end
end)

function unjam() 
	Citizen.SetTimeout(0, function()
		ExecuteCommand("e c")
		Notify("~b~Gunjam~w~: Your gun has been ~g~unjammed~w~.") 
		TriggerServerEvent("Server:SoundToRadius", netID, 3, "unjam", 0.2)
		jammed = false
		found, index = findJammedWeapon()
		if found then
			jammedList[index] = nil
		end
	end)
end


function findJammedWeapon() 
	hash = GetSelectedPedWeapon(GetPlayerPed(-1))
	for i, wep in ipairs(jammedList) do	
		if wep == hash then
			return true, i
		end
	end
	return false
end

function isBlacklisted(model)
	for _, blacklistedWeapon in pairs(Blacklist) do
		if model == GetHashKey(blacklistedWeapon) then
			return true
		end
	end
	return false
end

function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
	SetTextJustification(0)
    DrawNotification(false, false)
end
