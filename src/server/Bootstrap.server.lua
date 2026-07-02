local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Services = script.Parent.Services
local DataService = require(Services.DataService)
local Remotes = require(Services.Remotes)
local InventoryService = require(Services.InventoryService)
local LootService = require(Services.LootService)
local ExtractionService = require(Services.ExtractionService)
local DeathDropService = require(Services.DeathDropService)

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

local function createDrone(parent, name, startPosition, endPosition)
	local drone = createPart(parent, name, Vector3.new(4, 4, 4), startPosition, "Really red", Enum.Material.Neon)
	drone.Shape = Enum.PartType.Ball

	local light = Instance.new("PointLight")
	light.Range = 16
	light.Brightness = 2
	light.Color = Color3.fromRGB(255, 80, 80)
	light.Parent = drone

	drone.Touched:Connect(function(hit)
		damageCharacterFromHazard(hit, 30, "DroneHitCooldown")
	end)

	task.spawn(function()
		local movingToEnd = true
		while drone.Parent do
			local target = movingToEnd and endPosition or startPosition
			movingToEnd = not movingToEnd

			local start = drone.Position
			local duration = 3.5
			local startedAt = os.clock()

			while os.clock() - startedAt < duration and drone.Parent do
				local alpha = (os.clock() - startedAt) / duration
				drone.Position = start:Lerp(target, alpha)
				task.wait(0.05)
			end

			task.wait(0.25)
		end
	end)
end

local function createWorld()
	clearOldWorld()

	local world = Instance.new("Folder")
	world.Name = "RiskRaidWorld"
	world.Parent = Workspace

	createPart(world, "ArenaFloor", Vector3.new(130, 2, 130), Vector3.new(0, 0, 0), "Dark stone grey", Enum.Material.Concrete)
	createPart(world, "NorthWall", Vector3.new(130, 18, 2), Vector3.new(0, 9, -65), "Really black", Enum.Material.Metal)
	createPart(world, "SouthWall", Vector3.new(130, 18, 2), Vector3.new(0, 9, 65), "Really black", Enum.Material.Metal)
	createPart(world, "EastWall", Vector3.new(2, 18, 130), Vector3.new(65, 9, 0), "Really black", Enum.Material.Metal)
	createPart(world, "WestWall", Vector3.new(2, 18, 130), Vector3.new(-65, 9, 0), "Really black", Enum.Material.Metal)

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "RiskRaidSpawn"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.Position = Vector3.new(0, 2, -52)
	spawnLocation.Anchored = true
	spawnLocation.Neutral = true
	spawnLocation.BrickColor = BrickColor.new("Bright yellow")
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Parent = world

	createSign(world, "RiskRaidSign", "RISKRaid\nLOOT • SURVIVE • EXTRACT", Vector3.new(0, 8, -63.8), Vector3.new(30, 8, 1), Color3.fromRGB(255, 225, 90))

	createPart(world, "HighRiskZone", Vector3.new(34, 1, 34), Vector3.new(0, 1, 0), "Royal purple", Enum.Material.Neon, 0.65)
	createSign(world, "VaultSign", "HIGH RISK VAULT\nBetter loot, more danger", Vector3.new(0, 8, -17), Vector3.new(28, 6, 1), Color3.fromRGB(235, 160, 255))

	local killBlock = createPart(world, "DangerBlock_TestDeath", Vector3.new(12, 1, 12), Vector3.new(52, 1, 52), "Really red", Enum.Material.Neon, 0.1)
	killBlock.Touched:Connect(function(hit)
		damageCharacterFromHazard(hit, 999, "KillBlockCooldown")
	end)
	createSign(world, "DeathTestSign", "TEST DEATH", Vector3.new(52, 6, 59), Vector3.new(14, 4, 1), Color3.fromRGB(255, 90, 90))

	createDrone(world, "SecurityDrone_1", Vector3.new(-20, 4, 0), Vector3.new(20, 4, 0))
	createDrone(world, "SecurityDrone_2", Vector3.new(0, 4, -20), Vector3.new(0, 4, 20))
	createDrone(world, "SecurityDrone_3", Vector3.new(-38, 4, 38), Vector3.new(-12, 4, 38))

	LootService.setup(world)
	ExtractionService.setup(world)
end

local function setupPlayer(player)
	DataService.setupPlayer(player)
	InventoryService.refresh(player)
	Remotes.message(player, "Welcome to RiskRaid v0.2. Blue crates are safe. Purple crates are high risk.")

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

print("RiskRaid v0.2 server loaded.")
