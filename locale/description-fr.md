# Text Resource Modifier

**Auteur** : TheRedDaemon  
**Dépôt** : [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Ce module permet de modifier les textes renvoyés par les ressources textuelles internes. Il est déjà possible de remplacer les textes traduits du jeu en modifiant le fichier `cr.tex`. Toutefois, ces changements ne peuvent pas être effectués dynamiquement pendant l’exécution et rendent les modifications partielles plus difficiles.

Le module permet de remplacer des textes précis en les fournissant au format courant UTF-8. Il détourne pour cela la fonction centrale de récupération des textes de Stronghold Crusader. L’index et le numéro du texte demandé dans cet index servent à former une clé. Si un texte personnalisé est enregistré pour cette clé, il est renvoyé ; sinon, la fonction d’origine fournit le texte habituel.

L’API d’enregistrement attend du texte UTF-8 et le convertit vers l’encodage actuellement utilisé par le jeu.

Ce module ne propose pas directement de fonctionnalités de jeu. Il sert de base technique à d’autres extensions. Consultez le fichier README du dépôt pour en savoir plus.
