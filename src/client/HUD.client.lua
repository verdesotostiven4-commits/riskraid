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
screenGui.IgnoreGuiInset = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Size = UDim2.fromOffset(330, 210)
panel.Position = UDim2.new(1, -18, 0, 18)
panel.BackgroundTransparency = 0.08
panel.BackgroundColor3 = Color3.fromRGB(9, 12, 20)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(120, 170, 255)
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -24, 0, 32)
title.Position = UDim2.fromOffset(12, 10)
title.BackgroundTransparency = 1
title.Text = "RISKRaid"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -24, 0, 40)
statusLabel.Position = UDim2.fromOffset(12, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(190, 220, 255)
statusLabel.Text = "Loading..."
statusLabel.Parent = panel

local runLabel = Instance.new("TextLabel")
runLabel.Name = "RunInventory"
runLabel.Size = UDim2.new(1, -24, 0, 46)
runLabel.Position = UDim2.fromOffset(12, 88)
runLabel.BackgroundTransparency = 1
runLabel.TextXAlignment = Enum.TextXAlignment.Left
runLabel.TextYAlignment = Enum.TextYAlignment.Top
runLabel.TextWrapped = true
runLabel.Font = Enum.Font.GothamMedium
runLabel.TextSize = 13
runLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
runLabel.Text = "Backpack: empty"
runLabel.Parent = panel

local stashLabel = Instance.new("TextLabel")
stashLabel.Name = "Stash"
stashLabel.Size = UDim2.new(1, -24, 0, 46)
stashLabel.Position = UDim2.fromOffset(12, 136)
stashLabel.BackgroundTransparency = 1
stashLabel.TextXAlignment = Enum.TextXAlignment.Left
stashLabel.TextYAlignment = Enum.TextYAlignment.Top
stashLabel.TextWrapped = true
stashLabel.Font = Enum.Font.GothamMedium
stashLabel.TextSize = 13
stashLabel.TextColor3 = Color3.fromRGB(190, 255, 205)
stashLabel.Text = "Stash: empty"
stashLabel.Parent = panel

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "Message"
messageLabel.AnchorPoint = Vector2.new(0.5, 1)
messageLabel.Size = UDim2.fromOffset(520, 42)
messageLabel.Position = UDim2.new(0.5, 0, 1, -32)
messageLabel.BackgroundTransparency = 0.15
messageLabel.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
messageLabel.TextXAlignment = Enum.TextXAlignment.Center
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextColor3 = Color3.fromRGB(255, 230, 120)
messageLabel.Text = "Claim kit, equip loadout, deploy."
messageLabel.Parent = screenGui

local msgCorner = Instance.new("UICorner")
msgCorner.CornerRadius = UDim.new(0, 12)
msgCorner.Parent = messageLabel

local function summarize(itemIds, limit)
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
	if limit and #lines > limit then
		local visible = {}
		for index = 1, limit do
			table.insert(visible, lines[index])
		end
		table.insert(visible, ("+%d more"):format(#lines - limit))
		return table.concat(visible, ", ")
	end

	return table.concat(lines, ", ")
end

inventoryUpdate.OnClientEvent:Connect(function(snapshot)
	local stats = snapshot.stats or {}
	local stateText = snapshot.inRaid and "RAID" or "LOBBY"
	statusLabel.Text = ("%s | %s | Extracts %d | Best $%d"):format(
		stateText,
		snapshot.rank or "ROOKIE",
		stats.extractions or 0,
		stats.bestExtraction or 0
	)

	runLabel.Text = ("Backpack $%d | %d/%d\n%s"):format(
		snapshot.runValue or 0,
		snapshot.runWeight or 0,
		snapshot.maxWeight or 12,
		summarize(snapshot.runInventory, 3)
	)

	stashLabel.Text = ("Stash $%d\n%s"):format(
		snapshot.stashValue or 0,
		summarize(snapshot.stash, 3)
	)
end)

raidMessage.OnClientEvent:Connect(function(text)
	messageLabel.Text = text
end)
