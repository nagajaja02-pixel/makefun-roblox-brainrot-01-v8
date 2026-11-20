# Roblox Brainrot Blitz v9

## Implementasi

- Tombol Index hitam dihapus. Tombol biru membuka panel Index 3D v8 melalui BindableEvent lokal; pencarian, siluet terkunci, filter, kamera 3D dan koleksi tetap dipakai. Kartu sekarang memuat nama, pengali dan deskripsi efek mutasi yang ditemukan.
- Event biasa: Meteor, Gold, Thunder, Rainbow, Lucky. Pertama setelah 180 detik, lalu jeda 240 detik setelah event selesai. Durasi 90 detik (Lucky 120 detik). Event admin: Money, Giant, Disco, Cosmic, Secret, hanya lewat admin. Satu event aktif sekaligus.
- Setiap event mengubah waktu/langit, kabut, atmosfer, awan, pencahayaan, warna dan motif musik. Efek cuaca lokal dibatasi 18 part (ditambah lengkungan saat Rainbow). Meteor, uang jatuh, hujan petir, spektrum dan bintang merupakan efek kosmetik; hadiah uang dibayarkan saat event selesai kepada peserta yang masih berada di server. Conveyor memunculkan penawaran spesial sesuai mutasi event. Giant memperbesar model penawaran; Secret menawarkan dua karakter Mythic yang sudah ada, dengan mutasi Celestial, lebih sering. Tidak menambahkan spesies baru ke katalog lama.
- Pencahayaan/atmosfer/awan/volume musik sebelumnya disalin dan dipulihkan; efek dan musik event dibuang. Musik berupa motif nada menggunakan suara bawaan Roblox, tanpa ID audio eksternal.
- Mutasi: Gold x2, Diamond x3, Rainbow x5, Electric x7, Poison x10, Cosmic x15, Celestial x25. Gold/Diamond mempertahankan pengali lama. Setiap mutasi memiliki warna, material, aura dan parameter partikel/animasi berbeda. Animasi dan pembatasan jarak dilakukan di klien. Mutasi langka dapat muncul di spawn biasa; event meningkatkan peluang mutasi temanya.
- `BlitzV9Profiles` menyimpan penemuan mutasi, unit bermutasi terpasang, level stand yang diperlukan untuk memulihkannya, dan total curian. Riwayat penemuan tetap ada setelah unit dijual atau rebirth; unit yang dijual/rebirth tidak dipulihkan. Unit biasa dan uang tetap mengikuti perilaku lama. Penyimpanan berkala 60 detik, saat keluar dan shutdown. Raid dikembalikan sebelum pemilik keluar agar inventaris tersimpan tidak sekaligus dibawa pencuri.
- Leaderboard pemain **di server saat ini**, tab Cash/Steals/Rebirths, avatar, nama, peringkat, tiga statistik, pembaruan 3 detik ketika panel terbuka. Curian dihitung setelah barang curian berhasil dikirim atau dijual.
- Notifikasi event/admin dan alert serangan/pencurian memakai antrean ringkas; alert serangan dibatasi sekali per lima detik per base. Feedback lama tetap ada.
- Stand Gear Shop fisik terpisah dari merchant di (-42, 0, -17), dengan papan, atap, counter, display dan prompt. Slap $500 mengembalikan cargo dan melempar pembawa di depan dalam jarak tujuh stud, dengan pemeriksaan dinding dan cooldown. SpeedCoil $750 memberi kecepatan 28 ketika dipegang. Trap $350 sekali pakai, maksimum dua aktif per pembeli, membekukan musuh tiga detik dan hilang setelah 45 detik bila tidak terpicu.
- Gear berlaku sampai respawn (trap habis setelah dipasang). Auto-buy bersifat opt-in per item dalam sesi dan hanya membeli gear yang hilang ketika pemain dekat stand dan memiliki uang cukup; setiap pembelian tetap diperiksa server.
- Tanah diberi overlay kotak hijau berselang-seling dengan stud bawaan, sekitar 140 part. Dinding perimeter lama tetap menjadi penghalang, dengan material tanah, variasi coklat/batu, coping rumput dan pepohonan. Tidak mengganti World.buildHarbor atau safehouse lama.

## Admin

Satu UserId: **7445776793**. Pemeriksaan izin berada pada handler server bersama untuk panel dan chat. Panel tidak dibuat pada klien biasa. Server juga memvalidasi tipe/panjang input, cooldown, rentang angka, target dan mutasi. Pengumuman disaring TextService sebelum disiarkan.

Chat memakai `/blitz <perintah>`. Panel menyediakan tombol semua event, stop, kotak perintah dan petunjuk.

```
/blitz start Meteor
/blitz stop
/blitz spawn 13 Celestial
/blitz mutate me 1 Cosmic
/blitz money me 5000
/blitz speed me 28
/blitz tp me NamaPemain
/blitz bring NamaPemain
/blitz kick NamaPemain Alasan keluar
/blitz announce Pesan untuk semua pemain
```

ID event dan nama mutasi peka huruf besar/kecil. Target dapat berupa username, UserId, awalan username yang unik, atau `me`. Spawn ID 1–13; mutate memilih stand 1–8 milik target. Panel dapat memulai event biasa secara manual juga.

## Bukti pemeriksaan

Perintah dijalankan di lingkungan ini:

- `/home/hatch/.local/bin/rojo build -o game.rbxl` — sukses.
- `luau-compile` untuk seluruh 27 file `.lua`/`.luau` proyek — nol error.
- `python3 tests/v9-regression.py` — lolos. Menjalankan modul Luau asli dengan mock API Roblox: rumus/pengubahan mutasi, 10.000 penawaran acak valid, 5+5 definisi event, mulai/stop sepuluh event, larangan tumpang tindih, spawn spesial, hadiah peserta, pemulihan lighting, izin admin dan penolakan remote pemain biasa. Pengujian tambahan memeriksa pemulihan inventaris mutasi, statistik/kapasitas, penggabungan riwayat, penyimpanan penghapusan unit, dan pelepasan kunci join.

DataStore hanya dibuka di dalam fungsi melalui pcall. Gagal membuka/membaca tidak menghentikan permainan. Pembacaan profil dicoba tiga kali. Profil yang gagal dibaca tidak ditulis ulang agar data lama tidak tertimpa; atribut MutationStorageAvailable dan warning server menunjukkan kondisi ini. Tidak ada janji persistensi saat DataStore tidak tersedia, server crash sebelum save, atau layanan menolak penulisan. Uji mock bukan bukti layanan DataStore Roblox sungguhan.

## Masih wajib diuji di Roblox Studio / server privat

Tidak ada Roblox Studio, sesi multiplayer, pengukuran FPS perangkat mobile atau publish yang dijalankan di lingkungan ini. Build dan sintaks tidak menjalankan API/rendering/fisika Roblox.

1. Boot seluruh harbor, enam safehouse, conveyor, merchant, tsunami, shield, rebirth, steal dan bat; pastikan alur v8 tetap berfungsi.
2. Tombol biru membuka Index baru; tombol hitam tidak ada. Uji pencarian, siluet, viewport, filter dan tujuh riwayat mutasi pada ponsel serta desktop.
3. Jalankan sepuluh event, amati countdown, notifikasi awal/akhir, efek cuaca/langit, motif audio, reward dan penawaran spesial; stop manual dan bandingkan suasana dengan sebelum event.
4. Dengan akun admin nyata, uji semua perintah dan alasan kick. Dari akun biasa, kirim permintaan remote buatan dan pastikan tidak ada perubahan. Uji penyaringan teks dan chat baru/legacy sesuai konfigurasi experience.
5. Dua atau lebih pemain: alert ke pemilik saat raid, shield yang aktif, steal sukses/gagal, hit slap/bat di depan/di balik dinding, cargo kembali, dan statistik tidak bertambah saat raid dikembalikan.
6. Gear: uang kurang, pembelian berulang, jarak stand, auto-buy on/off, equip/unequip coil, mati/respawn, freeze/jump/gerak trap, pemilik kebal trap sendiri, cooldown serta batas dua trap. Uji touch UI dan gamepad.
7. DataStore aktif: simpan dan rejoin dengan semua mutasi, delapan stand, pencurian, penjualan dan rebirth. Uji pemilik keluar saat sedang dirampok. Ulangi dengan API disabled/throttled. Penyimpanan v9 tidak memakai session lock lintas server; uji khusus reconnect cepat dan shutdown sebelum merilis ke publik.
8. Pastikan tiles tidak menghalangi pintu/conveyor, wall tetap menutup laut, avatar leaderboard tampil dan panel terbaca di layar kecil; ukur FPS ketika banyak brainrot bermutasi terlihat.
