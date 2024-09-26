LeaEquipmentLister = LibStub("AceAddon-3.0"):NewAddon("LeaEquipmentLister", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local isOpen = false

function LeaEquipmentLister:OnInitialize()
  LeaEquipmentLister:Print("type /eqlist for Lea's Equipment Lister")
  LeaEquipmentLister:RegisterChatCommand("eqlist", "ShowDialog")
end

function GetItemsMarkup()
  local str = [[
<!DOCTYPE html>
<html>
<head>
]]
str = str .. "<title>" .. UnitFullName("player") .. " - Inventory</title>"

str = str .. [[<style>
  html{color-scheme: dark light; font-family: sans-serif;}
  body {line-height: 1.4; margin: 1rem; }
  .grid {
  display: grid;
  grid-gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 30ch), 1fr));
  }
</style>

</head>
<body>
]]
  str = str .. "<h1>Inventory of " .. UnitFullName("player") .. "</h1>\n"
  str = str .. "<div class=\"grid\">"
  for bag = 0,4 do
    str = str .. "<div class=\"bag\"><h2>Bag " .. bag .. "</h2>\n"
    local slots = C_Container.GetContainerNumSlots(bag)
    for slot = 1,slots do
      local item = C_Container.GetContainerItemInfo(bag, slot)

      if item == nil then
        str = str .. "free slot\n"
      else
        str = str .. "<a data-wowhead=\"item=" .. item.itemID .. "\" href=\"https://www.wowhead.com/classic/item=" .. item.itemID .. "\" data-quality=\"" .. item.quality .. "\">" .. item.itemName .. "</a><br>"
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
  local muh = C_Container.GetContainerItemInfo(0, 1)
  print (muh.itemName)
  button:SetCallback("OnClick", function(widget) editbox:SetText(GetItemsMarkup()) end)
  
end


-- print(C_Container.GetContainerItemInfo(1, 1).itemName)