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

-- define a function to handle chat messages
local lastCallTime = GetTime()
local function OnChatMessage(self, event, message, sender, ...)
    if (event == "CHAT_MSG_MONSTER_WHISPER") then
	   local currentTime = GetTime()
        if (currentTime - lastCallTime) >= 2 then
            -- clear the itemLinkFrame if it has been more than 2 seconds since the last call
            for i = #itemLinkFrame.buttons, 1, -1 do
                itemLinkFrame.buttons[i]:Hide()
                itemLinkFrame.buttons[i] = nil
				title:SetText(sender.."'s gear")
            end
        end
        local link = string.match(message, "|H(.*)|h%[(.*)%]|h")
		itemLinkFrame.name = sender.."'s gear"
        if (link) then
            local _, itemName, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
			 if not texture then
                -- item is not cached, display item name from link
                itemName = string.match(message, "%[(.*)%]")
				 -- item texture is not cached, get icon from message
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
			    -- set the title to the sender's name and show the frame
                title:SetText(sender.."'s gear")
                itemLinkFrame:Show()
            end
        end
		lastCallTime = GetTime()
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