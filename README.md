NovaLib v6 — Full Script Tutorial

Loading the Library

local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/radiov32waves/NovaLibv2/refs/heads/main/Script.lua"))()


Creating the Window

local Window = Nova:MakeWindow({
    Name         = "My Hub",
    Key          = Enum.KeyCode.RightShift,  -- toggle key
    SaveConfig   = true,
    ConfigFolder = "MyHub",
    HidePremium  = false,
    PremiumIds   = { 123456789 },            -- your Roblox ID
    Icon         = "",
    CloseCallback = function()
        print("closed")
    end,
})


Creating Tabs

local MainTab     = Window:MakeTab({ Name = "⚡  Main" })
local CombatTab   = Window:MakeTab({ Name = "⚔  Combat" })
local SettingsTab = Window:MakeTab({ Name = "⚙  Settings" })


Creating Sections
Sections group elements under a title inside a tab.

local MySection = MainTab:AddSection({ Name = "Player" })


After creating a section, add elements into the section like this:

MySection:AddButton({ ... })
MySection:AddToggle({ ... })


All Elements
Label — simple text line

MainTab:AddLabel("This is a text line")

-- or save it to update later
local myLabel = MainTab:AddLabel("Status: idle")
myLabel:Set("Status: active")


Paragraph — title + body text

MainTab:AddParagraph("About", "This script was made by me.")

-- update later
local myPara = MainTab:AddParagraph("Info", "Loading...")
myPara:Set("Info", "All done!")


Button — clickable button

MainTab:AddButton({
    Name     = "Click Me",
    Callback = function()
        print("Button clicked!")
    end,
})


Toggle — on/off switch

MainTab:AddToggle({
    Name     = "Auto Farm",
    Default  = false,       -- starts off
    Flag     = "autofarm",  -- access via Nova.Flags["autofarm"]
    Save     = true,        -- saves between sessions
    Callback = function(value)
        print("Auto Farm:", value)
    end,
})


Slider — number picker

MainTab:AddSlider({
    Name      = "Walk Speed",
    Min       = 1,
    Max       = 200,
    Increment = 1,
    Default   = 16,
    ValueName = "studs/s",
    Flag      = "speed",
    Save      = true,
    Callback  = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})


Dropdown — pick from a list

local myDropdown = MainTab:AddDropdown({
    Name     = "Choose Mode",
    Options  = { "Easy", "Medium", "Hard" },
    Default  = "Easy",
    Flag     = "mode",
    Save     = true,
    Callback = function(value)
        print("Selected:", value)
    end,
})

-- refresh the list later
myDropdown:Refresh({ "Option1", "Option2" }, true) -- true = clear old list first


Colorpicker — pick a color

local myColor = MainTab:AddColorpicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(120, 80, 255),
    Flag     = "espcolor",
    Save     = true,
    Callback = function(color)
        print("Color:", color)
    end,
})

-- set color from code
myColor:Set(Color3.fromRGB(255, 0, 0))


Bind — keyboard shortcut

MainTab:AddBind({
    Name     = "Toggle ESP",
    Default  = Enum.KeyCode.Z,
    Hold     = false,   -- true = only fires while held down
    Flag     = "espkey",
    Save     = true,
    Callback = function()
        print("Key pressed!")
    end,
})


Textbox — type something

MainTab:AddTextbox({
    Name           = "Player Name",
    Placeholder    = "Enter a name...",
    Default        = "",
    MaxChars       = 30,
    NumbersOnly    = false,
    TextDisappear  = false,   -- true = clears after pressing Enter
    Callback       = function(text, pressedEnter)
        if pressedEnter then
            print("Typed:", text)
        end
    end,
})


Key System — lock script behind a key

local KeyTab = Window:MakeTab({ Name = "🔑  Key" })

KeyTab:AddKeySystem({
    Title       = "Key System",
    Description = "Enter your key to access the script.",
    Placeholder = "NOVA-XXXX-XXXX",
    GetKeyUrl   = "discord.gg/yourserver",
    Keys        = { "NOVA-FREE-2024", "NOVA-VIP-KEY" },
    onSuccess   = function(key)
        print("Correct key:", key)
        -- unlock your tabs here
    end,
    onFail      = function(key)
        print("Wrong key:", key)
    end,
})


Notification — popup message

Nova:MakeNotification({
    Name    = "Hello",
    Content = "Script loaded successfully!",
    Image   = "rbxassetid://4483345998",  -- optional icon
    Time    = 4,  -- seconds
})


Reading Flag Values
Every element with a Flag can be read anywhere using Nova.Flags:

print(Nova.Flags["autofarm"].Value)   -- true or false
print(Nova.Flags["speed"].Value)      -- number
print(Nova.Flags["mode"].Value)       -- string
print(Nova.Flags["espcolor"].Value)   -- Color3

-- set a value from code
Nova.Flags["speed"]:Set(50)
Nova.Flags["autofarm"]:Set(true)


Full Example Script

local Nova = loadstring(game:HttpGet("YOUR_NOVA_URL"))()

local Window = Nova:MakeWindow({
    Name       = "My Hub",
    Key        = Enum.KeyCode.RightShift,
    SaveConfig = true,
    PremiumIds = { 123456789 },
})

-- Tab
local Tab = Window:MakeTab({ Name = "⚡  Main" })

-- Section
local Section = Tab:AddSection({ Name = "Movement" })

-- Info text
Tab:AddParagraph("Welcome", "Toggle the UI with RightShift.")

-- Toggle
Section:AddToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Flag     = "infjump",
    Callback = function(v)
        _G.InfJump = v
    end,
})

-- Slider
Section:AddSlider({
    Name      = "Walk Speed",
    Min       = 1,
    Max       = 200,
    Default   = 16,
    Increment = 1,
    Flag      = "wspeed",
    Callback  = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

-- Button
Section:AddButton({
    Name     = "Reset Character",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
        Nova:MakeNotification({
            Name    = "Done",
            Content = "Character reset.",
            Time    = 3,
        })
    end,
})

-- Infinite jump logic
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)


Quick Reference



|Element           |What it does           |
|------------------|-----------------------|
|`AddLabel`        |Static text line       |
|`AddParagraph`    |Title + body text block|
|`AddButton`       |Clickable button       |
|`AddToggle`       |On/off switch          |
|`AddSlider`       |Number slider          |
|`AddDropdown`     |Pick from a list       |
|`AddColorpicker`  |Pick a Color3          |
|`AddBind`         |Keyboard shortcut      |
|`AddTextbox`      |Type text input        |
|`AddKeySystem`    |Key verification lock  |
|`MakeNotification`|Popup toast message    |
