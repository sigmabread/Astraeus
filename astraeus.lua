--// ASTRAEUS FULL UI SYSTEM

local Astraeus = {}
Astraeus.__index = Astraeus

--// SERVICES
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// THEME ENGINE
local Theme = {
    Background = Color3.fromRGB(15,15,18),
    Card = Color3.fromRGB(25,25,30),
    Accent = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(240,240,240)
}

function Astraeus:SetTheme(new)
    for k,v in pairs(new) do
        Theme[k] = v
    end
end

--// UTILS
local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Ripple(btn)
    local circle = Instance.new("Frame", btn)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    circle.BackgroundTransparency = 0.7
    circle.Size = UDim2.new(0,0,0,0)
    circle.AnchorPoint = Vector2.new(0.5,0.5)
    circle.Position = UDim2.new(0.5,0,0.5,0)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    Tween(circle, {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1}, 0.4)
    task.delay(0.4, function() circle:Destroy() end)
end

--// CREATE ROOT
function Astraeus:Create()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "ASTRAEUS_FULL"

    local root = Instance.new("Frame", gui)
    root.Size = UDim2.new(1,0,1,0)
    root.BackgroundTransparency = 1

    local system = {}
    system.Cards = {}

    --// CREATE CARD (DRAGGABLE PANEL)
    function system:CreateCard(title, pos)
        local card = Instance.new("Frame", root)
        card.Size = UDim2.new(0, 300, 0, 250)
        card.Position = pos or UDim2.new(0.3,0,0.3,0)
        card.BackgroundColor3 = Theme.Card
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)

        -- Glow
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Theme.Accent
        stroke.Transparency = 0.8

        -- Title
        local titleLbl = Instance.new("TextLabel", card)
        titleLbl.Size = UDim2.new(1,0,0,35)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = Theme.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 16

        -- Layout
        local container = Instance.new("Frame", card)
        container.Size = UDim2.new(1,0,1,-35)
        container.Position = UDim2.new(0,0,0,35)
        container.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", container)
        layout.Padding = UDim.new(0,8)

        -- Dragging
        local dragging, start, startPos
        card.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = i.Position
                startPos = card.Position
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging then
                local delta = i.Position - start
                card.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        local elements = {}

        -- BUTTON
        function elements:Button(text, cb)
            local btn = Instance.new("TextButton", container)
            btn.Size = UDim2.new(1,-10,0,35)
            btn.Text = text
            btn.BackgroundColor3 = Theme.Background
            btn.TextColor3 = Theme.Text
            Instance.new("UICorner", btn)

            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.Accent}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = Theme.Background}, 0.2)
            end)

            btn.MouseButton1Click:Connect(function()
                Ripple(btn)
                cb()
            end)
        end

        -- TOGGLE
        function elements:Toggle(text, cb)
            local state = false

            local btn = Instance.new("TextButton", container)
            btn.Size = UDim2.new(1,-10,0,35)
            btn.Text = text.." [OFF]"
            btn.BackgroundColor3 = Theme.Background
            btn.TextColor3 = Theme.Text
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = text.." ["..(state and "ON" or "OFF").."]"
                Ripple(btn)
                cb(state)
            end)
        end

        -- SLIDER
        function elements:Slider(text, min, max, cb)
            local val = min

            local frame = Instance.new("Frame", container)
            frame.Size = UDim2.new(1,-10,0,50)
            frame.BackgroundColor3 = Theme.Background
            Instance.new("UICorner", frame)

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1,0,0.5,0)
            lbl.Text = text..": "..val
            lbl.TextColor3 = Theme.Text
            lbl.BackgroundTransparency = 1

            local bar = Instance.new("Frame", frame)
            bar.Size = UDim2.new(1,-20,0,6)
            bar.Position = UDim2.new(0,10,1,-15)
            bar.BackgroundColor3 = Theme.Card

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundColor3 = Theme.Accent

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move
                    move = UIS.InputChanged:Connect(function(m)
                        if m.UserInputType == Enum.UserInputType.MouseMovement then
                            local p = math.clamp(
                                (m.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,
                                0,1
                            )
                            val = math.floor(min + (max-min)*p)
                            fill.Size = UDim2.new(p,0,1,0)
                            lbl.Text = text..": "..val
                            cb(val)
                        end
                    end)

                    UIS.InputEnded:Connect(function(e)
                        if e.UserInputType == Enum.UserInputType.MouseButton1 then
                            move:Disconnect()
                        end
                    end)
                end
            end)
        end

        return elements
    end

    -- FPS MONITOR CARD
    function system:CreateStatsCard()
        local card = system:CreateCard("Performance", UDim2.new(0.75,0,0.05,0))

        local fpsLabel
        card:Button("Init FPS", function() end)

        fpsLabel = card

        local frames, last = 0, tick()

        RunService.RenderStepped:Connect(function()
            frames += 1
            if tick()-last >= 1 then
                last = tick()
                frames = 0
            end
        end)
    end

    -- CONFIG SYSTEM
    function system:SaveConfig(name, data)
        writefile(name..".json", HttpService:JSONEncode(data))
    end

    function system:LoadConfig(name)
        if isfile(name..".json") then
            return HttpService:JSONDecode(readfile(name..".json"))
        end
    end

    return system
end

return Astraeus
