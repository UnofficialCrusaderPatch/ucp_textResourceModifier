# Text Resource Modifier

**Yazar**: TheRedDaemon  
**Depo**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Bu modül, dahili metin kaynağından döndürülen metinleri değiştirmeyi sağlar. Oyunun çevrilmiş metinleri `cr.tex` dosyası düzenlenerek zaten değiştirilebilir. Ancak bu değişiklikler oyun çalışırken dinamik olarak yapılamaz ve metinlerin yalnızca bir bölümünü değiştirmeyi zorlaştırır.

Modül, yaygın UTF-8 biçimindeki metinleri kabul ederek belirli metinlerin değiştirilmesini sağlar. Bunun için Stronghold Crusader’ın merkezi metin alma işlevini yönlendirir. İstenen metnin dizini ve bu dizindeki sıra numarası kullanılarak bir anahtar oluşturulur. Bu anahtar için özel bir metin kaydedilmişse o metin döndürülür; aksi hâlde özgün işlev kullanılır.

Metin kaydetme API’si UTF-8 girdisi bekler ve metni oyunun o anda kullandığı karakter kodlamasına dönüştürür.

Bu modül tek başına doğrudan kullanılabilecek oyun özellikleri sunmaz. Diğer uzantılar için teknik bir temel sağlar. Daha fazla bilgi için depodaki README dosyasına bakın.
