
--[[
    SYNTEX HUB
    Version: 2.0.0
    Platform: Roblox
    Language: Luau
    Type: LocalScript

    SYNTEX HUB - Scripts que fazem a diferença.
]]

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIGURATION
local Config = {
    Name = "SYNTEX HUB",
    Version = "2.0.0",

    -- Envie as imagens ao Roblox e coloque os IDs abaixo.
    -- Exemplo: "rbxassetid://1234567890"
    SplashImage = "",
    LogoImage = "",

    SplashDuration = 2.5,
}

-- COLORS
local Colors = {
    Background = Color3.fromRGB(7, 5, 12),
    Panel = Color3.fromRGB(15, 10, 23),
    Element = Color3.fromRGB(25, 17, 37),

    Purple = Color3.fromRGB(133, 0, 255),
    Magenta = Color3.fromRGB(192, 0, 255),
    Lavender = Color3.fromRGB(201, 184, 232),

    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(145, 132, 160),
    Border = Color3.fromRGB(75, 35, 110),
    Red = Color3.fromRGB(235, 65, 85),
}

-- CLEANUP OLD GUI
local Old = PlayerGui:FindFirstChild("SyntexHub")
if Old then
    Old:Destroy()
end

-- CONNECTION MANAGEMENT
local Connections = {}
local Destroyed = false

local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function Cleanup()
    if Destroyed then return end
    Destroyed = true

    for _, connection in ipairs(Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(Connections)
end

-- HELPERS
local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, transparency)
    Create("UIStroke", {
        Color = color or Colors.Border,
        Transparency = transparency or 0,
        Thickness = 1
    }, parent)
end

local function Tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    animation:Play()
    return animation
end

local function NewLabel(parent, text, size, position, color, font)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        TextColor3 = color or Colors.White,
        Font = font or Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    }, parent)
end

-- SCREEN GUI
local Screen = Create("ScreenGui", {
    Name = "SyntexHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true
}, PlayerGui)

-- NOTIFICATIONS
local NotificationHolder = Create("Frame", {
    Name = "Notifications",
    Size = UDim2.new(0, 280, 1, -20),
    Position = UDim2.new(1, -290, 0, 10),
    BackgroundTransparency = 1
}, Screen)

Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom
}, NotificationHolder)

local function Notify(title, message)
    if Destroyed then return end

    local notification = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = Colors.Panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0
    }, NotificationHolder)

    Corner(notification, 9)
    Stroke(notification, Colors.Purple)

    Create("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.fromOffset(0, 8),
        BackgroundColor3 = Colors.Magenta,
        BorderSizePixel = 0
    }, notification)

    NewLabel(
        notification,
        title,
        UDim2.new(1, -25, 0, 22),
        UDim2.fromOffset(13, 9),
        Colors.White,
        Enum.Font.GothamBold
    )

    NewLabel(
        notification,
        message,
        UDim2.new(1, -25, 0, 25),
        UDim2.fromOffset(13, 34),
        Colors.Lavender
    )

    notification.Position = UDim2.new(0, 30, 0, 0)
    notification.BackgroundTransparency = 1

    Tween(notification, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.05
    }, 0.25)

    task.delay(3, function()
        if notification.Parent then
            Tween(notification, {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 30, 0, 0)
            }, 0.2)

            task.wait(0.25)
            notification:Destroy()
        end
    end)
end

-- SPLASH SCREEN
local Splash = Create("Frame", {
    Name = "Splash",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ZIndex = 100
}, Screen)

local SplashLogo = Create("ImageLabel", {
    Size = UDim2.fromOffset(170, 170),
    Position = UDim2.new(0.5, -85, 0.5, -100),
    BackgroundTransparency = 1,
    Image = Config.SplashImage,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 101
}, Splash)

local SplashFallback = NewLabel(
    Splash,
    "SYNTEX\nHUB",
    UDim2.fromOffset(250, 100),
    UDim2.new(0.5, -125, 0.5, -50),
    Colors.White,
    Enum.Font.GothamBlack
)
SplashFallback.TextSize = 34
SplashFallback.TextXAlignment = Enum.TextXAlignment.Center
SplashFallback.ZIndex = 101

if Config.SplashImage ~= "" then
    SplashFallback.Visible = false
else
    SplashLogo.Visible = false
end

local SplashSubtitle = NewLabel(
    Splash,
    "INITIALIZING SYSTEM...",
    UDim2.fromOffset(250, 25),
    UDim2.new(0.5, -125, 0.5, 75),
    Colors.Lavender,
    Enum.Font.GothamBold
)
SplashSubtitle.TextSize = 10
SplashSubtitle.TextXAlignment = Enum.TextXAlignment.Center
SplashSubtitle.ZIndex = 101

local LoadingBar = Create("Frame", {
    Size = UDim2.fromOffset(160, 3),
    Position = UDim2.new(0.5, -80, 0.5, 110),
    BackgroundColor3 = Colors.Element,
    BorderSizePixel = 0,
    ZIndex = 101
}, Splash)
Corner(LoadingBar, 5)

local LoadingFill = Create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Colors.Magenta,
    BorderSizePixel = 0,
    ZIndex = 102
}, LoadingBar)
Corner(LoadingFill, 5)

-- MAIN WINDOW
local Main = Create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 20),
    Size = UDim2.new(0.82, 0, 0.78, 0),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true
}, Screen)

Corner(Main, 12)
Stroke(Main, Colors.Purple)

Create("UISizeConstraint", {
    MinSize = Vector2.new(310, 300),
    MaxSize = Vector2.new(620, 540)
}, Main)

-- RESPONSIVE SCALE
local Scale = Create("UIScale", {
    Scale = 1
}, Main)

local function UpdateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize

    if viewport.X < 500 then
        Scale.Scale = 0.92
    else
        Scale.Scale = 1
    end
end

UpdateScale()

if workspace.CurrentCamera then
    Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), UpdateScale)
end

-- HEADER
local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 65),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0
}, Main)

local HeaderLogo = Create("ImageLabel", {
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(13, 11),
    BackgroundTransparency = 1,
    Image = Config.LogoImage,
    ScaleType = Enum.ScaleType.Fit
}, Header)

local HeaderFallback = NewLabel(
    Header,
    "S",
    UDim2.fromOffset(42, 42),
    UDim2.fromOffset(13, 10),
    Colors.Magenta,
    Enum.Font.GothamBlack
)
HeaderFallback.TextSize = 27
HeaderFallback.TextXAlignment = Enum.TextXAlignment.Center

if Config.LogoImage ~= "" then
    HeaderFallback.Visible = false
else
    HeaderLogo.Visible = false
end

NewLabel(
    Header,
    "SYNTEX HUB",
    UDim2.new(1, -145, 0, 24),
    UDim2.fromOffset(63, 10),
    Colors.White,
    Enum.Font.GothamBlack
).TextSize = 15

local VersionLabel = NewLabel(
    Header,
    "SYSTEM INTERFACE  /  V2.0.0",
    UDim2.new(1, -145, 0, 17),
    UDim2.fromOffset(64, 34),
    Colors.Lavender
)
VersionLabel.TextSize = 9

-- MINIMIZE BUTTON
local Minimize = Create("TextButton", {
    Size = UDim2.fromOffset(29, 29),
    Position = UDim2.new(1, -73, 0, 17),
    BackgroundColor3 = Colors.Element,
    Text = "—",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false
}, Header)
Corner(Minimize, 6)

-- CLOSE BUTTON
local CloseButton = Create("TextButton", {
    Size = UDim2.fromOffset(29, 29),
    Position = UDim2.new(1, -37, 0, 17),
    BackgroundColor3 = Colors.Element,
    Text = "X",
    TextColor3 = Colors.Red,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false
}, Header)
Corner(CloseButton, 6)

-- TABS
local TabBar = Create("Frame", {
    Name = "TabBar",
    Position = UDim2.fromOffset(0, 65),
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0
}, Main)

local TabLayout = Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, TabBar)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12)
}, TabBar)

-- PAGE HOLDER
local PageHolder = Create("Frame", {
    Name = "PageHolder",
    Position = UDim2.fromOffset(0, 107),
    Size = UDim2.new(1, 0, 1, -107),
    BackgroundTransparency = 1
}, Main)

local Pages = {}
local Tabs = {}
local CurrentTab = nil

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Purple,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, PageHolder)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    }, page)

    Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function CreateTab(name)
    local button = Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.fromOffset(100, 29),
        BackgroundColor3 = Colors.Element,
        Text = string.upper(name),
        TextColor3 = Colors.Gray,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = false
    }, TabBar)

    Corner(button, 6)

    local page = CreatePage(name)

    local function Select()
        if CurrentTab == name then return end

        CurrentTab = name

        for tabName, tabButton in pairs(Tabs) do
            local selected = tabName == name

            Tween(tabButton, {
                BackgroundColor3 = selected and Colors.Purple or Colors.Element,
                TextColor3 = selected and Colors.White or Colors.Gray
            }, 0.18)

            Pages[tabName].Visible = selected
        end
    end

    Tabs[name] = button
    Connect(button.MouseButton1Click, Select)

    return page
end

-- PAGES
local HomePage = CreateTab("Home")
local ComponentsPage = CreateTab("Components")
local SettingsPage = CreateTab("Settings")

-- SECTION
local function Section(parent, name)
    local label = NewLabel(
        parent,
        string.upper(name),
        UDim2.new(1, 0, 0, 25),
        UDim2.new(),
        Colors.Lavender,
        Enum.Font.GothamBold
    )

    label.TextSize = 10
    return label
end

-- ELEMENT CONTAINER
local function Element(parent, name, description, height)
    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 62),
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0,
        ClipsDescendants = false
    }, parent)

    Corner(frame, 8)
    Stroke(frame, Colors.Border, 0.35)

    NewLabel(
        frame,
        name,
        UDim2.new(0.58, -10, 0, 20),
        UDim2.fromOffset(12, 8),
        Colors.White,
        Enum.Font.GothamMedium
    )

    local descriptionLabel = NewLabel(
        frame,
        description or "",
        UDim2.new(0.63, -10, 0, 18),
        UDim2.fromOffset(12, 31),
        Colors.Gray
    )
    descriptionLabel.TextSize = 9

    return frame, descriptionLabel
end

-- HOME PAGE
Section(HomePage, "Welcome")

local WelcomeFrame = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 105),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0
}, HomePage)

Corner(WelcomeFrame, 9)
Stroke(WelcomeFrame, Colors.Purple, 0.25)

NewLabel(
    WelcomeFrame,
    "WELCOME TO SYNTEX",
    UDim2.new(1, -24, 0, 25),
    UDim2.fromOffset(12, 13),
    Colors.White,
    Enum.Font.GothamBlack
).TextSize = 16

NewLabel(
    WelcomeFrame,
    "Uma nova experiência de interface.",
    UDim2.new(1, -24, 0, 20),
    UDim2.fromOffset(12, 42),
    Colors.Lavender
).TextSize = 10

NewLabel(
    WelcomeFrame,
    "VERSION 2.0.0  |  SYSTEM ONLINE",
    UDim2.new(1, -24, 0, 17),
    UDim2.fromOffset(12, 72),
    Colors.Magenta,
    Enum.Font.GothamBold
).TextSize = 9

Section(HomePage, "Information")

local InfoFrame = Element(
    HomePage,
    "Interface status",
    "SYNTEX HUB is running."
)

local StatusLabel = NewLabel(
    InfoFrame,
    "ONLINE",
    UDim2.fromOffset(65, 25),
    UDim2.new(1, -78, 0.5, -12),
    Colors.Magenta,
    Enum.Font.GothamBold
)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- COMPONENTS PAGE
Section(ComponentsPage, "Toggle Components")

local ToggleFrame = Element(
    ComponentsPage,
    "Example Toggle",
    "Enable or disable a feature."
)

local ToggleState = false

local ToggleButton = Create("TextButton", {
    Size = UDim2.fromOffset(43, 23),
    Position = UDim2.new(1, -57, 0.5, -11),
    BackgroundColor3 = Colors.Element,
    Text = "",
    AutoButtonColor = false
}, ToggleFrame)

Corner(ToggleButton, 20)

local ToggleCircle = Create("Frame", {
    Size = UDim2.fromOffset(17, 17),
    Position = UDim2.fromOffset(3, 3),
    BackgroundColor3 = Colors.White,
    BorderSizePixel = 0
}, ToggleButton)

Corner(ToggleCircle, 20)

Connect(ToggleButton.MouseButton1Click, function()
    ToggleState = not ToggleState

    Tween(ToggleButton, {
        BackgroundColor3 = ToggleState and Colors.Purple or Colors.Element
    })

    Tween(ToggleCircle, {
        Position = ToggleState
            and UDim2.new(1, -20, 0, 3)
            or UDim2.fromOffset(3, 3)
    })

    print("Syntex Toggle:", ToggleState)
end)

-- SLIDER
Section(ComponentsPage, "Slider Components")

local SliderFrame, SliderDescription = Element(
    ComponentsPage,
    "Example Slider",
    "Adjust the value: 50",
    78
)

local SliderTrack = Create("TextButton", {
    Position = UDim2.new(0, 12, 1, -20),
    Size = UDim2.new(1, -24, 0, 6),
    BackgroundColor3 = Colors.Element,
    Text = "",
    AutoButtonColor = false
}, SliderFrame)

Corner(SliderTrack, 10)

local SliderFill = Create("Frame", {
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = Colors.Magenta,
    BorderSizePixel = 0
}, SliderTrack)

Corner(SliderFill, 10)

local SliderValue = NewLabel(
    SliderFrame,
    "50",
    UDim2.fromOffset(45, 20),
    UDim2.new(1, -58, 0, 8),
    Colors.White,
    Enum.Font.GothamBold
)
SliderValue.TextXAlignment = Enum.TextXAlignment.Right

local MinValue, MaxValue = 0, 100
local SliderValueCurrent = 50
local Sliding = false
local ActiveTouch = nil

local function UpdateSlider(input)
    local width = SliderTrack.AbsoluteSize.X
    if width <= 0 then return end

    local relative = math.clamp(
        (input.Position.X - SliderTrack.AbsolutePosition.X) / width,
        0,
        1
    )

    local value = math.floor(
        MinValue + relative * (MaxValue - MinValue)
    )

    SliderValueCurrent = value

    SliderFill.Size = UDim2.new(relative, 0, 1, 0)
    SliderValue.Text = tostring(value)

    -- Referência explícita: não altera o título do componente.
    SliderDescription.Text = "Adjust the value: " .. value

    print("Syntex Slider:", value)
end

Connect(SliderTrack.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Sliding = true
        UpdateSlider(input)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        Sliding = true
        ActiveTouch = input
        UpdateSlider(input)
    end
end)

Connect(UserInputService.InputChanged, function(input)
    if not Sliding then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateSlider(input)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if ActiveTouch then
            UpdateSlider(input)
        end
    end
end)

Connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Sliding = false
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if ActiveTouch then
            Sliding = false
            ActiveTouch = nil
        end
    end
end)

-- BUTTON
Section(ComponentsPage, "Button Components")

local ButtonFrame = Element(
    ComponentsPage,
    "Example Button",
    "Execute a test action."
)

local ActionButton = Create("TextButton", {
    Size = UDim2.fromOffset(100, 30),
    Position = UDim2.new(1, -112, 0.5, -15),
    BackgroundColor3 = Colors.Purple,
    Text = "EXECUTE",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false
}, ButtonFrame)

Corner(ActionButton, 6)

Connect(ActionButton.MouseButton1Click, function()
    print("Syntex Button executed!")
    Notify("SYNTEX HUB", "Button executed successfully.")
end)

-- DROPDOWN
Section(ComponentsPage, "Dropdown Components")

local DropdownFrame = Element(
    ComponentsPage,
    "Example Dropdown",
    "Choose an option.",
    62
)

local Options = {
    "Option 01",
    "Option 02",
    "Option 03",
    "Option 04"
}

local Selected = 1
local DropdownOpen = false

local DropdownButton = Create("TextButton", {
    Size = UDim2.fromOffset(125, 30),
    Position = UDim2.new(1, -137, 0, 16),
    BackgroundColor3 = Colors.Element,
    Text = Options[Selected] .. "  v",
    TextColor3 = Colors.White,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    AutoButtonColor = false
}, DropdownFrame)

Corner(DropdownButton, 6)
Stroke(DropdownButton, Colors.Border, 0.4)

local DropdownList = Create("Frame", {
    Position = UDim2.new(1, -137, 0, 51),
    Size = UDim2.fromOffset(125, 0),
    BackgroundColor3 = Colors.Element,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
    ZIndex = 10
}, DropdownFrame)

Corner(DropdownList, 6)
Stroke(DropdownList, Colors.Purple)

local DropdownLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder
}, DropdownList)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 4),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4)
}, DropdownList)

local function CloseDropdown()
    DropdownOpen = false

    Tween(DropdownList, {
        Size = UDim2.fromOffset(125, 0)
    }, 0.15)

    task.delay(0.16, function()
        if DropdownList.Parent and not DropdownOpen then
            DropdownList.Visible = false
            DropdownFrame.Size = UDim2.new(1, 0, 0, 62)
        end
    end)

    DropdownButton.Text = Options[Selected] .. "  v"
end

for index, option in ipairs(Options) do
    local optionButton = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundColor3 = Colors.Panel,
        Text = option,
        TextColor3 = Colors.Lavender,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        AutoButtonColor = false,
        LayoutOrder = index,
        ZIndex = 11
    }, DropdownList)

    Corner(optionButton, 4)

    Connect(optionButton.MouseButton1Click, function()
        Selected = index
        print("Dropdown selected:", option)

        CloseDropdown()
    end)
end

Connect(DropdownButton.MouseButton1Click, function()
    DropdownOpen = not DropdownOpen

    if DropdownOpen then
        DropdownFrame.Size = UDim2.new(1, 0, 0, 62 + (#Options * 30 + 8))
        DropdownList.Visible = true

        DropdownButton.Text = Options[Selected] .. "  ^"

        Tween(DropdownList, {
            Size = UDim2.fromOffset(125, #Options * 30 + 8)
        }, 0.18)
    else
        CloseDropdown()
    end
end)

-- TEXTBOX
Section(ComponentsPage, "Input Components")

local TextFrame = Element(
    ComponentsPage,
    "Example TextBox",
    "Enter a custom text."
)

local TextInput = Create("TextBox", {
    Size = UDim2.fromOffset(140, 30),
    Position = UDim2.new(1, -152, 0.5, -15),
    BackgroundColor3 = Colors.Element,
    Text = "",
    PlaceholderText = "Type here...",
    PlaceholderColor3 = Colors.Gray,
    TextColor3 = Colors.White,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    ClearTextOnFocus = false
}, TextFrame)

Corner(TextInput, 6)
Stroke(TextInput, Colors.Border, 0.5)

Connect(TextInput.FocusLost, function(enterPressed)
    if enterPressed then
        print("Input:", TextInput.Text)
        Notify("SYNTEX HUB", "Text received.")
    end
end)

-- KEYBIND
Section(ComponentsPage, "Keybind Components")

local KeyFrame = Element(
    ComponentsPage,
    "Example Keybind",
    "Click and press a keyboard key."
)

local KeyButton = Create("TextButton", {
    Size = UDim2.fromOffset(90, 30),
    Position = UDim2.new(1, -102, 0.5, -15),
    BackgroundColor3 = Colors.Element,
    Text = "E",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    AutoButtonColor = false
}, KeyFrame)

Corner(KeyButton, 6)
Stroke(KeyButton, Colors.Border, 0.5)

local WaitingKey = false
local CurrentKey = Enum.KeyCode.E

Connect(KeyButton.MouseButton1Click, function()
    WaitingKey = true
    KeyButton.Text = "..."
end)

Connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end

    if WaitingKey and input.UserInputType == Enum.UserInputType.Keyboard then
        CurrentKey = input.KeyCode
        KeyButton.Text = CurrentKey.Name
        WaitingKey = false

        print("New keybind:", CurrentKey.Name)
    elseif input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == CurrentKey then

        print("Keybind activated!")
        Notify("SYNTEX HUB", "Keybind activated.")
    end
end)

-- SETTINGS PAGE
Section(SettingsPage, "Interface Settings")

local SettingsInfo = Element(
    SettingsPage,
    "SYNTEX HUB",
    "Interface version 2.0.0"
)

local ThemeInfo = Element(
    SettingsPage,
    "Theme",
    "Electric Purple / Neon Magenta"
)

local ResetButtonFrame = Element(
    SettingsPage,
    "Notifications",
    "Test the notification system."
)

local TestNotify = Create("TextButton", {
    Size = UDim2.fromOffset(100, 30),
    Position = UDim2.new(1, -112, 0.5, -15),
    BackgroundColor3 = Colors.Purple,
    Text = "TEST",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false
}, ResetButtonFrame)

Corner(TestNotify, 6)

Connect(TestNotify.MouseButton1Click, function()
    Notify("SYNTEX HUB", "Notification system is working.")
end)

-- INITIAL TAB
Tabs.Home.BackgroundColor3 = Colors.Purple
Tabs.Home.TextColor3 = Colors.White
Pages.Home.Visible = true
CurrentTab = "Home"

-- MINIMIZE
local Minimized = false

Connect(Minimize.MouseButton1Click, function()
    Minimized = not Minimized

    TabBar.Visible = not Minimized
    PageHolder.Visible = not Minimized

    Tween(Main, {
        Size = Minimized
            and UDim2.new(0.82, 0, 0, 65)
            or UDim2.new(0.82, 0, 0.78, 0)
    }, 0.25)

    Minimize.Text = Minimized and "+" or "—"
end)

-- CLOSE CONFIRMATION
local ConfirmOverlay = Create("Frame", {
    Name = "CloseConfirmation",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.35,
    Visible = false,
    ZIndex = 50
}, Main)

local ConfirmBox = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.82, 0, 0, 165),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0,
    ZIndex = 51
}, ConfirmOverlay)

Corner(ConfirmBox, 10)
Stroke(ConfirmBox, Colors.Purple)

NewLabel(
    ConfirmBox,
    "CLOSE SYNTEX HUB?",
    UDim2.new(1, -24, 0, 25),
    UDim2.fromOffset(12, 15),
    Colors.White,
    Enum.Font.GothamBlack
).TextSize = 14

local ConfirmText = NewLabel(
    ConfirmBox,
    "Deseja realmente fechar o SYNTEX HUB?",
    UDim2.new(1, -24, 0, 35),
    UDim2.fromOffset(12, 48),
    Colors.Lavender
)
ConfirmText.TextSize = 10

local CancelButton = Create("TextButton", {
    Size = UDim2.new(0.44, 0, 0, 32),
    Position = UDim2.new(0.04, 0, 1, -45),
    BackgroundColor3 = Colors.Element,
    Text = "CANCEL",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false,
    ZIndex = 52
}, ConfirmBox)

Corner(CancelButton, 6)

local ConfirmButton = Create("TextButton", {
    Size = UDim2.new(0.44, 0, 0, 32),
    Position = UDim2.new(0.52, 0, 1, -45),
    BackgroundColor3 = Colors.Red,
    Text = "CLOSE HUB",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false,
    ZIndex = 52
}, ConfirmBox)

Corner(ConfirmButton, 6)

Connect(CloseButton.MouseButton1Click, function()
    ConfirmOverlay.Visible = true
end)

Connect(CancelButton.MouseButton1Click, function()
    ConfirmOverlay.Visible = false
end)

Connect(ConfirmButton.MouseButton1Click, function()
    Cleanup()
    Screen:Destroy()
end)

-- DRAG WINDOW
local Dragging = false
local DragStart
local StartPosition

Connect(Header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
    end
end)

Connect(UserInputService.InputChanged, function(input)
    if not Dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end
end)

Connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false
    end
end)

-- INITIALIZATION
print("--------------------------------")
print("SYNTEX HUB")
print("Version:", Config.Version)
print("Status: Initializing")
print("--------------------------------")

-- SPLASH ANIMATION
Tween(LoadingFill, {
    Size = UDim2.new(1, 0, 1, 0)
}, Config.SplashDuration)

Tween(Splash, {
    BackgroundTransparency = 0
}, 0.1)

Tween(SplashLogo, {
    Position = UDim2.new(0.5, -85, 0.5, -85)
}, 0.5)

Tween(SplashFallback, {
    Position = UDim2.new(0.5, -125, 0.5, -35)
}, 0.5)

task.wait(Config.SplashDuration)

if Destroyed then return end

-- SHOW MAIN HUB
Main.Visible = true
Main.Position = UDim2.new(0.5, 0, 1.5, 0)

Tween(Main, {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}, 0.45)

Tween(Splash, {
    BackgroundTransparency = 1
}, 0.35)

task.wait(0.4)

if Splash.Parent then
    Splash:Destroy()
end

Notify("SYNTEX HUB", "Interface successfully initialized.")

print("SYNTEX HUB V2.0.0 - ONLINE")
