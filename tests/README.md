# Text resource acceptance

Build the actual production implementation in an x86 Windows test host:

```powershell
cmake -S tests -B build-tests -A Win32
cmake --build build-tests --config Release
ctest --test-dir build-tests -C Release --output-on-failure
```

The host uses real Windows conversion APIs and Lua 5.4.6. Only framework logging
and the native text-manager loader/fallback are stand-ins. These tests do not
establish in-game display, native reload reachability, save, MP or Extreme
compatibility. Each test is a fresh process.

`composition` covers disjoint and colliding entries, separate group identity,
extra IDs, registration results, native restoration, empty/long/invalid text,
Windows substitution and Lua argument compatibility. `reload` exercises the
production interceptor repeatedly, including late registrations, different
codepages, unavailable encoding and conversion failure. It is a regression for
re-converting already encoded text, not a claim of supported live language switching.

## Native fixture packs

Use an isolated licensed game installation and the developer framework package.
Copy each directory in `fixtures` to `ucp/modules/<name>-1.0.0`. Enable
textResourceModifier, text-fixture-a, text-fixture-b in that order in the existing
`config-full.load-order`. Give both fixture modules `config: {language: en}` or
`config: {language: de}` matching the original installed game text source.
For collisions add `conflict: true` to B's config. Run both orders to confirm
that call order determines precedence; B's assertions assume A then B.

The packs register before native initialization; B checks encoded values,
native language, restoration, extra IDs, empty/long text and placeholders in
`afterInit`. Check logs for every PASS and `R042 NATIVE FIXTURE COMPLETE`;
callback errors are logged by the framework and do not terminate the game.
Inspect the single/multiplayer menu labels visually, including German accents.
The fixtures intentionally add test text only; do not ship them in the module.

Use separately obtained, unmodified English/German `cr.tex` files. The fixtures
never edit that file. Record executable, text file and module hashes, source
head, language, pack order, screenshots, display size/scaling and enabled Legacy
options. Repeat a fresh start, new match, save/load and restart on SHC and
Extreme. Existing AI pack integration requires separate tests of its reset and
language fallback paths; these minimal fixtures alone do not prove it.

## Locale coverage

Descriptions cover all nine GUI locales: `ch`, `de`, `en`, `es`, `fa`, `fr`,
`hu`, `ru`, `tr`, including the catalog's `ch` identifier. The `encodings` host
test checks representative CP1252, CP1250, CP1251, CP1254, CP936 and CP1256 bytes
across repeated initialization. This is conversion coverage, not proof that
every native executable or font supports those languages. Game-language
selection remains separate from GUI description selection. Human translation
review and native font/layout checks outside English/German remain outstanding.
No English fallback is described as a translation.
