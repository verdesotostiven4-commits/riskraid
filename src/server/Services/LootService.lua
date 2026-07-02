local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)
local InventoryService = require(script.Parent.InventoryService)
local Remotes = require(script.Parent.Remotes)

local LootService = {}

local randomGenerator = Random.new()

local NORMAL_LOOT_BOX_POSITIONS = {
	Vector3.new(-42, 3, -28),
	Vector3.new(-25, 3, 22),
	Vector3.new(28, 3, -30),
	Vector3.new(42, 3, 22),
	Vector3.new(-45, 3, 45),
	Vector3.new(45, 3, -5),
}

local HIGH_RISK_LOOT_BOX_POSITIONS = {
	Vector3.new(-10, 3, 0),
	Vector3.new(10, 3, 0),
	Vector3.new(0, 3, 10),
}

local function createLootBox(parent, index, position, lootTableName)
	local isHighRisk = lootTableName == "HighRisk"

	local box = Instance.new("Part")
	box.Name = (isHighRisk and "HighRiskCrate_%02d" or "LootBox_%02d"):format(index)
	box.Size = Vector3.new(5, 4, 5)
	box.Position = position
	box.Anchored = true
	box.Material = Enum.Material.Metal
	box.BrickColor = BrickColor.new(isHighRisk and "Royal purple" or "Bright blue")
	box.Parent = parent

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "LootPrompt"
	prompt.ActionText = "Search"
	prompt.ObjectText = isHighRisk and "High-Risk Vault Crate" or "Raid Crate"
	prompt.HoldDuration = isHighRisk and 0.85 or 0.4
	prompt.MaxActivationDistance = 12
	prompt.Parent = box

	prompt.Triggered:Connect(function(player)
		if box:GetAttribute("Looted") then
			Remotes.message(player, "This crate is empty. Keep moving or extract.")
			return
		end

		box:SetAttribute("Looted", true)
		prompt.Enabled = false
		box.Transparency = 0.55

		local itemId = ItemConfig.rollLoot(randomGenerator, lootTableName)
		InventoryService.addRunItem(player, itemId, 1)

		task.delay(isHighRisk and 22 or 14, function()
			if box.Parent then
				box:SetAttribute("Looted", false)
				prompt.Enabled = true
				box.Transparency = 0
			end
		end)
	end)
end

function LootService.setup(parent)
	for index, position in ipairs(NORMAL_LOOT_BOX_POSITIONS) do
		createLootBox(parent, index, position, "Normal")
	end

	for index, position in ipairs(HIGH_RISK_LOOT_BOX_POSITIONS) do
		createLootBox(parent, index, position, "HighRisk")
	end
end

return LootService
