
--[[
    SYNTEX HUB
    Version: 3.1.0 - FINAL UI TEST
    Interface visual em Luau

    LocalScript:
    StarterPlayer > StarterPlayerScripts

    Imagens:
    Substitua os IDs em CONFIG.
]]

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// CONFIGURATION
local CONFIG = {
    Name = "SYNTEX HUB",
    Version = "3.1.0",

    SplashImage = "rbxassetid://138904905387872",
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
        Green = Color3.fromRGB(70, 210, 140),
        Red = Color3.fromRGB(230, 75, 95),
    }
}

local T = CONFIG.Theme

--// CLEANUP
local oldGui = PlayerGui:FindFirstChild("SyntexHubUI")
if oldGui then
    oldGui:Destroy()
end

--// HELPERS
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
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        properties
    )

    animation:Play()
    return animation
end

local function label(parent, text, size, color, font)
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

local function button(parent, text, callback, height)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, height or 38),
        BackgroundColor3 = T.SurfaceLight,
        Text = text,
        TextColor3 = T.Lavender,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    }, parent)

    corner(btn, 8)
    stroke(btn, T.Purple, 0.75, 1)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {
            BackgroundColor3 = Color3.fromRGB(43, 25, 61)
        })
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {
            BackgroundColor3 = T.SurfaceLight
        })
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

--// SCREEN GUI
local ScreenGui = create("ScreenGui", {
    Name = "SyntexHubUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100
}, PlayerGui)

--// NOTIFICATION SYSTEM
local NotificationHolder = create("Frame", {
    Name = "Notifications",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.fromOffset(300, 300)
}, ScreenGui)

local NotificationLayout = create("UIListLayout", {
    Padding = UDim.new(0, 9),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder
}, NotificationHolder)

local notificationOrder = 0

local function notify(title, message, duration)
    duration = duration or 3.5
    notificationOrder += 1

    local card = create("Frame", {
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = 0.12,
        Size = UDim2.fromOffset(285, 72),
        ClipsDescendants = true,
        LayoutOrder = notificationOrder
    }, NotificationHolder)

    corner(card, 10)
    stroke(card, T.Purple, 0.35, 1)

    local accent = create("Frame", {
        BackgroundColor3 = T.Magenta,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0
    }, card)

    local titleLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -25, 0, 20),
        Text = title,
        TextColor3 = T.White,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, card)

    local messageLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 29),
        Size = UDim2.new(1, -25, 0, 22),
        Text = message,
        TextColor3 = T.Lavender,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    }, card)

    local timerBack = create("Frame", {
        BackgroundColor3 = T.SurfaceLight,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3)
    }, card)

    local timer = create("Frame", {
        BackgroundColor3 = T.Magenta,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1)
    }, timerBack)

    card.Position = UDim2.new(1, 30, 0, 0)
    tween(card, 0.35, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    tween(timer, duration, {
        Size = UDim2.new(0, 0, 1, 0)
    })

    task.delay(duration, function()
        if card and card.Parent then
            tween(card, 0.25, {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 30, 0, 0)
            })

            task.wait(0.3)
            card:Destroy()
        end
    end)
end

--// SPLASH SCREEN
local Splash = create("Frame", {
    Name = "Splash",
    BackgroundColor3 = T.Background,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 20
}, ScreenGui)

local SplashLogo = create("ImageLabel", {
    BackgroundTransparency = 1,
    Image = CONFIG.SplashImage,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.43),
    Size = UDim2.fromOffset(190, 190),
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 21
}, Splash)

local SplashTitle = create("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.fromScale(0.5, 0.61),
    Size = UDim2.fromOffset(300, 30),
    Text = "SYNTEX HUB",
    TextColor3 = T.White,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    ZIndex = 21
}, Splash)

local SplashSubtitle = create("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.fromScale(0.5, 0.66),
    Size = UDim2.fromOffset(300, 20),
    Text = "BEYOND THE SYSTEM",
    TextColor3 = T.Lavender,
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    ZIndex = 21
}, Splash)

local LoadingBack = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.fromScale(0.5, 0.76),
    Size = UDim2.fromOffset(190, 4),
    BackgroundColor3 = T.SurfaceLight,
    BorderSizePixel = 0,
    ZIndex = 21
}, Splash)
corner(LoadingBack, 5)

local LoadingBar = create("Frame", {
    BackgroundColor3 = T.Magenta,
    Size = UDim2.new(0, 0, 1, 0),
    BorderSizePixel = 0,
    ZIndex = 22
}, LoadingBack)
corner(LoadingBar, 5)

--// MAIN WINDOW
local Main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.53),
    Size = UDim2.fromOffset(690, 455),
    BackgroundColor3 = T.Background,
    Visible = false,
    ClipsDescendants = true
}, ScreenGui)

corner(Main, 13)
stroke(Main, T.Purple, 0.25, 1.3)

create("UISizeConstraint", {
    MinSize = Vector2.new(330, 300),
    MaxSize = Vector2.new(900, 650)
}, Main)

--// HEADER
local Header = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 57),
    BorderSizePixel = 0
}, Main)

local HeaderLogo = create("ImageLabel", {
    BackgroundTransparency = 1,
    Image = CONFIG.LogoImage,
    Position = UDim2.fromOffset(15, 8),
    Size = UDim2.fromOffset(40, 40),
    ScaleType = Enum.ScaleType.Fit
}, Header)

local HeaderName = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(63, 8),
    Size = UDim2.fromOffset(190, 23),
    Text = "SYNTEX HUB",
    TextColor3 = T.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local HeaderVersion = create("TextLabel", {
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

--// DRAG SYSTEM
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if input.Position.X > Header.AbsolutePosition.X + Header.AbsoluteSize.X - 90 then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
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
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--// BODY
local Body = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 57),
    Size = UDim2.new(1, 0, 1, -57)
}, Main)

--// SIDEBAR
local Sidebar = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(0, 155, 1, 0),
    BorderSizePixel = 0
}, Body)

local SidebarPadding = create("UIPadding", {
    PaddingTop = UDim.new(0, 15),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10)
}, Sidebar)

local SidebarLayout = create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Sidebar)

local Content = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 155, 0, 0),
    Size = UDim2.new(1, -155, 1, 0)
}, Body)

local Pages = {}
local TabButtons = {}

local function createPage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 18)
    }, page)

    create("UIListLayout", {
        Padding = UDim.new(0, 11),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function addTab(name, iconText)
    local tab = create("TextButton", {
        BackgroundColor3 = T.Surface,
        Size = UDim2.new(1, 0, 0, 37),
        Text = iconText .. "   " .. name,
        TextColor3 = T.Muted,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    }, Sidebar)

    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10)
    }, tab)

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

--// PAGE: HOME
local Home = createPage("Home")
addTab("Home", "⌂")

local Welcome = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 105)
}, Home)
corner(Welcome, 10)
stroke(Welcome, T.Purple, 0.7)

local WelcomeTitle = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 16),
    Size = UDim2.new(1, -30, 0, 25),
    Text = "Welcome to SYNTEX",
    TextColor3 = T.White,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Welcome)

local WelcomeText = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 45),
    Size = UDim2.new(1, -30, 0, 40),
    Text = "Your interface is ready. Select a section to continue.",
    TextColor3 = T.Muted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
}, Welcome)

local StatusTitle = label(Home, "SYSTEM STATUS", 10, T.Muted, Enum.Font.GothamBold)

local StatusCard = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 76)
}, Home)
corner(StatusCard, 9)

local StatusText = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -28, 0, 22),
    Text = "●  Interface initialized",
    TextColor3 = T.Green,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

local StatusDescription = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 35),
    Size = UDim2.new(1, -28, 0, 25),
    Text = "Visual components loaded successfully.",
    TextColor3 = T.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

button(Home, "Show test notification", function()
    notify("SYNTEX HUB", "Notification system is working.", 4)
end)

--// PAGE: PLAYERS
local PlayersPage = createPage("Players")
addTab("Players", "♙")

label(PlayersPage, "PLAYER MANAGEMENT", 10, T.Muted, Enum.Font.GothamBold)

local PlayerSearch = create("TextBox", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 39),
    PlaceholderText = "Search by player name or UserId...",
    PlaceholderColor3 = T.Muted,
    Text = "",
    TextColor3 = T.White,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false
}, PlayersPage)
corner(PlayerSearch, 8)
stroke(PlayerSearch, T.Purple, 0.75)

local PlayerList = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 190)
}, PlayersPage)
corner(PlayerList, 9)

local PlayerListLayout = create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, PlayerList)

create("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8)
}, PlayerList)

local SelectedPlayer = nil

local function refreshPlayers()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local search = string.lower(PlayerSearch.Text)

    for _, player in ipairs(Players:GetPlayers()) do
        local matches = search == ""
            or string.find(string.lower(player.Name), search, 1, true)
            or string.find(tostring(player.UserId), search, 1, true)

        if matches then
            local playerButton = create("TextButton", {
                BackgroundColor3 = T.SurfaceLight,
                Size = UDim2.new(1, 0, 0, 34),
                Text = player.Name .. "   |   " .. tostring(player.UserId),
                TextColor3 = T.Lavender,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false
            }, PlayerList)

            corner(playerButton, 6)

            playerButton.MouseButton1Click:Connect(function()
                SelectedPlayer = player
                notify("Player selected", player.Name, 3)
            end)
        end
    end
end

PlayerSearch:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

local SelectedPlayerInfo = create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 28),
    Text = "Selected player: none",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, PlayersPage)

button(PlayersPage, "Show selected player information", function()
    if not SelectedPlayer then
        notify("Players", "Select a player first.", 3)
        return
    end

    SelectedPlayerInfo.Text = "Selected player: " ..
        SelectedPlayer.Name .. " | UserId: " .. SelectedPlayer.UserId

    notify("Player information", SelectedPlayer.Name, 3)
end)

--// PAGE: PROFILES
local Profiles = createPage("Profiles")
addTab("Profiles", "▤")

label(Profiles, "PROFILE MANAGEMENT", 10, T.Muted, Enum.Font.GothamBold)

local ProfileName = create("TextBox", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 39),
    PlaceholderText = "Enter profile name...",
    PlaceholderColor3 = T.Muted,
    Text = "",
    TextColor3 = T.White,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false
}, Profiles)
corner(ProfileName, 8)
stroke(ProfileName, T.Purple, 0.75)

local ProfileStatus = label(Profiles, "Selected profile: Default", 11, T.Lavender)

local ProfileData = {
    Default = {
        Theme = "Purple",
        Notifications = true
    }
}

local function createProfile()
    local name = ProfileName.Text

    if name == "" then
        notify("Profiles", "Enter a profile name.", 3)
        return
    end

    if ProfileData[name] then
        notify("Profiles", "This profile already exists.", 3)
        return
    end

    ProfileData[name] = {
        Theme = "Purple",
        Notifications = true
    }

    ProfileStatus.Text = "Selected profile: " .. name
    notify("Profiles", "Profile created: " .. name, 3)
end

button(Profiles, "Create profile", createProfile)

button(Profiles, "Select Default profile", function()
    ProfileStatus.Text = "Selected profile: Default"
    notify("Profiles", "Default profile selected.", 3)
end)

button(Profiles, "Show profile count", function()
    local count = 0
    for _ in pairs(ProfileData) do
        count += 1
    end

    notify("Profiles", "Profiles available: " .. count, 3)
end)

--// PAGE: ASSETS
local Assets = createPage("Assets")
addTab("Assets", "▧")

label(Assets, "ASSET MANAGER", 10, T.Muted, Enum.Font.GothamBold)

local AssetCard = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 120)
}, Assets)
corner(AssetCard, 9)

local AssetLogo = create("ImageLabel", {
    BackgroundTransparency = 1,
    Image = CONFIG.LogoImage,
    Position = UDim2.fromOffset(12, 12),
    Size = UDim2.fromOffset(80, 80),
    ScaleType = Enum.ScaleType.Fit
}, AssetCard)

local AssetTitle = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(105, 22),
    Size = UDim2.new(1, -115, 0, 23),
    Text = "SYNTEX HUB LOGO",
    TextColor3 = T.White,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, AssetCard)

local AssetDescription = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(105, 47),
    Size = UDim2.new(1, -115, 0, 38),
    Text = "Image preview configured in the UI settings.",
    TextColor3 = T.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
}, AssetCard)

button(Assets, "Check image configuration", function()
    notify("Assets", "Image fields are configured.", 3)
end)

local AssetWarning = label(
    Assets,
    "Note: Roblox ImageLabel requires a valid Roblox asset ID.",
    10,
    T.Muted
)
AssetWarning.TextWrapped = true
AssetWarning.Size = UDim2.new(1, 0, 0, 35)

--// PAGE: SETTINGS
local Settings = createPage("Settings")
addTab("Settings", "⚙")

label(Settings, "INTERFACE SETTINGS", 10, T.Muted, Enum.Font.GothamBold)

local notificationEnabled = true

button(Settings, "Toggle notifications", function()
    notificationEnabled = not notificationEnabled

    notify(
        "Settings",
        "Notifications: " .. (notificationEnabled and "Enabled" or "Disabled"),
        3
    )
end)

button(Settings, "Reset interface position", function()
    Main.Position = UDim2.fromScale(0.5, 0.53)
    notify("Settings", "Interface position reset.", 3)
end)

button(Settings, "Show version information", function()
    notify("SYNTEX HUB", "Version " .. CONFIG.Version, 3)
end)

local SettingsInfo = create("Frame", {
    BackgroundColor3 = T.Surface,
    Size = UDim2.new(1, 0, 0, 75)
}, Settings)
corner(SettingsInfo, 9)

local SettingsInfoText = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 8),
    Size = UDim2.new(1, -24, 1, -16),
    Text = "SYNTEX HUB\nInterface build 3.1.0\nVisual test environment",
    TextColor3 = T.Lavender,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center
}, SettingsInfo)

--// CLOSE CONFIRMATION
local CloseOverlay = create("Frame", {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.35,
    Size = UDim2.fromScale(1, 1),
    Visible = false,
    ZIndex = 50
}, Main)

local ConfirmBox = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(290, 145),
    BackgroundColor3 = T.Surface,
    ZIndex = 51
}, CloseOverlay)

corner(ConfirmBox, 11)
stroke(ConfirmBox, T.Purple, 0.2, 1.2)

local ConfirmTitle = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 15),
    Size = UDim2.new(1, -30, 0, 25),
    Text = "Close SYNTEX HUB?",
    TextColor3 = T.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    ZIndex = 52
}, ConfirmBox)

local ConfirmDescription = create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(15, 43),
    Size = UDim2.new(1, -30, 0, 32),
    Text = "Are you sure you want to close the interface?",
    TextColor3 = T.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    ZIndex = 52
}, ConfirmBox)

local ConfirmYes = create("TextButton", {
    BackgroundColor3 = T.Purple,
    Position = UDim2.new(0, 15, 1, -45),
    Size = UDim2.new(0.5, -20, 0, 30),
    Text = "Close",
    TextColor3 = T.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    ZIndex = 52
}, ConfirmBox)
corner(ConfirmYes, 7)

local ConfirmNo = create("TextButton", {
    BackgroundColor3 = T.SurfaceLight,
    Position = UDim2.new(0.5, 5, 1, -45),
    Size = UDim2.new(0.5, -20, 0, 30),
    Text = "Cancel",
    TextColor3 = T.Lavender,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    ZIndex = 52
}, ConfirmBox)
corner(ConfirmNo, 7)

--// MINIMIZE / RESTORE
local minimized = false
local expandedSize = UDim2.fromOffset(690, 455)

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        tween(Main, 0.25, {
            Size = UDim2.fromOffset(690, 57)
        })
        Minimize.Text = "+"
    else
        tween(Main, 0.25, {
            Size = expandedSize
        })
        Minimize.Text = "—"
    end
end)

Close.MouseButton1Click:Connect(function()
    CloseOverlay.Visible = true
    CloseOverlay.BackgroundTransparency = 1

    tween(CloseOverlay, 0.2, {
        BackgroundTransparency = 0.35
    })
end)

ConfirmNo.MouseButton1Click:Connect(function()
    tween(CloseOverlay, 0.15, {
        BackgroundTransparency = 1
    })

    task.wait(0.16)
    CloseOverlay.Visible = false
end)

ConfirmYes.MouseButton1Click:Connect(function()
    tween(Main, 0.25, {
        Size = UDim2.fromOffset(0, 0)
    })

    task.wait(0.3)
    ScreenGui:Destroy()
end)

--// TAB CONNECTIONS
for name, tab in pairs(TabButtons) do
    tab.MouseButton1Click:Connect(function()
        showPage(name)
    end)
end

showPage("Home")

--// LOADING SEQUENCE
tween(LoadingBar, 1.5, {
    Size = UDim2.new(1, 0, 1, 0)
})

task.wait(1.65)

Main.Visible = true
Main.Size = UDim2.fromOffset(620, 400)
Main.BackgroundTransparency = 1

tween(Main, 0.4, {
    Size = expandedSize,
    BackgroundTransparency = 0
})

tween(Splash, 0.35, {
    BackgroundTransparency = 1
})

for _, object in ipairs(Splash:GetDescendants()) do
    if object:IsA("ImageLabel") then
        tween(object, 0.25, {ImageTransparency = 1})
    elseif object:IsA("TextLabel") then
        tween(object, 0.25, {TextTransparency = 1})
    elseif object:IsA("Frame") then
        tween(object, 0.25, {BackgroundTransparency = 1})
    end
end

task.wait(0.4)
Splash:Destroy()

notify("SYNTEX HUB", "Interface loaded successfully.", 4)
