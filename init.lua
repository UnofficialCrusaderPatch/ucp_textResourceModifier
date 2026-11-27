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

function exports:loadTextFile(folder, indexStride)
  if type(folder) ~= "string" then
    log(ERROR, "Text Resource Modifier: loadTextFile folder must be a string.")
    return
  end
  if indexStride == nil then
    indexStride = 1
  elseif type(indexStride) ~= "number" then
    log(ERROR, "Text Resource Modifier: loadTextFile indexStride must be a number.")
    return
  elseif indexStride ~= 1 and indexStride ~= 2 then
    log(WARNING, "Text Resource Modifier: invalid indexStride; using native indexes (1).")
    indexStride = 1
  end
  if self.SetText == nil then return end
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
        log(ERROR, label .. "expected an object")
      else
        local group, index, text = record.group, record.index, record.text
        if (group ~= nil and type(group) ~= "number")
          or (index ~= nil and type(index) ~= "number")
          or (text ~= nil and type(text) ~= "string") then
          log(ERROR, label .. "expected numeric group and index and string text")
        else
          local slot = index and index / indexStride
          if group == nil or slot == nil or text == nil
            or not isTextSlot(group) or not isTextSlot(slot)
            or text:find("\0", 1, true) or not utf8.len(text) then
            log(WARNING, label .. "invalid group, index or text")
          elseif not self:SetText(math.tointeger(group), math.tointeger(slot), text) then
            log(WARNING, label .. "could not apply text override")
          end
        end
      end
    end
  end)
end

local function unavailable(binding, reason)
  log(ERROR, string.format("Text Resource Modifier is off. The %s was %s.", binding, reason))
end

local function getAddress(aob, binding)
  local address, reason = core.AOBScanUnique(aob)
  if address == nil then unavailable(binding, reason) end
  return address
end

--[[ Main Func ]]--

exports.enable = function(self, moduleConfig, globalConfig)

  --[[ get addresses ]]--

  local getTextFuncStart = getAddress(
    "8b 44 24 04 8d 50 fb",
    "native text lookup"
  )
  if getTextFuncStart == nil then return end

  local mappedTextLookup = getAddress(
    "85 d2 8b 84 81 4c 13 00 00 8d 84 08 5c 17 00 00 5e 7e ? 8a 08",
    "mapped text lookup"
  )
  if mappedTextLookup == nil then return end
  
  local callToLoadCRTexFunc = getAddress(
    "e8 ? ? ? ff e8 ? ? ? ff 6a 08",
    "CRTex loading call"
  )
  if callToLoadCRTexFunc == nil then return end
  
  local realLoadCRTexFunc = getAddress(
    "51 53 55 56 33 ed 8b f1 55 68",
    "native CRTex loader"
  )
  if realLoadCRTexFunc == nil then return end
  local read, displacement = pcall(core.readInteger, callToLoadCRTexFunc + 1)
  if not read or type(displacement) ~= "number" then
    unavailable("CRTex loading call", "unreadable")
    return
  end
  if callToLoadCRTexFunc + 5 + displacement ~= realLoadCRTexFunc then
    unavailable("CRTex loading call", "redirected to another target")
    return
  end

  --[[ load module ]]--
  
  local requireTable = require("textResourceModifier.dll") -- loads the dll in memory and runs luaopen_textResourceModifier
  
  -- no wrapping needed?
  self.SetText = function(self, ...) return requireTable.lua_SetText(...) end
  self.GetText = function(self, ...) return requireTable.lua_GetText(...) end
  self.TransformText = function(self, ...) return requireTable.lua_TransformText(...) end
  self.GetLanguage = function(self, ...) return requireTable.lua_GetLanguage(...) end
  

  --[[ modify code ]]--
  
  core.writeInteger(requireTable.address_ToNativeTextAddr, getTextFuncStart)
  core.insertCode(mappedTextLookup, 9, { core.callTo(requireTable.funcAddress_GetMappedText) }, nil, "after")
  
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
