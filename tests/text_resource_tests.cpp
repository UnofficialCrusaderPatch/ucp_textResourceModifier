#include "pch.h"
#include "textResourceModifierInternal.h"
#include <cstring>
#include <iostream>
#include <stdexcept>

namespace {
int warnings = 0;
const char* nativeText = "Native source";
int codepage = 1252;
int checks = 0;
void check(bool value, const char* label) {
  ++checks;
  if (!value) throw std::runtime_error(label);
}
// Stand-in for the game object: the interceptor reads the fifth DWORD.
struct NativeManager {
  DWORD fields[5]{};
  void load() { fields[4] = codepage; }
};
// getNativeText already reproduced the original seven-byte prologue.
__declspec(naked) const char* nativeFallback() {
  __asm { mov eax, nativeText
          ret 8 }
}
void initialize(NativeManager& manager) {
  auto loader = &NativeManager::load;
  static_assert(sizeof(loader) == sizeof(TextHandler::realLoadCRTFunc));
  memcpy(&TextHandler::realLoadCRTFunc, &loader, sizeof(loader));
  TextHandler::toNativeTextAddr = reinterpret_cast<DWORD>(&nativeFallback);
  reinterpret_cast<TextHandler*>(&manager)->interceptedLoadCRTex();
}
void equals(int group, int index, const char* expected, const char* label) {
  check(strcmp(GetText(group, index), expected) == 0, label);
}
void __stdcall copyTransformed(const char* text, void* output) {
  *static_cast<std::string*>(output) = text;
}
void composition() {
  check(SetText(79, 385, u8"Pack A: Größe %s"), "early A registration");
  check(SetText(79, 386, u8"Pack B: château %d"), "early B registration");
  check(SetText(80, 385, "separate group"), "same index in another group");
  check(SetText(600, 700, "extra ID"), "extra IDs remain supported");
  check(strcmp(GetLanguage(), "ERROR: NO TEXT RESOURCE YET LOADED.") == 0, "language unavailable before initialization");
  NativeManager manager;
  initialize(manager);
  equals(79, 385, "Pack A: Gr\xf6\xdf" "e %s", "A survives composition");
  equals(79, 386, "Pack B: ch\xe2teau %d", "B survives composition");
  equals(80, 385, "separate group", "group/index identity");
  equals(600, 700, "extra ID", "extra ID lookup");
  check(strcmp(GetLanguage(), nativeText) == 0, "language reads native entry");
  check(SetText(6, 0, "language override"), "language entry can be overridden");
  check(strcmp(GetLanguage(), "language override") == 0, "existing language lookup semantics");
  check(SetText(6, 0, nullptr), "restore native language entry");
  std::string transformed;
  TransformText(u8"Größe", copyTransformed, &transformed);
  check(transformed == "Gr\xf6\xdf" "e", "C TransformText callback copy");
  const char* retained = GetText(79, 385);
  for (int i = 0; i < 2000; ++i) SetText(601, i, "rehash");
  check(retained == GetText(79, 385), "unrelated insertions preserve pointer");
  check(SetText(79, 385, u8"Pack B: für Öl"), "late conflicting write succeeds");
  equals(79, 385, "Pack B: f\xfcr \xd6l", "last successful write wins");
  check(SetText(79, 385, u8"Pack A: Größe %s"), "reverse registration order");
  equals(79, 385, "Pack A: Gr\xf6\xdf" "e %s", "A wins when called after B");
  check(SetText(79, 385, "repeat") && SetText(79, 385, "repeat"), "repeat succeeds");
  check(SetText(79, 385, nullptr), "clear succeeds");
  equals(79, 385, nativeText, "clear restores native, not displaced pack");
  check(SetText(79, 385, nullptr), "absent clear succeeds");
  equals(4, 0, nativeText, "untouched native fallback");
  check(SetText(79, 385, ""), "empty override");
  equals(79, 385, "", "empty is not removal");
  std::string longText(100000, 'x');
  longText += u8" Äöüß %s %d";
  check(SetText(79, 385, longText.c_str()), "long override");
  check(strlen(GetText(79, 385)) == 100011, "long text and placeholders");
  check(SetText(79, 385, "\xc3("), "Windows replacement behavior for invalid UTF-8");
  equals(79, 385, "?(", "malformed UTF-8 keeps Windows substitution contract");
  check(SetText(79, 385, u8"🙂"), "unrepresentable text uses Windows substitution");
  check(strchr(GetText(79, 385), '?') != nullptr, "substitution returned");

  lua_State* L = luaL_newstate();
  luaL_openlibs(L);
  lua_pushcfunction(L, lua_SetText); lua_setglobal(L, "SetText");
  lua_pushcfunction(L, lua_GetText); lua_setglobal(L, "GetText");
  const char* script =
    "assert(not pcall(SetText, 1, 2))\n"
    "assert(not pcall(SetText, {}, 2, 'x'))\n"
    "assert(not pcall(SetText, 1, 2, {}))\n"
    "assert(not pcall(GetText, 1.5, 2))\n"
    "assert(SetText(600, 702, 123))\n" // lua_isstring deliberately accepts numbers
    "assert(GetText(600, 702) == '123')\n"
    "assert(SetText(600, 702, nil))\n";
  int result = luaL_dostring(L, script);
  if (result) std::cerr << lua_tostring(L, -1) << '\n';
  check(result == LUA_OK, "Lua input compatibility");
  lua_close(L);
}
void reload() {
  NativeManager manager;
  check(SetText(79, 385, u8"Größe für Öl %s"), "early registration");
  initialize(manager);
  equals(79, 385, "Gr\xf6\xdf" "e f\xfcr \xd6l %s", "first initialization");
  for (int i = 0; i < 10; ++i) {
    initialize(manager);
    equals(79, 385, "Gr\xf6\xdf" "e f\xfcr \xd6l %s", "repeat initialization preserves original UTF-8");
  }
  check(SetText(79, 386, u8"français"), "late registration");
  initialize(manager);
  equals(79, 386, "fran\xe7" "ais", "late registration survives reload");
  codepage = 1250;
  check(SetText(79, 387, u8"Łódź"), "register for another encoding");
  initialize(manager);
  equals(79, 387, "\xa3\xf3\x64\x9f", "new codepage uses retained UTF-8");
  codepage = 0;
  initialize(manager);
  equals(79, 385, nativeText, "unknown codepage falls back to native");
  check(TextHandler::TransformText(u8"Größe") == "ERROR: NO TEXT RESOURCE YET LOADED.", "unknown game codepage must not use system encoding");
  codepage = 1252;
  initialize(manager);
  equals(79, 385, "Gr\xf6\xdf" "e f\xfcr \xd6l %s", "recover from unknown codepage");
  codepage = 99999;
  const int warningsBeforeFailure = warnings;
  initialize(manager);
  check(warnings > warningsBeforeFailure, "conversion failure logged");
  equals(79, 385, nativeText, "failed initialization removes override");
  check(!SetText(79, 385, "bad codepage"), "failed registration returns false");
}
void encodings() {
  const struct { int page; const char* utf8; const char* bytes; } samples[] = {
    {1252, "English %s %d", "English %s %d"},
    {1252, u8"Größe", "\x47\x72\xf6\xdf\x65"},
    {1252, u8"français", "\x66\x72\x61\x6e\xe7\x61\x69\x73"},
    {1252, u8"español", "\x65\x73\x70\x61\xf1\x6f\x6c"},
    {1250, u8"árvíztűrő", "\xe1\x72\x76\xed\x7a\x74\xfb\x72\xf5"},
    {1251, u8"Русский", "\xd0\xf3\xf1\xf1\xea\xe8\xe9"},
    {1254, u8"Türkçe ıİşğ", "\x54\xfc\x72\x6b\xe7\x65\x20\xfd\xdd\xfe\xf0"},
    {936, u8"中文", "\xd6\xd0\xce\xc4"},
    {1256, u8"فارسي", "\xdd\xc7\xd1\xd3\xed"},
  };
  NativeManager manager;
  for (const auto& sample : samples) {
    codepage = sample.page;
    initialize(manager);
    check(SetText(600, 20, sample.utf8), "locale registration");
    equals(600, 20, sample.bytes, "locale encoded bytes");
    initialize(manager);
    equals(600, 20, sample.bytes, "locale reload bytes");
  }
}
}
void ucp_log(ucp_NamedVerbosity, const char*) { ++warnings; }
int main(int argc, char** argv) {
  try {
    if (argc == 2 && strcmp(argv[1], "reload") == 0) reload();
    else if (argc == 2 && strcmp(argv[1], "encodings") == 0) encodings();
    else composition();
    std::cout << "PASS " << checks << " checks\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "FAIL after " << checks << " checks: " << error.what() << '\n';
    return 1;
  }
}
