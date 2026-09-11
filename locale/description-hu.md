# Text Resource Modifier

**Szerző**: TheRedDaemon
**Forráskódtár**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Ez a modul lehetővé teszi a belső szöveges erőforrásból visszaadott szövegek módosítását. A játék lefordított szövegei már a `cr.tex` fájl szerkesztésével is lecserélhetők. Ezek a változtatások azonban nem végezhetők el dinamikusan, futás közben, és megnehezítik az egyes szövegek külön módosítását.

A modul adott szövegek cseréjét teszi lehetővé, a széles körben használt UTF-8 formátumot fogadva. Ehhez átirányítja a Stronghold Crusader központi szöveglekérő függvényét. A kért szöveg indexéből és az azon belüli sorszámából kulcsot képez. Ha ehhez egyéni szöveg van regisztrálva, azt adja vissza; egyébként az eredeti függvény szolgáltatja a szöveget.

A szövegek regisztrálására szolgáló API UTF-8 bemenetet vár, és azt a játék aktuális karakterkódolására alakítja.

A modul önmagában nem ad közvetlenül használható játékfunkciókat. Más bővítmények műszaki alapjául szolgál. További információ a forráskódtár README fájljában található.
