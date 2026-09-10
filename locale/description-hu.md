# Text Resource Modifier

**Szerző**: TheRedDaemon  
**Verzió**: 0.3.1  
**Forráskód**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Ez a modul lehetővé teszi, hogy más modulok a `cr.tex` fájl módosítása nélkül
változtassák meg a játék egyes szövegeit. Az API UTF-8 szöveget fogad, és a játék
karakterkódolására alakítja. A változatlan bejegyzések eredeti szövege megmarad.

A különböző bejegyzések módosításai egymás mellett érvényesülnek. Ugyanannál a
bejegyzésnél az utolsó sikeres regisztráció érvényes. A regisztráció törlése
visszaállítja az eredeti szöveg elérését. Az eredeti UTF-8 szöveg megmarad az
újabb inicializálásokhoz. A játék nyelve és karakterkódolása független az indító
nyelvétől.

A modul műszaki felületet biztosít, közvetlenül bekapcsolható játékfunkciókat
nem tartalmaz. A használatról és a szövegek élettartamáról a forráskód README
fájlja ad tájékoztatást.
