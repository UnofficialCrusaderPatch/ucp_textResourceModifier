# Text Resource Modifier

**作者**：TheRedDaemon  
**代码仓库**：[ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

此模块可以修改游戏内部文本资源返回的文本。目前，通过编辑 `cr.tex` 文件就能替换游戏的本地化文本，但这种方式无法在游戏运行时动态修改文本，也不方便只替换其中的一部分。

此模块允许按需替换特定文本，并接受通用的 UTF-8 格式。它会重定向 Stronghold Crusader 的核心文本读取函数，根据所请求文本的索引及其在该索引内的编号生成一个键。如果该键已注册自定义文本，则返回自定义文本；否则调用原函数返回原有文本。

用于注册文本的 API 接受 UTF-8 输入，并将其转换为游戏当前使用的字符编码。

此模块本身不提供可直接使用的游戏功能，而是为其他扩展提供底层支持。更多信息请参阅代码仓库中的 README 文件。
