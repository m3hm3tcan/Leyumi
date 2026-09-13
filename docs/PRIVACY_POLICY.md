# Leyumi Gizlilik Politikası

**Yürürlük tarihi:** 12 Eylül 2026

**Uygulama:** Leyumi

**Geliştirici ve yayıncı:** Leyumi Studio

**Gizlilik iletişim adresi:** leyumistudio@gmail.com

## 1. Leyumi'nin amacı

Leyumi, bakıcıların kendi girdikleri bebek bakım kayıtlarını düzenlemelerine ve takip etmelerine yardımcı olan çevrimdışı bir kayıt aracıdır. Leyumi bir tıbbi cihaz veya sağlık hizmeti değildir.

Leyumi sağlık önerisi, tanı, tedavi, acil durum yönlendirmesi veya profesyonel değerlendirme sunmaz; herhangi bir hastalığı teşhis etmez, tedavi etmez, iyileştirmez veya önlemez. Uygulamadaki kayıtlar yalnızca kullanıcı tarafından girilen bilgilere dayanır ve profesyonel yardımın yerine kullanılamaz. Sağlıkla ilgili tavsiye, tanı veya tedavi için yetkili bir sağlık profesyoneline danışılmalıdır. Acil bir durumda uygulamaya güvenilmemeli, ilgili yerel acil yardım hizmetine başvurulmalıdır.

## 2. Cihazda işlenen veriler

Leyumi, kullanıcının isteğe bağlı olarak girdiği aşağıdaki bilgileri uygulamanın çalışması için cihazda işler:

- çocuk profili, ad veya takma ad ve doğum tarihi;
- büyüme ölçümleri;
- beslenme ve bez kayıtları;
- süt stoğu kayıtları;
- bakım planları ve etkinlik hatırlatma ayarları;
- uygulama tercihleri ve aktif çocuk seçimi.

Bu bilgiler Leyumi Studio tarafından toplanmaz. Buradaki “toplanmaz” ifadesi, verilerin geliştiriciye ait veya geliştirici tarafından işletilen bir sunucuya gönderilmediği anlamına gelir. Uygulama, girilen bilgileri özelliklerini sunabilmek için kullanıcının cihazında yerel olarak işler.

## 3. Yerel saklama

Kayıtlar yalnızca cihazdaki Leyumi'ye özel uygulama alanında bulunan yerel SQLite veritabanında saklanır. Bu sürüm hesap açmayı gerektirmez; bulut eşitleme ve geliştirici sunucusuna yedekleme yapmaz.

Android sistem yedeklemesi Leyumi için kapalıdır. Uygulamanın kaldırılması, uygulama verilerinin temizlenmesi veya cihazın kaybedilmesi kayıtların kalıcı olarak kaybolmasına neden olabilir.

## 4. Veri toplama, paylaşma ve satış

Leyumi Studio kişisel bilgileri veya bebek bakım kayıtlarını:

- cihazdan otomatik olarak almaz;
- kendi sunucularına iletmez;
- üçüncü taraflarla paylaşmaz;
- reklam, profil oluşturma veya analiz amacıyla kullanmaz;
- satmaz.

Uygulamada reklam, kullanıcı davranışı analizi veya izleme SDK'sı bulunmaz.

Kullanıcı bir rapor için Android'in paylaşma veya yazdırma işlevini açıkça seçerse, seçilen içerik kullanıcının belirlediği uygulamaya veya hizmete aktarılır. Bu kullanıcı tarafından başlatılan aktarımın sonraki işlenmesi, seçilen hizmetin gizlilik koşullarına tabidir. Leyumi Studio aktarım hedefini seçmez ve aktarılan içeriğin bir kopyasını almaz.

## 5. Bildirimler ve izinler

Leyumi, kullanıcı tarafından başlatılan etkin zamanlayıcıları ve kullanıcının seçtiği planlı etkinlik hatırlatmalarını cihazda göstermek için bildirim izni isteyebilir. Bildirim izni kişisel veri toplamak, kullanıcıyı izlemek veya verileri cihaz dışına göndermek için kullanılmaz. İzin reddedilirse bakım kayıtları çalışmaya devam eder.

## 6. Saklama ve silme

Yerel kayıtlar kullanıcı tek tek silene, Ayarlar bölümündeki **Leyumi'yi Sıfırla** seçeneğini kullanana, Android ayarlarından uygulama verilerini temizleyene veya uygulamayı kaldırana kadar cihazda kalır.

**Leyumi'yi Sıfırla** işlemi Leyumi'nin cihazda tuttuğu profilleri, bakım kayıtlarını, taslakları ve tercihleri kalıcı olarak siler. Leyumi Studio bu verileri toplamadığı için geliştirici tarafında ayrıca silinecek bir kullanıcı hesabı veya sunucu kaydı bulunmaz.

## 7. Güvenlik

Leyumi yerel kayıtları korumak için Android uygulama alanından ve cihazın güvenlik mekanizmalarından yararlanır. Kullanıcıların cihazlarını güncel tutmaları ve PIN, parola veya biyometrik kilit kullanmaları önerilir. Hiçbir yerel saklama yöntemi mutlak güvenlik garanti edemez.

## 8. Çocukların gizliliği

Leyumi çocukların doğrudan kullanımı için tasarlanmamıştır. Bebekle ilgili bilgiler yetişkin bir kullanıcı veya bakıcı tarafından girilir. Leyumi Studio çocuklardan veya yetişkinlerden kişisel veri toplamaz.

## 9. Yedekleme ve cihaz değişikliği

Kullanıcı Ayarlar bölümünden parola korumalı bir `.leyumi` yedek dosyası oluşturabilir. Yedek, kullanıcının belirlediği parola kullanılarak Argon2id ile türetilen bir anahtar ve AES-256-GCM ile şifrelenir. Parola Leyumi Studio'ya gönderilmez, hiçbir yerde saklanmaz ve Leyumi Studio tarafından kurtarılamaz.

Android dosya seçici, yedeğin kaydedileceği veya geri yükleneceği konumu kullanıcıya seçtirir. Kullanıcı Google Drive, OneDrive veya başka bir hizmet seçerse dosya kullanıcının açık talebiyle o hizmete aktarılır ve sonraki işlemler ilgili hizmetin gizlilik koşullarına tabi olur. Leyumi Studio yedek dosyasını veya parolayı almaz.

Geri yükleme işleminde dosya ve parola doğrulandıktan ve kullanıcı açıkça onay verdikten sonra cihazdaki mevcut Leyumi kayıtları yedekteki kayıtlarla değiştirilir.

## 10. Politika değişiklikleri

Uygulamanın veri işleme biçimi değişirse bu politika güncellenir ve yeni yürürlük tarihi yayımlanır. Veri toplama veya paylaşma getiren bir özellik, gerekli açıklamalar ve kullanıcı seçimleri sunulmadan etkinleştirilmez.

## 11. İletişim

Bu politika veya Leyumi'nin gizlilik uygulamalarıyla ilgili sorular için **leyumistudio@gmail.com** adresinden Leyumi Studio ile iletişime geçebilirsiniz.

---

# Leyumi Privacy Policy

**Effective date:** September 12, 2026

**Application:** Leyumi

**Developer and publisher:** Leyumi Studio

**Privacy contact:** leyumistudio@gmail.com

## 1. Purpose of Leyumi

Leyumi is an offline record-keeping tool that helps caregivers organize and track baby-care information they enter themselves. Leyumi is not a medical device or healthcare service.

Leyumi does not provide health recommendations, diagnosis, treatment, emergency guidance, or professional assessment, and it does not diagnose, treat, cure, or prevent any medical condition. Records in the application are based only on information entered by the user and must not be used as a substitute for professional assistance. Users should consult a qualified healthcare professional for medical advice, diagnosis, or treatment. The application must not be relied upon in an emergency; users should contact the appropriate local emergency service.

## 2. Data processed on the device

Leyumi locally processes the following optional user-entered information to provide its features:

- child profile, name or nickname, and date of birth;
- growth measurements;
- feeding and diaper records;
- milk inventory records;
- care plans and activity reminder settings;
- application preferences and the active-child selection.

Leyumi Studio does not collect this information. “Does not collect” means that the data is not transmitted to a server owned or operated by the developer. The application processes entered information locally on the user's device to provide its features.

## 3. Local storage

Records are stored only in Leyumi's private application area in a local SQLite database. This version does not require an account and does not use cloud synchronization or backup to a developer server.

Android system backup is disabled for Leyumi. Uninstalling the application, clearing its data, or losing the device may permanently remove the records.

## 4. Collection, sharing, and sale

Leyumi Studio does not automatically retrieve personal information or baby-care records from the device, transmit them to its servers, share them with third parties, use them for advertising, profiling, or analytics, or sell them.

The application contains no advertising, user-behavior analytics, or tracking SDK.

If the user explicitly selects Android's share or print controls for a report, the selected content is transferred to the application or service chosen by the user. Further processing of this user-initiated transfer is governed by the chosen service's privacy terms. Leyumi Studio does not choose the destination and does not receive a copy.

## 5. Notifications and permissions

Leyumi may request notification permission to display user-started active timers and user-selected planned activity reminders on the device. Notification permission is not used to collect personal data, track users, or send records off the device. Care records continue to work if permission is denied.

## 6. Retention and deletion

Local records remain on the device until the user deletes them individually, uses **Reset Leyumi** in Settings, clears application data through Android, or uninstalls the application.

**Reset Leyumi** permanently deletes the profiles, care records, drafts, and preferences held locally by Leyumi. Because Leyumi Studio does not collect these records, there is no developer-side user account or server record requiring a separate deletion request.

## 7. Security

Leyumi relies on Android's application sandbox and the device's security mechanisms to protect local records. Users should keep their devices updated and use a PIN, password, or biometric lock. No local storage method can guarantee absolute security.

## 8. Children's privacy

Leyumi is not designed for direct use by children. Information about a baby is entered by an adult user or caregiver. Leyumi Studio does not collect personal data from children or adults.

## 9. Backup and device transfer

The user can create a password-protected `.leyumi` backup file from Settings. The backup is encrypted with AES-256-GCM using a key derived from the user's password with Argon2id. The password is not transmitted to or stored by Leyumi Studio and cannot be recovered by Leyumi Studio.

Android's file picker lets the user choose where a backup is saved or selected for restoration. If the user selects Google Drive, OneDrive, or another service, the file is transferred to that service at the user's explicit request, and further processing is governed by that service's privacy terms. Leyumi Studio does not receive the backup file or password.

During restoration, the file and password are validated and the user must explicitly confirm before the current Leyumi records on the device are replaced with records from the backup.

## 10. Changes to this policy

This policy will be updated if the application's data-handling practices change, and a new effective date will be published. A feature that introduces data collection or sharing will not be enabled without the required disclosures and user choices.

## 11. Contact

For questions about this policy or Leyumi's privacy practices, contact Leyumi Studio at **leyumistudio@gmail.com**.
