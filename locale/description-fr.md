# Text Resource Modifier

**Auteur** : TheRedDaemon  
**Version** : 0.3.1  
**Dépôt** : [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Ce module permet à d'autres modules de modifier des textes du jeu sans modifier
le fichier `cr.tex`. L'API reçoit du texte UTF-8 et le convertit dans l'encodage
du jeu. Les entrées non modifiées conservent le texte d'origine.

Les modifications d'entrées distinctes coexistent. Pour une même entrée, la
dernière inscription réussie l'emporte. Supprimer une inscription rétablit
l'accès au texte d'origine. Le texte source UTF-8 est conservé pour les
initialisations suivantes. La langue et l'encodage du jeu sont indépendants de
la langue du lanceur.

Ce module fournit une interface technique, sans fonction de jeu à activer
directement. Consultez le fichier README du dépôt pour son utilisation et la
durée de validité des textes.
