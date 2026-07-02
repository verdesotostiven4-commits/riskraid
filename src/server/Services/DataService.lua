local DataService = {}

local playerStates = {}

local function createDefaultState()
	return {
		stash = {},
		runInventory = {},
		stats = {
			extractions = 0,
			deaths = 0,
			lootBagsStolen = 0,
		},
	}
end

local function copyArray(array)
	local copy = {}
	for index, value in ipairs(array) do
		copy[index] = value
	end
	return copy
end

function DataService.setupPlayer(player)
	playerStates[player] = createDefaultState()
	return playerStates[player]
end

function DataService.cleanupPlayer(player)
	playerStates[player] = nil
end

function DataService.getState(player)
	local state = playerStates[player]
	if not state then
		state = DataService.setupPlayer(player)
	end
	return state
end

function DataService.addRunItem(player, itemId, amount)
	local state = DataService.getState(player)
	local count = amount or 1

	for _ = 1, count do
		table.insert(state.runInventory, itemId)
	end
end

function DataService.addStashItem(player, itemId, amount)
	local state = DataService.getState(player)
	local count = amount or 1

	for _ = 1, count do
		table.insert(state.stash, itemId)
	end
end

function DataService.moveRunToStash(player)
	local state = DataService.getState(player)
	local movedItems = state.runInventory

	for _, itemId in ipairs(movedItems) do
		table.insert(state.stash, itemId)
	end

	state.runInventory = {}
	state.stats.extractions += 1

	return movedItems
end

function DataService.removeRunInventory(player)
	local state = DataService.getState(player)
	local removedItems = state.runInventory
	state.runInventory = {}
	return removedItems
end

function DataService.incrementStat(player, statName, amount)
	local state = DataService.getState(player)
	if state.stats[statName] == nil then
		state.stats[statName] = 0
	end
	state.stats[statName] += amount or 1
end

function DataService.getSnapshot(player)
	local state = DataService.getState(player)

	return {
		stash = copyArray(state.stash),
		runInventory = copyArray(state.runInventory),
		stats = {
			extractions = state.stats.extractions,
			deaths = state.stats.deaths,
			lootBagsStolen = state.stats.lootBagsStolen,
		},
	}
end

return DataService
