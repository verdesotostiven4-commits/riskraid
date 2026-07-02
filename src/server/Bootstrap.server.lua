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

local function createPart(parent, name, size, position, brickColor, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.BrickColor = BrickColor.new(brickColor)
	part.Material = material or Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

local function createWorld()
	clearOldWorld()

	local world = Instance.new("Folder")
	world.Name = "RiskRaidWorld"
	world.Parent = Workspace

	createPart(world, "ArenaFloor", Vector3.new(120, 2, 120), Vector3.new(0, 0, 0), "Dark stone grey", Enum.Material.Concrete)
	createPart(world, "NorthWall", Vector3.new(120, 18, 2), Vector3.new(0, 9, -60), "Really black", Enum.Material.Metal)
	createPart(world, "SouthWall", Vector3.new(120, 18, 2), Vector3.new(0, 9, 60), "Really black", Enum.Material.Metal)
	createPart(world, "EastWall", Vector3.new(2, 18, 120), Vector3.new(60, 9, 0), "Really black", Enum.Material.Metal)
	createPart(world, "WestWall", Vector3.new(2, 18, 120), Vector3.new(-60, 9, 0), "Really black", Enum.Material.Metal)

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "RiskRaidSpawn"
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.Position = Vector3.new(0, 2, -45)
	spawnLocation.Anchored = true
	spawnLocation.Neutral = true
	spawnLocation.BrickColor = BrickColor.new("Bright yellow")
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Parent = world

	local killBlock = createPart(world, "DangerBlock_TestDeath", Vector3.new(12, 1, 12), Vector3.new(42, 1, 42), "Really red", Enum.Material.Neon)
	killBlock.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)

	LootService.setup(world)
	ExtractionService.setup(world)
end

local function setupPlayer(player)
	DataService.setupPlayer(player)
	InventoryService.refresh(player)
	Remotes.message(player, "Welcome to RiskRaid. Loot crates, then extract alive.")

	player.CharacterAdded:Connect(function(character)
		DeathDropService.attachCharacter(player, character)
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

print("RiskRaid prototype server loaded.")
