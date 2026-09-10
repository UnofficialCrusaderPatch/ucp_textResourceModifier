# Text Resource Modifier

**Autor**: TheRedDaemon  
**Version**: 0.3.1  
**Repository**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Dieses Modul ermöglicht es anderen Modulen, einzelne Texte des Spiels zu ändern,
ohne die Datei `cr.tex` zu bearbeiten. Die API nimmt UTF-8-Text entgegen und
wandelt ihn in die Zeichenkodierung des Spiels um. Für unveränderte Einträge
wird weiterhin der ursprüngliche Text des Spiels verwendet.

Änderungen an verschiedenen Texteinträgen bleiben nebeneinander erhalten. Wird
derselbe Eintrag mehrfach geändert, gilt die letzte erfolgreiche Registrierung.
Das Entfernen einer Registrierung stellt den ursprünglichen Textzugriff des
Spiels wieder her. Bei erneuter Textinitialisierung wird der aufbewahrte
UTF-8-Quelltext umgewandelt. Sprache und Zeichenkodierung des Spiels sind von der
Sprache des Launchers unabhängig.

Das Modul stellt eine technische Schnittstelle bereit und bietet selbst keine
direkt aktivierbaren Spielfunktionen. Weitere Informationen zur Verwendung und
Lebensdauer der Texte stehen in der README des Repositorys.
