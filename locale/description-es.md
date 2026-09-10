# Text Resource Modifier

**Autor**: TheRedDaemon  
**Versión**: 0.3.1  
**Repositorio**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Este módulo permite que otros módulos cambien textos del juego sin modificar
el archivo `cr.tex`. La API recibe texto UTF-8 y lo convierte a la codificación
del juego. Las entradas sin modificar conservan su texto original.

Los cambios en entradas distintas coexisten. Para una misma entrada, prevalece
el último registro correcto. Al eliminar un registro se restablece el acceso
al texto original. El texto fuente UTF-8 se conserva para las siguientes
inicializaciones. El idioma y la codificación del juego son independientes del
idioma del lanzador.

Este módulo ofrece una interfaz técnica, sin funciones del juego que se puedan
activar directamente. Consulte el README del repositorio para conocer su uso
y la duración de la validez de los textos.
