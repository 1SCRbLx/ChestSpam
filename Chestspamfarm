local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local chestFarmDelay = 0.2
local serverHopDelay = 25
local PlaceId = game.PlaceId
local JobId = game.JobId

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
    while true do
        if autoFarm then
            pcall(farmChest)
        end
        wait(1)
    end
end)

spawn(function()
    while true do
        if autoHop then
            wait(serverHopDelay)
            pcall(serverHop)
        else
            wait(1)
        end
    end
end)
