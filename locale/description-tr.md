# Text Resource Modifier

**Geliştirici**: TheRedDaemon  
**Sürüm**: 0.3.1  
**Depo**: [ucp_textResourceModifier](https://github.com/UnofficialCrusaderPatch/ucp_textResourceModifier)

Bu modül, diğer modüllerin `cr.tex` dosyasını değiştirmeden oyundaki metinleri
değiştirmesini sağlar. API, UTF-8 metin alır ve oyunun karakter kodlamasına
dönüştürür. Değiştirilmeyen girdiler için özgün oyun metni kullanılır.

Farklı girdilerdeki değişiklikler birlikte korunur. Aynı girdi için son başarılı
kayıt geçerli olur. Kaydın kaldırılması özgün metne erişimi geri getirir.
Özgün UTF-8 metin, sonraki başlatmalarda dönüştürülmek üzere saklanır. Oyunun
dili ve karakter kodlaması, başlatıcının dilinden bağımsızdır.

Bu modül teknik bir arayüz sunar; doğrudan etkinleştirilebilen oyun özellikleri
içermez. Kullanım ve metinlerin geçerlilik süresi için deponun README dosyasına
bakın.
