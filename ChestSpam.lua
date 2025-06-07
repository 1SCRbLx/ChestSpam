local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local chestFarmDelay = 0.2
local serverHopDelay = 25
local PlaceId = game.PlaceId
local JobId = game.JobId

local WEBHOOK_URL = "https://discord.com/api/webhooks/1380694630106140854/rNvNZMpLgKzE2r8AyvqfU7RZpJEMfneC9M25Mvy8VgYqx83ZIb2EyYgj4vDogLNdhvky"

local teamToJoin = "Pirates"

local function joinTeam(teamName)
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", teamName)
    end)
end

joinTeam(teamToJoin)

local autoFarm = false
local autoHop = false

local farmLoopRunning = false
local hopLoopRunning = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SCRbLxUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0, 300, 0, 100)
Frame.Size = UDim2.new(0, 250, 0, 180)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Text = "SCRbLx Chest Farm + Server Hop"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local ChestFarmBtn = Instance.new("TextButton")
ChestFarmBtn.Parent = Frame
ChestFarmBtn.Text = "Auto Chest Farm: ON"
ChestFarmBtn.Size = UDim2.new(0.9, 0, 0, 40)
ChestFarmBtn.Position = UDim2.new(0.05, 0, 0, 60)
ChestFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChestFarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ChestFarmBtn.Font = Enum.Font.SourceSansBold
ChestFarmBtn.TextSize = 18

local ServerHopBtn = Instance.new("TextButton")
ServerHopBtn.Parent = Frame
ServerHopBtn.Text = "Auto Server Hop: ON"
ServerHopBtn.Size = UDim2.new(0.9, 0, 0, 40)
ServerHopBtn.Position = UDim2.new(0.05, 0, 0, 110)
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ServerHopBtn.Font = Enum.Font.SourceSansBold
ServerHopBtn.TextSize = 18

-- Fungsi untuk farming chest
local function farmChest()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:match("Chest") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame + Vector3.new(0, 3, 0)
                wait(chestFarmDelay)
            end
        end
    end
end

-- Fungsi deteksi nama buah di server secara dinamis
local function getFruitName()
    -- Cek buah di workspace atau ReplicatedStorage (contoh sederhana)
    local fruitNames = {}
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj.Name:find("Fruit") and obj:IsA("BasePart") then
            table.insert(fruitNames, obj.Name)
        end
    end
    if #fruitNames > 0 then
        return fruitNames[1] -- Ambil buah pertama yang ditemukan
    else
        return "No Fruit Found"
    end
end

-- Fungsi dapatkan nama Sea berdasarkan PlaceId
local function getSeaName()
    if PlaceId == 2753915549 then
        return "Sea1"
    elseif PlaceId == 4442272183 then
        return "Sea2"
    elseif PlaceId == 7449423635 then
        return "Sea3"
    else
        return "Unknown"
    end
end

-- Fungsi kirim webhook dengan embed info fruit dan server
local function sendWebhook(fruitName)
    local seaName = getSeaName()
    local playerCount = #Players:GetPlayers()

    local data = {
        username = "📢 SCRbLx Notification",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        embeds = {{
            title = "Fruit Detected in Server!",
            color = 0x00ff00,
            fields = {
                {name = "Fruit Name", value = fruitName, inline = false},
                {name = "Players", value = tostring(playerCount) .. "/12", inline = true},
                {name = "Sea", value = seaName, inline = true},
                {name = "Job Id", value = tostring(JobId), inline = false}
            },
            footer = {text = "discord.gg/redz-hub"},
            timestamp = os.date("!%Y-%m-%dT%TZ")
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    local req = syn and syn.request or http_request or http.request or request
    if req then
        local response = req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
        if response and response.StatusCode then
            print("[WEBHOOK] Sent with StatusCode:", response.StatusCode)
        else
            warn("[WEBHOOK] No response or invalid response!")
        end
    else
        pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
            print("[WEBHOOK] PostAsync sent (no response available)")
        end)
    end
end

-- Loop farming dengan webhook notifikasi fruit (kirim sekali saat fruit ditemukan)
local fruitNotified = false
local function farmLoop()
    while farmLoopRunning do
        if autoFarm then
            pcall(farmChest)
            if not fruitNotified then
                local fruit = getFruitName()
                if fruit ~= "No Fruit Found" then
                    sendWebhook(fruit)
                    fruitNotified = true
                end
            end
        end
        wait(1)
    end
end

-- Fungsi server hop
local function getServers()
    local servers = {}
    local req = syn and syn.request or http_request or http.request or request
    if req then
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
        local res = req({
            Url = url,
            Method = "GET"
        })
        if res and res.Body then
            local body = HttpService:JSONDecode(res.Body)
            for _,v in pairs(body.data or {}) do
                if v.playing < v.maxPlayers and v.id ~= JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end
    return servers
end

local function serverHop()
    local servers = getServers()
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], player)
    else
        TeleportService:Teleport(PlaceId, player)
    end
end

-- Loop server hop
local function hopLoop()
    while hopLoopRunning do
        if autoHop then
            wait(serverHopDelay)
            pcall(serverHop)
        else
            wait(1)
        end
    end
end

-- Tombol toggle chest farm
ChestFarmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    ChestFarmBtn.Text = "Auto Chest Farm: " .. (autoFarm and "ON" or "OFF")
    if autoFarm and not farmLoopRunning then
        farmLoopRunning = true
        fruitNotified = false
        spawn(farmLoop)
    elseif not autoFarm then
        farmLoopRunning = false
    end
end)

-- Tombol toggle server hop
ServerHopBtn.MouseButton1Click:Connect(function()
    autoHop = not autoHop
    ServerHopBtn.Text = "Auto Server Hop: " .. (autoHop and "ON" or "OFF")
    if autoHop and not hopLoopRunning then
        hopLoopRunning = true
        spawn(hopLoop)
    elseif not autoHop then
        hopLoopRunning = false
    end
end)

-- Jalankan loop awal kalau auto aktif
if autoFarm then
    farmLoopRunning = true
    spawn(farmLoop)
end
if autoHop then
    hopLoopRunning = true
    spawn(hopLoop)
end
