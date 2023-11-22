BotInventoryDB = BotInventoryDB or {}
local botInventories = botInventories or {}

local function LoadSavedInventories()
    for botName, inventory in pairs(BotInventoryDB) do
        botInventories[botName] = inventory
		        print("Loaded inventory for bot:", botName)  -- Debugging line

    end
end

-- create a new frame for the item links
local itemLinkFrame = CreateFrame("Frame", "ItemLinkFrame", UIParent)
itemLinkFrame:SetMovable(true)
itemLinkFrame:EnableMouse(true)
itemLinkFrame:RegisterForDrag("LeftButton")
itemLinkFrame:SetScript("OnDragStart", itemLinkFrame.StartMoving)
itemLinkFrame:SetScript("OnDragStop", itemLinkFrame.StopMovingOrSizing)
itemLinkFrame:SetSize(400, 570)
itemLinkFrame:SetPoint("CENTER")
itemLinkFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4
    }
})
itemLinkFrame:SetBackdropColor(0, 0, 0, 1)


-- create a fontstring for the title
local title = itemLinkFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", itemLinkFrame, "TOP", 0, -10)
title:SetText("")

itemLinkFrame:Hide()

-- Create a frame to list bot names
local botListFrame = CreateFrame("Frame", "BotListFrame", UIParent)
botListFrame:SetMovable(true)
botListFrame:EnableMouse(true)
botListFrame:RegisterForDrag("LeftButton")
botListFrame:SetScript("OnDragStart", botListFrame.StartMoving)
botListFrame:SetScript("OnDragStop", botListFrame.StopMovingOrSizing)
botListFrame:SetSize(200, 400)
--botListFrame:SetPoint("CENTER", UIParent, "CENTER", -250, 0)
botListFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
})
botListFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
botListFrame:Hide()

-- Table to store individual frames for each bot
local botFrames = {}

-- Function to display or update saved inventory for a bot
local function ShowSavedInventory(botName)
    -- Create a new frame if it doesn't exist
    if not botFrames[botName] then
        botFrames[botName] = CreateFrame("Frame", botName.."ItemLinkFrame", UIParent)
        local frame = botFrames[botName]
		-- Refresh Button
local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
refreshButton:SetSize(125, 22)
refreshButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
refreshButton:SetText("Query and Refresh")

refreshButton:SetScript("OnClick", function()
    -- First execution
    for _, itemLink in ipairs(botInventories[botName]) do
        if itemLink then
            GameTooltip:SetHyperlink(itemLink)
        end
    end
    ShowSavedInventory(botName)

    -- Second execution (consider adding a delay if necessary)
    for _, itemLink in ipairs(botInventories[botName]) do
        if itemLink then
            GameTooltip:SetHyperlink(itemLink)
        end
    end
    ShowSavedInventory(botName)
end)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetSize(400, 570)
        frame:SetPoint("CENTER")
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        frame:SetBackdropColor(0, 0, 0, 1)

        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", frame, "TOP", 0, -10)
        title:SetText(botName.."'s gear")

        frame.buttons = {}

        local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
        closeButton:SetScript("OnClick", function()
            frame:Hide()
            for i = #frame.buttons, 1, -1 do
                frame.buttons[i]:Hide()
                frame.buttons[i]:SetParent(nil)
                table.remove(frame.buttons, i)
            end
        end)

        frame:Hide()
    end

    local frame = botFrames[botName]

    -- Clear existing buttons
    for i = #frame.buttons, 1, -1 do
        frame.buttons[i]:Hide()
        frame.buttons[i] = nil
    end

    -- Populate the frame with bot inventory
    for i, link in ipairs(botInventories[botName]) do
        local _, itemName, _, _, _, _, _, _, _, texture = GetItemInfo(link)
        if not texture then
            itemName = string.match(link, "%[(.*)%]")
            texture = string.match(link, "|T(.-):")
        end

        local buttonName = "ItemButton_"..(#frame.buttons + 1)
        local itemButton = CreateFrame("Button", buttonName, frame, "ItemButtonTemplate")
        itemButton:SetSize(24, 24)
        itemButton:SetNormalTexture(texture)

        local normalTexture = itemButton:GetNormalTexture()
        if normalTexture then
            local textureWidth, textureHeight = normalTexture:GetSize()
            local ratio = itemButton:GetWidth() / textureWidth
            normalTexture:SetSize(itemButton:GetWidth(), textureHeight * ratio)
        end

        itemButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(itemButton, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
        itemButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        table.insert(frame.buttons, itemButton)

        if #frame.buttons == 1 then
            itemButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
        else
            itemButton:SetPoint("TOPLEFT", frame.buttons[#frame.buttons - 1], "BOTTOMLEFT", 0, -10)
        end

        local itemNameText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemNameText:SetPoint("LEFT", itemButton, "RIGHT", 10, 0)
        itemNameText:SetText(itemName)
    end

    frame:Show()
end

local function UpdateBotList()
    print("Updating bot list UI...")  -- Debugging line

    -- Clear existing buttons
    for _, button in pairs(botListFrame.buttons) do
        button:Hide()
    end
    wipe(botListFrame.buttons)

    -- Create a sorted list of bot names
    local sortedBotNames = {}
    for botName, _ in pairs(botInventories) do
        table.insert(sortedBotNames, botName)
    end
    table.sort(sortedBotNames)

    -- Create a button for each sorted bot name and calculate the new height
    local yOffset = -30
    local buttonHeight = 20
    local spacing = 5
    local numBots = 0

    for _, botName in ipairs(sortedBotNames) do
        local botButton = CreateFrame("Button", nil, botListFrame, "GameMenuButtonTemplate")
        botButton:SetSize(180, buttonHeight)
        botButton:SetPoint("TOP", botListFrame, "TOP", 0, yOffset)
        botButton:SetText(botName)
        botButton:SetNormalFontObject("GameFontNormal")
        botButton:SetHighlightFontObject("GameFontHighlight")
        botButton:SetScript("OnClick", function()
            ShowSavedInventory(botName)
        end)
        table.insert(botListFrame.buttons, botButton)
        yOffset = yOffset - (buttonHeight + spacing)
        numBots = numBots + 1
    end

    -- Calculate and set the new height of the frame
    local newHeight = (buttonHeight + spacing) * numBots + 70
    botListFrame:SetHeight(math.max(100, newHeight)) -- Ensure a minimum height
end

-- Add the "Clear All Bots" button here
local clearAllButton = CreateFrame("Button", "ClearAllBotsButton", botListFrame, "UIPanelButtonTemplate")
clearAllButton:SetSize(160, 30)
clearAllButton:SetPoint("BOTTOM", botListFrame, "BOTTOM", 0, 10)
clearAllButton:SetText("Clear All Bots")
clearAllButton:SetScript("OnClick", function()
    wipe(BotInventoryDB)
    wipe(botInventories)
    UpdateBotList()
    print("All bot inventories cleared.")
end)

botListFrame.buttons = {}

-- define a function to handle chat messages
local lastCallTime = GetTime()
local function OnChatMessage(self, event, message, sender, ...)
    if (event == "CHAT_MSG_MONSTER_WHISPER") then
        local currentTime = GetTime()
        local isNewBot = false

        if (currentTime - lastCallTime) >= 2 then
            -- Check if the bot inventory is new
            if not botInventories[sender] then
                isNewBot = true
				botInventories[sender] = {} -- Initialize inventory for the new bot
            end

            -- Clear the itemLinkFrame if it has been more than 2 seconds since the last call
            for i = #itemLinkFrame.buttons, 1, -1 do
                itemLinkFrame.buttons[i]:Hide()
                itemLinkFrame.buttons[i] = nil
            end
            title:SetText(sender.."'s gear")

            -- Initialize inventory for the sender
            botInventories[sender] = {}
        end

        local link = string.match(message, "|H(.*)|h%[(.*)%]|h")
        if (link) then
            -- Save inventory information
            table.insert(botInventories[sender], link)
			BotInventoryDB[sender] = botInventories[sender]
            local _, itemName, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
            if not texture then
                -- Item is not cached, display item name from link
                itemName = string.match(message, "%[(.*)%]")
                -- Extract the color code from the message and apply it to the item text
                local colorCode = string.match(message, "|c%x%x%x%x%x%x%x%x")
                if colorCode then
                    itemName = colorCode .. "[" .. itemName .. "]" .. "|r"
                end
                -- Item texture is not cached, get icon from message
                texture = string.match(message, "|T(.-):")
            end

            local buttonName = "ItemButton_"..(#itemLinkFrame.buttons + 1)
            local itemButton = CreateFrame("Button", buttonName, itemLinkFrame, "ItemButtonTemplate")
            itemButton:SetSize(24, 24)
            itemButton:SetNormalTexture(texture)
            local normalTexture = itemButton:GetNormalTexture()
            if normalTexture then
                local textureWidth, textureHeight = normalTexture:GetSize()
                local ratio = itemButton:GetWidth() / textureWidth
                normalTexture:SetSize(itemButton:GetWidth(), textureHeight * ratio)
            end

            itemButton:SetScript("OnEnter", function()
                GameTooltip:SetOwner(itemButton, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
            end)

            itemButton:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            table.insert(itemLinkFrame.buttons, itemButton)

            if #itemLinkFrame.buttons == 1 then
                itemButton:SetPoint("TOPLEFT", itemLinkFrame, "TOPLEFT", 20, -20)
            else
                itemButton:SetPoint("TOPLEFT", itemLinkFrame.buttons[#itemLinkFrame.buttons-1], "BOTTOMLEFT", 0, -10)
            end

            local itemNameText = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            itemNameText:SetPoint("LEFT", itemButton, "RIGHT", 10, 0)
            itemNameText:SetText(itemName)

            if not itemLinkFrame:IsShown() then
                title:SetText(sender.."'s gear")
                itemLinkFrame:Show()
            end
        end

        lastCallTime = GetTime()

        -- Update the bot list if it's open and a new bot was added
        if botListFrame:IsShown() and isNewBot then
            UpdateBotList()
        end
    end
end

-- register the OnChatMessage function for the CHAT_MSG_MONSTER_WHISPER event
itemLinkFrame:SetScript("OnEvent", OnChatMessage)
itemLinkFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")

-- initialize the buttons table
itemLinkFrame.buttons = {}

-- create a button to close the itemLinkFrame window
local closeButton = CreateFrame("Button", nil, itemLinkFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", itemLinkFrame, "TOPRIGHT", -6, -6)
closeButton:SetScript("OnClick", function()
    itemLinkFrame:Hide()
    for i = #itemLinkFrame.buttons, 1, -1 do
        itemLinkFrame.buttons[i]:Hide()
        itemLinkFrame.buttons[i]:SetParent(nil)
        table.remove(itemLinkFrame.buttons, i)
    end
end)

-- Registering the slash command
SLASH_SHOWINVENTORY1 = '/showinventory'

-- Slash command handler
SlashCmdList["SHOWINVENTORY"] = function(msg)
    local botName = msg:trim()  -- Extract the bot name from the command argument
    if botName == "" then
        botName = "McKenzie"  -- Default to "McKenzie" if no name is provided
    end
    ShowSavedInventory(botName)
end


local botListTitle = botListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botListTitle:SetPoint("TOP", botListFrame, "TOP", 0, -10)
botListTitle:SetText("Bot Inventory List")

-- Slash command to toggle bot list frame
SLASH_TOGGLEBOTLIST1 = '/togglebotlist'
SlashCmdList["TOGGLEBOTLIST"] = function(msg)
    if botListFrame:IsShown() then
        botListFrame:Hide()
    else
        UpdateBotList()
        botListFrame:Show()
    end
end

local toggleButton = CreateFrame("Button", "BotListToggleButton", UIParent, "UIPanelButtonTemplate")
toggleButton:SetSize(120, 30)
toggleButton:SetPoint("CENTER", UIParent, "CENTER", 0, -300) -- Adjust this position as needed
toggleButton:SetText("Bot Inventory List")
toggleButton:SetMovable(true)
toggleButton:EnableMouse(true)
toggleButton:RegisterForDrag("LeftButton")

toggleButton:SetScript("OnDragStart", toggleButton.StartMoving)
toggleButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Reposition botListFrame relative to the new position of toggleButton
    if botListFrame:IsShown() then
        botListFrame:ClearAllPoints()
        botListFrame:SetPoint("TOP", self, "BOTTOM", 0, -10)
    end
end)

-- Toggle the visibility of the botListFrame
toggleButton:SetScript("OnClick", function()
    if botListFrame:IsShown() then
        botListFrame:Hide()
    else
        UpdateBotList()
        botListFrame:Show()
    end
end)

-- Position the botListFrame to drop down from the toggleButton
botListFrame:ClearAllPoints()
botListFrame:SetPoint("TOP", toggleButton, "BOTTOM", 0, -10)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "NPCBotInventory" then 
        LoadSavedInventories()
        UpdateBotList()
        botListFrame:Show()
    end
end)
