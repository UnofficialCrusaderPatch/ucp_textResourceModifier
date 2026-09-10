# UCP Text Resource Modifier

This repository contains a module for the "Unofficial Crusader Patch Version 3" (UCP3), a modification for Stronghold Crusader.
This module exposes the possibility to modify the text returned for the internal text resource.


### Motivation and Plan

Changing localized text is already possible by editing the `cr.tex` file.
However, these changes can not happen dynamically during runtime and it makes partial modifications harder.
Additionally, the text file is not a simple text file and instead uses special encoding, possibly the windows internal 16-bit unicode. 

This module intends to provide the functionality to change specific texts while also allowing to provide the text as UTF-8, which allows a common text format.
The module uses the single text receiver function of Stronghold Crusader for this.
It is detoured to a function that uses the index and the number in this index of the requested string to generate a key.
If a string was registered for it, the custom string is returned, otherwise it falls back to the default handler.

The API to register strings expects UTF-8 and transforms it to the current encoding of the game.

### Composition and lifetime

Use the existing per-entry API from a trusted module; it is not exported to
sandboxed plugins. There is no JSON text-pack loader in this module.
Different `(offsetIndex, numInGroup)` entries coexist. The key packs the low
16 bits of each number; use distinct values within that representation. Extra
IDs are supported, but querying an unregistered extra ID delegates to the native
handler without bounds checks. IDs are not validated against the original file.

For the same entry, the last successful `SetText` call wins. Repeating a write
returns `true`. UCP enables modules in configured load order; deferred callbacks
and later calls can replace those startup writes. There are no pack priorities,
ownership tokens or retained layers. `nil`/`nullptr` removes the current global
override and restores native lookup, even if a different module wrote it. It
does not restore the previous contributor. An empty string is an override.

Version 0.3.1 retains the original UTF-8 separately from the game-encoded result,
so repeated text initialization converts the original source each time. Early
registrations wait for the native loader's codepage. If that codepage is zero,
lookups stay native and registrations wait for a later valid initialization.
`TransformText` returns the existing not-loaded error until the game codepage
is available; it does not fall back to the Windows system encoding.
An actual conversion failure logs the existing diagnostic and removes that
entry during initialization; a failed immediate replacement leaves the old
entry intact and returns `false`.

Conversion uses Windows' existing substitution behavior: malformed UTF-8 and
characters absent from the selected codepage may be replaced, not rejected.
English and German use the native game's codepage, not the launcher language.
`GetLanguage()` is the current `(6, 0)` text lookup, normally `American` or
`German`; overriding that entry also overrides the API result. Changing a
launcher locale does not select a different `cr.tex` or re-register translated
strings. C strings are NUL terminated; embedded NULs in Lua strings are truncated
by the existing C-string API. Lua also accepts numbers where `lua_isstring`
allows conversion. These compatibility behaviors are unchanged.

Copy C `GetText` results if retaining them across replacement, removal or text
initialization. Unrelated insertions do not invalidate an override's pointer.
Native pointers retain the native resource's lifetime. `TransformText`'s C
callback pointer lasts only for that callback; Lua results are copied strings.
The API is intended for the game's existing single-threaded callbacks.

Module disabling is not implemented. Registrations belong to the process;
there is no general dynamic pack-unload, automatic save restoration or live
language-switching contract. AI Swapper explicitly writes and clears its AI
entries, including nil for missing fields. Coordinate shared IDs with it.
The original `cr.tex` is never written by this module. See
[acceptance tests and native fixtures](tests/README.md) for reproducible checks
and the distinction between host tests and game acceptance.


### Usage

The module is part of the UCP3. Certain commits of the main branch of this repository are included as a git submodule.
It is therefore not needed to download additional content.

However, should issues or suggestions arise that are related to this module, feel free to add a new GitHub issue.
Support is currently only guaranteed for the western versions of Crusader 1.41 and Crusader Extreme 1.41.1-E.
Other, eastern versions of 1.41 might work.


### C++-Exports

The API is provided via exported C functions and can be accessed via the `ucp.dll`-API.  
To make using the module easier, the header [textResourceModifierHeader.h](ucp_textResourceModifier/ucp_textResourceModifier/textResourceModifierHeader.h) can be copied into your project.  
It is used by calling the function *initModuleFunctions()* in your module once after it was loaded, for example in the lua require-call. It tries to receive the provided functions and returns *true* if successful. For this to work, the *textResourceModifier* needs to be a dependency of your module.
The provided functions are the following:


* `bool SetText(int offsetIndex, int numInGroup, const char* utf8Str)`  
  Allows to register an UTF-8-string for a specific combination of `offsetIndex` and  `numInGroup`.
  If the string pointer is `null`, the registered string is removed and the native handler will once again be used.
  Returns `true` if the action was successful.
  Note, that strings registered before start-up will be transformed after the games own initialization.
  If they fail there, they are removed and an error is printed to the console.

* `const char* GetText(int offsetIndex, int numInGroup)`  
  Returns the current string for the given `offsetIndex` and `numInGroup`.
  This might either be the games own string or the current overwriting string.
  Only works after the game text is first loaded.
  Note, that there are no safety checks, since this module should also allow the register strings on new indexes.
  Use with caution, either for tests, or if you are sure this index exits.

* `const char* GetLanguage()`  
  Simply returns the language string for the loaded text source file.
  Only works after the game text is first loaded.

* `void TransformText(const char* utf8Str, TextReceiver* receiver, void* misc)`  
  Receives an UTF-8 string and tries to transform it into the games text encoding.
  Can be used for text if it should not be managed by this module.
  The `receiver` is used to return the transformed string or a dummy string on failure.
  `misc` is passed through to the receiver function.
  Only works after the game text is first loaded.

  * `void TextReceiver(const char* transformedString, void* misc)`  
    The structure of the function pointer needed by `TransformText`.
    Is called with the transformed string and the `misc` given before.


### Lua-Exports

The Lua exports are parameters and functions accessible through the module object.

* `bool SetText(int offsetIndex, int numInGroup, string utf8Str)`  
  Allows to register an UTF-8-string for a specific combination of `offsetIndex` and  `numInGroup`.
  If the string is `nil`, the registered string is removed and the native handler will once again be used.
  Returns `true` if the action was successful.
  Note, that strings registered before start-up will be transformed after the games own initialization.
  If they fail there, they are removed and an error is printed to the console.

* `string GetText(int offsetIndex, int numInGroup)`  
  Returns the current string for the given `offsetIndex` and `numInGroup`.
  This might either be the games own string or the current overwriting string.
  Only works after the game text is first loaded.
  Note, that there are no safety checks, since this module should also allow the register strings on new indexes.
  Use with caution, either for tests, or if you are sure this index exits.

* `string GetLanguage()`  
  Simply returns the language string for the loaded text source file.
  Only works after the game text is first loaded.

* `string TransformText(string utf8Str)`  
  Receives an UTF-8 string and tries to transform it into the games text encoding.
  Can be used for text if it should not be managed by this module.
  Only works after the game text is first loaded.


### Special Thanks

To all of the UCP Team, the [Ghidra project](https://github.com/NationalSecurityAgency/ghidra) and
of course to [Firefly Studios](https://fireflyworlds.com/), the creators of Stronghold Crusader.
