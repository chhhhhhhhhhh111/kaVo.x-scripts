-- made by chhhhhhhhhhh111
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

local function parentGui(gui)
    local getHui = rawget(_G, "gethui")
    if type(getHui) == "function" then
        local ok, result = pcall(getHui)
        if ok and result then return result end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function corner(parent, radius)
    local item = Instance.new("UICorner")
    item.CornerRadius = UDim.new(0, radius or 8)
    item.Parent = parent
end

local function stroke(parent, color)
    local item = Instance.new("UIStroke")
    item.Color = color
    item.Transparency = 0.15
    item.Parent = parent
end

local function make(className, props, parent)
    local item = Instance.new(className)
    for key, value in pairs(props or {}) do item[key] = value end
    item.Parent = parent
    return item
end

local function clampNumber(value, min, max)
    return math.clamp(tonumber(value) or min, min, max)
end

local function draggable(handle, target)
    local dragging = false
    local startInput, startPosition
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        startInput = input.Position
        startPosition = target.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - startInput
        target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end)
end

function Library.new(options)
    options = options or {}
    local self = setmetatable({ tabs = {}, theme = options.theme or {} }, Library)
    self.theme.background = self.theme.background or Color3.fromRGB(12, 13, 18)
    self.theme.panel = self.theme.panel or Color3.fromRGB(20, 22, 29)
    self.theme.card = self.theme.card or Color3.fromRGB(27, 30, 39)
    self.theme.text = self.theme.text or Color3.fromRGB(245, 247, 255)
    self.theme.muted = self.theme.muted or Color3.fromRGB(150, 157, 175)
    self.theme.accent = self.theme.accent or Color3.fromRGB(168, 143, 242)

    local gui = make("ScreenGui", { Name = options.name or "kaVoX_Menu", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, parentGui())
    self.gui = gui
    local window = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(math.clamp(options.width or 520, 280, 1100), math.clamp(options.height or 380, 220, 800)), BackgroundColor3 = self.theme.background, BorderSizePixel = 0, ClipsDescendants = true }, gui)
    corner(window, options.radius or 10)
    stroke(window, self.theme.card)
    self.window = window

    local header = make("TextButton", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, window)
    local title = make("TextLabel", { Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = options.title or "kaVo.x Menu", TextColor3 = self.theme.text }, header)
    draggable(header, window)
    local close = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Text = "×", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(255, 100, 115), AutoButtonColor = false }, header)
    close.MouseButton1Click:Connect(function() self:Destroy() end)

    local sidebar = make("Frame", { Position = UDim2.new(0, 8, 0, 50), Size = UDim2.new(0, 126, 1, -58), BackgroundColor3 = self.theme.panel, BorderSizePixel = 0 }, window)
    corner(sidebar, 8)
    local tabList = make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
    make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, sidebar)
    local content = make("Frame", { Position = UDim2.new(0, 142, 0, 50), Size = UDim2.new(1, -150, 1, -58), BackgroundTransparency = 1, ClipsDescendants = true }, window)
    self.sidebar, self.content, self.title = sidebar, content, title

    function self:Toggle()
        window.Visible = not window.Visible
    end
    function self:Open() window.Visible = true end
    function self:Close() window.Visible = false end
    function self:Destroy() if gui then gui:Destroy() end end
    function self:SetTitle(value) title.Text = tostring(value) end
    return self
end

Library.CreateWindow = Library.new

function Library:AddTab(options)
    options = options or {}
    local tab = { library = self, controls = {}, title = options.title or ("Tab " .. (#self.tabs + 1)) }
    tab.page = make("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = self.theme.accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = #self.tabs == 0 }, self.content)
    make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, tab.page)
    make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, tab.page)
    tab.button = make("TextButton", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = self.theme.accent, BackgroundTransparency = #self.tabs == 0 and 0 or 1, Text = tab.title, Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.theme.text, TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false }, self.sidebar)
    corner(tab.button, 6)
    self.tabs[#self.tabs + 1] = tab
    function tab:Select()
        for _, item in ipairs(self.library.tabs) do
            item.page.Visible = item == self
            item.button.BackgroundTransparency = item == self and 0 or 1
        end
    end
    local function add(control) tab.controls[#tab.controls + 1] = control; return control end
    function tab:Label(text)
        return add(make("TextLabel", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = tostring(text), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = self.library.theme.muted, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }, self.page))
    end
    function tab:Button(options)
        options = options or {}; local button = make("TextButton", { Size = UDim2.new(1, 0, 0, options.height or 32), BackgroundColor3 = self.library.theme.card, Text = options.title or "Button", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.library.theme.text, AutoButtonColor = false }, self.page); corner(button, 7); stroke(button, self.library.theme.card); button.MouseButton1Click:Connect(function() if options.callback then options.callback() end end); return add(button)
    end
    function tab:Toggle(options)
        options = options or {}; local value = options.value == true; local row = make("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 }, self.page); make("TextLabel", { Size = UDim2.new(1, -54, 1, 0), BackgroundTransparency = 1, Text = options.title or "Toggle", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.library.theme.text, TextXAlignment = Enum.TextXAlignment.Left }, row); local button = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 20), Text = "", AutoButtonColor = false }, row); corner(button, 10); local knob = make("Frame", { Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0 }, button); corner(knob, 8); local function draw() button.BackgroundColor3 = value and self.library.theme.accent or self.library.theme.card; knob.BackgroundColor3 = value and self.library.theme.text or self.library.theme.muted; knob.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) end; draw(); button.MouseButton1Click:Connect(function() value = not value; draw(); if options.callback then options.callback(value) end end); return add({ Get = function() return value end, Set = function(_, nextValue) value = nextValue == true; draw(); if options.callback then options.callback(value) end end })
    end
    function tab:Textbox(options)
        options = options or {}; local box = make("TextBox", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, Text = options.value or "", PlaceholderText = options.placeholder or "", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = self.library.theme.text, PlaceholderColor3 = self.library.theme.muted, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, self.page); corner(box, 7); make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box); box.FocusLost:Connect(function() if options.callback then options.callback(box.Text) end end); return add(box)
    end
    function tab:Slider(options)
        options = options or {}; local min, max = options.min or 0, options.max or 100; local value = clampNumber(options.value or min, min, max); local row = make("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 }, self.page); local label = make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = options.title or "Slider", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.library.theme.text, TextXAlignment = Enum.TextXAlignment.Left }, row); local track = make("TextButton", { Position = UDim2.new(0, 4, 0, 30), Size = UDim2.new(1, -8, 0, 5), BackgroundColor3 = self.library.theme.card, Text = "", AutoButtonColor = false }, row); corner(track, 3); local fill = make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = self.library.theme.accent, BorderSizePixel = 0 }, track); corner(fill, 3); local active = false; local function set(valueToSet) value = clampNumber(valueToSet, min, max); fill.Size = UDim2.new((value - min) / math.max(max - min, 0.0001), 0, 1, 0); label.Text = (options.title or "Slider") .. ": " .. tostring(math.floor(value * 100) / 100); if options.callback then options.callback(value) end end; local function update(input) set(min + (max - min) * math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)) end; track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = true; update(input); input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then active = false end end) end end); UserInputService.InputChanged:Connect(function(input) if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end); set(value); return add({ Get = function() return value end, Set = function(_, nextValue) set(nextValue) end })
    end
    function tab:Dropdown(options)
        options = options or {}; local values = options.options or {}; local selected = options.value or values[1]; local button = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, Text = (options.title or "Dropdown") .. ": " .. tostring(selected or "-"), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.library.theme.text, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, self.page); corner(button, 7); button.MouseButton1Click:Connect(function() if #values == 0 then return end; local index = table.find(values, selected) or 0; selected = values[index % #values + 1]; button.Text = (options.title or "Dropdown") .. ": " .. tostring(selected); if options.callback then options.callback(selected) end end); return add({ Get = function() return selected end, Set = function(_, nextValue) selected = nextValue; button.Text = (options.title or "Dropdown") .. ": " .. tostring(selected) end })
    end
    function tab:Colorpicker(options)
        options = options or {}; local color = options.value or self.library.theme.accent; local button = make("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.library.theme.card, Text = options.title or "Color", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = self.library.theme.text, AutoButtonColor = false }, self.page); corner(button, 7); local swatch = make("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(24, 18), BackgroundColor3 = color, BorderSizePixel = 0 }, button); corner(swatch, 5); local colors = options.colors or { Color3.fromRGB(255, 80, 95), Color3.fromRGB(168, 143, 242), Color3.fromRGB(70, 220, 230), Color3.fromRGB(80, 225, 160) }; button.MouseButton1Click:Connect(function() local index = table.find(colors, color) or 0; color = colors[index % #colors + 1]; swatch.BackgroundColor3 = color; if options.callback then options.callback(color) end end); return add({ Get = function() return color end, Set = function(_, nextValue) if typeof(nextValue) == "Color3" then color = nextValue; swatch.BackgroundColor3 = color; if options.callback then options.callback(color) end end end })
    end
    tab.button.MouseButton1Click:Connect(function() tab:Select() end)
    return tab
end

local env = (getgenv and getgenv()) or _G
env.kaVoXMenu = Library
return Library
