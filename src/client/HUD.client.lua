local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ItemConfig = require(ReplicatedStorage:WaitForChild("RiskRaidShared"):WaitForChild("Configs"):WaitForChild("ItemConfig"))
local remotes = ReplicatedStorage:WaitForChild("RiskRaidRemotes")

local inventoryUpdate = remotes:WaitForChild("InventoryUpdate")
local raidMessage = remotes:WaitForChild("RaidMessage")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RiskRaidHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(420, 300)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundTransparency = 0.12
panel.BackgroundColor3 = Color3.fromRGB(6, 8, 12)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "RISKRaid v0.2"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 44)
statusLabel.Position = UDim2.fromOffset(10, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 15
statusLabel.TextColor3 = Color3.fromRGB(190, 230, 255)
statusLabel.Text = "Status loading..."
statusLabel.Parent = panel

local runLabel = Instance.new("TextLabel")
runLabel.Name = "RunInventory"
runLabel.Size = UDim2.new(1, -20, 0, 82)
runLabel.Position = UDim2.fromOffset(10, 92)
runLabel.BackgroundTransparency = 1
runLabel.TextXAlignment = Enum.TextXAlignment.Left
runLabel.TextYAlignment = Enum.TextYAlignment.Top
runLabel.TextWrapped = true
runLabel.Font = Enum.Font.GothamMedium
runLabel.TextSize = 15
runLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
runLabel.Text = "Raid Backpack: empty"
runLabel.Parent = panel

local stashLabel = Instance.new("TextLabel")
stashLabel.Name = "Stash"
stashLabel.Size = UDim2.new(1, -20, 0, 76)
stashLabel.Position = UDim2.fromOffset(10, 174)
stashLabel.BackgroundTransparency = 1
stashLabel.TextXAlignment = Enum.TextXAlignment.Left
stashLabel.TextYAlignment = Enum.TextYAlignment.Top
stashLabel.TextWrapped = true
stashLabel.Font = Enum.Font.GothamMedium
stashLabel.TextSize = 15
stashLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
stashLabel.Text = "Stash: empty"
stashLabel.Parent = panel

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "Message"
messageLabel.Size = UDim2.new(1, -20, 0, 42)
messageLabel.Position = UDim2.fromOffset(10, 252)
messageLabel.BackgroundTransparency = 1
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
messageLabel.Text = "Find crates. Extract alive."
messageLabel.Parent = panel

local function summarize(itemIds)
	if not itemIds or #itemIds == 0 then
		return "empty"
	end

	local counts = {}
	for _, itemId in ipairs(itemIds) do
		counts[itemId] = (counts[itemId] or 0) + 1
	end

	local lines = {}
	for itemId, count in pairs(counts) do
		local item = ItemConfig.getItem(itemId)
		local name = item and item.name or itemId
		table.insert(lines, ("%sx %s"):format(count, name))
	end

	table.sort(lines)
	return table.concat(lines, ", ")
end

inventoryUpdate.OnClientEvent:Connect(function(snapshot)
	local stats = snapshot.stats or {}
	statusLabel.Text = ("Rank: %s | Extracts: %d | Deaths: %d | Best Run: $%d"):format(
		snapshot.rank or "ROOKIE",
		stats.extractions or 0,
		stats.deaths or 0,
		stats.bestExtraction or 0
	)

	runLabel.Text = ("Raid Backpack: $%d | Weight: %d/%d\n%s"):format(
		snapshot.runValue or 0,
		snapshot.runWeight or 0,
		snapshot.maxWeight or 10,
		summarize(snapshot.runInventory)
	)

	stashLabel.Text = ("Stash Value: $%d\n%s"):format(
		snapshot.stashValue or 0,
		summarize(snapshot.stash)
	)
end)

raidMessage.OnClientEvent:Connect(function(text)
	messageLabel.Text = text
end)
