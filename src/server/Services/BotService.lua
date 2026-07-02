local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage.RiskRaidShared.Configs.ItemConfig)
local DataService = require(script.Parent.DataService)
local InventoryService = require(script.Parent.InventoryService)
local Remotes = require(script.Parent.Remotes)

local BotService = {}

local randomGenerator = Random.new()
local botFolder = nil

local BOT_CONFIGS = {
	{ name = "Sentry_A", start = Vector3.new(-22, 4, 0), finish = Vector3.new(22, 4, 0), health = 90 },
	{ name = "Sentry_B", start = Vector3.new(0, 4, -22), finish = Vector3.new(0, 4, 22), health = 90 },
	{ name = "Sentry_C", start = Vector3.new(-42, 4, 38), finish = Vector3.new(-14, 4, 38), health = 70 },
	{ name = "Sentry_D", start = Vector3.new(42, 4, -35), finish = Vector3.new(15, 4, -35), health = 70 },
}

local function ensureFolder(parent)
	if botFolder and botFolder.Parent then
		return botFolder
	end

	botFolder = Instance.new("Folder")
	botFolder.Name = "SecurityBots"
	botFolder.Parent = parent
	return botFolder
end

local function setBotActive(bot, active)
	bot:SetAttribute("Active", active)
	bot.CanTouch = active
	bot.Transparency = active and 0 or 0.75

	local prompt = bot:FindFirstChild("DisablePrompt")
	if prompt then
		prompt.Enabled = active
	end
end

local function finishBot(bot, player)
	setBotActive(bot, false)
	DataService.incrementStat(player, "botKills", 1)

	local rewardItem = ItemConfig.rollLoot(randomGenerator, "BotDrop")
	InventoryService.addRunItem(player, rewardItem, 1, "silent")
	local item = ItemConfig.getItem(rewardItem)
	Remotes.message(player, ("Sentry disabled. Salvaged %s."):format(item and item.name or rewardItem))

	task.delay(18, function()
		if bot and bot.Parent then
			bot:SetAttribute("Health", bot:GetAttribute("MaxHealth") or 70)
			setBotActive(bot, true)
		end
	end)
end

local function moveBetween(bot, startPosition, endPosition)
	task.spawn(function()
		local movingToEnd = true
		while bot.Parent do
			if bot:GetAttribute("Active") then
				local target = movingToEnd and endPosition or startPosition
				movingToEnd = not movingToEnd
				local start = bot.Position
				local duration = 3.4
				local startedAt = os.clock()

				while os.clock() - startedAt < duration and bot.Parent and bot:GetAttribute("Active") do
					local alpha = (os.clock() - startedAt) / duration
					bot.Position = start:Lerp(target, alpha)
					task.wait(0.05)
				end
			end
			task.wait(0.2)
		end
	end)
end

local function createBot(parent, config)
	local bot = Instance.new("Part")
	bot.Name = config.name
	bot.Size = Vector3.new(4, 4, 4)
	bot.Shape = Enum.PartType.Ball
	bot.Position = config.start
	bot.Anchored = true
	bot.Material = Enum.Material.Neon
	bot.BrickColor = BrickColor.new("Really red")
	bot:SetAttribute("RiskRaidBot", true)
	bot:SetAttribute("MaxHealth", config.health)
	bot:SetAttribute("Health", config.health)
	bot:SetAttribute("Active", true)
	bot.Parent = parent

	local light = Instance.new("PointLight")
	light.Range = 16
	light.Brightness = 2
	light.Color = Color3.fromRGB(255, 70, 70)
	light.Parent = bot

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "DisablePrompt"
	prompt.ActionText = "Disable"
	prompt.ObjectText = "Security Sentry"
	prompt.HoldDuration = 1.4
	prompt.MaxActivationDistance = 9
	prompt.Parent = bot
	prompt.Triggered:Connect(function(player)
		if bot:GetAttribute("Active") then
			finishBot(bot, player)
		end
	end)

	bot.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local player = character and game.Players:GetPlayerFromCharacter(character)
		if not humanoid or humanoid.Health <= 0 or not player then
			return
		end

		local lastContactAt = character:GetAttribute("SentryContactAt") or 0
		if os.clock() - lastContactAt < 1.1 then
			return
		end

		character:SetAttribute("SentryContactAt", os.clock())
		humanoid:TakeDamage(25)
		Remotes.message(player, "Security contact: keep distance or disable the sentry.")
	end)

	moveBetween(bot, config.start, config.finish)
	return bot
end

function BotService.setup(parent)
	local folder = ensureFolder(parent)
	for _, child in ipairs(folder:GetChildren()) do
		child:Destroy()
	end

	for _, config in ipairs(BOT_CONFIGS) do
		createBot(folder, config)
	end
end

function BotService.handleHit(bot, player, amount)
	if not bot or not bot.Parent or not bot:GetAttribute("RiskRaidBot") or not bot:GetAttribute("Active") then
		return false
	end

	local health = bot:GetAttribute("Health") or 0
	health -= amount
	bot:SetAttribute("Health", health)
	Remotes.message(player, ("Security integrity: %d"):format(math.max(0, health)))

	if health <= 0 then
		finishBot(bot, player)
	end

	return true
end

return BotService
