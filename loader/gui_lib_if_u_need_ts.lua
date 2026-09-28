-- made by chhhhhhhhhhh111
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.__index = Library

local DEFAULTS = {
    background = Color3.fromRGB(10, 10, 13),
    background2 = Color3.fromRGB(17, 17, 21),
    card = Color3.fromRGB(19, 19, 24),
    stroke = Color3.fromRGB(37, 37, 45),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(142, 142, 152),
    accent = Color3.fromRGB(168, 143, 242),
    accent2 = Color3.fromRGB(203, 186, 255),
}

local function make(className, props, parent)
    local item = Instance.new(className)
    for key, value in pairs(props or {}) do item[key] = value end
    item.Parent = parent
    return item
end

local function round(item, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = item
    return corner
end

local function outline(item, color)
    local border = Instance.new("UIStroke")
    border.Color = color
    border.Transparency = 0.1
    border.Parent = item
    return border
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function guiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function drag(handle, target)
    local active, startInput, startPosition = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        active, startInput, startPosition = true, input.Position, target.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then active = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not active or not isMove(input) then return end
        local delta = input.Position - startInput
        target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)
end

local function tween(item, info, properties)
    local animation = TweenService:Create(item, info or TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    animation:Play()
    return animation
end

local function asset(image, source)
    if type(source) ~= "string" or source == "" then return end
    if source:match("^%d+$") then image.Image = "rbxassetid://" .. source
    elseif source:match("^rbxassetid://") or source:match("^rbxthumb://") then image.Image = source
    else image.Image = source end
end

local function copyDefaults(custom)
    local result = {}
    for key, value in pairs(DEFAULTS) do result[key] = custom and custom[key] or value end
    return result
end

function Library.new(options)
    options = options or {}
    local self = setmetatable({ tabs = {}, windows = {}, theme = copyDefaults(options.theme), destroyed = false }, Library)
    local gui = make("ScreenGui", { Name = options.name or "kaVoX_Menu", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = options.displayOrder or 1000 }, guiParent())
    self.gui = gui

    local width = math.clamp(options.width or 680, 560, 1100)
    local height = math.clamp(options.height or 440, 360, 820)
    local window = make("CanvasGroup", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(width, height), BackgroundColor3 = self.theme.background, BorderSizePixel = 0, GroupTransparency = 0, ClipsDescendants = true }, gui)
    round(window, options.radius or 12)
    outline(window, self.theme.stroke)
    self.window = window

    local header = make("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 }, window)
    local title = make("TextLabel", { Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 14, Text = options.title or "kaVo.x Menu", TextColor3 = self.theme.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, header)
    self.title = title
    drag(header, window)
    local minimize = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -50, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Text = "−", TextColor3 = self.theme.muted, Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false }, header)
    local close = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 82, 98), Font = Enum.Font.GothamBold, TextSize = 20, AutoButtonColor = false }, header)
    close.MouseButton1Click:Connect(function() self:Destroy() end)
    minimize.MouseButton1Click:Connect(function() self:Close() end)

    local sidebar = make("Frame", { Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 168, 1, -16), BackgroundColor3 = self.theme.background2, BorderSizePixel = 0, ClipsDescendants = true }, window)
    round(sidebar, 10)
    local brand = make("TextLabel", { Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1, Text = options.brand or "kaVo.x", TextColor3 = self.theme.text, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, sidebar)
    local subtitle = make("TextLabel", { Position = UDim2.new(0, 14, 0, 27), Size = UDim2.new(1, -28, 0, 12), BackgroundTransparency = 1, Text = options.subtitle or "script menu", TextColor3 = self.theme.muted, Font = Enum.Font.Gotham, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left }, sidebar)
    local tabHolder = make("ScrollingFrame", { Position = UDim2.new(0, 8, 0, 52), Size = UDim2.new(1, -16, 1, -60), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, sidebar)
    make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, tabHolder)
    local content = make("Frame", { Position = UDim2.new(0, 184, 0, 40), Size = UDim2.new(1, -184, 1, -40), BackgroundTransparency = 1, ClipsDescendants = true }, window)
    self.sidebar, self.tabHolder, self.content = sidebar, tabHolder, content

    function self:Open() window.Visible = true end
    function self:Close() window.Visible = false end
    function self:Toggle() window.Visible = not window.Visible end
    function self:SetTitle(value) title.Text = tostring(value) end
    function self:SetTheme(theme)
        for key, value in pairs(theme or {}) do self.theme[key] = value end
        window.BackgroundColor3 = self.theme.background
        sidebar.BackgroundColor3 = self.theme.background2
        title.TextColor3 = self.theme.text
        for _, tab in ipairs(self.tabs) do tab:RefreshTheme() end
    end
    function self:Destroy() self.destroyed = true; if gui then gui:Destroy() end end
    return self
end

Library.CreateWindow = Library.new

local function addControl(tab, control)
    tab.controls[#tab.controls + 1] = control
    return control
end

function Library:AddTab(options)
    options = options or {}
    local tab = setmetatable({ library = self, controls = {}, title = options.title or ("Tab " .. (#self.tabs + 1)), icon = options.icon or options.iconUrl or options.iconId }, { __index = Library.Tab })
    tab.page = make("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = self.theme.stroke, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = #self.tabs == 0 }, self.content)
    make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, tab.page)
    make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }, tab.page)
    tab.button = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.theme.accent, BackgroundTransparency = #self.tabs == 0 and 0 or 1, Text = "", AutoButtonColor = false }, self.tabHolder)
    round(tab.button, 8)
    local icon = make("ImageLabel", { Position = UDim2.new(0, 10, 0.5, -6), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1 }, tab.button)
    asset(icon, tab.icon)
    local label = make("TextLabel", { Position = UDim2.new(0, 31, 0, 0), Size = UDim2.new(1, -38, 1, 0), BackgroundTransparency = 1, Text = tab.title, TextColor3 = self.theme.text, TextTransparency = #self.tabs == 0 and 0 or 0.35, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, tab.button)
    tab.iconObject, tab.label = icon, label
    self.tabs[#self.tabs + 1] = tab
    function tab:Select()
        for _, item in ipairs(self.library.tabs) do
            local active = item == self
            item.page.Visible = active
            item.button.BackgroundTransparency = active and 0 or 1
            item.label.TextTransparency = active and 0 or 0.35
        end
    end
    function tab:RefreshTheme()
        tab.button.BackgroundColor3 = self.library.theme.accent
        tab.label.TextColor3 = self.library.theme.text
    end
    tab.button.MouseButton1Click:Connect(function() tab:Select() end)
    return tab
end

Library.Tab = {}

function Library.Tab:Label(options)
    options = type(options) == "table" and options or { title = options }
    return addControl(self, make("TextLabel", { Size = UDim2.new(1, 0, 0, options.height or 26), BackgroundTransparency = 1, Text = tostring(options.title or options.text or ""), TextColor3 = self.library.theme.muted, Font = Enum.Font.GothamBold, TextSize = options.textSize or 10, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = options.wrapped == true }, self.page))
end

function Library.Tab:Section(title)
    local holder = make("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1 }, self.page)
    make("Frame", { Position = UDim2.new(0, 0, 0.5, -5), Size = UDim2.fromOffset(3, 10), BackgroundColor3 = self.library.theme.accent, BorderSizePixel = 0 }, holder)
    make("TextLabel", { Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -10, 1, 0), BackgroundTransparency = 1, Text = tostring(title), TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, holder)
    return addControl(self, holder)
end

function Library.Tab:Button(options)
    options = options or {}
    local button = make("TextButton", { Size = UDim2.new(1, 0, 0, options.height or 32), BackgroundColor3 = self.library.theme.card, Text = tostring(options.title or options.text or "Button"), TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, self.page)
    round(button, 8); outline(button, self.library.theme.stroke)
    button.MouseEnter:Connect(function() tween(button, nil, { BackgroundColor3 = self.library.theme.accent }) end)
    button.MouseLeave:Connect(function() tween(button, nil, { BackgroundColor3 = self.library.theme.card }) end)
    button.MouseButton1Click:Connect(function() if options.callback then options.callback() end end)
    return addControl(self, button)
end

function Library.Tab:Toggle(options)
    options = options or {}
    local value = options.value == true
    local row = make("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1 }, self.page)
    make("TextLabel", { Size = UDim2.new(1, -58, 1, 0), BackgroundTransparency = 1, Text = tostring(options.title or "Toggle"), TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, row)
    local button = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(38, 19), Text = "", AutoButtonColor = false }, row)
    round(button, 10)
    local knob = make("Frame", { Size = UDim2.fromOffset(15, 15), BorderSizePixel = 0 }, button)
    round(knob, 8)
    local function render()
        button.BackgroundColor3 = value and self.library.theme.accent or self.library.theme.card
        knob.BackgroundColor3 = value and self.library.theme.text or self.library.theme.muted
        knob.Position = value and UDim2.new(1, -17, 0.5, -7.5) or UDim2.new(0, 2, 0.5, -7.5)
    end
    render()
    button.MouseButton1Click:Connect(function() value = not value; render(); if options.callback then options.callback(value) end end)
    local control = { Get = function() return value end, Set = function(_, nextValue) value = nextValue == true; render(); if options.callback then options.callback(value) end end }
    addControl(self, control)
    if options.settings and type(options.settings.build) == "function" then
        local gear = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -45, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "⚙", TextColor3 = self.library.theme.muted, Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = false }, row)
        gear.MouseButton1Click:Connect(function()
            local child = self.library:CreateWindow({ title = options.settings.title or "Toggle Settings", width = options.settings.width or 360, height = options.settings.height or 400 })
            local settingsTab = child:AddTab({ title = options.settings.title or "Settings", icon = "settings" })
            options.settings.build(settingsTab)
        end)
    end
    return control
end

function Library.Tab:Slider(options)
    options = options or {}
    local min, max = options.min or 0, options.max or 100
    local value = math.clamp(tonumber(options.value) or min, min, max)
    local row = make("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 }, self.page)
    local label = make("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local track = make("TextButton", { Position = UDim2.new(0, 5, 0, 29), Size = UDim2.new(1, -10, 0, 5), BackgroundColor3 = self.library.theme.stroke, Text = "", AutoButtonColor = false }, row)
    round(track, 3)
    local fill = make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = self.library.theme.accent, BorderSizePixel = 0 }, track)
    round(fill, 3)
    local active = false
    local function set(nextValue)
        value = math.clamp(tonumber(nextValue) or min, min, max)
        local alpha = (value - min) / math.max(max - min, 0.0001)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        label.Text = tostring(options.title or "Slider") .. ": " .. tostring(math.floor(value * 100) / 100)
        if options.callback then options.callback(value) end
    end
    local function update(input) set(min + (max - min) * math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)) end
    track.InputBegan:Connect(function(input) if isPress(input) then active = true; update(input); input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then active = false end end) end end)
    UserInputService.InputChanged:Connect(function(input) if active and isMove(input) then update(input) end end)
    set(value)
    return addControl(self, { Get = function() return value end, Set = function(_, nextValue) set(nextValue) end })
end

function Library.Tab:Dropdown(options)
    options = options or {}
    local values, selected = options.options or {}, options.value or (options.options and options.options[1])
    local button = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, self.page)
    round(button, 8)
    local function render() button.Text = tostring(options.title or "Dropdown") .. ": " .. tostring(selected or "-") end
    render()
    button.MouseButton1Click:Connect(function() if #values == 0 then return end; selected = values[(table.find(values, selected) or 0) % #values + 1]; render(); if options.callback then options.callback(selected) end end)
    return addControl(self, { Get = function() return selected end, Set = function(_, nextValue) selected = nextValue; render() end })
end

function Library.Tab:Colorpicker(options)
    options = options or {}
    local color = options.value or self.library.theme.accent
    local button = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, Text = tostring(options.title or "Color"), TextColor3 = self.library.theme.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, self.page)
    round(button, 8)
    local swatch = make("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(24, 18), BackgroundColor3 = color, BorderSizePixel = 0 }, button)
    round(swatch, 5)
    local colors = options.colors or { Color3.fromRGB(255, 82, 98), Color3.fromRGB(168, 143, 242), Color3.fromRGB(92, 150, 255), Color3.fromRGB(80, 225, 160), Color3.fromRGB(240, 200, 90) }
    button.MouseButton1Click:Connect(function() color = colors[(table.find(colors, color) or 0) % #colors + 1]; swatch.BackgroundColor3 = color; if options.callback then options.callback(color) end end)
    return addControl(self, { Get = function() return color end, Set = function(_, nextValue) if typeof(nextValue) == "Color3" then color = nextValue; swatch.BackgroundColor3 = color; if options.callback then options.callback(color) end end end })
end

function Library.Tab:Textbox(options)
    options = options or {}
    local box = make("TextBox", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, Text = options.value or "", PlaceholderText = options.placeholder or "", TextColor3 = self.library.theme.text, PlaceholderColor3 = self.library.theme.muted, Font = Enum.Font.Gotham, TextSize = 10, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, self.page)
    round(box, 8)
    make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
    box.FocusLost:Connect(function() if options.callback then options.callback(box.Text) end end)
    return addControl(self, box)
end

local env = (getgenv and getgenv()) or _G
return Library
