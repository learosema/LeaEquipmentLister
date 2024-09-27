LeaEquipmentLister = LibStub("AceAddon-3.0"):NewAddon("LeaEquipmentLister", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local isOpen = false

function LeaEquipmentLister:OnInitialize()
  LeaEquipmentLister:Print("type /eqlist for Lea's Equipment Lister")
  LeaEquipmentLister:RegisterChatCommand("eqlist", "ShowDialog")
end

function GetLinkData(link)
  local _, linkOptions = LinkUtil.ExtractLink(link)
  if linkOptions == nil then
    return nil, nil
  end
  local data = {strsplit(":", linkOptions)}
  if data == nil then 
    return nil, nil
  end
  local itemID = tonumber(data[1])
  local enchID = data[2]
  return itemID, enchID
end

function GetItemsMarkup()
  local str = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
]]
str = str .. "<title>" .. UnitFullName("player") .. " - Inventory</title>"

str = str .. [[<style>
  html{background: #111; color: #fff; font-family: sans-serif;}
  body {line-height: 1.4; margin: 1rem; }
  .grid {
  display: grid;
  grid-gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 30ch), 1fr));
  }
  th{text-align: left;}
  th,td{padding: 0.25rem;}
</style>

</head>
<body>
]]
  str = str .. "<h1>" .. UnitName("player") .. "'s Profile</h1>\n"
  local unitClass = UnitClass("player")
  str = str .. "<p>" .. UnitClass("player") .. " Level " .. UnitLevel("player") .. " on " .. GetRealmName() .. "</p>"
  str = str .. "<h2>Equipment</h2>\n"
  str = str .. "<table>\n"

  for inventorySlot = 1,34 do 
    local link = GetInventoryItemLink("player", inventorySlot)
    if link == nil then 
      -- skip
    else
      local itemID, enchantID = GetLinkData(link)
      local invType = C_Item.GetItemInventoryTypeByID(itemID)
      local slotName = C_Item.GetItemInventorySlotInfo(invType)
      local itemName = C_Item.GetItemName({equipmentSlotIndex = inventorySlot})
      local itemQuality = C_Item.GetItemQuality({equipmentSlotIndex = inventorySlot})
      str = str .. "<tr><th>" .. slotName .. "</th><td>"
      str = str .. "<a data-wowhead=\"item=" .. itemID
      if enchantID ~= nil then
        str = str .. "&amp;ench=" .. enchantID 
      end
      
      str = str .. "\" href=\"https://www.wowhead.com/classic/item=" .. itemID .. "\" data-quality=\"" .. itemQuality .. "\">"
      str = str .. itemName .. "</a>"
      str = str .. "</td></tr>\n"
    end
  end
  str = str .. "</table>\n\n"

  str = str .. "<h2>Inventory</h2>\n"
  str = str .. "<div class=\"grid\">"
  for bag = 0,4 do
    str = str .. "<div class=\"bag\"><h3>Bag " .. bag .. "</h3>\n"
    local slots = C_Container.GetContainerNumSlots(bag)
    for slot = 1,slots do
      local item = C_Container.GetContainerItemInfo(bag, slot)
      if item == nil then
        str = str .. "free slot<br>"
      else
        local itemLink = item.hyperlink
        local _, enchantID = GetLinkData(itemLink)
        str = str .. "<a data-wowhead=\"item=" .. item.itemID
        if enchantID ~= nil then
          str = str .. "&amp;ench=" .. enchantID
        end
        str = str .. "\" href=\"https://www.wowhead.com/classic/item=" .. item.itemID .. "\" data-quality=\"" .. item.quality .. "\">"
        str = str .. item.itemName .. "</a>"
        if item.stackCount > 1 then
          str = str .. " (" .. item.stackCount .. ")"
        end
        str = str .. "<br>"
      end
    end
    str = str .. "</div>\n\n"
  end
  str = str .. "</div>"
  str = str .. [[
  <script>const whTooltips = {colorLinks: true, iconizeLinks: true, renameLinks: true};</script>
  <script src="https://wow.zamimg.com/js/tooltips.js"></script>
</body>
</html>
]]
  return str
end


function LeaEquipmentLister:ShowDialog(input)
  if isOpen then
    return
  end
  isOpen = true

  local frame = AceGUI:Create("Frame")
  frame:SetTitle("Example Frame")
  frame:SetStatusText("AceGUI-3.0 Example Container Frame")
  frame:SetCallback("OnClose", function(widget) isOpen = false;AceGUI:Release(widget) end)
  frame:SetLayout("Flow")
  
  local editbox = AceGUI:Create("MultiLineEditBox")
  editbox:SetRelativeWidth(1)
  editbox:SetNumLines(20)
  editbox:SetText(GetItemsMarkup())
  frame:AddChild(editbox)
  
  local button = AceGUI:Create("Button")
  button:SetText("Refresh")
  button:SetWidth(200)
  frame:AddChild(button)
  button:SetCallback("OnClick", function(widget) editbox:SetText(GetItemsMarkup()) end)
  
end


-- print(C_Container.GetContainerItemInfo(1, 1).itemName)

-- print(C_Item:GetItemInfo(ItemLocation:CreateFromEquipmentSlot(INVSLOT_HEAD)))

-- /dump LinkUtil.ExtractLink(GetInventoryItemLink("player", 15))
-- /dump C_Item.GetItemName({equipmentSlotIndex = 15})
-- /dump C_Item.GetItemFamily(12905)
-- /dump C_Item.GetItemInventoryTypeByID(12905)
-- /dump C_Item.GetItemInfo(itemInfo)
-- /dump C_Item.GetItemInventorySlotInfo("INVTYPE_CLOAK")
-- /script a,b=LinkUtil.ExtractLink(GetInventoryItemLink("player", 15));print(strsplit(":",b))