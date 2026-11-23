# Text Resource Modifier

**Autor**: TheRedDaemon  
**Repository**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Dieses Modul ermöglicht es, die Texte der internen Textressourcen zu ändern. Übersetzte Spieltexte lassen sich bereits durch Bearbeiten der Datei `cr.tex` ersetzen. Solche Änderungen sind jedoch nicht dynamisch zur Laufzeit möglich und erschweren den Austausch einzelner Texte.

Das Modul ermöglicht gezielte Textänderungen und nimmt Texte im verbreiteten Format UTF-8 entgegen. Dafür leitet es die zentrale Textabfragefunktion von Stronghold Crusader um. Aus dem Index und der Nummer des angeforderten Textes innerhalb dieses Index wird ein Schlüssel gebildet. Ist dafür ein eigener Text registriert, wird dieser zurückgegeben; andernfalls wird der ursprüngliche Text verwendet.

Die API zur Registrierung von Texten erwartet UTF-8 und wandelt es in die aktuelle Zeichenkodierung des Spiels um.

Dieses Modul stellt selbst keine direkt nutzbaren Spielfunktionen bereit. Es dient als technische Grundlage für andere Erweiterungen. Weitere Informationen stehen in der README im Repository.
