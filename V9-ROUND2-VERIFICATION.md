# v9 — Play Test fix ronde 2

## Perubahan

- Ranks: tombol tetap 78×36, berpindah dari Y=65 ke Y=8 di kanan atas area GUI yang mengikuti inset Roblox. Area status gelombang mulai Y=53 sehingga ada jarak 9 px. Sinkronisasi IsOpen Index dan pemulihan panel sebelumnya dipertahankan.
- Gear Shop: setiap baris mempunyai ViewportFrame 68×80, WorldModel dan kamera lokal. Slap berupa telapak, empat jari, ibu jari dan cuff; SpeedCoil berupa heliks 64 segmen serta dua grip; Trap berupa pelat, trigger, rahang dan delapan gigi. Semua Part lokal tanpa aset gambar eksternal. Teks berada di samping ikon, tombol beli tetap selebar baris di bawahnya; daftar tetap bisa di-scroll dan panel tetap memakai ukuran relatif serta batas maksimum lama.
- Katalog: 17 karakter ditambahkan setelah ID 13, total 30. Common 7, Rare 6, Epic 6, Legendary 5, Mythic 6. Setiap tambahan memiliki nama, caption, harga, income, warna dan fungsi sculpt sendiri dengan bentuk khas. Harga/income semua rarity lebih tinggi daripada rarity di bawahnya. Tiga belas entri lama, model lama dan bobot rarity 52/26/14/6/2 tidak berubah. Bantuan admin spawn sekarang menyebut 1–30.
- Integrasi memakai jalur lama: ConveyorService melakukan iterasi seluruh Data.cast dan randomOffer memilih anggota tier; CollectionService membuat template Index untuk setiap ID; pembelian/carry/raid menggunakan unit dan Models.sculpt generik; MutationService menyimpan dan memulihkan ID melalui Data.cast. Tidak menulis ulang sistem tersebut.
- Safehouse: permukaan luar rear/front wall, side wall/header dan corner pier memperoleh SurfaceGui pola bata abu-abu dengan stud bulat berbayang. Nama safehouse, kaca dan aksen canopy tetap dipertahankan. SurfaceGui mengikuti muka Part, AlwaysOnTop=false, offset permukaan kecil; tidak ada lapisan Part yang bertumpuk, collision baru atau perubahan ukuran/posisi struktur. Pola tidak melintasi bukaan pintu/jendela.
- DataStore tidak diubah. Ketiga pemanggilan GetDataStore tetap hanya di fungsi openRebirthStore / Collection.start / MutationService.start, dibungkus pcall dengan fallback nil.

## Bukti lokal

- `/home/hatch/.local/bin/rojo build -o game.rbxl`: sukses, artifact diperbarui.
- `/home/hatch/.local/bin/luau-compile` untuk seluruh 27 script: sukses.
- `python3 tests/v9-regression.py`: PASS 10.577 assertion; PASS pemulihan profil, save, discovery merge, inventory removal dan join lock.
- `python3 tests/round2-regression.py`: PASS 2.663 assertion. Menjalankan sculpt seluruh 30 karakter untuk normal/Gold/Diamond dengan mock API Roblox (90 pembuatan model), memeriksa dimensi primitif positif, PrimaryPart, kelengkapan model, nama unik, semua tier terisi dan ekonomi lintas rarity. Membandingkan data 13 karakter lama serta bobot rarity dengan HEAD baseline.
- `git diff --check`: sukses.

Mock tidak merender gambar dan tidak menjalankan server Roblox. Build/syntax tidak menjamin perilaku runtime.

## Play Test pemain yang masih diperlukan

1. Desktop dan ponsel kecil: periksa Ranks tidak menutupi status gelombang/topbar; klik tombol dan ulangi buka/tutup Index saat Ranks terbuka maupun tertutup, termasuk sesudah respawn.
2. Buka Gear Shop lewat NPC: lihat bentuk tangan, kumparan dan trap; periksa keterbacaan teks dan scroll pada layar portrait/landscape, klik setiap Buy dan pastikan membuka toko tidak membeli otomatis.
3. Spawn ID 14–30 lewat admin atau tunggu conveyor: periksa siluet, posisi wajah, kaki, label dan ukuran pada belt/stand/carry. Beli, antar ke base, lalu curi dan antar dengan pemain kedua. Periksa income dan penemuan Index, preview semua karakter, mutasi seluruh jenis dan persistensi sesudah rejoin.
4. Dekati keenam safehouse dari semua sisi, gerakkan kamera dekat/jauh dan sudut miring: pastikan pola/stud terbaca dan tidak berkedip. Lewati pintu, lihat melalui kaca, periksa conveyor serta shield tetap berfungsi. Stud merupakan detail permukaan, bukan geometri collision.
5. API DataStore aktif/nonaktif: uji penyimpanan karakter baru dan fallback. Tidak ada sesi Studio, multiplayer atau akses DataStore nyata yang dijalankan untuk verifikasi lokal ini.
