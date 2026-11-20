-- Shared game data for "Noodle Knight's Brainrot Bay" (original make.fun roblox-brainrot-01 entry).
-- One source of truth for the character roster, the rarity ladder and the mutation table,
-- required by both the server (spawning, economy) and the client (HUD colours and labels).

local Config = {}

Config.GameName = "Noodle Knight's Brainrot Bay"
Config.StartCash = 100
Config.MaxWandering = 18
Config.SpawnInterval = 3
Config.WavePeriod = 90
Config.WaveWarning = 10
Config.WaveTravelTime = 9
Config.RebirthBaseCost = 1000
Config.RebirthBonusPer = 0.5

-- Rarity ladder: spawn weight, income multiplier and display colour.
Config.Rarities = {
	{ Name = "Common", Weight = 50, IncomeMult = 1, Color = Color3.fromRGB(200, 200, 200) },
	{ Name = "Uncommon", Weight = 40, IncomeMult = 2, Color = Color3.fromRGB(90, 220, 110) },
	{ Name = "Rare", Weight = 28, IncomeMult = 3, Color = Color3.fromRGB(80, 170, 255) },
	{ Name = "Epic", Weight = 14, IncomeMult = 8, Color = Color3.fromRGB(180, 90, 255) },
	{ Name = "Legendary", Weight = 6, IncomeMult = 20, Color = Color3.fromRGB(255, 190, 40) },
	{ Name = "Divine", Weight = 3, IncomeMult = 80, Color = Color3.fromRGB(255, 245, 200) },
	{ Name = "Mythic", Weight = 2, IncomeMult = 50, Color = Color3.fromRGB(255, 80, 160) },
	{ Name = "Brainrot", Weight = 1, IncomeMult = 150, Color = Color3.fromRGB(255, 40, 40) },
}

-- Mutations rolled at spawn time; IncomeMult multiplies the character's income.
Config.Mutations = {
	{ Name = "", Weight = 62, IncomeMult = 1 },
	{ Name = "Golden", Weight = 18, IncomeMult = 2 },
	{ Name = "Glitch", Weight = 9, IncomeMult = 3 },
	{ Name = "Rainbow", Weight = 3, IncomeMult = 5 },
	{ Name = "Diamond", Weight = 6, IncomeMult = 4 },
	{ Name = "Shadow", Weight = 4, IncomeMult = 6 },
	{ Name = "Cosmic", Weight = 2, IncomeMult = 10 },
}

-- The original roster: twelve absurd characters invented for this game.
-- BaseIncome is cash per second at Common with no mutation.
Config.Characters = {
	{ Name = "Sir Noodleknight", BaseIncome = 1, Color = Color3.fromRGB(245, 210, 120), Scale = 1.0, Hat = "horns" },
	{ Name = "Turbo Toaster", BaseIncome = 1, Color = Color3.fromRGB(190, 190, 200), Scale = 0.9, Hat = "antenna" },
	{ Name = "Baron Von Bubbles", BaseIncome = 2, Color = Color3.fromRGB(140, 220, 255), Scale = 1.1, Hat = "crown" },
	{ Name = "Professor Picklehat", BaseIncome = 2, Color = Color3.fromRGB(110, 200, 90), Scale = 1.0, Hat = "cap" },
	{ Name = "DJ Wafflebot", BaseIncome = 3, Color = Color3.fromRGB(230, 170, 80), Scale = 1.1, Hat = "antenna" },
	{ Name = "Madame Marshmallow", BaseIncome = 3, Color = Color3.fromRGB(255, 200, 225), Scale = 1.2, Hat = "cap" },
	{ Name = "Captain Crumb", BaseIncome = 4, Color = Color3.fromRGB(200, 140, 80), Scale = 1.0, Hat = "cap" },
	{ Name = "Robo Ravioli", BaseIncome = 5, Color = Color3.fromRGB(255, 120, 90), Scale = 1.1, Hat = "chef" },
	{ Name = "Siren Sushi", BaseIncome = 6, Color = Color3.fromRGB(255, 150, 150), Scale = 1.0, Hat = "chef" },
	{ Name = "Wizard Wobble", BaseIncome = 8, Color = Color3.fromRGB(150, 120, 255), Scale = 1.2, Hat = "antenna" },
	{ Name = "Count Churro", BaseIncome = 10, Color = Color3.fromRGB(210, 130, 60), Scale = 1.1, Hat = "chef" },
	{ Name = "Mega Meatball Sage", BaseIncome = 14, Color = Color3.fromRGB(170, 80, 60), Scale = 1.3, Hat = "crown" },
	{ Name = "Sir Spaghetti Shield", BaseIncome = 15, Color = Color3.fromRGB(255, 180, 60), Scale = 1.0, Hat = "horns" },
	{ Name = "Lady Lasagna Lance", BaseIncome = 16, Color = Color3.fromRGB(255, 100, 70), Scale = 1.0, Hat = "horns" },
	{ Name = "Baron Baguette Bay", BaseIncome = 17, Color = Color3.fromRGB(222, 184, 110), Scale = 1.1, Hat = "chef" },
	{ Name = "Captain Crabcake", BaseIncome = 18, Color = Color3.fromRGB(255, 90, 90), Scale = 1.1, Hat = "cap" },
	{ Name = "Duchess Dumpling", BaseIncome = 19, Color = Color3.fromRGB(250, 240, 210), Scale = 0.9, Hat = "crown" },
	{ Name = "Prince Pretzel Pike", BaseIncome = 20, Color = Color3.fromRGB(185, 120, 55), Scale = 1.1, Hat = "crown" },
	{ Name = "Siren Seaweed Soup", BaseIncome = 22, Color = Color3.fromRGB(60, 200, 140), Scale = 1.0, Hat = "none" },
	{ Name = "Turbo Taco Knight", BaseIncome = 24, Color = Color3.fromRGB(255, 205, 50), Scale = 1.2, Hat = "horns" },
	{ Name = "Madame Miso Moon", BaseIncome = 26, Color = Color3.fromRGB(240, 225, 190), Scale = 1.1, Hat = "crown" },
	{ Name = "Count Coconut Cannon", BaseIncome = 28, Color = Color3.fromRGB(130, 90, 60), Scale = 1.2, Hat = "crown" },
	{ Name = "Wizard Wasabi Whirl", BaseIncome = 30, Color = Color3.fromRGB(120, 230, 80), Scale = 1.2, Hat = "antenna" },
	{ Name = "Robo Ramen Rocket", BaseIncome = 32, Color = Color3.fromRGB(255, 160, 40), Scale = 1.3, Hat = "antenna" },
	{ Name = "Queen Quiche Reef", BaseIncome = 34, Color = Color3.fromRGB(255, 215, 130), Scale = 1.2, Hat = "crown" },
	{ Name = "Baron Banana Boat", BaseIncome = 36, Color = Color3.fromRGB(255, 235, 80), Scale = 1.3, Hat = "cap" },
	{ Name = "Professor Pancake Pirate", BaseIncome = 38, Color = Color3.fromRGB(230, 180, 110), Scale = 1.3, Hat = "cap" },
	{ Name = "DJ Donut Diver", BaseIncome = 40, Color = Color3.fromRGB(255, 140, 190), Scale = 1.2, Hat = "antenna" },
	{ Name = "Captain Calamari Crown", BaseIncome = 42, Color = Color3.fromRGB(200, 160, 255), Scale = 1.4, Hat = "crown" },
	{ Name = "Lady Lobster Lantern", BaseIncome = 44, Color = Color3.fromRGB(255, 70, 60), Scale = 1.3, Hat = "cap" },
	{ Name = "Mega Mochi Monarch", BaseIncome = 46, Color = Color3.fromRGB(255, 240, 245), Scale = 1.4, Hat = "crown" },
	{ Name = "Sir Sushi Samurai", BaseIncome = 48, Color = Color3.fromRGB(255, 110, 110), Scale = 1.4, Hat = "horns" },
	{ Name = "Countess Clam Chowder", BaseIncome = 50, Color = Color3.fromRGB(210, 225, 235), Scale = 1.5, Hat = "chef" },
	{ Name = "Wizard Waffle Tempest", BaseIncome = 52, Color = Color3.fromRGB(255, 190, 90), Scale = 1.5, Hat = "antenna" },
	{ Name = "Robo Risotto Rex", BaseIncome = 54, Color = Color3.fromRGB(170, 200, 120), Scale = 1.5, Hat = "antenna" },
	{ Name = "Empress Egg Tart Tide", BaseIncome = 56, Color = Color3.fromRGB(255, 220, 100), Scale = 1.6, Hat = "crown" },
	{ Name = "Baron Burrito Buccaneer", BaseIncome = 57, Color = Color3.fromRGB(160, 200, 80), Scale = 1.6, Hat = "cap" },
	{ Name = "Captain Curry Kraken", BaseIncome = 58, Color = Color3.fromRGB(255, 130, 30), Scale = 1.7, Hat = "horns" },
	{ Name = "Lady Linguine Leviathan", BaseIncome = 59, Color = Color3.fromRGB(120, 220, 220), Scale = 1.7, Hat = "horns" },
	{ Name = "Grand Noodle Neptune", BaseIncome = 60, Color = Color3.fromRGB(80, 140, 255), Scale = 1.8, Hat = "crown" },
}

local function rollFrom(weights)
	local total = 0
	for _, item in ipairs(weights) do
		total += item.Weight
	end
	local roll = math.random() * total
	local acc = 0
	for _, item in ipairs(weights) do
		acc += item.Weight
		if roll <= acc then
			return item
		end
	end
	return weights[#weights]
end

function Config.RollRarity()
	return rollFrom(Config.Rarities)
end

function Config.RollMutation()
	return rollFrom(Config.Mutations)
end

function Config.RandomCharacter()
	return Config.Characters[math.random(1, #Config.Characters)]
end

-- Full display name, e.g. "Rainbow Wizard Wobble (Epic)".
function Config.DisplayName(character, rarity, mutation)
	local prefix = ""
	if mutation and mutation.Name ~= "" then
		prefix = mutation.Name .. " "
	end
	return prefix .. character.Name .. " (" .. rarity.Name .. ")"
end

function Config.IncomeFor(character, rarity, mutation)
	local income = character.BaseIncome * rarity.IncomeMult
	if mutation then
		income *= mutation.IncomeMult
	end
	return income
end

return Config
