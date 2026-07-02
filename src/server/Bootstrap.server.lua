local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Services = script.Parent.Services
local DataService = require(Services.DataService)
local Remotes = require(Services.Remotes)
local InventoryService = require(Services.InventoryService)
local LootService = require(Services.LootService)
local ExtractionService = require(Services.ExtractionService)
local DeathDropService = require(Services.DeathDropService)
local BotService = require(Services.BotService)

local function clearOldWorld()
	local oldWorld = Workspace:FindFirstChild("RiskRaidWorld")
	if oldWorld then
		oldWorld:Destroy()
	end
end

local function createPart(parent, name, size, position, brickColor, material, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.BrickColor = BrickColor.new(brickColor)
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createSign(parent, name, text, position, size, textColor)
	local sign = createPart(parent, name, size or Vector3.new(18, 5, 1), position, "Really black", Enum.Material.Metal)

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	label.Parent = surfaceGui
end

local function createPromptPart(parent, name, position, colorName, objectText, actionText, onTriggered)
	local base = createPart(parent, name, Vector3.new(7, 1.2, 7), position, colorName, Enum.Material.Neon, 0.08)
	local tower = createPart(parent, name .. "Tower", Vector3.new(4, 4, 4), position + Vector3.new(0, 2.6, 0), colorName, Enum.Material.SmoothPlastic, 0.05)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name .. "Prompt"
	prompt.ObjectText = objectText
	prompt.ActionText = actionText
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 13
	prompt.Parent = tower
	prompt.Triggered:Connect(onTriggered)

	return tower, base
end

local function damageCharacterFromHazard(hit, damage, cooldownAttribute)
	local character = hit.Parent
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local player = character and Players:GetPlayerFromCharacter(character)

	if not humanoid or humanoid.Health <= 0 or not player then
		return
	end

	local lastHitAt = character:GetAttribute(cooldownAttribute) or 0
	if os.clock() - lastHitAt < 1 then
		return
	end

	character:SetAttribute(cooldownAttribute, os.clock())
	humanoid:TakeDamage(damage)
	Remotes.message(player, ("Security hit: -%d HP"):format(damage))
	InventoryService.refresh(player)
end

local function setupLighting()
	Lighting.ClockTime = 17.5
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(80, 90, 115)
	Lighting.OutdoorAmbient = Color3.fromRGB(80, 90, 115)
	Lighting.FogColor = Color3.fromRGB(18, 24, 38)
	Lighting.FogEnd = 260
end

local function createDecor(parent)
	for index = 1, 10 do
		local x = -60 + (index * 12)
		local rail = createPart(parent, "LowCover_" .. index, Vector3.new(8, 3, 2), Vector3.new(x, 2.5, -12), "Black", Enum.Material.Metal, 0.05)
		rail.Orientation = Vector3.new(0, index % 2 == 0 and 18 or -18, 0)
	end

	createPart(parent, "CenterCore", Vector3.new(14, 7, 14), Vector3.new(0, 4.5, 0), "Royal purple", Enum.Material.Glass, 0.45)
	createPart(parent, "CenterCoreLight", Vector3.new(9, 9, 9), Vector3.new(0, 6, 0), "Magenta", Enum.Material.Neon, 0.55)
end

local function createWorld()
	clearOldWorld()
	setupLighting()

	local world = Instance.new("Folder")
	world.Name = "RiskRaidWorld"
	world.Parent = Workspace

	createPart(world, "ArenaFloor", Vector3.new(150, 2, 150), Vector3.new(0, 0, 0), "Dark stone grey", Enum.Material.Slate)
	createPart(world, "NorthWall", Vector3.new(150, 16, 2), Vector3.new(0, 8, -75), "Black", Enum.Material.Metal)
	createPart(world, "SouthWall", Vector3.new(150, 16, 2), Vector3.new(0, 8, 75), "Black", Enum.Material.Metal)
	createPart(world, "EastWall", Vector3.new(2, 16, 150), Vector3.new(75, 8, 0), "Black", Enum.Material.Metal)
	createPart(world, "WestWall", Vector3.new(2, 16, 150), Vector3.new(-75, 8, 0), "Black", Enum.Material.Metal)

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "LobbySpawn"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.Position = Vector3.new(0, 2, -62)
	spawnLocation.Anchored = true
	spawnLocation.Neutral = true
	spawnLocation.BrickColor = BrickColor.new("Bright yellow")
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Transparency = 0.15
	spawnLocation.Parent = world

	createSign(world, "RiskRaidSign", "RISKRaid\nSTASH • LOADOUT • RAID • EXTRACT", Vector3.new(0, 9, -73.8), Vector3.new(42, 8, 1), Color3.fromRGB(255, 225, 90))

	createPart(world, "LobbyPad", Vector3.new(58, 1, 24), Vector3.new(0, 1, -58), "Bright yellow", Enum.Material.Neon, 0.75)
	createSign(world, "LobbySign", "LOBBY\nClaim kit, equip loadout, deploy", Vector3.new(0, 7, -45), Vector3.new(36, 5, 1), Color3.fromRGB(255, 240, 130))

	createPromptPart(world, "ClaimStarterKit", Vector3.new(-22, 2, -61), "Bright yellow", "Starter Kit", "Claim", function(player)
		InventoryService.claimStarterKit(player)
	end)

	createPromptPart(world, "EquipBlaster", Vector3.new(-10, 2, -61), "Cyan", "Pulse Blaster", "Equip", function(player)
		InventoryService.moveStashItemToRun(player, "BasicBlaster")
	end)

	createPromptPart(world, "EquipMedKit", Vector3.new(2, 2, -61), "Lime green", "Med Kit", "Equip", function(player)
		InventoryService.moveStashItemToRun(player, "MedKit")
	end)

	createPromptPart(world, "EquipArmor", Vector3.new(14, 2, -61), "Institutional white", "Armor Plate", "Equip", function(player)
		InventoryService.moveStashItemToRun(player, "ArmorPlate")
	end)

	createPromptPart(world, "DeployToRaid", Vector3.new(28, 2, -61), "Really blue", "Deploy Gate", "Deploy", function(player)
		InventoryService.deploy(player)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = CFrame.new(0, 6, -30)
		end
	end)

	createPart(world, "HighRiskZone", Vector3.new(42, 1, 42), Vector3.new(0, 1, 0), "Royal purple", Enum.Material.Neon, 0.72)
	createSign(world, "VaultSign", "HIGH RISK VAULT\nBetter loot, more danger", Vector3.new(0, 8, -24), Vector3.new(30, 5, 1), Color3.fromRGB(235, 160, 255))

	local killBlock = createPart(world, "DangerBlock_TestDrop", Vector3.new(12, 1, 12), Vector3.new(58, 1, 58), "Really red", Enum.Material.Neon, 0.25)
	killBlock.Touched:Connect(function(hit)
		damageCharacterFromHazard(hit, 999, "DropTestCooldown")
	end)
	createSign(world, "DropTestSign", "DROP TEST", Vector3.new(58, 6, 66), Vector3.new(14, 4, 1), Color3.fromRGB(255, 90, 90))

	createDecor(world)
	LootService.setup(world)
	ExtractionService.setup(world)
	BotService.setup(world)
end

local function setupPlayer(player)
	DataService.setupPlayer(player)
	InventoryService.refresh(player)
	Remotes.message(player, "Welcome to RiskRaid. Equip loadout, deploy, extract.")

	player.CharacterAdded:Connect(function(character)
		DeathDropService.attachCharacter(player, character)
		task.delay(1, function()
			InventoryService.refresh(player)
		end)
	end)
end

Remotes.init()
createWorld()

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	DataService.cleanupPlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

print("RiskRaid polished vertical slice server loaded.")
