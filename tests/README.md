# Text resource regression tests

Build and run on Windows with MSVC and the x86 toolchain:

```powershell
cmake -S tests -B build-tests -A Win32
cmake --build build-tests --config Release
ctest --test-dir build-tests -C Release --output-on-failure
```

The host compiles the production implementation with real Windows conversion
APIs and Lua 5.4.6. Only framework logging and the native text manager's
loader/fallback are stand-ins. Each test runs in a fresh process.

- `composition`: independent entries, both conflict orders, native restoration,
  pointer lifetime, C/Lua compatibility, empty/long text and Windows substitution.
- `reload`: original UTF-8 survives repeated initialization and encoding changes;
  unavailable encoding and conversion failure retain their defined behavior.
- `encodings`: representative text for all nine GUI locales across Windows
  codepages 1252, 1250, 1251, 1254, 936 and 1256.

To reproduce the reload bug, run the same host against the pre-fix production
source: register `Größe für Öl %s`, initialize with codepage 1252, and initialize
again. The old code returns `Gr??e f?r ?l %s`; the fixed code preserves the text.
This invokes the loader explicitly. It does not establish that a normal game
session loads its text file twice, or prove native fonts, layout or multiplayer.
