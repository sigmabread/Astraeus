--// ASTRAEUS ASCENDED (GEN2 STYLE)

local Astraeus = {}
Astraeus.__index = Astraeus

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// THEME
local Theme = {
    Background = Color3.fromRGB(20,20,25),
    Sidebar = Color3.fromRGB(15,15,18),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(255,255,255)
}

--// WINDOW
function Astraeus:CreateWindow(config)
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "ASTRAEUS_GEN2"

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 700, 0, 450)
    main.Position = UDim2.new(0.5,-350,0.5,-225)
    main.BackgroundColor3 = Theme.Background
    Instance.new("UICorner", main)

    -- SIDEBAR
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.BackgroundColor3 = Theme.Sidebar

    local tabLayout = Instance.new("UIListLayout", sidebar)

    -- CONTENT
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1,-160,1,0)
    content.Position = UDim2.new(0,160,0,0)
    content.BackgroundTransparency = 1

    local window = {}
    window.Tabs = {}

    -- SEARCH BAR
    local search = Instance.new("TextBox", sidebar)
    search.PlaceholderText = "Search..."
    search.Size = UDim2.new(1,-10,0,30)
    search.BackgroundColor3 = Theme.Background
    search.TextColor3 = Theme.Text
    Instance.new("UICorner", search)

    -- CREATE TAB
    function window:CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1,0,0,40)
        tabBtn.Text = name
        tabBtn.BackgroundTransparency = 1
        tabBtn.TextColor3 = Theme.Text

        local page = Instance.new("ScrollingFrame", content)
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", page)

        tabBtn.MouseButton1Click:Connect(function()
            for _,v in pairs(content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            page.Visible = true
        end)

        local tab = {}

        -- SECTION
        function tab:CreateSection(title)
            local section = Instance.new("Frame", page)
            section.Size = UDim2.new(1,-10,0,0)
            section.BackgroundTransparency = 1

            local layout = Instance.new("UIListLayout", section)

            local sec = {}

            -- BUTTON
            function sec:Button(txt, cb)
                local btn = Instance.new("TextButton", section)
                btn.Size = UDim2.new(1,0,0,35)
                btn.Text = txt
                btn.BackgroundColor3 = Theme.Sidebar
                btn.TextColor3 = Theme.Text
                Instance.new("UICorner", btn)

                btn.MouseButton1Click:Connect(cb)
            end

            -- TOGGLE
            function sec:Toggle(txt, cb)
                local state = false

                local btn = Instance.new("TextButton", section)
                btn.Size = UDim2.new(1,0,0,35)
                btn.Text = txt.." [OFF]"
                btn.BackgroundColor3 = Theme.Sidebar
                btn.TextColor3 = Theme.Text

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.Text = txt.." ["..(state and "ON" or "OFF").."]"
                    cb(state)
                end)
            end

            -- SLIDER
            function sec:Slider(txt, min, max, cb)
                local val = min

                local slider = Instance.new("TextButton", section)
                slider.Size = UDim2.new(1,0,0,35)
                slider.Text = txt..": "..val
                slider.BackgroundColor3 = Theme.Sidebar
                slider.TextColor3 = Theme.Text

                slider.MouseButton1Click:Connect(function()
                    val = val + 1
                    if val > max then val = min end
                    slider.Text = txt..": "..val
                    cb(val)
                end)
            end

            return sec
        end

        return tab
    end

    -- CONFIG SYSTEM
    function window:SaveConfig(name, data)
        writefile(name..".json", HttpService:JSONEncode(data))
    end

    function window:LoadConfig(name)
        if isfile(name..".json") then
            return HttpService:JSONDecode(readfile(name..".json"))
        end
    end

    return window
end

return Astraeus
