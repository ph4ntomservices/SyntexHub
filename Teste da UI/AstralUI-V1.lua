
--[[
    ASTRAL SYSTEMS HUB
    Version: 1.0.0
    Platform: Roblox
    Language: Luau
    Type: LocalScript
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIGURATION
local Config = {
    Name = "ASTRAL SYSTEMS",
    Version = "1.0.0",
    DefaultTheme = Color3.fromRGB(9, 17, 34),
}

-- COLORS
local Colors = {
    Background = Color3.fromRGB(9, 17, 34),
    Panel = Color3.fromRGB(15, 26, 47),
    Element = Color3.fromRGB(22, 35, 57),
    Border = Color3.fromRGB(49, 65, 88),
    White = Color3.fromRGB(245, 247, 250),
    Gray = Color3.fromRGB(153, 166, 185),
    Accent = Color3.fromRGB(190, 205, 225),
    Active = Color3.fromRGB(225, 235, 248),
}

-- CLEANUP
local Old = PlayerGui:FindFirstChild("AstralSystemsHub")
if Old then
    Old:Destroy()
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
    TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad),
        properties
    ):Play()
end

-- SCREEN GUI
local Screen = Create("ScreenGui", {
    Name = "AstralSystemsHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

-- MAIN WINDOW
local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(510, 440),
    Position = UDim2.new(0.5, -255, 0.5, -220),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, Screen)

Corner(Main, 12)
Stroke(Main, Colors.Border)

-- TOP BAR
local Topbar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Colors.Panel,
    BorderSizePixel = 0
}, Main)

local Logo = Create("TextLabel", {
    Position = UDim2.fromOffset(18, 7),
    Size = UDim2.new(1, -100, 0, 25),
    BackgroundTransparency = 1,
    Text = "ASTRAL SYSTEMS",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, Topbar)

local Version = Create("TextLabel", {
    Position = UDim2.fromOffset(19, 32),
    Size = UDim2.new(1, -100, 0, 15),
    BackgroundTransparency = 1,
    Text = "SYSTEM HUB  /  V1.0.0",
    TextColor3 = Colors.Gray,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left
}, Topbar)

local Minimize = Create("TextButton", {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -43, 0, 14),
    BackgroundColor3 = Colors.Element,
    Text = "—",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false
}, Topbar)

Corner(Minimize, 6)

-- CONTENT
local Content = Create("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.fromOffset(12, 70),
    Size = UDim2.new(1, -24, 1, -82),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Colors.Accent,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, Main)

local Layout = Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Content)

local Padding = Create("UIPadding", {
    PaddingTop = UDim.new(0, 3),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 3),
    PaddingRight = UDim.new(0, 3)
}, Content)

-- SECTION
local function Section(name)
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = string.upper(name),
        TextColor3 = Colors.Gray,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Content)

    return Label
end

-- ELEMENT CONTAINER
local function Element(name, description, height)
    local Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 58),
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0
    }, Content)

    Corner(Frame, 8)
    Stroke(Frame, Colors.Border, 0.5)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(0.58, -12, 0, 19),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Colors.White,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Frame)

    if description then
        Create("TextLabel", {
            Position = UDim2.fromOffset(12, 29),
            Size = UDim2.new(0.65, -12, 0, 16),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = Colors.Gray,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Frame)
    end

    return Frame
end

-- NOTIFICATIONS
local function Notify(title, message)
    local Notification = Create("Frame", {
        Size = UDim2.fromOffset(260, 65),
        Position = UDim2.new(1, 280, 1, -85),
        BackgroundColor3 = Colors.Panel,
        BorderSizePixel = 0
    }, Screen)

    Corner(Notification, 9)
    Stroke(Notification)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 9),
        Size = UDim2.new(1, -24, 0, 19),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.White,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Notification)

    Create("TextLabel", {
        Position = UDim2.fromOffset(12, 31),
        Size = UDim2.new(1, -24, 0, 20),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Colors.Gray,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Notification)

    Tween(Notification, {
        Position = UDim2.new(1, -275, 1, -85)
    }, 0.3)

    task.delay(3, function()
        if Notification.Parent then
            Tween(Notification, {
                Position = UDim2.new(1, 280, 1, -85)
            }, 0.3)
            task.wait(0.35)
            Notification:Destroy()
        end
    end)
end

-- SECTION: TOGGLE
Section("Toggle Components")

local ToggleFrame = Element("Example Toggle", "Enable or disable a feature")

local ToggleState = false

local ToggleButton = Create("TextButton", {
    Size = UDim2.fromOffset(42, 23),
    Position = UDim2.new(1, -55, 0.5, -11),
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

ToggleButton.MouseButton1Click:Connect(function()
    ToggleState = not ToggleState

    Tween(ToggleButton, {
        BackgroundColor3 = ToggleState and Colors.Accent or Colors.Element
    })

    Tween(ToggleCircle, {
        Position = ToggleState
            and UDim2.new(1, -20, 0, 3)
            or UDim2.fromOffset(3, 3)
    })

    print("Toggle:", ToggleState)
end)

-- SECTION: SLIDER
Section("Slider Components")

local SliderFrame = Element("Example Slider", "Adjust the value: 50", 75)

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
    BackgroundColor3 = Colors.Accent,
    BorderSizePixel = 0
}, SliderTrack)

Corner(SliderFill, 10)

local SliderValue = Create("TextLabel", {
    Position = UDim2.new(1, -60, 0, 8),
    Size = UDim2.fromOffset(48, 20),
    BackgroundTransparency = 1,
    Text = "50",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right
}, SliderFrame)

local Sliding = false
local MinValue, MaxValue = 0, 100

local function UpdateSlider(input)
    local relative = math.clamp(
        (input.Position.X - SliderTrack.AbsolutePosition.X)
        / SliderTrack.AbsoluteSize.X,
        0, 1
    )

    local value = math.floor(MinValue + relative * (MaxValue - MinValue))

    SliderFill.Size = UDim2.new(relative, 0, 1, 0)
    SliderValue.Text = tostring(value)

    SliderFrame:FindFirstChildWhichIsA("TextLabel").Text =
        "Adjust the value: " .. value

    print("Slider:", value)
end

SliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Sliding = true
        UpdateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Sliding and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Sliding = false
    end
end)

-- SECTION: BUTTON
Section("Button Components")

local ButtonFrame = Element("Example Button", "Execute a test action")

local ActionButton = Create("TextButton", {
    Size = UDim2.fromOffset(95, 29),
    Position = UDim2.new(1, -107, 0.5, -14),
    BackgroundColor3 = Colors.Element,
    Text = "EXECUTE",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false
}, ButtonFrame)

Corner(ActionButton, 6)
Stroke(ActionButton)

ActionButton.MouseButton1Click:Connect(function()
    print("Astral Button executed!")
    Notify("ASTRAL SYSTEMS", "Button executed successfully.")
end)

-- SECTION: DROPDOWN
Section("Dropdown Components")

local DropdownFrame = Element("Example Dropdown", "Choose an option")

local Options = {"Option 01", "Option 02", "Option 03"}
local Selected = 1

local DropdownButton = Create("TextButton", {
    Size = UDim2.fromOffset(115, 29),
    Position = UDim2.new(1, -127, 0.5, -14),
    BackgroundColor3 = Colors.Element,
    Text = Options[Selected] .. "  v",
    TextColor3 = Colors.White,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    AutoButtonColor = false
}, DropdownFrame)

Corner(DropdownButton, 6)

DropdownButton.MouseButton1Click:Connect(function()
    Selected = (Selected % #Options) + 1
    DropdownButton.Text = Options[Selected] .. "  v"

    print("Selected:", Options[Selected])
end)

-- SECTION: TEXTBOX
Section("Input Components")

local TextFrame = Element("Example TextBox", "Enter a custom text")

local TextInput = Create("TextBox", {
    Size = UDim2.fromOffset(140, 29),
    Position = UDim2.new(1, -152, 0.5, -14),
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

TextInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        print("Input:", TextInput.Text)
        Notify("ASTRAL SYSTEMS", "Text received.")
    end
end)

-- SECTION: KEYBIND
Section("Keybind Components")

local KeyFrame = Element("Example Keybind", "Click and press a keyboard key")

local KeyButton = Create("TextButton", {
    Size = UDim2.fromOffset(90, 29),
    Position = UDim2.new(1, -102, 0.5, -14),
    BackgroundColor3 = Colors.Element,
    Text = "E",
    TextColor3 = Colors.White,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    AutoButtonColor = false
}, KeyFrame)

Corner(KeyButton, 6)

local WaitingKey = false
local CurrentKey = Enum.KeyCode.E

KeyButton.MouseButton1Click:Connect(function()
    WaitingKey = true
    KeyButton.Text = "..."
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if WaitingKey and input.UserInputType == Enum.UserInputType.Keyboard then
        CurrentKey = input.KeyCode
        KeyButton.Text = CurrentKey.Name
        WaitingKey = false
        print("Keybind:", CurrentKey.Name)
    elseif input.KeyCode == CurrentKey then
        print("Keybind activated!")
    end
end)

-- MINIMIZE
local Minimized = false

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    Content.Visible = not Minimized

    Tween(Main, {
        Size = Minimized
            and UDim2.fromOffset(510, 58)
            or UDim2.fromOffset(510, 440)
    }, 0.25)

    Minimize.Text = Minimized and "+" or "—"
end)

-- DRAG WINDOW
local Dragging = false
local DragStart
local StartPosition

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local Delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

-- INITIALIZATION
Notify("ASTRAL SYSTEMS", "Interface initialized.")

print("--------------------------------")
print("ASTRAL SYSTEMS HUB")
print("Version:", Config.Version)
print("Status: Initialized")
print("--------------------------------")
