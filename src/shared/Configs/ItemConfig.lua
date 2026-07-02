local ItemConfig = {}

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
	GoldRelic = {
		id = "GoldRelic",
		name = "Gold Relic",
		rarity = "Legendary",
		value = 1250,
		weight = 3,
	},
}

ItemConfig.LootTable = {
	{ itemId = "ScrapMetal", weight = 45 },
	{ itemId = "BatteryCell", weight = 30 },
	{ itemId = "BlueCircuit", weight = 16 },
	{ itemId = "VaultKey", weight = 7 },
	{ itemId = "EncryptedCore", weight = 2 },
	{ itemId = "GoldRelic", weight = 0.5 },
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

function ItemConfig.rollLoot(randomGenerator)
	local totalWeight = 0

	for _, entry in ipairs(ItemConfig.LootTable) do
		totalWeight += entry.weight
	end

	local roll = randomGenerator:NextNumber(0, totalWeight)
	local current = 0

	for _, entry in ipairs(ItemConfig.LootTable) do
		current += entry.weight
		if roll <= current then
			return entry.itemId
		end
	end

	return "ScrapMetal"
end

return ItemConfig
