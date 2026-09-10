local exports = {}
exports.enable = function(self, config)
  local text = modules.textResourceModifier
  local german = config.language == "de"
  local a = german and "A: Größe" or "A: New game"
  local b = german and "B: Öl & Spaß" or "B: Multiplayer"
  local index = config.conflict and 1 or 2
  assert(text:SetText(5, index, b))
  hooks.registerHookCallback("afterInit", function()
    local function check(value, label)
      assert(value, "R042: " .. label)
      log(INFO, "R042 PASS: " .. label)
    end
    check(text:GetLanguage() == (german and "German" or "American"), "native game language")
    check(text:GetText(5, index) == text:TransformText(b), "pack B encoded text")
    check(text:GetText(5, 1) == text:TransformText(config.conflict and b or a), "composition/conflict")
    check(text:GetText(600, 10) == "A: %s %d", "unaffected pack A extra ID/placeholders")
    local original = text:GetText(4, 0)
    check(text:SetText(4, 0, "temporary"), "late write")
    check(text:SetText(4, 0, nil), "clear")
    check(text:GetText(4, 0) == original, "native restoration")
    check(text:SetText(4, 0, ""), "empty write")
    check(text:GetText(4, 0) == "", "empty remains an override")
    check(text:SetText(4, 0, nil), "empty clear")
    local long = string.rep("Äöüß ", 1000) .. "%s %d"
    check(text:SetText(600, 11, long), "long UTF-8 write")
    check(text:GetText(600, 11) == text:TransformText(long), "long conversion/placeholders")
    log(INFO, "R042 NATIVE FIXTURE COMPLETE")
  end)
end
return exports
