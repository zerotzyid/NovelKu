# ADDENDUM PROMPT — PERSONALIZED AI NOVEL GENERATOR

Integrasikan fitur AI ke dalam aplikasi Flutter Novelku. Fitur AI harus benar-benar berfungsi untuk menghasilkan, melanjutkan, merevisi, dan mengembangkan bab novel berdasarkan konteks cerita serta preferensi pengguna.

---

## 1. AI Provider: OpenRouter dan Custom Endpoint

Buat sistem AI provider yang fleksibel dan tidak terkunci pada satu penyedia.

### Provider yang wajib didukung

#### A. OpenRouter

- Menggunakan OpenRouter API.
- Endpoint default: "https://openrouter.ai/api/v1/chat/completions".
- API key dimasukkan sendiri oleh pengguna.
- Model dapat dipilih dari daftar model yang tersedia.
- Jika API model list tidak tersedia, sediakan input ID model manual.
- Tampilkan nama model, ID model, dan informasi kemampuan jika tersedia.
- Jangan mengasumsikan semua model mendukung fitur yang sama.

#### B. Custom OpenAI-compatible endpoint

- Pengguna bisa memasukkan base URL sendiri.
- Pengguna bisa memasukkan API key.
- Pengguna bisa menentukan model atau model ID.
- Endpoint harus mendukung format API chat completions yang kompatibel dengan OpenAI.
- Pengaturan opsional untuk header tambahan harus tersedia.
- Berikan opsi menguji koneksi sebelum konfigurasi disimpan.
- Validasi URL dan tangani timeout, error autentikasi, rate limit, serta respons yang tidak valid.

Jangan mengunci aplikasi pada OpenRouter. Struktur kode harus memungkinkan penambahan provider baru melalui interface yang konsisten.

Buat abstraksi "AIProvider" dengan implementasi terpisah seperti "OpenRouterProvider" dan "CustomOpenAIProvider".

### Keamanan

- Jangan menanamkan API key ke source code.
- Jangan mencatat API key dalam log.
- Simpan kredensial menggunakan penyimpanan aman yang sesuai untuk Android.
- Berikan opsi menghapus kredensial.
- Jangan mengirim naskah pengguna ke server lain selain provider yang dipilih.
- Jelaskan bahwa provider eksternal dapat menerima prompt dan konteks novel yang diperlukan untuk menghasilkan teks.
- Jangan mengirim seluruh isi database ke AI secara otomatis.
- Kirim hanya konteks relevan yang dibutuhkan.
- Jangan membuat proxy server wajib untuk aplikasi yang berjalan lokal.

---

## 2. Setup AI yang Mudah

Buat halaman pengaturan AI dengan wizard sederhana:

1. Pilih provider: OpenRouter atau Custom Endpoint.
2. Masukkan API key.
3. Pilih atau masukkan model.
4. Tekan tombol "Tes Koneksi".
5. Simpan konfigurasi dan mulai menulis.

Pengguna awam tidak harus memahami istilah teknis untuk menggunakan AI.

Sediakan dua mode pengaturan:

- Mode Sederhana: provider, API key, model, dan preferensi penulisan.
- Mode Lanjutan: endpoint, parameter sampling, system prompt, header custom, batas token, timeout, dan konfigurasi lainnya.

API key yang belum tersedia tidak boleh menghalangi pengguna untuk menggunakan editor dan fitur non-AI.

---

## 3. Personalisasi AI Secara Menyeluruh

Buat halaman khusus bernama Kepribadian Penulisan AI.

Pengguna dapat mengatur profil penulisan yang digunakan sebagai pedoman AI.

### A. Gaya bahasa

Sediakan pilihan:

- Formal.
- Santai.
- Sastra.
- Puitis.
- Realistis.
- Sinematik.
- Deskriptif.
- Minimalis.
- Gelap dan misterius.
- Komedi.
- Romantis.
- Petualangan.
- Gaya khusus buatan pengguna.

Pengguna dapat memilih lebih dari satu karakteristik dan menambahkan instruksi sendiri.

### B. Parameter penulisan

- Sudut pandang: orang pertama, orang ketiga terbatas, atau orang ketiga serbatahu.
- Waktu penceritaan: lampau atau sekarang.
- Panjang paragraf.
- Kepadatan dialog.
- Intensitas deskripsi.
- Kecepatan alur.
- Kedalaman emosi.
- Tingkat kompleksitas kosakata.
- Target jumlah kata per bab.
- Bahasa utama dan bahasa dialog.
- Penggunaan istilah asing.
- Gaya pembukaan dan penutupan bab.
- Tingkat konsistensi terhadap gaya penulis.

Gunakan kontrol sederhana, seperti pilihan kartu, dropdown, dan slider. Jangan menampilkan seluruh parameter lanjutan sekaligus.

### C. Custom writing instructions

Sediakan kolom instruksi bebas, misalnya:

"Tulis dengan bahasa Indonesia yang natural, dialog tidak kaku, deskripsi secukupnya, perkembangan karakter bertahap, dan hindari narasi yang berulang."

Instruksi ini harus disimpan per profil dan dapat digunakan kembali pada novel lain.

### D. Profil berbeda untuk setiap novel

Setiap novel dapat memiliki profil AI sendiri, terpisah dari pengaturan global.

Contoh:

- Novel A: fantasi epik, narasi detail, dunia kompleks.
- Novel B: romansa realistis, dialog natural, bab pendek.
- Novel C: misteri, petunjuk bertahap, atmosfer gelap.

Perubahan profil sebuah novel tidak boleh otomatis mengubah profil novel lainnya.

---

## 4. Story Bible — Memori Cerita

Implementasikan fitur Story Bible sebagai sumber kebenaran cerita.

Story Bible berisi:

### Dunia cerita

- Nama dunia dan lokasi.
- Periode waktu.
- Sistem sosial dan budaya.
- Aturan dunia.
- Sistem sihir atau teknologi jika ada.
- Sejarah dan peristiwa penting.

### Karakter

- Nama lengkap.
- Umur.
- Penampilan.
- Kepribadian.
- Motivasi.
- Tujuan.
- Ketakutan.
- Hubungan dengan karakter lain.
- Latar belakang.
- Cara berbicara.
- Perkembangan karakter.

### Alur

- Premis utama.
- Konflik utama.
- Subplot.
- Rahasia yang belum terungkap.
- Foreshadowing.
- Peristiwa yang sudah terjadi.
- Peristiwa yang direncanakan.
- Akhir cerita yang dituju.

### Aturan kontinuitas

AI harus:

- Menggunakan nama dan fakta karakter yang sudah ditentukan.
- Menghormati peristiwa dari bab sebelumnya.
- Tidak menghidupkan kembali karakter yang sudah meninggal tanpa alasan cerita yang ditetapkan.
- Tidak mengubah hubungan karakter secara mendadak.
- Tidak mengubah aturan dunia secara sembarangan.
- Tidak mengulang adegan penting tanpa tujuan naratif.
- Tidak mengungkap rahasia terlalu cepat jika belum waktunya.
- Mengikuti batasan dan instruksi khusus pengguna.

Jika informasi penting bertentangan atau belum tersedia, AI harus meminta klarifikasi atau menyatakan asumsi sebelum menggunakannya.

Story Bible harus dapat diedit secara manual. AI boleh mengusulkan perubahan, tetapi tidak boleh diam-diam menimpa fakta yang sudah dikunci pengguna.

---

## 5. AI Chapter Generator

Buat fitur utama bernama Tulis dengan AI.

Pengguna dapat memilih salah satu tindakan:

1. Buat kerangka novel.
2. Buat outline bab.
3. Generate bab lengkap.
4. Lanjutkan tulisan.
5. Kembangkan adegan.
6. Tulis ulang paragraf.
7. Perbaiki dialog.
8. Perbaiki tata bahasa.
9. Tambahkan deskripsi.
10. Buat konflik atau plot twist.
11. Periksa konsistensi cerita.
12. Buat beberapa alternatif adegan.

### Alur pembuatan bab

Sebelum menghasilkan bab, AI menggunakan:

- Premis novel.
- Outline global.
- Outline bab yang sedang dibuat.
- Isi bab sebelumnya yang relevan.
- Ringkasan cerita terbaru.
- Profil karakter terkait.
- Aturan dunia yang relevan.
- Profil gaya bahasa pengguna.
- Instruksi khusus untuk bab tersebut.

Sediakan formulir sederhana:

- Nomor dan judul bab.
- Tujuan bab.
- Peristiwa yang wajib terjadi.
- Karakter yang terlibat.
- Target jumlah kata.
- Nuansa emosional.
- Cara mengakhiri bab.
- Instruksi tambahan.

Sebagian besar informasi harus diisi otomatis dari proyek novel. Pengguna hanya perlu melengkapi hal yang ingin diubah.

Tombol utama: Generate Bab.

### Proses generation

- Tampilkan status proses yang jelas.
- Jika provider mendukung streaming, tampilkan teks secara bertahap.
- Sediakan tombol berhenti.
- Tangani respons kosong, terputus, atau gagal.
- Jangan menghapus tulisan sebelumnya ketika generation gagal.
- Jika batas token model tidak mencukupi, tawarkan generation dalam beberapa bagian.
- Jangan mengklaim target kata terpenuhi jika hasilnya belum mencapai target.
- Hindari mengirim permintaan berulang yang dapat menimbulkan biaya tanpa persetujuan pengguna.

---

## 6. Multi-turn Writing dan Context Management

Jangan mengandalkan satu prompt besar yang berisi seluruh novel.

Buat sistem manajemen konteks yang terdiri atas:

1. System prompt dan profil penulis.
2. Instruksi khusus novel.
3. Story Bible yang relevan.
4. Outline global.
5. Ringkasan novel terbaru.
6. Ringkasan bab sebelumnya.
7. Potongan teks asli yang relevan.
8. Instruksi generation saat ini.

Batas konteks mengikuti kemampuan model yang dipilih. Jangan menganggap semua model memiliki context window yang sama.

Setelah bab selesai:

- Simpan teks lengkap ke database.
- Buat atau perbarui ringkasan bab.
- Identifikasi karakter dan peristiwa baru.
- Usulkan pembaruan Story Bible.
- Tandai fakta yang berpotensi bertentangan dengan cerita sebelumnya.

Ringkasan dan perubahan Story Bible harus dapat ditinjau pengguna sebelum diterapkan.

Jika memungkinkan, hitung penggunaan token dan tampilkan estimasi biaya berdasarkan informasi harga provider yang tersedia. Jika harga tidak diketahui, jangan mengarang estimasi.

---

## 7. AI Writing Workspace yang Sederhana

Integrasikan AI ke editor utama, bukan menjadikan pengguna harus berpindah-pindah halaman.

Tampilkan tombol atau menu:

- Tulis dengan AI.
- Lanjutkan dari sini.
- Tulis ulang pilihan.
- Perbaiki dialog.
- Perluas adegan.
- Ringkas.
- Periksa kontinuitas.

Untuk tindakan berbasis seleksi teks, gunakan teks yang dipilih sebagai target, bukan menulis ulang seluruh bab.

Sebelum mengganti isi:

- Tampilkan hasil AI sebagai preview.
- Sediakan tindakan "Ganti teks", "Sisipkan", dan "Salin".
- Untuk generation satu bab penuh, sediakan "Buat sebagai draf baru" dan "Ganti isi bab".
- Jangan pernah menimpa tulisan pengguna tanpa tindakan eksplisit.
- Pertahankan versi sebelumnya agar dapat dipulihkan.

---

## 8. Revision dan Version History

Buat riwayat revisi untuk bab:

- Simpan snapshot sebelum perubahan besar dari AI.
- Tampilkan waktu revisi.
- Tampilkan sumber perubahan jika diketahui.
- Izinkan pengguna melihat dan memulihkan versi sebelumnya.
- Jangan membuat snapshot identik berulang kali tanpa kebutuhan.
- Batasi penyimpanan versi melalui pengaturan yang jelas.

Pengguna harus memiliki kontrol penuh terhadap hasil AI. AI adalah asisten penulis, bukan pemilik naskah.

---

## 9. Arsitektur Implementasi AI

Pisahkan komponen berikut:

- "AIProvider": interface provider.
- "OpenRouterProvider": implementasi OpenRouter.
- "CustomOpenAIProvider": implementasi endpoint custom.
- "AISettingsRepository": penyimpanan konfigurasi.
- "AuthorProfileRepository": profil gaya penulis.
- "StoryBibleRepository": data cerita.
- "ContextBuilder": menyusun konteks relevan.
- "ChapterGenerator": generation bab.
- "ChapterRevisionService": revisi teks.
- "ContinuityChecker": pemeriksaan konsistensi.
- "TokenUsageService": penggunaan token dan estimasi biaya.
- "GenerationHistoryRepository": riwayat generation.

Gunakan state management yang konsisten dengan Riverpod. Semua request AI harus memiliki status loading, success, error, dan cancellation bila didukung.

Jangan mencampurkan logika HTTP, prompt construction, dan widget UI dalam satu file.

---

## 10. Acceptance Criteria

Fitur AI dinyatakan selesai hanya jika:

1. Pengguna dapat menambahkan API key OpenRouter sendiri.
2. Pengguna dapat memakai custom OpenAI-compatible endpoint.
3. Pengguna dapat menguji koneksi dan memilih model.
4. Pengguna dapat menyimpan profil penulis.
5. Profil penulis benar-benar memengaruhi hasil generation.
6. AI dapat menghasilkan bab berdasarkan outline dan Story Bible.
7. AI dapat melanjutkan cerita tanpa mengabaikan konteks relevan.
8. Pengguna dapat mengedit hasil AI secara manual.
9. Generation gagal tidak merusak atau menghapus naskah.
10. Pengguna dapat memulihkan revisi sebelumnya.
11. Semua bab dan hasil AI tersimpan secara lokal.
12. Seluruh novel tetap dapat diekspor ke DOCX yang valid.
13. Fitur dasar menulis tetap berjalan tanpa internet.
14. API key tidak muncul dalam log atau source code.
15. Semua fitur memiliki status, penanganan error, dan pengujian yang memadai.

---

## 11. Instruksi Pelaksanaan

Implementasikan secara bertahap:

- Tahap 1: Fondasi Flutter, database, proyek novel, dan editor.
- Tahap 2: Manajemen bab, autosave, dan ekspor DOCX.
- Tahap 3: Integrasi OpenRouter dan custom endpoint.
- Tahap 4: Profil penulis dan personalisasi AI.
- Tahap 5: Story Bible, context builder, dan generation bab.
- Tahap 6: Revision history, kontinuitas, dan statistik penggunaan AI.
- Tahap 7: Pengujian menyeluruh, optimasi Android, dan penyempurnaan UI/UX.

Setelah setiap tahap, jalankan analisis statis, pengujian unit, dan pengujian integrasi yang relevan. Jangan meninggalkan tombol palsu, data dummy sebagai fitur final, atau fungsi inti yang hanya berupa placeholder.

Prioritaskan aplikasi yang mudah digunakan, aman, hemat penggunaan token, stabil pada perangkat Android dengan RAM terbatas, dan tidak kehilangan naskah pengguna.