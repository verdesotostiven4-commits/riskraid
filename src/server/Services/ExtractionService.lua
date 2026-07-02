local InventoryService = require(script.Parent.InventoryService)
local Remotes = require(script.Parent.Remotes)

local ExtractionService = {}

local function createExtractionZone(parent)
	local zone = Instance.new("Part")
	zone.Name = "ExtractionZone"
	zone.Size = Vector3.new(18, 1, 18)
	zone.Position = Vector3.new(0, 1, 42)
	zone.Anchored = true
	zone.Transparency = 0.25
	zone.Material = Enum.Material.Neon
	zone.BrickColor = BrickColor.new("Lime green")
	zone.Parent = parent

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ExtractPrompt"
	prompt.ActionText = "Extract"
	prompt.ObjectText = "Extraction Zone"
	prompt.HoldDuration = 1.25
	prompt.MaxActivationDistance = 16
	prompt.Parent = zone

	prompt.Triggered:Connect(function(player)
		InventoryService.extract(player)
	end)

	local sign = Instance.new("Part")
	sign.Name = "ExtractionSign"
	sign.Size = Vector3.new(18, 5, 1)
	sign.Position = Vector3.new(0, 5, 51)
	sign.Anchored = true
	sign.BrickColor = BrickColor.new("Black")
	sign.Parent = parent

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "EXTRACTION"
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(0.2, 1, 0.2)
	label.Parent = surfaceGui
end

function ExtractionService.setup(parent)
	createExtractionZone(parent)
	Remotes.broadcast("Extraction zone online. Secure loot and escape alive.")
end

return ExtractionService
