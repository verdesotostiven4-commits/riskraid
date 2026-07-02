local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)
local DataService = require(script.Parent.DataService)
local Remotes = require(script.Parent.Remotes)

local InventoryService = {}

local function buildSnapshot(player)
	local snapshot = DataService.getSnapshot(player)
	snapshot.runValue = ItemConfig.getInventoryValue(snapshot.runInventory)
	snapshot.stashValue = ItemConfig.getInventoryValue(snapshot.stash)
	return snapshot
end

function InventoryService.refresh(player)
	Remotes.sendInventory(player, buildSnapshot(player))
end

function InventoryService.addRunItem(player, itemId, amount, reason)
	local item = ItemConfig.getItem(itemId)
	if not item then
		warn(("Unknown itemId: %s"):format(tostring(itemId)))
		return false
	end

	DataService.addRunItem(player, itemId, amount or 1)
	InventoryService.refresh(player)

	if reason ~= "silent" then
		Remotes.message(player, ("+ %s [%s]"):format(item.name, item.rarity))
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
	DataService.moveRunToStash(player)
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
	for _, itemId in ipairs(itemIds) do
		DataService.addRunItem(player, itemId, 1)
	end

	DataService.incrementStat(player, "lootBagsStolen", 1)
	InventoryService.refresh(player)

	local value = ItemConfig.getInventoryValue(itemIds)
	Remotes.message(player, ("Loot bag stolen: %d items. Value: $%d"):format(#itemIds, value))
end

return InventoryService
