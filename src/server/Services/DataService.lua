local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)

local DataService = {}

local playerStates = {}

local function copyArray(array)
	local copy = {}
	for index, value in ipairs(array or {}) do
		copy[index] = value
	end
	return copy
end

local function createDefaultStats()
	return {
		extractions = 0,
		deaths = 0,
		lootBagsStolen = 0,
		bestExtraction = 0,
		botKills = 0,
		playerKills = 0,
		rankPoints = 0,
	}
end

local function createDefaultState()
	return {
		stash = copyArray(ItemConfig.StarterKit),
		runInventory = {},
		stats = createDefaultStats(),
		starterClaimed = true,
		inRaid = false,
	}
end

function DataService.refreshLeaderstats(player)
	local state = DataService.getState(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local stashValue = ItemConfig.getInventoryValue(state.stash)
	local rank = ItemConfig.getRankFromStashValue(stashValue)

	local function setValue(className, name, value)
		local instance = leaderstats:FindFirstChild(name)
		if not instance then
			instance = Instance.new(className)
			instance.Name = name
			instance.Parent = leaderstats
		end
		instance.Value = value
	end

	setValue("IntValue", "StashValue", stashValue)
	setValue("IntValue", "Extracts", state.stats.extractions)
	setValue("IntValue", "BotKills", state.stats.botKills or 0)
	setValue("StringValue", "Rank", rank)
end

function DataService.setupPlayer(player)
	playerStates[player] = createDefaultState()
	DataService.refreshLeaderstats(player)
	return playerStates[player]
end

function DataService.savePlayer(player)
	return playerStates[player] ~= nil
end

function DataService.cleanupPlayer(player)
	DataService.savePlayer(player)
	playerStates[player] = nil
end

function DataService.getState(player)
	local state = playerStates[player]
	if not state then
		state = DataService.setupPlayer(player)
	end
	return state
end

function DataService.setInRaid(player, inRaid)
	local state = DataService.getState(player)
	state.inRaid = inRaid == true
end

function DataService.addRunItem(player, itemId, amount)
	local state = DataService.getState(player)
	local count = amount or 1

	for _ = 1, count do
		table.insert(state.runInventory, itemId)
	end
	DataService.refreshLeaderstats(player)
end

function DataService.addStashItem(player, itemId, amount)
	local state = DataService.getState(player)
	local count = amount or 1

	for _ = 1, count do
		table.insert(state.stash, itemId)
	end
	DataService.refreshLeaderstats(player)
end

function DataService.removeOneStashItem(player, itemId)
	local state = DataService.getState(player)
	for index, existingItemId in ipairs(state.stash) do
		if existingItemId == itemId then
			table.remove(state.stash, index)
			DataService.refreshLeaderstats(player)
			return true
		end
	end
	return false
end

function DataService.moveRunToStash(player, runValue)
	local state = DataService.getState(player)
	local movedItems = state.runInventory

	for _, itemId in ipairs(movedItems) do
		table.insert(state.stash, itemId)
	end

	state.runInventory = {}
	state.inRaid = false
	state.stats.extractions += 1
	state.stats.rankPoints += math.floor((runValue or 0) / 25)

	if runValue and runValue > state.stats.bestExtraction then
		state.stats.bestExtraction = runValue
	end

	DataService.refreshLeaderstats(player)
	DataService.savePlayer(player)
	return movedItems
end

function DataService.removeRunInventory(player)
	local state = DataService.getState(player)
	local removedItems = state.runInventory
	state.runInventory = {}
	state.inRaid = false
	DataService.refreshLeaderstats(player)
	return removedItems
end

function DataService.incrementStat(player, statName, amount)
	local state = DataService.getState(player)
	if state.stats[statName] == nil then
		state.stats[statName] = 0
	end
	state.stats[statName] += amount or 1
	DataService.refreshLeaderstats(player)
end

function DataService.claimStarterKit(player)
	local state = DataService.getState(player)
	if state.starterClaimed and #state.stash > 0 then
		return false
	end

	for _, itemId in ipairs(ItemConfig.StarterKit) do
		table.insert(state.stash, itemId)
	end
	state.starterClaimed = true
	DataService.refreshLeaderstats(player)
	DataService.savePlayer(player)
	return true
end

function DataService.getSnapshot(player)
	local state = DataService.getState(player)

	return {
		stash = copyArray(state.stash),
		runInventory = copyArray(state.runInventory),
		inRaid = state.inRaid,
		stats = {
			extractions = state.stats.extractions,
			deaths = state.stats.deaths,
			lootBagsStolen = state.stats.lootBagsStolen,
			bestExtraction = state.stats.bestExtraction,
			botKills = state.stats.botKills or 0,
			playerKills = state.stats.playerKills or 0,
			rankPoints = state.stats.rankPoints or 0,
		},
	}
end

return DataService
