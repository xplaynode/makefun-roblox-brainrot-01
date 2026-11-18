-- Shared game data for "Noodle Knight's Brainrot Bay" (original make.fun roblox-brainrot-01 entry).
-- One source of truth for the character roster, the rarity ladder and the mutation table,
-- required by both the server (spawning, economy) and the client (HUD colours and labels).

local Config = {}

Config.GameName = "Noodle Knight's Brainrot Bay"
Config.StartCash = 100
Config.MaxWandering = 12
Config.SpawnInterval = 3
Config.WavePeriod = 90
Config.WaveWarning = 10
Config.WaveTravelTime = 9
Config.RebirthBaseCost = 1000
Config.RebirthBonusPer = 0.5

-- Rarity ladder: spawn weight, income multiplier and display colour.
Config.Rarities = {
	{ Name = "Common", Weight = 50, IncomeMult = 1, Color = Color3.fromRGB(200, 200, 200) },
	{ Name = "Rare", Weight = 28, IncomeMult = 3, Color = Color3.fromRGB(80, 170, 255) },
	{ Name = "Epic", Weight = 14, IncomeMult = 8, Color = Color3.fromRGB(180, 90, 255) },
	{ Name = "Legendary", Weight = 6, IncomeMult = 20, Color = Color3.fromRGB(255, 190, 40) },
	{ Name = "Mythic", Weight = 2, IncomeMult = 50, Color = Color3.fromRGB(255, 80, 160) },
}

-- Mutations rolled at spawn time; IncomeMult multiplies the character's income.
Config.Mutations = {
	{ Name = "", Weight = 70, IncomeMult = 1 },
	{ Name = "Golden", Weight = 18, IncomeMult = 2 },
	{ Name = "Glitch", Weight = 9, IncomeMult = 3 },
	{ Name = "Rainbow", Weight = 3, IncomeMult = 5 },
}

-- The original roster: twelve absurd characters invented for this game.
-- BaseIncome is cash per second at Common with no mutation.
Config.Characters = {
	{ Name = "Sir Noodleknight", BaseIncome = 1, Color = Color3.fromRGB(245, 210, 120) },
	{ Name = "Turbo Toaster", BaseIncome = 1, Color = Color3.fromRGB(190, 190, 200) },
	{ Name = "Baron Von Bubbles", BaseIncome = 2, Color = Color3.fromRGB(140, 220, 255) },
	{ Name = "Professor Picklehat", BaseIncome = 2, Color = Color3.fromRGB(110, 200, 90) },
	{ Name = "DJ Wafflebot", BaseIncome = 3, Color = Color3.fromRGB(230, 170, 80) },
	{ Name = "Madame Marshmallow", BaseIncome = 3, Color = Color3.fromRGB(255, 200, 225) },
	{ Name = "Captain Crumb", BaseIncome = 4, Color = Color3.fromRGB(200, 140, 80) },
	{ Name = "Robo Ravioli", BaseIncome = 5, Color = Color3.fromRGB(255, 120, 90) },
	{ Name = "Siren Sushi", BaseIncome = 6, Color = Color3.fromRGB(255, 150, 150) },
	{ Name = "Wizard Wobble", BaseIncome = 8, Color = Color3.fromRGB(150, 120, 255) },
	{ Name = "Count Churro", BaseIncome = 10, Color = Color3.fromRGB(210, 130, 60) },
	{ Name = "Mega Meatball Sage", BaseIncome = 14, Color = Color3.fromRGB(170, 80, 60) },
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
