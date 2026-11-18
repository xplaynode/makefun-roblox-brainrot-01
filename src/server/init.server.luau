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

local function rarityColorOf(name: string): Color3
	for _, rarity in ipairs(Config.Rarities) do
		if rarity.Name == name then
			return rarity.Color
		end
	end
	return Color3.fromRGB(255, 255, 255)
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
	pad:SetAttribute("Occupied", true)
	table.insert(state.Placed, { Pad = pad, Visual = visual, Income = carried.Income })
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
		end
		states[player] = nil
	end
end)

-- Wandering characters -------------------------------------------------------

local function spawnCharacter()
	if #wandering >= Config.MaxWandering then
		return
	end
	local def = Config.RandomCharacter()
	local rarity = Config.RollRarity()
	local mutation = Config.RollMutation()
	local income = Config.IncomeFor(def, rarity, mutation)
	local body = Instance.new("Part")
	body.Name = "BrainrotNPC"
	body.Size = Vector3.new(3, 4, 3)
	body.Anchored = true
	body.CanCollide = false
	body.Color = def.Color
	body:SetAttribute("DisplayName", Config.DisplayName(def, rarity, mutation))
	body:SetAttribute("Income", income)
	body:SetAttribute("Rarity", rarity.Name)
	body.Position = Vector3.new(math.random(-52, 52), 3, math.random(-52, 52))
	body.Parent = Workspace
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = Config.DisplayName(def, rarity, mutation) .. "\n$" .. tostring(income) .. "/s"
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
		state.Carried = {
			Name = body:GetAttribute("DisplayName"),
			Income = body:GetAttribute("Income"),
			Rarity = body:GetAttribute("Rarity"),
		}
		player:SetAttribute("Carrying", state.Carried.Name)
		local idx = table.find(wandering, body)
		if idx then
			table.remove(wandering, idx)
		end
		body:Destroy()
	end)
end

task.spawn(function()
	while true do
		spawnCharacter()
		task.wait(Config.SpawnInterval)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	for _, body in ipairs(wandering) do
		local pos = body.Position
		local tx = body:GetAttribute("TargetX")
		local tz = body:GetAttribute("TargetZ")
		local dx = tx - pos.X
		local dz = tz - pos.Z
		local dist = math.sqrt(dx * dx + dz * dz)
		if dist < 2 then
			body:SetAttribute("TargetX", math.random(-52, 52))
			body:SetAttribute("TargetZ", math.random(-52, 52))
		else
			local step = 6 * dt
			body.Position = Vector3.new(pos.X + dx / dist * step, 3, pos.Z + dz / dist * step)
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
	end
end)

print(Config.GameName .. " server ready: " .. tostring(#Config.Characters) .. " original characters loaded.")
