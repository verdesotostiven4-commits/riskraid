local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)
local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Remotes)

local InventoryService = {}

local function buildSnapshot(player)
	local snapshot = DataService.getSnapshot(player)
	snapshot.runValue = ItemConfig.getInventoryValue(snapshot.runInventory)
	snapshot.stashValue = ItemConfig.getInventoryValue(snapshot.stash)
	snapshot.runWeight = ItemConfig.getInventoryWeight(snapshot.runInventory)
	snapshot.maxWeight = ItemConfig.MaxBackpackWeight
	snapshot.rank = ItemConfig.getRankFromStashValue(snapshot.stashValue)
	return snapshot
end

function InventoryService.refresh(player)
	Remotes.sendInventory(player, buildSnapshot(player))
end

function InventoryService.canAddItems(player, itemIds)
	local snapshot = DataService.getSnapshot(player)
	local currentWeight = ItemConfig.getInventoryWeight(snapshot.runInventory)
	local addedWeight = ItemConfig.getInventoryWeight(itemIds)
	return currentWeight + addedWeight <= ItemConfig.MaxBackpackWeight, currentWeight, addedWeight
end

function InventoryService.addRunItem(player, itemId, amount, reason)
	local item = ItemConfig.getItem(itemId)
	if not item then
		warn(("Unknown itemId: %s"):format(tostring(itemId)))
		return false
	end

	local itemsToAdd = {}
	for _ = 1, amount or 1 do
		table.insert(itemsToAdd, itemId)
	end

	local canAdd = InventoryService.canAddItems(player, itemsToAdd)
	if not canAdd then
		Remotes.message(player, ("Backpack full. Cannot take %s. Extract or steal less."):format(item.name))
		InventoryService.refresh(player)
		return false
	end

	DataService.addRunItem(player, itemId, amount or 1)
	InventoryService.refresh(player)

	if reason ~= "silent" then
		Remotes.message(player, ("+ %s [%s] | $%d"):format(item.name, item.rarity, item.value))
	end

	return true
end

function InventoryService.extract(player)
	local snapshotBefore = DataService.getSnapshot(player)
	local itemsToMove = snapshotBefore.runInventory

	if #itemsToMove <= 0 then
		Remotes.message(player, "Extraction complete, but your backpack was empty.")
		return false
	end

	local value = ItemConfig.getInventoryValue(itemsToMove)
	DataService.moveRunToStash(player, value)
	InventoryService.refresh(player)
	Remotes.message(player, ("Extraction successful: %d items secured. Value: $%d"):format(#itemsToMove, value))

	return true
end

function InventoryService.removeRunInventory(player)
	local removedItems = DataService.removeRunInventory(player)
	InventoryService.refresh(player)
	return removedItems
end

function InventoryService.addLootBagItems(player, itemIds)
	local canAdd = InventoryService.canAddItems(player, itemIds)
	if not canAdd then
		Remotes.message(player, "Loot bag is too heavy for your backpack. Extract first or reduce weight.")
		InventoryService.refresh(player)
		return false
	end

	for _, itemId in ipairs(itemIds) do
		DataService.addRunItem(player, itemId, 1)
	end

	DataService.incrementStat(player, "lootBagsStolen", 1)
	InventoryService.refresh(player)

	local value = ItemConfig.getInventoryValue(itemIds)
	Remotes.message(player, ("Loot bag stolen: %d items. Value: $%d"):format(#itemIds, value))
	return true
end

return InventoryService
