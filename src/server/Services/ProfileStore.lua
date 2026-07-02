local DataStoreService = game:GetService("DataStoreService")

local ProfileStore = {}

local store = DataStoreService:GetDataStore("RiskRaidProfiles_v1")

function ProfileStore.load(player)
	local ok, data = pcall(function()
		return store:GetAsync("profile_" .. player.UserId)
	end)

	if ok and type(data) == "table" then
		return data
	end

	if not ok then
		warn("RiskRaid profile load skipped:", player.Name, data)
	end

	return nil
end

function ProfileStore.save(player, data)
	if type(data) ~= "table" then
		return false
	end

	local ok, err = pcall(function()
		store:SetAsync("profile_" .. player.UserId, data)
	end)

	if not ok then
		warn("RiskRaid profile save skipped:", player.Name, err)
	end

	return ok
end

return ProfileStore
