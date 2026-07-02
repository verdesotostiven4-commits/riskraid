local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local remoteFolder

local REMOTE_NAMES = {
	InventoryUpdate = "RemoteEvent",
	RaidMessage = "RemoteEvent",
}

local function getOrCreate(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

function Remotes.init()
	remoteFolder = getOrCreate(ReplicatedStorage, "Folder", "RiskRaidRemotes")

	for remoteName, className in pairs(REMOTE_NAMES) do
		getOrCreate(remoteFolder, className, remoteName)
	end

	return remoteFolder
end

function Remotes.get(remoteName)
	if not remoteFolder then
		Remotes.init()
	end

	return remoteFolder:WaitForChild(remoteName)
end

function Remotes.sendInventory(player, snapshot)
	Remotes.get("InventoryUpdate"):FireClient(player, snapshot)
end

function Remotes.message(player, text)
	Remotes.get("RaidMessage"):FireClient(player, text)
end

function Remotes.broadcast(text)
	Remotes.get("RaidMessage"):FireAllClients(text)
end

return Remotes
