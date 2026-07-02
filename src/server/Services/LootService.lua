local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)
local InventoryService = require(script.Parent.InventoryService)
local Remotes = require(script.Parent.Remotes)

local LootService = {}

local randomGenerator = Random.new()

local LOOT_BOX_POSITIONS = {
	Vector3.new(-32, 3, -20),
	Vector3.new(-18, 3, 22),
	Vector3.new(0, 3, -28),
	Vector3.new(22, 3, 18),
	Vector3.new(34, 3, -12),
	Vector3.new(8, 3, 28),
}

local function createLootBox(parent, index, position)
	local box = Instance.new("Part")
	box.Name = ("LootBox_%02d"):format(index)
	box.Size = Vector3.new(5, 4, 5)
	box.Position = position
	box.Anchored = true
	box.Material = Enum.Material.Metal
	box.BrickColor = BrickColor.new("Bright blue")
	box.Parent = parent

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "LootPrompt"
	prompt.ActionText = "Search"
	prompt.ObjectText = "Raid Crate"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.Parent = box

	prompt.Triggered:Connect(function(player)
		if box:GetAttribute("Looted") then
			Remotes.message(player, "This crate is empty.")
			return
		end

		box:SetAttribute("Looted", true)
		prompt.Enabled = false
		box.Transparency = 0.55

		local itemId = ItemConfig.rollLoot(randomGenerator)
		InventoryService.addRunItem(player, itemId, 1)

		task.delay(12, function()
			if box.Parent then
				box:SetAttribute("Looted", false)
				prompt.Enabled = true
				box.Transparency = 0
			end
		end)
	end)
end

function LootService.setup(parent)
	for index, position in ipairs(LOOT_BOX_POSITIONS) do
		createLootBox(parent, index, position)
	end
end

return LootService
