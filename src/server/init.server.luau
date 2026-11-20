-- Noodle Knight's Brainrot Bay -- server (ServerScriptService.Server)
-- Economy, character spawning/wandering, collection pads, the tsunami wave cycle and rebirths.
--
-- Layout (built by default.project.json): Workspace.Bases holds four base plots (Base1..Base4),
-- each a Folder with a Platform part and six Pad parts (Pad1..Pad6). Workspace.SpawnField is the
-- central field wandering characters roam. Workspace.TsunamiWave is the wave wall part this
-- script sweeps across the map.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local basesFolder = Workspace:WaitForChild("Bases")
local wavePart = Workspace:WaitForChild("TsunamiWave")

-- Remote the HUD's Rebirth button fires.
local rebirthRemote = Instance.new("RemoteEvent")
rebirthRemote.Name = "RebirthRequest"
rebirthRemote.Parent = ReplicatedStorage

type PlacedEntry = {
	Pad: BasePart,
	Visual: BasePart,
	Income: number,
}

type CarriedEntry = {
	Name: string,
	Income: number,
	Rarity: string,
	CharacterName: string?,
	IsGoldenRunaway: boolean?,
}

type PlayerState = {
	Base: Folder,
	Pads: { BasePart },
	Placed: { PlacedEntry },
	Carried: CarriedEntry?,
	IncomePerSec: number,
}

local states: { [Player]: PlayerState } = {}
local wandering: { BasePart } = {}
local wanderingHeads: { [BasePart]: BasePart } = {}
local waveCycleCount = 0

local function rarityColorOf(name: string): Color3
	for _, rarity in ipairs(Config.Rarities) do
		if rarity.Name == name then
			return rarity.Color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

local function rarityRankOf(name: string): number
	for index, rarity in ipairs(Config.Rarities) do
		if rarity.Name == name then
			return index
		end
	end
	return 1
end

local function lighterShade(color: Color3): Color3
	return Color3.new(math.min(1, color.R + 0.18), math.min(1, color.G + 0.18), math.min(1, color.B + 0.18))
end

local function refreshIncome(player: Player, state: PlayerState)
	local total = 0
	for _, entry in ipairs(state.Placed) do
		total += entry.Income
	end
	local rebirths = 0
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local r = stats:FindFirstChild("Rebirths")
		if r then
			rebirths = r.Value
		end
	end
	state.IncomePerSec = total * (1 + Config.RebirthBonusPer * rebirths)
	player:SetAttribute("IncomePerSec", math.floor(state.IncomePerSec * 10) / 10)
end

local function claimFreeBase(player: Player): Folder?
	for _, base in ipairs(basesFolder:GetChildren()) do
		if base:IsA("Folder") and base:GetAttribute("OwnerUserId") == nil then
			base:SetAttribute("OwnerUserId", player.UserId)
			return base
		end
	end
	return nil
end

local function onPadTouched(state: PlayerState, player: Player, pad: BasePart, hit: BasePart)
	if not state.Carried then
		return
	end
	local character = hit.Parent
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if pad:GetAttribute("Occupied") then
		return
	end
	local carried = state.Carried
	state.Carried = nil
	player:SetAttribute("Carrying", "")
	local visual = Instance.new("Part")
	visual.Name = "PlacedFigure"
	visual.Size = Vector3.new(3, 4, 3)
	visual.Anchored = true
	visual.CanCollide = false
	visual.Color = rarityColorOf(carried.Rarity)
	visual.Position = pad.Position + Vector3.new(0, 2.5, 0)
	visual.Parent = Workspace
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = carried.Name .. "\n$" .. tostring(carried.Income) .. "/s"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextStrokeTransparency = 0.4
	text.TextScaled = true
	text.Font = Enum.Font.SourceSansBold
	text.Parent = gui
	gui.Parent = visual
	visual.Material = Enum.Material.Neon
	pad.Material = Enum.Material.Neon
	pad:SetAttribute("Occupied", true)
	table.insert(state.Placed, { Pad = pad, Visual = visual, Income = carried.Income })
	if carried.IsGoldenRunaway then
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local cashValue = stats:FindFirstChild("Cash")
			if cashValue then
				cashValue.Value += 500
			end
		end
	end
	if carried.CharacterName then
		local indexFolder = player:FindFirstChild("Index")
		if not indexFolder then
			indexFolder = Instance.new("Folder")
			indexFolder.Name = "Index"
			indexFolder.Parent = player
		end
		local entryValue = indexFolder:FindFirstChild(carried.CharacterName)
		if not entryValue then
			entryValue = Instance.new("BoolValue")
			entryValue.Name = carried.CharacterName
			entryValue.Parent = indexFolder
		end
		if entryValue:IsA("BoolValue") then
			entryValue.Value = true
		end
	end
	refreshIncome(player, state)
end

local function teleportToBase(player: Player, base: Folder)
	local character = player.Character
	if not character then
		return
	end
	local platform = base:FindFirstChild("Platform")
	local root = character:FindFirstChild("HumanoidRootPart")
	if platform and root then
		root.CFrame = CFrame.new(platform.Position + Vector3.new(0, 4, 0))
	end
end

local function setupPlayer(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.StartCash
	cash.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = stats
	stats.Parent = player

	local indexFolder = Instance.new("Folder")
	indexFolder.Name = "Index"
	indexFolder.Parent = player

	local base = claimFreeBase(player)
	if not base then
		return
	end
	local pads = {}
	for i = 1, 6 do
		local pad = base:FindFirstChild("Pad" .. tostring(i))
		if pad and pad:IsA("BasePart") then
			table.insert(pads, pad)
		end
	end
	local state: PlayerState = { Base = base, Pads = pads, Placed = {}, Carried = nil, IncomePerSec = 0 }
	states[player] = state
	player:SetAttribute("Carrying", "")
	player:SetAttribute("IncomePerSec", 0)
	for _, pad in ipairs(pads) do
		pad.Touched:Connect(function(hit)
			onPadTouched(state, player, pad, hit)
		end)
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		teleportToBase(player, base)
	end)
	teleportToBase(player, base)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	local state = states[player]
	if state then
		state.Base:SetAttribute("OwnerUserId", nil)
		for _, entry in ipairs(state.Placed) do
			entry.Visual:Destroy()
			entry.Pad:SetAttribute("Occupied", nil)
			entry.Pad.Material = Enum.Material.SmoothPlastic
		end
		states[player] = nil
	end
end)

-- Wandering characters -------------------------------------------------------

local function spawnCharacterInternal(forceGolden: boolean?)
	if not forceGolden and #wandering >= Config.MaxWandering then
		return
	end
	local def = Config.RandomCharacter()
	local rarity = Config.RollRarity()
	local mutation = Config.RollMutation()
	if forceGolden then
		for _, candidate in ipairs(Config.Mutations) do
			if candidate.Name == "Golden" then
				mutation = candidate
			end
		end
	end
	local income = Config.IncomeFor(def, rarity, mutation)
	local scale = def.Scale or 1
	local body = Instance.new("Part")
	body.Name = "BrainrotNPC"
	body.Size = Vector3.new(3 * scale, 4 * scale, 3 * scale)
	body.Anchored = true
	body.CanCollide = false
	body.Color = def.Color
	local displayName = Config.DisplayName(def, rarity, mutation)
	if forceGolden then
		displayName = "GOLDEN RUNAWAY - " .. displayName
	end
	body:SetAttribute("DisplayName", displayName)
	body:SetAttribute("Income", income)
	body:SetAttribute("Rarity", rarity.Name)
	body:SetAttribute("CharacterName", def.Name)
	body:SetAttribute("IsGoldenRunaway", forceGolden == true)
	body:SetAttribute("GoldenBonusPaid", false)
	body:SetAttribute("Phase", math.random() * math.pi * 2)
	body.Position = Vector3.new(math.random(-52, 52), 1 + body.Size.Y / 2, math.random(-52, 52))
	body.Parent = Workspace
	local head = Instance.new("Part")
	head.Name = "BrainrotHead"
	head.Size = body.Size * 0.6
	head.Anchored = true
	head.CanCollide = false
	head.Color = lighterShade(def.Color)
	head.Position = body.Position + Vector3.new(0, body.Size.Y / 2 + head.Size.Y / 2, 0)
	head.Parent = Workspace
	wanderingHeads[body] = head
	local rank = rarityRankOf(rarity.Name)
	if rank >= 4 then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "RaritySparkles"
		emitter.Rate = 20
		emitter.Lifetime = NumberRange.new(0.6, 1.2)
		emitter.Parent = body
	end
	if rank >= 5 then
		local light = Instance.new("PointLight")
		light.Name = "RarityGlow"
		light.Color = rarity.Color
		light.Brightness = 2
		light.Range = 12
		light.Parent = body
	end
	if forceGolden then
		local goldLight = Instance.new("PointLight")
		goldLight.Name = "GoldenGlow"
		goldLight.Color = Color3.fromRGB(255, 215, 0)
		goldLight.Brightness = 3
		goldLight.Range = 14
		goldLight.Parent = body
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = displayName .. "\n$" .. tostring(income) .. "/s"
	text.TextColor3 = rarity.Color
	text.TextStrokeTransparency = 0.4
	text.TextScaled = true
	text.Font = Enum.Font.SourceSansBold
	text.Parent = gui
	gui.Parent = body
	body:SetAttribute("TargetX", body.Position.X)
	body:SetAttribute("TargetZ", body.Position.Z)
	table.insert(wandering, body)
	body.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		local state = states[player]
		if not state or state.Carried then
			return
		end
		local isGolden = body:GetAttribute("IsGoldenRunaway") == true
		local bonusPaid = body:GetAttribute("GoldenBonusPaid") == true
		state.Carried = {
			Name = body:GetAttribute("DisplayName"),
			Income = body:GetAttribute("Income"),
			Rarity = body:GetAttribute("Rarity"),
			CharacterName = body:GetAttribute("CharacterName"),
			IsGoldenRunaway = isGolden and not bonusPaid,
		}
		if isGolden then
			body:SetAttribute("GoldenBonusPaid", true)
		end
		player:SetAttribute("Carrying", state.Carried.Name)
		local idx = table.find(wandering, body)
		if idx then
			table.remove(wandering, idx)
		end
		local headPart = wanderingHeads[body]
		wanderingHeads[body] = nil
		if headPart then
			headPart:Destroy()
		end
		body:Destroy()
	end)
end

local function spawnCharacter()
	spawnCharacterInternal(false)
end

local function spawnGoldenRunaway()
	spawnCharacterInternal(true)
end

task.spawn(function()
	while true do
		spawnCharacter()
		task.wait(Config.SpawnInterval)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()
	for _, body in ipairs(wandering) do
		local pos = body.Position
		local tx = body:GetAttribute("TargetX")
		local tz = body:GetAttribute("TargetZ")
		local dx = tx - pos.X
		local dz = tz - pos.Z
		local dist = math.sqrt(dx * dx + dz * dz)
		local phase = body:GetAttribute("Phase") or 0
		local bob = math.sin(now * 3 + phase) * 0.3
		local baseY = 1 + body.Size.Y / 2
		local newPos = pos
		if dist < 2 then
			body:SetAttribute("TargetX", math.random(-52, 52))
			body:SetAttribute("TargetZ", math.random(-52, 52))
			newPos = Vector3.new(pos.X, baseY + bob, pos.Z)
		else
			local step = 6 * dt
			newPos = Vector3.new(pos.X + dx / dist * step, baseY + bob, pos.Z + dz / dist * step)
		end
		local spin = (now * 0.8 + phase) % (math.pi * 2)
		body.CFrame = CFrame.new(newPos) * CFrame.Angles(0, spin, 0)
		local head = wanderingHeads[body]
		if head then
			local headPos = newPos + Vector3.new(0, body.Size.Y / 2 + head.Size.Y / 2, 0)
			head.CFrame = CFrame.new(headPos) * CFrame.Angles(0, spin, 0)
		end
	end
end)

-- Income loop ----------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(1)
		for player, state in pairs(states) do
			if state.IncomePerSec > 0 then
				local stats = player:FindFirstChild("leaderstats")
				if stats then
					local cash = stats:FindFirstChild("Cash")
					if cash then
						cash.Value += math.floor(state.IncomePerSec)
					end
				end
			end
		end
	end
end)

-- Rebirth --------------------------------------------------------------------
rebirthRemote.OnServerEvent:Connect(function(player)
	local state = states[player]
	if not state then
		return
	end
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local cash = stats:FindFirstChild("Cash")
	local rebirths = stats:FindFirstChild("Rebirths")
	if not cash or not rebirths then
		return
	end
	local cost = Config.RebirthBaseCost * (rebirths.Value + 1)
	if cash.Value < cost then
		return
	end
	rebirths.Value += 1
	cash.Value = Config.StartCash
	state.Carried = nil
	player:SetAttribute("Carrying", "")
	for _, entry in ipairs(state.Placed) do
		entry.Visual:Destroy()
		entry.Pad:SetAttribute("Occupied", nil)
		entry.Pad.Material = Enum.Material.SmoothPlastic
	end
	state.Placed = {}
	refreshIncome(player, state)
end)

-- Tsunami wave cycle -----------------------------------------------------------
local function isSafe(player: Player): boolean
	local state = states[player]
	if not state or not player.Character then
		return false
	end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	local platform = state.Base:FindFirstChild("Platform")
	if not root or not platform then
		return false
	end
	local dx = math.abs(root.Position.X - platform.Position.X)
	local dz = math.abs(root.Position.Z - platform.Position.Z)
	return dx <= platform.Size.X / 2 and dz <= platform.Size.Z / 2
end

task.spawn(function()
	while true do
		for t = Config.WavePeriod, 1, -1 do
			Workspace:SetAttribute("WaveCountdown", t)
			Workspace:SetAttribute("WaveWarning", t <= Config.WaveWarning)
			task.wait(1)
		end
		Workspace:SetAttribute("WaveCountdown", 0)
		local startX = -230
		local endX = 230
		local steps = 90
		for i = 0, steps do
			local x = startX + (endX - startX) * (i / steps)
			wavePart.Position = Vector3.new(x, 10, 0)
			for player, state in pairs(states) do
				if state.Carried and player.Character then
					local root = player.Character:FindFirstChild("HumanoidRootPart")
					if root and math.abs(root.Position.X - x) < 5 and not isSafe(player) then
						state.Carried = nil
						player:SetAttribute("Carrying", "")
						player:SetAttribute("WaveLost", os.clock())
					end
				end
			end
			task.wait(Config.WaveTravelTime / steps)
		end
		wavePart.Position = Vector3.new(0, -60, 0)
		Workspace:SetAttribute("WaveWarning", false)
		waveCycleCount += 1
		if waveCycleCount % 3 == 0 then
			spawnGoldenRunaway()
		end
	end
end)

print(Config.GameName .. " server ready: " .. tostring(#Config.Characters) .. " original characters loaded.")
