# Text Resource Modifier

**Autor**: TheRedDaemon  
**Repositorio**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Este módulo permite modificar los textos devueltos por el recurso interno de texto. Ya es posible sustituir los textos traducidos del juego editando el archivo `cr.tex`. Sin embargo, esos cambios no pueden realizarse dinámicamente durante la ejecución y dificultan las modificaciones parciales.

El módulo permite sustituir textos concretos y proporcionarlos en el formato habitual UTF-8. Para ello, redirige la función central de obtención de texto de Stronghold Crusader. El índice y el número del texto solicitado dentro de ese índice se utilizan para generar una clave. Si se ha registrado un texto personalizado para esa clave, se devuelve ese texto; de lo contrario, se utiliza la función original.

La API para registrar textos espera entradas UTF-8 y las convierte a la codificación que utiliza el juego en ese momento.

Este módulo no ofrece funciones de juego directamente utilizables por sí solo. Sirve como base técnica para otras extensiones. Consulta el archivo README del repositorio para obtener más información.
