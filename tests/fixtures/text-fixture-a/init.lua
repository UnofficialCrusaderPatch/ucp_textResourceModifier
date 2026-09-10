local exports = {}
exports.enable = function(self, config)
  local text = modules.textResourceModifier
  local value = config.language == "de" and "A: Größe" or "A: New game"
  assert(text:SetText(250, 0, value))
  assert(text:SetText(79, 239, value))
  assert(text:SetText(79, 385, value))
  assert(text:SetText(600, 10, "A: %s %d"))
end
return exports
