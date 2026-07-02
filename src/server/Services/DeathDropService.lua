local ItemConfig = require(game:GetService("ReplicatedStorage").RiskRaidShared.Configs.ItemConfig)
local DataService = require(script.Parent.DataService)
local InventoryService = require(script.Parent.InventoryService)
local Remotes = require(script.Parent.Remotes)

local DeathDropService = {}

local dropsFolder

local function ensureDropsFolder()
	if dropsFolder and dropsFolder.Parent then
		return dropsFolder
	end

	dropsFolder = workspace:FindFirstChild("RiskRaidDrops")
	if not dropsFolder then
		dropsFolder = Instance.new("Folder")
		dropsFolder.Name = "RiskRaidDrops"
		dropsFolder.Parent = workspace
	end

	return dropsFolder
end

local function createLootBag(ownerPlayer, itemIds, position)
	local value = ItemConfig.getInventoryValue(itemIds)
	local bag = Instance.new("Part")
	bag.Name = ("LootBag_%s"):format(ownerPlayer.Name)
	bag.Size = Vector3.new(4, 2, 4)
	bag.Position = position + Vector3.new(0, 2, 0)
	bag.Anchored = true
	bag.Material = Enum.Material.Fabric
	bag.BrickColor = BrickColor.new("Really red")
	bag:SetAttribute("OwnerUserId", ownerPlayer.UserId)
	bag:SetAttribute("ItemCount", #itemIds)
	bag:SetAttribute("TotalValue", value)
	bag.Parent = ensureDropsFolder()

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "StealLootPrompt"
	prompt.ActionText = "Steal"
	prompt.ObjectText = ("%s's Loot Bag ($%d)"):format(ownerPlayer.Name, value)
	prompt.HoldDuration = 0.75
	prompt.MaxActivationDistance = 12
	prompt.Parent = bag

	local looted = false
	prompt.Triggered:Connect(function(player)
		if looted then
			return
		end

		looted = true
		InventoryService.addLootBagItems(player, itemIds)
		Remotes.broadcast(("%s stole %s's loot bag."):format(player.Name, ownerPlayer.Name))
		bag:Destroy()
	end)

	task.delay(90, function()
		if bag and bag.Parent then
			bag:Destroy()
		end
	end)
end

function DeathDropService.attachCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end

	humanoid.Died:Connect(function()
		DataService.incrementStat(player, "deaths", 1)

		local items = InventoryService.removeRunInventory(player)
		if #items <= 0 then
			Remotes.message(player, "You died, but you had no raid loot to drop.")
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local dropPosition = rootPart and rootPart.Position or Vector3.new(0, 4, 0)
		createLootBag(player, items, dropPosition)
		Remotes.message(player, ("You died and dropped %d items."):format(#items))
	end)
end

return DeathDropService
