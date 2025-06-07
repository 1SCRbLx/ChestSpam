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

-- Perbaikan fungsi getFruitName()
local function getFruitName()
    local fruitNames = {}
    
    -- Cek di Workspace
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj.Name:find("Fruit") and (obj:IsA("BasePart") or obj:IsA("Tool")) then
            table.insert(fruitNames, obj.Name)
        end
    end
    
    -- Cek juga di ReplicatedStorage
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj.Name:find("Fruit") and (obj:IsA("BasePart") or obj:IsA("Tool")) then
            table.insert(fruitNames, obj.Name)
        end
    end

    if #fruitNames > 0 then
        return fruitNames[1] -- Ambil buah pertama yang ditemukan
    else
        return "No Fruit Found"
    end
end
