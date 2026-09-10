local exports = {}
exports.enable = function(self, config)
  local text = modules.textResourceModifier
  local german = config.language == "de"
  local a = german and "A: Größe" or "A: New game"
  local b = german and "B: Öl & Spaß" or "B: Multiplayer"
  local index = config.conflict and 0 or 1
  assert(text:SetText(250, index, b))
  assert(text:SetText(79, config.conflict and 239 or 248, b))
  assert(text:SetText(79, config.conflict and 385 or 386, b))
  if config.consumers then
    assert(text:SetText(79, 249, "temporary Snake title"))
  end
  hooks.registerHookCallback("afterInit", function()
    local function check(value, label)
      assert(value, "R042: " .. label)
      log(INFO, "R042 PASS: " .. label)
    end
    check(text:GetLanguage() == (german and "German" or "American"), "native game language")
    check(text:GetText(250, index) == text:TransformText(b), "pack B encoded text")
    check(text:GetText(250, 0) == text:TransformText(config.conflict and b or a), "composition/conflict")
    check(text:GetText(79, 239) == text:TransformText(config.conflict and b or a), "AI name composition/conflict")
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
    if config.consumers then
      -- The real consumer's configured callback runs before this callback.
      check(text:GetText(79, 248) == text:TransformText(german and "Prüfung" or "Fixture"), "native AI Swapper localized write")
      local restored = text:GetText(79, 249)
      check(restored ~= "temporary Snake title", "native AI Swapper missing-field clear")
      check(text:SetText(79, 249, nil) and text:GetText(79, 249) == restored, "consumer clear restores native lookup")
      if not config.conflict then
        check(text:SetText(79, 248, b), "restore pack B after consumer reset")
        check(text:SetText(79, 386, b), "restore pack B description")
      end
    end
    log(INFO, "R042 NATIVE FIXTURE COMPLETE")
  end)
end
return exports
