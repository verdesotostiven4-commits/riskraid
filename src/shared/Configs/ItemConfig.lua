local ItemConfig = {}

ItemConfig.MaxBackpackWeight = 10

ItemConfig.RarityOrder = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
}

ItemConfig.Items = {
	ScrapMetal = {
		id = "ScrapMetal",
		name = "Scrap Metal",
		rarity = "Common",
		value = 15,
		weight = 1,
	},
	BatteryCell = {
		id = "BatteryCell",
		name = "Battery Cell",
		rarity = "Common",
		value = 25,
		weight = 1,
	},
	BlueCircuit = {
		id = "BlueCircuit",
		name = "Blue Circuit",
		rarity = "Uncommon",
		value = 60,
		weight = 1,
	},
	MedKit = {
		id = "MedKit",
		name = "Med Kit",
		rarity = "Uncommon",
		value = 80,
		weight = 1,
	},
	VaultKey = {
		id = "VaultKey",
		name = "Vault Key",
		rarity = "Rare",
		value = 150,
		weight = 1,
	},
	EncryptedCore = {
		id = "EncryptedCore",
		name = "Encrypted Core",
		rarity = "Epic",
		value = 420,
		weight = 2,
	},
	PhantomChip = {
		id = "PhantomChip",
		name = "Phantom Chip",
		rarity = "Epic",
		value = 680,
		weight = 2,
	},
	GoldRelic = {
		id = "GoldRelic",
		name = "Gold Relic",
		rarity = "Legendary",
		value = 1250,
		weight = 3,
	},
	BlackCard = {
		id = "BlackCard",
		name = "Black Card",
		rarity = "Mythic",
		value = 3000,
		weight = 1,
	},
}

ItemConfig.LootTables = {
	Normal = {
		{ itemId = "ScrapMetal", weight = 40 },
		{ itemId = "BatteryCell", weight = 28 },
		{ itemId = "BlueCircuit", weight = 18 },
		{ itemId = "MedKit", weight = 8 },
		{ itemId = "VaultKey", weight = 4 },
		{ itemId = "EncryptedCore", weight = 1.5 },
		{ itemId = "GoldRelic", weight = 0.4 },
	},
	HighRisk = {
		{ itemId = "BlueCircuit", weight = 28 },
		{ itemId = "VaultKey", weight = 25 },
		{ itemId = "EncryptedCore", weight = 20 },
		{ itemId = "PhantomChip", weight = 12 },
		{ itemId = "GoldRelic", weight = 5 },
		{ itemId = "BlackCard", weight = 1 },
	},
}

function ItemConfig.getItem(itemId)
	return ItemConfig.Items[itemId]
end

function ItemConfig.getInventoryValue(itemIds)
	local total = 0

	for _, itemId in ipairs(itemIds) do
		local item = ItemConfig.getItem(itemId)
		if item then
			total += item.value
		end
	end

	return total
end

function ItemConfig.getInventoryWeight(itemIds)
	local total = 0

	for _, itemId in ipairs(itemIds) do
		local item = ItemConfig.getItem(itemId)
		if item then
			total += item.weight
		end
	end

	return total
end

function ItemConfig.getRankFromStashValue(stashValue)
	if stashValue >= 25000 then
		return "LEGEND"
	elseif stashValue >= 10000 then
		return "DIAMOND"
	elseif stashValue >= 4000 then
		return "GOLD"
	elseif stashValue >= 1500 then
		return "SILVER"
	elseif stashValue >= 500 then
		return "BRONZE"
	end

	return "ROOKIE"
end

function ItemConfig.rollLoot(randomGenerator, lootTableName)
	local lootTable = ItemConfig.LootTables[lootTableName or "Normal"] or ItemConfig.LootTables.Normal
	local totalWeight = 0

	for _, entry in ipairs(lootTable) do
		totalWeight += entry.weight
	end

	local roll = randomGenerator:NextNumber(0, totalWeight)
	local current = 0

	for _, entry in ipairs(lootTable) do
		current += entry.weight
		if roll <= current then
			return entry.itemId
		end
	end

	return "ScrapMetal"
end

return ItemConfig
