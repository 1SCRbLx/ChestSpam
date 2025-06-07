local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local chestFarmDelay = 0.2
local serverHopDelay = 25
local PlaceId = game.PlaceId
local JobId = game.JobId

local WEBHOOK_URL = "https://discordapp.com/api/webhooks/1380694630106140854/rNvNZMpLgKzE2r8AyvqfU7RZpJEMfneC9M25Mvy8VgYqx83ZIb2EyYgj4vDogLNdhvky"

local teamToJoin = "Pirates"

local function joinTeam(teamName)
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", teamName)
    end)
end

joinTeam(teamToJoin)

local autoFarm = true
local autoHop = true

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ChestFarmBtn = Instance.new("TextButton")
local ServerHopBtn = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0, 300, 0, 100)
Frame.Size = UDim2.new(0, 250, 0, 180)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Text = "SCRbLx Chest Farm + Server Hop"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

ChestFarmBtn.Parent = Frame
ChestFarmBtn.Text = "Auto Chest Farm: ON"
ChestFarmBtn.Size = UDim2.new(0.9, 0, 0, 40)
ChestFarmBtn.Position = UDim2.new(0.05, 0, 0, 60)
ChestFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ChestFarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ChestFarmBtn.Font = Enum.Font.SourceSansBold
ChestFarmBtn.TextSize = 18

ServerHopBtn.Parent = Frame
ServerHopBtn.Text = "Auto Server Hop: ON"
ServerHopBtn.Size = UDim2.new(0.9, 0, 0, 40)
ServerHopBtn.Position = UDim2.new(0.05, 0, 0, 110)
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ServerHopBtn.Font = Enum.Font.SourceSansBold
ServerHopBtn.TextSize = 18

local function farmChest()
    for _,v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:match("Chest") then
            Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Parent.CFrame + Vector3.new(0,3,0)
            wait(chestFarmDelay)
        end
    end
end

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

local function sendWebhook(fruitName, jobId)
    local seaName = getSeaName()
    local playerCount = #Players:GetPlayers()
    local formattedFruitName = "Fruit [ " .. fruitName .. " ]"

    local data = {
        username = "🍎 Fruits",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        embeds = {
            {
                title = "🍎 Fruits Detected!",
                color = 0xff0000,
                fields = {
                    {
                        name = "Spawned Fruit",
                        value = formattedFruitName,
                        inline = false
                    },
                    {
                        name = "Server",
                        value = "Players: "..playerCount.."/12\nSea: "..seaName,
                        inline = false
                    },
                    {
                        name = "Job Id",
                        value = jobId,
                        inline = false
                    }
                },
                footer = {
                    text = "discord.gg/redz-hub"
                },
                timestamp = os.date("!%Y-%m-%dT%TZ")
            }
        }
    }

    local jsonData = HttpService:JSONEncode(data)
    local req = syn and syn.request or http_request or http.request or request
    if req then
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    else
        pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

local detectedFruitNames = {}

local function extractFruitName(v)
    local fruitName = "Unknown"

    if v:IsA("Tool") then
        if v:FindFirstChildWhichIsA("BillboardGui") then
            fruitName = v:FindFirstChildWhichIsA("BillboardGui").TextLabel.Text
        else
            fruitName = v.Name
        end
    elseif v:IsA("Model") or v:IsA("Part") or v:IsA("MeshPart") then
        local handle = v:FindFirstChild("Handle") or v
        if handle:FindFirstChild("FruitName") then
            fruitName = handle.FruitName.Value
        elseif handle:FindFirstChildWhichIsA("BillboardGui") then
            fruitName = handle:FindFirstChildWhichIsA("BillboardGui").TextLabel.Text
        elseif v.Name ~= nil then
            fruitName = v.Name
        end
    end

    return fruitName
end

local function detectFruits()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name:lower():match("fruit") then
            local fruitName = extractFruitName(v)
            fruitName = fruitName:gsub("%s+", "")

            local fruitKey = fruitName:lower() .. "_" .. JobId

            if not detectedFruitNames[fruitKey] then
                detectedFruitNames[fruitKey] = true
                sendWebhook(fruitName, JobId)
            end
        end
    end
end

game.Workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name:lower():match("fruit") then
        wait(0.5)
        detectFruits()
    end
end)

local function getServer()
    local servers = {}
    local req = syn and syn.request or http_request or http.request or request
    if req then
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
        local res = req({
            Url = url,
            Method = "GET"
        })
        local body = HttpService:JSONDecode(res.Body)
        for _,v in pairs(body.data) do
            if v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers,v.id)
            end
        end
    end
    return servers
end

local function serverHop()
    local servers = getServer()
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], player)
    else
        TeleportService:Teleport(PlaceId, player)
    end
end

ChestFarmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    ChestFarmBtn.Text = "Auto Chest Farm: " .. (autoFarm and "ON" or "OFF")
end)

ServerHopBtn.MouseButton1Click:Connect(function()
    autoHop = not autoHop
    ServerHopBtn.Text = "Auto Server Hop: " .. (autoHop and "ON" or "OFF")
end)

spawn(function()
    wait(4)  -- delay 4 detik sebelum mulai auto farming
    while true do
        if autoFarm then
            pcall(farmChest)
            pcall(detectFruits)
        end
        wait(1)
    end
end)

spawn(function()
    wait(4)  -- delay 4 detik sebelum mulai auto server hop
    while true do
        if autoHop then
            wait(serverHopDelay)
            pcall(serverHop)
        else
            wait(1)
        end
    end
end)
