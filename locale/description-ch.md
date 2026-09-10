# Text Resource Modifier

**作者**：TheRedDaemon  
**版本**：0.3.1  
**代码仓库**：[ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

此模块允许其他模块修改游戏中的单条文本，无需修改 `cr.tex` 文件。
API 接收 UTF-8 文本，并将其转换为游戏使用的字符编码。
未修改的条目仍使用游戏原始文本。

不同条目的修改可以同时生效。同一条目以最后一次成功注册的文本为准。
移除注册后，将恢复对游戏原始文本的读取。
模块保留原始 UTF-8 文本，供再次初始化时转换。
游戏的语言和字符编码与启动器的语言相互独立。

此模块提供技术接口，本身不包含可直接启用的游戏功能。
使用方法和文本有效期的说明请参阅代码仓库中的 README 文件。
