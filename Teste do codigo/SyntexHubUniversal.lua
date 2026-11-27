--[[
    SYNTEX HUB
    Interface visual em Luau

    LocalScript:
    StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    Name = "SYNTEX HUB",
    Version = "3.1.0",
    LogoImage = "rbxassetid://92098547337251",
    Theme = {
        Background = Color3.fromRGB(9, 8, 13),
        Surface = Color3.fromRGB(17, 14, 24),
        SurfaceLight = Color3.fromRGB(25, 20, 35),
        Purple = Color3.fromRGB(133, 0, 255),
        Magenta = Color3.fromRGB(192, 0, 255),
        Lavender = Color3.fromRGB(201, 184, 232),
        White = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(135, 126, 150),
    }
}

local T = CONFIG.Theme
local StorageSystem = {
    Available = false,
    Root = "Syntex Ultra",
    HubFolder = "Syntex Ultra/Syntex Hub Universal",
    ImagesFolder = "Syntex Ultra/Syntex Hub Universal/Images",
    SettingsFolder = "Syntex Ultra/Syntex Hub Universal/Settings",
    ImagePath = "Syntex Ultra/Syntex Hub Universal/Images/Logo.png",
    SettingsPath = nil,
    Status = "Armazenamento não configurado",
    AutoSave = true,
    SaveTask = nil,
}

local function executorCall(name, ...)
    local success, result = pcall(function()
        local fn = nil
        if getfenv then
            fn = getfenv(0)[name]
        elseif _G then
            fn = _G[name]
        end
        if fn then
            return fn(...)
        end
        return nil
    end)
    if success then
        return result
    end
    return nil
end

local function hasExecutorFunction(name)
    local success, value = pcall(function()
        if getfenv then
            return getfenv(0)[name]
        end
        if _G then
            return _G[name]
        end
        return nil
    end)
    return success and type(value) == "function"
end

StorageSystem.Available = hasExecutorFunction("isfolder")
    and hasExecutorFunction("makefolder")
    and hasExecutorFunction("writefile")
    and hasExecutorFunction("readfile")
    and hasExecutorFunction("isfile")

if StorageSystem.Available then
    pcall(function()
        if not executorCall("isfolder", StorageSystem.Root) then
            executorCall("makefolder", StorageSystem.Root)
        end
        if not executorCall("isfolder", StorageSystem.HubFolder) then
            executorCall("makefolder", StorageSystem.HubFolder)
        end
        if not executorCall("isfolder", StorageSystem.ImagesFolder) then
            executorCall("makefolder", StorageSystem.ImagesFolder)
        end
        if not executorCall("isfolder", StorageSystem.SettingsFolder) then
            executorCall("makefolder", StorageSystem.SettingsFolder)
        end
    end)
    StorageSystem.SettingsPath = StorageSystem.SettingsFolder
        .. "/" .. tostring(LocalPlayer.UserId) .. ".json"

    local logoExists = executorCall("isfile", StorageSystem.ImagePath)
    if not logoExists then
        local downloaded = false
        pcall(function()
            local response
            if syn and syn.request then
                response = syn.request({
                    Url = "https://raw.githubusercontent.com/ph4ntomservices/SyntexHub/main/Arquivos%20Extras/file_000000002774820e87bfd80f29e8e44e.png",
                    Method = "GET",
                })
            elseif http_request then
                response = http_request({
                    Url = "https://raw.githubusercontent.com/ph4ntomservices/SyntexHub/main/Arquivos%20Extras/file_000000002774820e87bfd80f29e8e44e.png",
                    Method = "GET",
                })
            elseif request then
                response = request({
                    Url = "https://raw.githubusercontent.com/ph4ntomservices/SyntexHub/main/Arquivos%20Extras/file_000000002774820e87bfd80f29e8e44e.png",
                    Method = "GET",
                })
            end

            if response and response.Success ~= false
                and type(response.Body) == "string"
                and #response.Body > 0 then
                executorCall("writefile", StorageSystem.ImagePath, response.Body)
                downloaded = true
            end
        end)

        if downloaded and executorCall("isfile", StorageSystem.ImagePath) then
            StorageSystem.Status = "Logo oficial salva"
        end
    end

    if executorCall("isfile", StorageSystem.ImagePath) then
        pcall(function()
            if getcustomasset then
                local customAsset = getcustomasset(StorageSystem.ImagePath)
                if type(customAsset) == "string" and #customAsset > 0 then
                    CONFIG.LogoImage = customAsset
                end
            end
        end)
        if StorageSystem.Status == "Armazenamento não configurado" then
            StorageSystem.Status = "Armazenamento local disponível"
        end
    else
        StorageSystem.Status = "Armazenamento local disponível"
    end
else
    StorageSystem.Status = "Armazenamento local não suportado"
end

local HubSettings = {
    UIScale = 1,
    Keybind = Enum.KeyCode.RightControl,
    KeybindName = "RightControl",
    Notifications = true,
    PerformanceMode = false,
}

local scheduleHubProfileSave = function()
end

local oldGui = PlayerGui:FindFirstChild("SyntexHubUI")
if oldGui then
    oldGui:Destroy()
end

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, parent)
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or T.Purple,
        Transparency = transparency or 0,
        Thickness = thickness or 1
    }, parent)
end

local function tween(object, duration, properties)
    if HubSettings and HubSettings.PerformanceMode then
        duration = math.min(duration, 0.05)
    end
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function makeLabel(parent, text, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or T.White,
        TextSize = size or 13,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 0, 22),
    }, parent)
end

local ScreenGui = create("ScreenGui", {
    Name = "SyntexHubUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100
}, PlayerGui)

local connections = {}
local function trackConnection(connection)
    table.insert(connections, connection)
    return connection
end

local destroyConnection
destroyConnection = ScreenGui.Destroying:Connect(function()
    for featureId in pairs(ActiveFeatures) do
        disableFeature(featureId)
    end
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    destroyConnection:Disconnect()
end)

local Main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.53),
    Size = UDim2.fromOffset(690, 455),
    BackgroundColor3 = T.Background,
    ClipsDescendants = true
}, ScreenGui)
corner(Main, 13)
stroke(Main, T.Purple, 0.25, 1.3)

create("UISizeConstraint", {
    MinSize = Vector2.new(330, 300),
    MaxSize = Vector2.new(900, 650)
}, Main)

local Header = create("Frame", {
    Name = "Header",
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 57),
    BorderSizePixel = 0
}, Main)

create("ImageLabel", {
    Name = "Logo",
    BackgroundTransparency = 1,
    Image = CONFIG.LogoImage,
    Position = UDim2.fromOffset(15, 8),
    Size = UDim2.fromOffset(40, 40),
    ScaleType = Enum.ScaleType.Fit
}, Header)

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(63, 8),
    Size = UDim2.fromOffset(190, 23),
    Text = CONFIG.Name,
    TextColor3 = T.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(64, 29),
    Size = UDim2.fromOffset(150, 17),
    Text = "VERSION " .. CONFIG.Version,
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local Minimize = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -77, 0, 13),
    Size = UDim2.fromOffset(27, 27),
    Text = "—",
    TextColor3 = T.Lavender,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, Header)
corner(Minimize, 7)

local Close = create("TextButton", {
    BackgroundColor3 = Color3.fromRGB(70, 25, 43),
    Position = UDim2.new(1, -42, 0, 13),
    Size = UDim2.fromOffset(27, 27),
    Text = "×",
    TextColor3 = T.White,
    TextSize = 18,
    Font = Enum.Font.Gotham,
    AutoButtonColor = false
}, Header)
corner(Close, 7)

local dragging = false
local dragStart
local startPosition

trackConnection(Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.X > Header.AbsolutePosition.X + Header.AbsoluteSize.X - 90 then
            return
        end
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

trackConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

local TabBar = create("ScrollingFrame", {
    Name = "Tabs",
    BackgroundColor3 = T.Surface,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 57),
    Size = UDim2.new(1, 0, 0, 43),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.X,
    ScrollingDirection = Enum.ScrollingDirection.X,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = T.Purple
}, Main)

create("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 5)
}, TabBar)

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center
}, TabBar)

local Content = create("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 100),
    Size = UDim2.new(1, 0, 1, -100)
}, Main)

local Pages = {}
local TabButtons = {}
local tabOrder = 0

local function createPage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 17),
        PaddingRight = UDim.new(0, 17),
        PaddingBottom = UDim.new(0, 17)
    }, page)

    create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function addTab(name, icon)
    tabOrder += 1
    local tab = create("TextButton", {
        Name = name .. "Tab",
        BackgroundColor3 = T.Surface,
        Size = UDim2.fromOffset(88, 31),
        Text = icon .. "  " .. name,
        TextColor3 = T.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        LayoutOrder = tabOrder
    }, TabBar)
    corner(tab, 8)
    TabButtons[name] = tab
    return tab
end

local function showPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for tabName, tab in pairs(TabButtons) do
        local selected = tabName == name
        tween(tab, 0.15, {
            BackgroundColor3 = selected and Color3.fromRGB(48, 20, 70) or T.Surface,
            TextColor3 = selected and T.White or T.Muted
        })
    end
end

local function addSectionTitle(parent, text)
    local title = makeLabel(parent, string.upper(text), 10, T.Muted, Enum.Font.GothamBold)
    title.Size = UDim2.new(1, 0, 0, 20)
end

local function addCard(parent, height)
    local card = create("Frame", {
        BackgroundColor3 = T.Surface,
        Size = UDim2.new(1, 0, 0, height),
        BorderSizePixel = 0
    }, parent)
    corner(card, 9)
    stroke(card, T.Purple, 0.82, 1)
    return card
end

local function addReservedRow(parent, title, description)
    local row = create("Frame", {
        BackgroundColor3 = T.Surface,
        Size = UDim2.new(1, 0, 0, 58),
        BorderSizePixel = 0
    }, parent)
    corner(row, 8)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -115, 0, 21),
        Text = title,
        TextColor3 = T.Lavender,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -115, 0, 18),
        Text = description or "Espaço reservado para implementação futura.",
        TextColor3 = T.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local badge = create("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(39, 24, 53),
        Position = UDim2.new(1, -94, 0.5, -12),
        Size = UDim2.fromOffset(82, 24),
        Text = "EM BREVE",
        TextColor3 = T.Lavender,
        TextSize = 8,
        Font = Enum.Font.GothamBold
    }, row)
    corner(badge, 6)

end

local ActiveFeatures = {}
local FeatureDefinitions = {}

local ActiveCard
local ActiveEmptyLabel
local ActiveDescriptionLabel

local function refreshActiveFeatures()
    if not ActiveCard or not ActiveEmptyLabel or not ActiveDescriptionLabel then
        return
    end

    for _, definition in pairs(FeatureDefinitions) do
        if definition.Button then
            definition.Button.Text = ActiveFeatures[definition.Id] and "DESATIVAR" or "ATIVAR"
        end
    end

    for _, child in ipairs(ActiveCard:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local names = {}
    for _, definition in pairs(FeatureDefinitions) do
        if ActiveFeatures[definition.Id] then
            table.insert(names, definition.Name)
        end
    end
    table.sort(names)

    if #names == 0 then
        ActiveEmptyLabel.Visible = true
        ActiveDescriptionLabel.Visible = true
        ActiveCard.Size = UDim2.new(1, 0, 0, 68)
        return
    end

    ActiveEmptyLabel.Visible = false
    ActiveDescriptionLabel.Visible = false
    ActiveCard.Size = UDim2.new(1, 0, 0, math.max(68, 14 + (#names * 32)))

    for index, name in ipairs(names) do
        local featureId
        for id, definition in pairs(FeatureDefinitions) do
            if definition.Name == name then
                featureId = id
                break
            end
        end

        local button = create("TextButton", {
            BackgroundColor3 = T.SurfaceLight,
            Position = UDim2.fromOffset(14, 10 + ((index - 1) * 32)),
            Size = UDim2.new(1, -28, 0, 26),
            Text = name .. "  •  DESATIVAR",
            TextColor3 = T.Lavender,
            TextSize = 9,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false
        }, ActiveCard)
        corner(button, 6)
        stroke(button, T.Purple, 0.82, 1)
        trackConnection(button.MouseButton1Click:Connect(function()
            if featureId then
                disableFeature(featureId)
            end
        end))
    end
end

function registerFeature(id, name, enableCallback, disableCallback)
    FeatureDefinitions[id] = {
        Id = id,
        Name = name,
        Enable = enableCallback,
        Disable = disableCallback,
    }
end

function enableFeature(id)
    local definition = FeatureDefinitions[id]
    if not definition or ActiveFeatures[id] then
        return
    end

    local success, errorMessage = pcall(definition.Enable)
    if success then
        ActiveFeatures[id] = true
        refreshActiveFeatures()
    else
        warn("SYNTEX HUB: falha ao ativar " .. definition.Name .. " — " .. tostring(errorMessage))
    end
end

function disableFeature(id)
    local definition = FeatureDefinitions[id]
    if not definition or not ActiveFeatures[id] then
        return
    end

    local success, errorMessage = pcall(definition.Disable)
    if success then
        ActiveFeatures[id] = nil
        refreshActiveFeatures()
    else
        warn("SYNTEX HUB: falha ao desativar " .. definition.Name .. " — " .. tostring(errorMessage))
    end
end

local function toggleFeature(id)
    if ActiveFeatures[id] then
        disableFeature(id)
    else
        enableFeature(id)
    end
end

local function addFeatureRow(parent, id, title, description)
    local row = create("Frame", {
        BackgroundColor3 = T.Surface,
        Size = UDim2.new(1, 0, 0, 58),
        BorderSizePixel = 0
    }, parent)
    corner(row, 8)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -115, 0, 21),
        Text = title,
        TextColor3 = T.Lavender,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -115, 0, 18),
        Text = description,
        TextColor3 = T.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local button = create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(39, 24, 53),
        Position = UDim2.new(1, -94, 0.5, -12),
        Size = UDim2.fromOffset(82, 24),
        Text = "ATIVAR",
        TextColor3 = T.Lavender,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, row)
    corner(button, 6)

    trackConnection(button.MouseButton1Click:Connect(function()
        toggleFeature(id)
        button.Text = ActiveFeatures[id] and "DESATIVAR" or "ATIVAR"
    end))

    local definition = FeatureDefinitions[id]
    if definition then
        definition.Button = button
    end

    return row, button
end

local function addNumericFeatureRow(parent, id, title, description, defaultValue, onValueChanged)
    local row, button = addFeatureRow(parent, id, title, description)

    local box = create("TextBox", {
        BackgroundColor3 = T.SurfaceLight,
        Position = UDim2.new(1, -148, 0.5, -12),
        Size = UDim2.fromOffset(48, 24),
        Text = tostring(defaultValue),
        PlaceholderText = tostring(defaultValue),
        TextColor3 = T.White,
        PlaceholderColor3 = T.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false
    }, row)
    corner(box, 6)
    stroke(box, T.Purple, 0.75, 1)

    trackConnection(box:GetPropertyChangedSignal("Text"):Connect(function()
        local value = tonumber(box.Text)
        if value and value >= 0 then
            onValueChanged(value)
        end
    end))

    return row, button, box
end

-- Início
local Home = createPage("Inicio")
addTab("Início", "⌂")
addSectionTitle(Home, "Perfil do jogador")

local ProfileCard = addCard(Home, 92)
local Avatar = create("ImageLabel", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.fromOffset(64, 64),
    Image = "",
    ScaleType = Enum.ScaleType.Crop
}, ProfileCard)
corner(Avatar, 32)
stroke(Avatar, T.Purple, 0.35, 1)

local AvatarImage = Players:GetUserThumbnailAsync(
    LocalPlayer.UserId,
    Enum.ThumbnailType.HeadShot,
    Enum.ThumbnailSize.Size100x100
)
Avatar.Image = AvatarImage

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(91, 23),
    Size = UDim2.new(1, -105, 0, 23),
    Text = LocalPlayer.DisplayName,
    TextColor3 = T.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, ProfileCard)

create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(91, 48),
    Size = UDim2.new(1, -105, 0, 18),
    Text = "@" .. LocalPlayer.Name,
    TextColor3 = T.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, ProfileCard)

addSectionTitle(Home, "Funcionalidades ativas")
ActiveCard = addCard(Home, 68)
ActiveEmptyLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -28, 0, 22),
    Text = "Nenhuma funcionalidade ativa",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, ActiveCard)
ActiveDescriptionLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 34),
    Size = UDim2.new(1, -28, 0, 19),
    Text = "Use DESATIVAR para encerrar qualquer função ativada.",
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
}, ActiveCard)

-- Jogador
local PlayerPage = createPage("Jogador")
addTab("Jogador", "♙")
addSectionTitle(PlayerPage, "Atributos do jogador")

local WalkSpeedState = {
    Desired = 16,
    Originals = {},
    CharacterConnection = nil,
}

local function applyWalkSpeed(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if not WalkSpeedState.Originals[character] then
        WalkSpeedState.Originals[character] = humanoid.WalkSpeed
    end
    humanoid.WalkSpeed = WalkSpeedState.Desired
end

registerFeature("walkspeed", "WalkSpeed", function()
    local character = LocalPlayer.Character
    applyWalkSpeed(character)
    WalkSpeedState.CharacterConnection = trackConnection(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.defer(function()
            if ActiveFeatures["walkspeed"] then
                applyWalkSpeed(newCharacter)
            end
        end)
    end))
end, function()
    for character, originalSpeed in pairs(WalkSpeedState.Originals) do
        if character and character.Parent then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalSpeed
            end
        end
    end
    table.clear(WalkSpeedState.Originals)
    if WalkSpeedState.CharacterConnection then
        WalkSpeedState.CharacterConnection:Disconnect()
        WalkSpeedState.CharacterConnection = nil
    end
end)

local _, _, WalkSpeedBox = addNumericFeatureRow(
    PlayerPage,
    "walkspeed",
    "Velocidade",
    "WalkSpeed do personagem local",
    16,
    function(value)
        WalkSpeedState.Desired = math.clamp(value, 0, 1000)
        local character = LocalPlayer.Character
        if ActiveFeatures["walkspeed"] and character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = WalkSpeedState.Desired
            end
        end
        scheduleHubProfileSave()
    end
)

local JumpPowerState = {
    Desired = 50,
    Originals = {},
    CharacterConnection = nil,
}

local function applyJumpPower(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if not JumpPowerState.Originals[character] then
        JumpPowerState.Originals[character] = {
            UseJumpPower = humanoid.UseJumpPower,
            JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight,
        }
    end
    humanoid.UseJumpPower = true
    humanoid.JumpPower = JumpPowerState.Desired
end

registerFeature("jumppower", "JumpPower", function()
    applyJumpPower(LocalPlayer.Character)
    JumpPowerState.CharacterConnection = trackConnection(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.defer(function()
            if ActiveFeatures["jumppower"] then
                applyJumpPower(newCharacter)
            end
        end)
    end))
end, function()
    for character, original in pairs(JumpPowerState.Originals) do
        if character and character.Parent then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = original.UseJumpPower
                humanoid.JumpPower = original.JumpPower
                humanoid.JumpHeight = original.JumpHeight
            end
        end
    end
    table.clear(JumpPowerState.Originals)
    if JumpPowerState.CharacterConnection then
        JumpPowerState.CharacterConnection:Disconnect()
        JumpPowerState.CharacterConnection = nil
    end
end)

addNumericFeatureRow(
    PlayerPage,
    "jumppower",
    "Força do pulo",
    "JumpPower / UseJumpPower",
    50,
    function(value)
        JumpPowerState.Desired = math.clamp(value, 0, 1000)
        local character = LocalPlayer.Character
        if ActiveFeatures["jumppower"] and character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = JumpPowerState.Desired
            end
        end
        scheduleHubProfileSave()
    end
)

local InfiniteJumpConnection = nil
registerFeature("infinitejump", "Pulo infinito", function()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
    end
    InfiniteJumpConnection = trackConnection(UserInputService.JumpRequest:Connect(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end, function()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end)
addFeatureRow(PlayerPage, "infinitejump", "Pulo infinito", "Permite pular enquanto estiver no ar")

-- Movimentação
local MovementPage = createPage("Movimentacao")
addTab("Movimentação", "↗")
addSectionTitle(MovementPage, "Movimentação")

local NoclipState = {
    Originals = {},
    CharacterConnection = nil,
    DescendantConnections = {},
    HeartbeatConnection = nil,
}

local function restoreNoclipCharacter(character)
    local originalParts = NoclipState.Originals[character]
    if not originalParts then
        return
    end
    for part, canCollide in pairs(originalParts) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    NoclipState.Originals[character] = nil
end

local function applyNoclipCharacter(character)
    if not character then
        return
    end

    NoclipState.Originals[character] = NoclipState.Originals[character] or {}
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local originalParts = NoclipState.Originals[character]
            if originalParts[descendant] == nil then
                originalParts[descendant] = descendant.CanCollide
            end
            descendant.CanCollide = false
        end
    end

    if not NoclipState.DescendantConnections[character] then
        NoclipState.DescendantConnections[character] = trackConnection(character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") and ActiveFeatures["noclip"] then
                local originalParts = NoclipState.Originals[character]
                if originalParts and originalParts[descendant] == nil then
                    originalParts[descendant] = descendant.CanCollide
                end
                descendant.CanCollide = false
            end
        end))
    end
end

registerFeature("noclip", "Noclip", function()
    applyNoclipCharacter(LocalPlayer.Character)
    NoclipState.CharacterConnection = trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
        task.defer(function()
            if ActiveFeatures["noclip"] then
                applyNoclipCharacter(character)
            end
        end)
    end))
    NoclipState.HeartbeatConnection = trackConnection(RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            applyNoclipCharacter(character)
        end
    end))
end, function()
    if NoclipState.CharacterConnection then
        NoclipState.CharacterConnection:Disconnect()
        NoclipState.CharacterConnection = nil
    end
    if NoclipState.HeartbeatConnection then
        NoclipState.HeartbeatConnection:Disconnect()
        NoclipState.HeartbeatConnection = nil
    end
    for character, connection in pairs(NoclipState.DescendantConnections) do
        connection:Disconnect()
        restoreNoclipCharacter(character)
    end
    table.clear(NoclipState.DescendantConnections)
end)
addFeatureRow(MovementPage, "noclip", "Noclip", "Atravessa partes do mapa")

local FlyState = {
    DesiredSpeed = 50,
    RenderConnection = nil,
    InputBeganConnection = nil,
    InputEndedConnection = nil,
    CharacterConnection = nil,
    Keys = {},
    Originals = {},
}

local function restoreFlyCharacter(character)
    local original = FlyState.Originals[character]
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and original then
        humanoid.PlatformStand = original.PlatformStand
        humanoid.AutoRotate = original.AutoRotate
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    FlyState.Originals[character] = nil
end

local function applyFlyCharacter(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and not FlyState.Originals[character] then
        FlyState.Originals[character] = {
            PlatformStand = humanoid.PlatformStand,
            AutoRotate = humanoid.AutoRotate,
        }
    end
    if humanoid then
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
    end
end

registerFeature("fly", "Fly", function()
    disableFeature("freecamera")
    applyFlyCharacter(LocalPlayer.Character)
    FlyState.CharacterConnection = trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
        task.defer(function()
            if ActiveFeatures["fly"] then
                applyFlyCharacter(character)
            end
        end)
    end))
    FlyState.InputBeganConnection = trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        FlyState.Keys[input.KeyCode] = true
    end))
    FlyState.InputEndedConnection = trackConnection(UserInputService.InputEnded:Connect(function(input)
        FlyState.Keys[input.KeyCode] = nil
    end))
    FlyState.RenderConnection = trackConnection(RunService.RenderStepped:Connect(function(deltaTime)
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then
            return
        end

        local camera = Workspace.CurrentCamera
        local move = Vector3.zero
        if FlyState.Keys[Enum.KeyCode.W] then move += camera.CFrame.LookVector end
        if FlyState.Keys[Enum.KeyCode.S] then move -= camera.CFrame.LookVector end
        if FlyState.Keys[Enum.KeyCode.D] then move += camera.CFrame.RightVector end
        if FlyState.Keys[Enum.KeyCode.A] then move -= camera.CFrame.RightVector end
        if FlyState.Keys[Enum.KeyCode.Space] or FlyState.Keys[Enum.KeyCode.E] then move += Vector3.yAxis end
        if FlyState.Keys[Enum.KeyCode.LeftControl] or FlyState.Keys[Enum.KeyCode.Q] then move -= Vector3.yAxis end

        if move.Magnitude > 0 then
            move = move.Unit * FlyState.DesiredSpeed
        end
        root.AssemblyLinearVelocity = move
        root.AssemblyAngularVelocity = Vector3.zero
        humanoid.PlatformStand = true
    end))
end, function()
    for character in pairs(FlyState.Originals) do
        restoreFlyCharacter(character)
    end
    table.clear(FlyState.Keys)
    for _, connectionName in ipairs({
        "RenderConnection",
        "InputBeganConnection",
        "InputEndedConnection",
        "CharacterConnection",
    }) do
        local connection = FlyState[connectionName]
        if connection then
            connection:Disconnect()
            FlyState[connectionName] = nil
        end
    end
end)
addNumericFeatureRow(
    MovementPage,
    "fly",
    "Fly",
    "WASD + Espaço/Q ou Ctrl",
    50,
    function(value)
        FlyState.DesiredSpeed = math.clamp(value, 0, 500)
        scheduleHubProfileSave()
    end
)

local ClickTPConnection = nil
registerFeature("clicktp", "Click TP", function()
    if ClickTPConnection then
        ClickTPConnection:Disconnect()
    end
    ClickTPConnection = trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        local camera = Workspace.CurrentCamera
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not camera or not root then
            return
        end

        local mouseLocation = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = character and {character} or {}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
        if not result then
            return
        end

        local look = root.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude == 0 then
            look = Vector3.new(0, 0, -1)
        end
        local target = result.Position + Vector3.new(0, 3, 0)
        root.PivotTo(CFrame.lookAt(target, target + look.Unit))
    end))
end, function()
    if ClickTPConnection then
        ClickTPConnection:Disconnect()
        ClickTPConnection = nil
    end
end)
addFeatureRow(MovementPage, "clicktp", "Click TP", "Clique com o mouse no ponto do mapa")

local FreeCameraState = {
    DesiredSpeed = 32,
    RenderConnection = nil,
    InputBeganConnection = nil,
    InputEndedConnection = nil,
    InputChangedConnection = nil,
    Keys = {},
    Yaw = 0,
    Pitch = 0,
    OriginalType = nil,
    OriginalSubject = nil,
    OriginalCFrame = nil,
}

registerFeature("freecamera", "Free Camera", function()
    disableFeature("fly")
    local camera = Workspace.CurrentCamera
    if not camera then
        error("Câmera indisponível")
    end

    FreeCameraState.OriginalType = camera.CameraType
    FreeCameraState.OriginalSubject = camera.CameraSubject
    FreeCameraState.OriginalCFrame = camera.CFrame

    local _, yaw, _ = camera.CFrame:ToEulerAnglesYXZ()
    FreeCameraState.Yaw = yaw
    FreeCameraState.Pitch = 0
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = nil

    FreeCameraState.InputBeganConnection = trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            FreeCameraState.Keys[input.KeyCode] = true
        end
    end))
    FreeCameraState.InputEndedConnection = trackConnection(UserInputService.InputEnded:Connect(function(input)
        FreeCameraState.Keys[input.KeyCode] = nil
    end))
    FreeCameraState.InputChangedConnection = trackConnection(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            FreeCameraState.Yaw -= input.Delta.X * 0.003
            FreeCameraState.Pitch = math.clamp(
                FreeCameraState.Pitch - input.Delta.Y * 0.003,
                -math.pi / 2 + 0.05,
                math.pi / 2 - 0.05
            )
        end
    end))
    FreeCameraState.RenderConnection = trackConnection(RunService.RenderStepped:Connect(function(deltaTime)
        local currentCamera = Workspace.CurrentCamera
        if not currentCamera then
            return
        end

        local move = Vector3.zero
        local right = currentCamera.CFrame.RightVector
        local look = currentCamera.CFrame.LookVector
        if FreeCameraState.Keys[Enum.KeyCode.W] then move += look end
        if FreeCameraState.Keys[Enum.KeyCode.S] then move -= look end
        if FreeCameraState.Keys[Enum.KeyCode.D] then move += right end
        if FreeCameraState.Keys[Enum.KeyCode.A] then move -= right end
        if FreeCameraState.Keys[Enum.KeyCode.E] or FreeCameraState.Keys[Enum.KeyCode.Space] then move += Vector3.yAxis end
        if FreeCameraState.Keys[Enum.KeyCode.Q] or FreeCameraState.Keys[Enum.KeyCode.LeftControl] then move -= Vector3.yAxis end

        local rotation = CFrame.Angles(0, FreeCameraState.Yaw, 0)
            * CFrame.Angles(FreeCameraState.Pitch, 0, 0)
        if move.Magnitude > 0 then
            local speed = FreeCameraState.DesiredSpeed
            if FreeCameraState.Keys[Enum.KeyCode.LeftShift] then
                speed *= 3
            end
            currentCamera.CFrame = currentCamera.CFrame + move.Unit * speed * deltaTime
        end
        currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position) * rotation
    end))
end, function()
    table.clear(FreeCameraState.Keys)
    for _, connectionName in ipairs({
        "RenderConnection",
        "InputBeganConnection",
        "InputEndedConnection",
        "InputChangedConnection",
    }) do
        local connection = FreeCameraState[connectionName]
        if connection then
            connection:Disconnect()
            FreeCameraState[connectionName] = nil
        end
    end

    local camera = Workspace.CurrentCamera
    if camera then
        camera.CameraType = FreeCameraState.OriginalType or Enum.CameraType.Custom
        camera.CameraSubject = FreeCameraState.OriginalSubject
        if FreeCameraState.OriginalCFrame then
            camera.CFrame = FreeCameraState.OriginalCFrame
        end
    end
    FreeCameraState.OriginalType = nil
    FreeCameraState.OriginalSubject = nil
    FreeCameraState.OriginalCFrame = nil
end)
addNumericFeatureRow(
    MovementPage,
    "freecamera",
    "Free Camera",
    "WASD + E/Q, mouse livre",
    32,
    function(value)
        FreeCameraState.DesiredSpeed = math.clamp(value, 0, 500)
        scheduleHubProfileSave()
    end
)

-- Teleporte
local TeleportPage = createPage("Teleporte")
addTab("Teleporte", "⌖")
addSectionTitle(TeleportPage, "Posição")

local SavedTeleportPosition = nil

local function getLocalRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function teleportExact(position)
    local root = getLocalRoot()
    if not root then
        return false
    end

    local _, yaw, _ = root.CFrame:ToEulerAnglesYXZ()
    root.PivotTo(CFrame.new(position) * CFrame.Angles(0, yaw, 0))
    return true
end

local function teleportLocalRoot(position)
    local root = getLocalRoot()
    if not root then
        return false
    end

    local yLevel = position.Y
    local groundParams = RaycastParams.new()
    groundParams.FilterType = Enum.RaycastFilterType.Exclude
    groundParams.FilterDescendantsInstances = LocalPlayer.Character and {LocalPlayer.Character} or {}
    local groundResult = Workspace:Raycast(
        Vector3.new(position.X, position.Y + 200, position.Z),
        Vector3.new(0, -1000, 0),
        groundParams
    )
    if groundResult then
        yLevel = groundResult.Position.Y + 3
    end

    local _, yaw, _ = root.CFrame:ToEulerAnglesYXZ()
    root.PivotTo(CFrame.new(position.X, yLevel, position.Z)
        * CFrame.Angles(0, yaw, 0))
    return true
end

local PositionCard = addCard(TeleportPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Retornar à posição",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, PositionCard)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = "Salva antes do próximo teleporte.",
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, PositionCard)

local ReturnButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -94, 0.5, -12),
    Size = UDim2.fromOffset(82, 24),
    Text = "RETORNAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, PositionCard)
corner(ReturnButton, 6)
stroke(ReturnButton, T.Purple, 0.88, 1)

trackConnection(ReturnButton.MouseButton1Click:Connect(function()
    if SavedTeleportPosition then
        teleportExact(SavedTeleportPosition)
    end
end))

local CoordinatesCard = addCard(TeleportPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(0, 118, 0, 21),
    Text = "Teleporte por coordenadas",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, CoordinatesCard)

local CoordinateBoxes = {}
for index, axis in ipairs({"X", "Y", "Z"}) do
    CoordinateBoxes[axis] = create("TextBox", {
        BackgroundColor3 = T.SurfaceLight,
        Position = UDim2.fromOffset(13 + ((index - 1) * 58), 31),
        Size = UDim2.fromOffset(50, 20),
        Text = "0",
        PlaceholderText = axis,
        TextColor3 = T.White,
        PlaceholderColor3 = T.Muted,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false
    }, CoordinatesCard)
    corner(CoordinateBoxes[axis], 5)
    stroke(CoordinateBoxes[axis], T.Purple, 0.75, 1)
end

local CoordinatesButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -94, 0.5, -12),
    Size = UDim2.fromOffset(82, 24),
    Text = "TELEPORTAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, CoordinatesCard)
corner(CoordinatesButton, 6)
stroke(CoordinatesButton, T.Purple, 0.88, 1)

trackConnection(CoordinatesButton.MouseButton1Click:Connect(function()
    local x = tonumber(CoordinateBoxes.X.Text)
    local y = tonumber(CoordinateBoxes.Y.Text)
    local z = tonumber(CoordinateBoxes.Z.Text)
    if not x or not y or not z then
        return
    end

    local root = getLocalRoot()
    if root then
        SavedTeleportPosition = root.CFrame.Position
        teleportExact(Vector3.new(x, y, z))
    end
end))

addSectionTitle(TeleportPage, "Jogadores")
local PlayerList = create("ScrollingFrame", {
    Name = "PlayerList",
    BackgroundColor3 = T.Surface,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 108),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = T.Purple
}, TeleportPage)
corner(PlayerList, 8)
create("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 6)
}, PlayerList)
create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, PlayerList)

local SelectedTeleportPlayer = nil

local function refreshPlayerList()
    if not PlayerList.Parent then
        return
    end

    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if SelectedTeleportPlayer and not table.find(Players:GetPlayers(), SelectedTeleportPlayer) then
        SelectedTeleportPlayer = nil
    end

    local playerList = Players:GetPlayers()
    table.sort(playerList, function(first, second)
        return string.lower(first.Name) < string.lower(second.Name)
    end)

    for _, player in ipairs(playerList) do
        local playerRow = create("TextButton", {
            BackgroundColor3 = player == SelectedTeleportPlayer
                and Color3.fromRGB(48, 20, 70)
                or T.SurfaceLight,
            Size = UDim2.new(1, 0, 0, 28),
            Text = player.DisplayName .. "  @" .. player.Name,
            TextColor3 = T.Lavender,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        }, PlayerList)
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 9)
        }, playerRow)
        corner(playerRow, 5)
        trackConnection(playerRow.MouseButton1Click:Connect(function()
            SelectedTeleportPlayer = player
            refreshPlayerList()
        end))
    end
end

refreshPlayerList()
trackConnection(Players.PlayerAdded:Connect(refreshPlayerList))
trackConnection(Players.PlayerRemoving:Connect(function()
    task.defer(refreshPlayerList)
end))

local TeleportControls = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 37)
}, TeleportPage)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, TeleportControls)

local function addActionControl(parent, text, callback)
    local control = create("TextButton", {
        BackgroundColor3 = T.SurfaceLight,
        Size = UDim2.new(0.5, -4, 0, 34),
        Text = text,
        TextColor3 = T.Lavender,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    }, parent)
    corner(control, 7)
    stroke(control, T.Purple, 0.88, 1)
    trackConnection(control.MouseButton1Click:Connect(callback))
end

addActionControl(TeleportControls, "TP Player", function()
    if not SelectedTeleportPlayer then
        return
    end
    local targetRoot = SelectedTeleportPlayer.Character
        and SelectedTeleportPlayer.Character:FindFirstChild("HumanoidRootPart")
    local root = getLocalRoot()
    if targetRoot and root then
        SavedTeleportPosition = root.CFrame.Position
        root.PivotTo(targetRoot.CFrame + targetRoot.CFrame.RightVector * 3)
    end
end)
addActionControl(TeleportControls, "Atualizar", refreshPlayerList)

-- Visual
local VisualPage = createPage("Visual")
addTab("Visual", "◉")
addSectionTitle(VisualPage, "Opções visuais")

local VisualState = {
    EspObjects = {},
    NameObjects = {},
    DistanceObjects = {},
    HighlightObjects = {},
    EspConnection = nil,
    NameConnection = nil,
    DistanceConnection = nil,
    HighlightConnection = nil,
    PlayerConnections = {},
}

local function destroyStoredObject(tableOfObjects, player)
    local object = tableOfObjects[player]
    if object then
        object:Destroy()
        tableOfObjects[player] = nil
    end
end

local function getTrackedRoot(player)
    local character = player and player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function updateEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = getTrackedRoot(player)
            if root then
                local billboard = VisualState.EspObjects[player]
                if not billboard or not billboard.Parent then
                    billboard = create("BillboardGui", {
                        Name = "SYNTEX_ESP",
                        Adornee = root,
                        AlwaysOnTop = true,
                        Size = UDim2.fromOffset(58, 92),
                        StudsOffset = Vector3.new(0, 0, 0),
                        MaxDistance = 1000
                    }, root)
                    local box = create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        BorderSizePixel = 0
                    }, billboard)
                    stroke(box, T.Purple, 0.15, 1)
                    corner(box, 2)
                    VisualState.EspObjects[player] = billboard
                else
                    billboard.Adornee = root
                end
            else
                destroyStoredObject(VisualState.EspObjects, player)
            end
        end
    end
end

registerFeature("esp", "ESP", function()
    updateEsp()
    VisualState.EspConnection = trackConnection(RunService.RenderStepped:Connect(updateEsp))
end, function()
    if VisualState.EspConnection then
        VisualState.EspConnection:Disconnect()
        VisualState.EspConnection = nil
    end
    for player in pairs(VisualState.EspObjects) do
        destroyStoredObject(VisualState.EspObjects, player)
    end
end)
addFeatureRow(VisualPage, "esp", "ESP", "Destaca outros jogadores")

local function updateNameEsp()
    local localRoot = getLocalRoot()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = getTrackedRoot(player)
            if root then
                local billboard = VisualState.NameObjects[player]
                if not billboard or not billboard.Parent then
                    billboard = create("BillboardGui", {
                        Name = "SYNTEX_NAME_ESP",
                        Adornee = root,
                        AlwaysOnTop = true,
                        Size = UDim2.fromOffset(220, 24),
                        StudsOffset = Vector3.new(0, 3.2, 0),
                        MaxDistance = 1000
                    }, root)
                    create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Text = player.DisplayName .. "  @" .. player.Name,
                        TextColor3 = T.White,
                        TextSize = 12,
                        Font = Enum.Font.GothamBold,
                        TextStrokeTransparency = 0.25,
                        TextStrokeColor3 = Color3.new(0, 0, 0)
                    }, billboard)
                    VisualState.NameObjects[player] = billboard
                else
                    billboard.Adornee = root
                end
            else
                destroyStoredObject(VisualState.NameObjects, player)
            end
        end
    end
end

registerFeature("nameesp", "Name ESP", function()
    updateNameEsp()
    VisualState.NameConnection = trackConnection(RunService.RenderStepped:Connect(updateNameEsp))
end, function()
    if VisualState.NameConnection then
        VisualState.NameConnection:Disconnect()
        VisualState.NameConnection = nil
    end
    for player in pairs(VisualState.NameObjects) do
        destroyStoredObject(VisualState.NameObjects, player)
    end
end)
addFeatureRow(VisualPage, "nameesp", "Name ESP", "Mostra nomes sobre personagens")

local function updateDistanceEsp()
    local localRoot = getLocalRoot()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = getTrackedRoot(player)
            if root and localRoot then
                local billboard = VisualState.DistanceObjects[player]
                if not billboard or not billboard.Parent then
                    billboard = create("BillboardGui", {
                        Name = "SYNTEX_DISTANCE_ESP",
                        Adornee = root,
                        AlwaysOnTop = true,
                        Size = UDim2.fromOffset(180, 24),
                        StudsOffset = Vector3.new(0, -3.2, 0),
                        MaxDistance = 1000
                    }, root)
                    create("TextLabel", {
                        Name = "DistanceLabel",
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Text = "0 studs",
                        TextColor3 = T.Lavender,
                        TextSize = 11,
                        Font = Enum.Font.GothamMedium,
                        TextStrokeTransparency = 0.25,
                        TextStrokeColor3 = Color3.new(0, 0, 0)
                    }, billboard)
                    VisualState.DistanceObjects[player] = billboard
                else
                    billboard.Adornee = root
                end

                local label = billboard:FindFirstChild("DistanceLabel")
                if label then
                    local distance = (root.Position - localRoot.Position).Magnitude
                    label.Text = string.format("%d studs", math.floor(distance + 0.5))
                end
            else
                destroyStoredObject(VisualState.DistanceObjects, player)
            end
        end
    end
end

registerFeature("distanceesp", "Distance ESP", function()
    updateDistanceEsp()
    VisualState.DistanceConnection = trackConnection(RunService.RenderStepped:Connect(updateDistanceEsp))
end, function()
    if VisualState.DistanceConnection then
        VisualState.DistanceConnection:Disconnect()
        VisualState.DistanceConnection = nil
    end
    for player in pairs(VisualState.DistanceObjects) do
        destroyStoredObject(VisualState.DistanceObjects, player)
    end
end)
addFeatureRow(VisualPage, "distanceesp", "Distance ESP", "Exibe distância em studs")

local function updateHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local highlight = VisualState.HighlightObjects[player]
                if not highlight or not highlight.Parent then
                    highlight = create("Highlight", {
                        Name = "SYNTEX_HIGHLIGHT",
                        Adornee = character,
                        FillColor = T.Purple,
                        FillTransparency = 0.65,
                        OutlineColor = T.White,
                        OutlineTransparency = 0
                    }, character)
                    VisualState.HighlightObjects[player] = highlight
                else
                    highlight.Adornee = character
                end
            else
                destroyStoredObject(VisualState.HighlightObjects, player)
            end
        end
    end
end

registerFeature("highlight", "Highlight", function()
    updateHighlights()
    VisualState.HighlightConnection = trackConnection(RunService.RenderStepped:Connect(updateHighlights))
end, function()
    if VisualState.HighlightConnection then
        VisualState.HighlightConnection:Disconnect()
        VisualState.HighlightConnection = nil
    end
    for player in pairs(VisualState.HighlightObjects) do
        destroyStoredObject(VisualState.HighlightObjects, player)
    end
end)
addFeatureRow(VisualPage, "highlight", "Highlight", "Destaque local com cores do tema")

local RemoveVisualButton = create("TextButton", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 58),
    Text = "REMOVER TODOS OS VISUAIS",
    TextColor3 = T.Lavender,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, VisualPage)
corner(RemoveVisualButton, 8)
stroke(RemoveVisualButton, T.Purple, 0.82, 1)

trackConnection(RemoveVisualButton.MouseButton1Click:Connect(function()
    disableFeature("esp")
    disableFeature("nameesp")
    disableFeature("distanceesp")
    disableFeature("highlight")
end))

trackConnection(Players.PlayerRemoving:Connect(function(player)
    destroyStoredObject(VisualState.EspObjects, player)
    destroyStoredObject(VisualState.NameObjects, player)
    destroyStoredObject(VisualState.DistanceObjects, player)
    destroyStoredObject(VisualState.HighlightObjects, player)
end))

-- Mundo
local WorldPage = createPage("Mundo")
addTab("Mundo", "◇")
addSectionTitle(WorldPage, "Opções do mundo")

local WorldOriginals = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FieldOfView = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
}

local WorldState = {
    Time = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FogEnabled = Lighting.FogEnd < 100000,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    Fov = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
}

local TimeCard = addCard(WorldPage, 58)
local TimeLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Time Control",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, TimeCard)
local TimeValueLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = "Atual: " .. string.format("%02d:%02d", math.floor(Lighting.ClockTime), (Lighting.ClockTime % 1) * 60),
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, TimeCard)
local TimeBox = create("TextBox", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -148, 0.5, -12),
    Size = UDim2.fromOffset(48, 24),
    Text = tostring(math.floor(Lighting.ClockTime)),
    PlaceholderText = "0-24",
    TextColor3 = T.White,
    PlaceholderColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false
}, TimeCard)
corner(TimeBox, 6)
stroke(TimeBox, T.Purple, 0.75, 1)

registerFeature("timecontrol", "Time Control", function()
    Lighting.ClockTime = WorldState.Time
end, function()
    Lighting.ClockTime = WorldOriginals.ClockTime
end)
local _, TimeButton = addFeatureRow(WorldPage, "timecontrol", "Horário local", "Altera ClockTime local")
TimeButton.Position = UDim2.new(1, -94, 0.5, -12)

trackConnection(TimeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local value = tonumber(TimeBox.Text)
    if value then
        WorldState.Time = math.clamp(value, 0, 24)
        if ActiveFeatures["timecontrol"] then
            Lighting.ClockTime = WorldState.Time
        end
        TimeValueLabel.Text = "Atual: " .. string.format("%02d:%02d", math.floor(WorldState.Time), (WorldState.Time % 1) * 60)
        scheduleHubProfileSave()
    end
end))

registerFeature("brightness", "Brightness", function()
    Lighting.Brightness = WorldState.Brightness
end, function()
    Lighting.Brightness = WorldOriginals.Brightness
end)
addNumericFeatureRow(WorldPage, "brightness", "Brightness", "Brilho local", math.clamp(math.floor(Lighting.Brightness), 0, 10), function(value)
    WorldState.Brightness = math.clamp(value, 0, 10)
    if ActiveFeatures["brightness"] then
        Lighting.Brightness = WorldState.Brightness
    end
    scheduleHubProfileSave()
end)

registerFeature("fog", "Fog Control", function()
    WorldState.FogEnabled = true
    if WorldState.FogEnabled then
        Lighting.FogStart = WorldState.FogStart
        Lighting.FogEnd = WorldState.FogEnd
    end
end, function()
    WorldState.FogEnabled = false
    Lighting.FogStart = WorldOriginals.FogStart
    Lighting.FogEnd = WorldOriginals.FogEnd
end)

local FogCard = addCard(WorldPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Fog Control",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, FogCard)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = "Ativa/desativa e ajusta distância.",
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, FogCard)

local FogStartBox = create("TextBox", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -148, 0.5, -12),
    Size = UDim2.fromOffset(48, 24),
    Text = tostring(math.max(0, math.floor(WorldState.FogStart))),
    PlaceholderText = "Start",
    TextColor3 = T.White,
    PlaceholderColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false
}, FogCard)
corner(FogStartBox, 6)
stroke(FogStartBox, T.Purple, 0.75, 1)

trackConnection(FogStartBox:GetPropertyChangedSignal("Text"):Connect(function()
    local value = tonumber(FogStartBox.Text)
    if value then
        WorldState.FogStart = math.max(0, value)
        if ActiveFeatures["fog"] then
            Lighting.FogStart = WorldState.FogStart
        end
        scheduleHubProfileSave()
    end
end))
local FogEndBox = create("TextBox", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -202, 0.5, -12),
    Size = UDim2.fromOffset(48, 24),
    Text = tostring(math.max(0, math.floor(WorldState.FogEnd))),
    PlaceholderText = "End",
    TextColor3 = T.White,
    PlaceholderColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false
}, FogCard)
corner(FogEndBox, 6)
stroke(FogEndBox, T.Purple, 0.75, 1)
trackConnection(FogEndBox:GetPropertyChangedSignal("Text"):Connect(function()
    local value = tonumber(FogEndBox.Text)
    if value then
        WorldState.FogEnd = math.max(WorldState.FogStart, value)
        if ActiveFeatures["fog"] then
            Lighting.FogEnd = WorldState.FogEnd
        end
        scheduleHubProfileSave()
    end
end))
local FogButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -94, 0.5, -12),
    Size = UDim2.fromOffset(82, 24),
    Text = "ATIVAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, FogCard)
corner(FogButton, 6)
trackConnection(FogButton.MouseButton1Click:Connect(function()
    toggleFeature("fog")
    FogButton.Text = ActiveFeatures["fog"] and "DESATIVAR" or "ATIVAR"
end))
local FogDefinition = FeatureDefinitions["fog"]
if FogDefinition then
    FogDefinition.Button = FogButton
end

registerFeature("fov", "Field of View", function()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = WorldState.Fov
    end
end, function()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = WorldOriginals.FieldOfView
    end
end)
addNumericFeatureRow(WorldPage, "fov", "Field of View", "Campo de visão da câmera", WorldState.Fov, function(value)
    WorldState.Fov = math.clamp(value, 30, 120)
    local camera = Workspace.CurrentCamera
    if ActiveFeatures["fov"] and camera then
        camera.FieldOfView = WorldState.Fov
    end
    scheduleHubProfileSave()
end)

registerFeature("graphicsquality", "Graphics Quality", function()
    local success, gameSettings = pcall(function()
        return UserSettings():GetService("UserGameSettings")
    end)
    if success and gameSettings then
        gameSettings.SavedQualityLevel = WorldState.GraphicsQuality
    end
end, function()
    local success, gameSettings = pcall(function()
        return UserSettings():GetService("UserGameSettings")
    end)
    if success and gameSettings then
        gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.Automatic
    end
end)

WorldState.GraphicsQuality = Enum.SavedQualitySetting.Automatic
local QualityCard = addCard(WorldPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Graphics Quality",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, QualityCard)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = "Qualidade disponível ao cliente.",
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, QualityCard)

local QualityBox = create("TextBox", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -148, 0.5, -12),
    Size = UDim2.fromOffset(48, 24),
    Text = "AUTO",
    PlaceholderText = "AUTO",
    TextColor3 = T.White,
    PlaceholderColor3 = T.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false
}, QualityCard)
corner(QualityBox, 6)
stroke(QualityBox, T.Purple, 0.75, 1)
trackConnection(QualityBox:GetPropertyChangedSignal("Text"):Connect(function()
    local quality = string.upper(QualityBox.Text)
    local values = {
        ["LOW"] = Enum.SavedQualitySetting.Low,
        ["MEDIUM"] = Enum.SavedQualitySetting.Medium,
        ["HIGH"] = Enum.SavedQualitySetting.High,
        ["AUTO"] = Enum.SavedQualitySetting.Automatic,
    }
    if values[quality] then
        WorldState.GraphicsQuality = values[quality]
        if ActiveFeatures["graphicsquality"] then
            local success, gameSettings = pcall(function()
                return UserSettings():GetService("UserGameSettings")
            end)
            if success and gameSettings then
                gameSettings.SavedQualityLevel = WorldState.GraphicsQuality
            end
        end
        scheduleHubProfileSave()
    end
end))
addFeatureRow(WorldPage, "graphicsquality", "Graphics Quality", "Low / Medium / High / Auto")

registerFeature("worldreset", "Reset World Settings", function()
    Lighting.ClockTime = WorldOriginals.ClockTime
    Lighting.Brightness = WorldOriginals.Brightness
    Lighting.FogStart = WorldOriginals.FogStart
    Lighting.FogEnd = WorldOriginals.FogEnd
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = WorldOriginals.FieldOfView
    end
    local success, gameSettings = pcall(function()
        return UserSettings():GetService("UserGameSettings")
    end)
    if success and gameSettings then
        gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.Automatic
    end
    WorldState.Time = WorldOriginals.ClockTime
    WorldState.Brightness = WorldOriginals.Brightness
    WorldState.FogStart = WorldOriginals.FogStart
    WorldState.FogEnd = WorldOriginals.FogEnd
    WorldState.Fov = WorldOriginals.FieldOfView
    WorldState.GraphicsQuality = Enum.SavedQualitySetting.Automatic
end, function()
end)
addFeatureRow(WorldPage, "worldreset", "Reset World Settings", "Restaura valores originais")

-- Configurações
local SettingsPage = createPage("Configuracoes")
addTab("Configurações", "⚙")
addSectionTitle(SettingsPage, "Preferências gerais")

local function defaultHubProfile()
    return {
        UserId = tostring(LocalPlayer.UserId),
        WalkSpeed = 16,
        JumpPower = 50,
        FlySpeed = 50,
        FreeCameraSpeed = 32,
        World = {
            Time = Lighting.ClockTime,
            Brightness = Lighting.Brightness,
            FogEnabled = false,
            FogStart = 0,
            FogEnd = 100000,
            Fov = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
            GraphicsQuality = "Automatic",
        },
        UI = {
            Scale = 1,
            Keybind = "RightControl",
            Notifications = true,
            PerformanceMode = false,
        },
        Visual = {
            Esp = false,
            NameEsp = false,
            DistanceEsp = false,
            Highlight = false,
        },
        Teleport = {
            ReturnPosition = nil,
        },
        ActiveSafe = {},
    }
end

local function validNumber(value, minimum, maximum, fallback)
    if type(value) ~= "number" or value ~= value then
        return fallback
    end
    return math.clamp(value, minimum, maximum)
end

local function collectHubProfile()
    local profile = defaultHubProfile()
    profile.WalkSpeed = validNumber(WalkSpeedState and WalkSpeedState.Desired, 0, 1000, 16)
    profile.JumpPower = validNumber(JumpPowerState and JumpPowerState.Desired, 0, 1000, 50)
    profile.FlySpeed = validNumber(FlyState and FlyState.DesiredSpeed, 0, 500, 50)
    profile.FreeCameraSpeed = validNumber(FreeCameraState and FreeCameraState.DesiredSpeed, 0, 500, 32)
    profile.World.Time = validNumber(WorldState and WorldState.Time, 0, 24, Lighting.ClockTime)
    profile.World.Brightness = validNumber(WorldState and WorldState.Brightness, 0, 10, Lighting.Brightness)
    profile.World.FogEnabled = WorldState and WorldState.FogEnabled or false
    profile.World.FogStart = validNumber(WorldState and WorldState.FogStart, 0, 100000, 0)
    profile.World.FogEnd = validNumber(WorldState and WorldState.FogEnd, 0, 100000, 100000)
    profile.World.Fov = validNumber(WorldState and WorldState.Fov, 30, 120, 70)
    profile.World.GraphicsQuality = QualityBox and QualityBox.Text or "AUTO"
    profile.UI.Scale = validNumber(HubSettings and HubSettings.UIScale, 0.75, 1.25, 1)
    profile.UI.Keybind = HubSettings and HubSettings.KeybindName or "RightControl"
    profile.UI.Notifications = HubSettings and HubSettings.Notifications or true
    profile.UI.PerformanceMode = HubSettings and HubSettings.PerformanceMode or false

    if ActiveFeatures then
        profile.Visual.Esp = ActiveFeatures["esp"] == true
        profile.Visual.NameEsp = ActiveFeatures["nameesp"] == true
        profile.Visual.DistanceEsp = ActiveFeatures["distanceesp"] == true
        profile.Visual.Highlight = ActiveFeatures["highlight"] == true
    end
    if SavedTeleportPosition then
        profile.Teleport.ReturnPosition = {
            X = SavedTeleportPosition.X,
            Y = SavedTeleportPosition.Y,
            Z = SavedTeleportPosition.Z,
        }
    end

    profile.ActiveSafe = {}
    if ActiveFeatures then
        for _, id in ipairs({"uiscale", "keybind", "notifications", "performancemode"}) do
            profile.ActiveSafe[id] = ActiveFeatures[id] == true
        end
    end
    return profile
end

local function applyHubProfile(profile)
    if type(profile) ~= "table" then
        return false
    end

    if type(profile.WalkSpeed) == "number" then
        WalkSpeedState.Desired = validNumber(profile.WalkSpeed, 0, 1000, 16)
    end
    if type(profile.JumpPower) == "number" then
        JumpPowerState.Desired = validNumber(profile.JumpPower, 0, 1000, 50)
    end
    if type(profile.FlySpeed) == "number" then
        FlyState.DesiredSpeed = validNumber(profile.FlySpeed, 0, 500, 50)
    end
    if type(profile.FreeCameraSpeed) == "number" then
        FreeCameraState.DesiredSpeed = validNumber(profile.FreeCameraSpeed, 0, 500, 32)
    end
    if type(profile.Teleport) == "table"
        and type(profile.Teleport.ReturnPosition) == "table" then
        local position = profile.Teleport.ReturnPosition
        if type(position.X) == "number"
            and type(position.Y) == "number"
            and type(position.Z) == "number" then
            SavedTeleportPosition = Vector3.new(
                validNumber(position.X, -100000, 100000, 0),
                validNumber(position.Y, -100000, 100000, 0),
                validNumber(position.Z, -100000, 100000, 0)
            )
        end
    end

    if type(profile.World) == "table" then
        WorldState.Time = validNumber(profile.World.Time, 0, 24, WorldState.Time)
        WorldState.Brightness = validNumber(profile.World.Brightness, 0, 10, WorldState.Brightness)
        WorldState.FogEnabled = profile.World.FogEnabled == true
        WorldState.FogStart = validNumber(profile.World.FogStart, 0, 100000, WorldState.FogStart)
        WorldState.FogEnd = validNumber(profile.World.FogEnd, 0, 100000, WorldState.FogEnd)
        WorldState.Fov = validNumber(profile.World.Fov, 30, 120, WorldState.Fov)

        Lighting.ClockTime = WorldState.Time
        Lighting.Brightness = WorldState.Brightness
        if WorldState.FogEnabled then
            Lighting.FogStart = WorldState.FogStart
            Lighting.FogEnd = WorldState.FogEnd
        end
        local camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = WorldState.Fov
        end

        if type(profile.World.GraphicsQuality) == "string" then
            local qualityName = string.upper(profile.World.GraphicsQuality)
            if qualityName == "LOW" then
                WorldState.GraphicsQuality = Enum.SavedQualitySetting.Low
            elseif qualityName == "MEDIUM" then
                WorldState.GraphicsQuality = Enum.SavedQualitySetting.Medium
            elseif qualityName == "HIGH" then
                WorldState.GraphicsQuality = Enum.SavedQualitySetting.High
            else
                WorldState.GraphicsQuality = Enum.SavedQualitySetting.Automatic
            end
            pcall(function()
                local gameSettings = UserSettings():GetService("UserGameSettings")
                gameSettings.SavedQualityLevel = WorldState.GraphicsQuality
            end)
            if QualityBox then
                if WorldState.GraphicsQuality == Enum.SavedQualitySetting.Low then
                    QualityBox.Text = "LOW"
                elseif WorldState.GraphicsQuality == Enum.SavedQualitySetting.Medium then
                    QualityBox.Text = "MEDIUM"
                elseif WorldState.GraphicsQuality == Enum.SavedQualitySetting.High then
                    QualityBox.Text = "HIGH"
                else
                    QualityBox.Text = "AUTO"
                end
            end
        end
    end

    if type(profile.UI) == "table" then
        HubSettings.UIScale = validNumber(profile.UI.Scale, 0.75, 1.25, 1)
        HubSettings.Notifications = profile.UI.Notifications ~= false
        HubSettings.PerformanceMode = profile.UI.PerformanceMode == true
        if type(profile.UI.Keybind) == "string" then
            local keyCode = Enum.KeyCode[profile.UI.Keybind]
            if keyCode then
                HubSettings.Keybind = keyCode
                HubSettings.KeybindName = profile.UI.Keybind
            end
        end
        if MainScale then
            MainScale.Scale = HubSettings.UIScale
        end
        if KeybindBox then
            KeybindBox.Text = HubSettings.KeybindName
        end
    end
    return true
end

local StorageStatusLabel = nil

local function setStorageStatus(status)
    StorageSystem.Status = status
    if StorageStatusLabel then
        StorageStatusLabel.Text = status
    end
end

local function saveHubProfile()
    if not StorageSystem.Available or not StorageSystem.SettingsPath then
        setStorageStatus("Armazenamento local não suportado")
        return false
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(collectHubProfile())
    end)
    if not success then
        setStorageStatus("Falha ao preparar configurações")
        return false
    end

    local writeSuccess = pcall(function()
        executorCall("writefile", StorageSystem.SettingsPath, encoded)
    end)
    if writeSuccess and executorCall("isfile", StorageSystem.SettingsPath) then
        setStorageStatus("Salvamento concluído")
        return true
    end

    setStorageStatus("Falha ao salvar")
    return false
end

local function loadHubProfile()
    if not StorageSystem.Available or not StorageSystem.SettingsPath then
        setStorageStatus("Armazenamento local não suportado")
        return false
    end

    if not executorCall("isfile", StorageSystem.SettingsPath) then
        saveHubProfile()
        setStorageStatus("Arquivo padrão criado")
        return true
    end

    local content = executorCall("readfile", StorageSystem.SettingsPath)
    if type(content) ~= "string" or #content == 0 then
        saveHubProfile()
        setStorageStatus("Arquivo vazio recuperado")
        return true
    end

    local success, decoded = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not success or type(decoded) ~= "table" then
        saveHubProfile()
        setStorageStatus("JSON inválido recuperado")
        return true
    end

    applyHubProfile(decoded)
    setStorageStatus("Configurações carregadas")
    return true
end

scheduleHubProfileSave = function()
    if not StorageSystem.AutoSave then
        return
    end
    if StorageSystem.SaveTask then
        return
    end
    StorageSystem.SaveTask = task.delay(0.5, function()
        StorageSystem.SaveTask = nil
        saveHubProfile()
    end)
end

local MainScale = create("UIScale", {
    Scale = HubSettings.UIScale
}, Main)

local function saveHubSettings()
    pcall(function()
        LocalPlayer:SetAttribute("SyntexHubUIScale", HubSettings.UIScale)
        LocalPlayer:SetAttribute("SyntexHubKeybind", HubSettings.KeybindName)
        LocalPlayer:SetAttribute("SyntexHubNotifications", HubSettings.Notifications)
        LocalPlayer:SetAttribute("SyntexHubPerformanceMode", HubSettings.PerformanceMode)
    end)
    scheduleHubProfileSave()
end

local function loadHubSettings()
    pcall(function()
        local scale = LocalPlayer:GetAttribute("SyntexHubUIScale")
        local keybindName = LocalPlayer:GetAttribute("SyntexHubKeybind")
        local notifications = LocalPlayer:GetAttribute("SyntexHubNotifications")
        local performance = LocalPlayer:GetAttribute("SyntexHubPerformanceMode")

        if type(scale) == "number" then
            HubSettings.UIScale = math.clamp(scale, 0.75, 1.25)
        end
        if type(keybindName) == "string" then
            local keyCode = Enum.KeyCode[keybindName]
            if keyCode then
                HubSettings.Keybind = keyCode
                HubSettings.KeybindName = keybindName
            end
        end
        if type(notifications) == "boolean" then
            HubSettings.Notifications = notifications
        end
        if type(performance) == "boolean" then
            HubSettings.PerformanceMode = performance
        end
    end)
end

loadHubSettings()
loadHubProfile()
MainScale.Scale = HubSettings.UIScale

registerFeature("uiscale", "UI Scale", function()
    MainScale.Scale = HubSettings.UIScale
end, function()
    HubSettings.UIScale = 1
    MainScale.Scale = 1
    saveHubSettings()
end)
addNumericFeatureRow(SettingsPage, "uiscale", "UI Scale", "Escala da interface", math.floor(HubSettings.UIScale * 100), function(value)
    HubSettings.UIScale = math.clamp(value / 100, 0.75, 1.25)
    if ActiveFeatures["uiscale"] then
        MainScale.Scale = HubSettings.UIScale
    end
    saveHubSettings()
end)

local StorageCard = addCard(SettingsPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Armazenamento local",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, StorageCard)

StorageStatusLabel = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = StorageSystem.Status,
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, StorageCard)

local SaveSettingsButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -196, 0.5, -12),
    Size = UDim2.fromOffset(58, 24),
    Text = "SALVAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, StorageCard)
corner(SaveSettingsButton, 6)

trackConnection(SaveSettingsButton.MouseButton1Click:Connect(function()
    saveHubProfile()
end))

local LoadSettingsButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -132, 0.5, -12),
    Size = UDim2.fromOffset(58, 24),
    Text = "CARREGAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, StorageCard)
corner(LoadSettingsButton, 6)

trackConnection(LoadSettingsButton.MouseButton1Click:Connect(function()
    loadHubProfile()
end))

local AutoSaveButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -68, 0.5, -12),
    Size = UDim2.fromOffset(56, 24),
    Text = StorageSystem.AutoSave and "AUTO ON" or "AUTO OFF",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, StorageCard)
corner(AutoSaveButton, 6)

trackConnection(AutoSaveButton.MouseButton1Click:Connect(function()
    StorageSystem.AutoSave = not StorageSystem.AutoSave
    AutoSaveButton.Text = StorageSystem.AutoSave and "AUTO ON" or "AUTO OFF"
    setStorageStatus(StorageSystem.AutoSave and "Auto Save ativado" or "Auto Save desativado")
end))

registerFeature("toggleui", "Toggle UI", function()
    ScreenGui.Enabled = false
end, function()
    ScreenGui.Enabled = true
end)
addFeatureRow(SettingsPage, "toggleui", "Toggle UI", "Oculta sem encerrar recursos")

local KeybindConnection = nil

local function applyKeybindConnection()
    if KeybindConnection then
        KeybindConnection:Disconnect()
        KeybindConnection = nil
    end
    KeybindConnection = trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == HubSettings.Keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end))
end

registerFeature("keybind", "Keybind", function()
    applyKeybindConnection()
end, function()
    if KeybindConnection then
        KeybindConnection:Disconnect()
        KeybindConnection = nil
    end
end)

local KeybindCard = addCard(SettingsPage, 58)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -290, 0, 21),
    Text = "Keybind",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, KeybindCard)
create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 29),
    Size = UDim2.new(1, -290, 0, 18),
    Text = "Tecla para abrir/fechar.",
    TextColor3 = T.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, KeybindCard)
local KeybindBox = create("TextBox", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -148, 0.5, -12),
    Size = UDim2.fromOffset(48, 24),
    Text = HubSettings.KeybindName,
    PlaceholderText = "RightControl",
    TextColor3 = T.White,
    PlaceholderColor3 = T.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false
}, KeybindCard)
corner(KeybindBox, 6)
stroke(KeybindBox, T.Purple, 0.75, 1)
local KeybindButton = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(1, -94, 0.5, -12),
    Size = UDim2.fromOffset(82, 24),
    Text = "ATIVAR",
    TextColor3 = T.Lavender,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, KeybindCard)
corner(KeybindButton, 6)
trackConnection(KeybindButton.MouseButton1Click:Connect(function()
    toggleFeature("keybind")
    KeybindButton.Text = ActiveFeatures["keybind"] and "DESATIVAR" or "ATIVAR"
end))
local KeybindDefinition = FeatureDefinitions["keybind"]
if KeybindDefinition then
    KeybindDefinition.Button = KeybindButton
end
trackConnection(KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
    local name = string.gsub(KeybindBox.Text, "^KeyCode%.", "")
    local keyCode = Enum.KeyCode[name]
    if keyCode then
        HubSettings.Keybind = keyCode
        HubSettings.KeybindName = name
        saveHubSettings()
    end
end))

enableFeature("keybind")

local NotificationFrame = nil
local function showNotification(text)
    if not HubSettings.Notifications then
        return
    end
    if NotificationFrame then
        NotificationFrame:Destroy()
    end
    NotificationFrame = create("TextLabel", {
        BackgroundColor3 = T.SurfaceLight,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 12),
        Size = UDim2.fromOffset(260, 38),
        Text = text,
        TextColor3 = T.Lavender,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        ZIndex = 200
    }, ScreenGui)
    corner(NotificationFrame, 8)
    stroke(NotificationFrame, T.Purple, 0.45, 1)
    task.delay(2.5, function()
        if NotificationFrame then
            NotificationFrame:Destroy()
            NotificationFrame = nil
        end
    end)
end

registerFeature("notifications", "Notifications", function()
    HubSettings.Notifications = true
    saveHubSettings()
    showNotification("Notificações ativadas")
end, function()
    HubSettings.Notifications = false
    if NotificationFrame then
        NotificationFrame:Destroy()
        NotificationFrame = nil
    end
    saveHubSettings()
end)
addFeatureRow(SettingsPage, "notifications", "Notifications", "Exibe avisos locais do HUB")

registerFeature("performancemode", "Performance Mode", function()
    HubSettings.PerformanceMode = true
    saveHubSettings()
end, function()
    HubSettings.PerformanceMode = false
    saveHubSettings()
end)
addFeatureRow(SettingsPage, "performancemode", "Performance Mode", "Reduz animações da interface")

local function resetHubSettings()
    disableFeature("uiscale")
    disableFeature("toggleui")
    disableFeature("keybind")
    disableFeature("notifications")
    disableFeature("performancemode")
    HubSettings.UIScale = 1
    HubSettings.Keybind = Enum.KeyCode.RightControl
    HubSettings.KeybindName = "RightControl"
    HubSettings.Notifications = true
    HubSettings.PerformanceMode = false
    MainScale.Scale = 1
    KeybindBox.Text = "RightControl"
    saveHubSettings()
    enableFeature("keybind")
    showNotification("Configurações restauradas")
end

registerFeature("resetsettings", "Reset Settings", function()
    resetHubSettings()
end, function()
end)
addFeatureRow(SettingsPage, "resetsettings", "Reset Settings", "Restaurar padrões do HUB")

registerFeature("unloadhub", "Unload Hub", function()
    for featureId in pairs(ActiveFeatures) do
        if featureId ~= "unloadhub" then
            disableFeature(featureId)
        end
    end
    task.defer(function()
        ScreenGui:Destroy()
    end)
end, function()
end)
addFeatureRow(SettingsPage, "unloadhub", "Unload Hub", "Encerrar e remover o SYNTEX HUB")

for name, tab in pairs(TabButtons) do
    trackConnection(tab.MouseButton1Click:Connect(function()
        showPage(name)
    end))
end
showPage("Início")

local minimized = false
local expandedSize = UDim2.fromOffset(690, 455)

trackConnection(Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(Main, 0.25, {Size = UDim2.fromOffset(690, 57)})
        Minimize.Text = "+"
    else
        tween(Main, 0.25, {Size = expandedSize})
        Minimize.Text = "—"
    end
end))

trackConnection(Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end))
