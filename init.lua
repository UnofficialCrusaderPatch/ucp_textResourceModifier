local exports = {}

local jsonNull = {}
-- Preserve null records and fields for validation.
local function preserveNull(value, key, entry)
  rawset(value, key, entry == nil and jsonNull or entry)
end

local array = { __newindex = preserveNull }
local object = { __newindex = preserveNull }
local decoder = json:new({
  strictTypes = true,
  newArray = function(self, value) return setmetatable(value, array) end,
  newObject = function(self, value) return setmetatable(value, object) end,
})

local function isTextSlot(value)
  return value >= 0 and value <= 0xffff and value % 1 == 0
end

function exports:loadTextFile(folder)
  hooks.registerHookCallback("afterInit", function()
    local language = data.version.getGameLanguage()
    if not language then return end
    if language == "american" then language = "english" end

    local path = folder .. "/" .. language .. ".json"
    local opened, file = pcall(io.open, path, "rb")
    if not opened then
      log(WARNING, path .. ": could not open text overrides")
      return
    end
    if not file then return end
    local contents = file:read("a")
    file:close()

    local ok, records = pcall(decoder.decode, decoder, contents)
    if not ok or getmetatable(records) ~= array then
      log(WARNING, path .. ": expected a JSON array of text overrides")
      return
    end

    for i, record in ipairs(records) do
      local label = string.format("%s: record %d: ", path, i)
      if getmetatable(record) ~= object then
        log(WARNING, label .. "expected an object")
      else
        local group, index, text = record.group, record.index, record.text
        if (group ~= nil and type(group) ~= "number")
          or (index ~= nil and type(index) ~= "number")
          or (text ~= nil and type(text) ~= "string") then
          log(ERROR, label .. "expected numeric group and index and string text")
        elseif group == nil or index == nil or text == nil
          or not isTextSlot(group) or not isTextSlot(index)
          or text:find("\0", 1, true) or not utf8.len(text) then
          log(WARNING, label .. "invalid group, index or text")
        elseif not self:SetText(math.tointeger(group), math.tointeger(index), text) then
          log(WARNING, label .. "could not apply text override")
        end
      end
    end
  end)
end

local function getAddress(aob, errorMsg, modifierFunc)
  local address = core.AOBScan(aob, 0x400000)
  if address == nil then
    log(ERROR, errorMsg)
    error("'textResourceModifier' can not be initialized.")
  end
  if modifierFunc == nil then
    return address;
  end
  return modifierFunc(address)
end

--[[ Main Func ]]--

exports.enable = function(self, moduleConfig, globalConfig)

  --[[ get addresses ]]--

  local getTextFuncStart = getAddress(
    "8b 44 24 04 8d 50 fb",
    "'textResourceModifier' was unable to find the start of the address that selects the right text strings."
  )
  local backJmpAddress = getTextFuncStart + 7 -- address to jmp back to
  
  local callToLoadCRTexFunc = getAddress(
    "e8 ? ? ? ff e8 ? ? ? ff 6a 08",
    "'textResourceModifier' was unable to find the call to load the CRTex file."
  )
  
  local realLoadCRTexFunc = getAddress(
    "51 53 55 56 33 ed 8b f1 55 68",
    "'textResourceModifier' was unable to find the CRTex load func."
  )

  --[[ load module ]]--
  
  local requireTable = require("textResourceModifier.dll") -- loads the dll in memory and runs luaopen_textResourceModifier
  
  -- no wrapping needed?
  self.SetText = function(self, ...) return requireTable.lua_SetText(...) end
  self.GetText = function(self, ...) return requireTable.lua_GetText(...) end
  self.TransformText = function(self, ...) return requireTable.lua_TransformText(...) end
  self.GetLanguage = function(self, ...) return requireTable.lua_GetLanguage(...) end
  

  --[[ modify code ]]--
  
  -- write the jmp to the own function
  core.writeCode(
    getTextFuncStart,
    {0xE9, requireTable.funcAddress_GetMapText - getTextFuncStart - 5}  -- jmp to func
  )
  
  -- give return jump address to the dll
  core.writeCode(
    requireTable.address_ToNativeTextAddr,
    {backJmpAddress}
  )
  
  -- gives the address of crusaders CRTex load func
  core.writeCode(
    requireTable.address_RealLoadCRTFuncAddr,
    {realLoadCRTexFunc}
  )
  
  -- writes the call to the modified loadCRT in the mainLoop
  core.writeCode(
    callToLoadCRTexFunc,
    {0xE8, requireTable.funcAddress_InterceptedLoadCRTex - callToLoadCRTexFunc - 5}
  )
  
  
  --[[ use config ]]--
  
  -- none at the moment


  --[[ test code ]]--
  
  -- self.SetText(4, 0, "Güterchen")

end

exports.disable = function(self, moduleConfig, globalConfig) error("not implemented") end

return exports, { public = { "loadTextFile" } }
