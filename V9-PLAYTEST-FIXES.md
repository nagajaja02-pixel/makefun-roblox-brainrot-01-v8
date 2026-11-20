# v9 — perbaikan empat bug Play Test

## Perubahan

1. Tanah: lapisan atas pulau diganti tile solid setebal 0,5 stud, bukan overlay tipis. Pulau pendukung berakhir di Y=-0,5, tile berakhir di Y=0. Pola tetap hijau berselang-seling, permukaan berjalan tetap pada ketinggian semula dan jalur dekorasi tetap di atasnya. Tile berdampingan tanpa tumpang tindih area; permukaan sambungan ke pulau berada di bawah tanah.
2. Gear Shop: seluruh stand diputar 180 derajat agar Front papan menghadap jalur di +Z. Penjaga berbentuk karakter dengan wajah, topi, apron, lengan dan kaki ditempatkan di belakang counter. Prompt Open Shop berada pada penjaga dan hanya membuka panel. Panel menyediakan Slap $500, SpeedCoil $750 dan Trap $350 dengan tombol beli masing-masing. Seluruh UI, state, remote action dan loop pembelian otomatis dihapus. Server tetap memeriksa katalog, pemain hidup/siap, jarak, uang, duplikasi, cooldown dan batas trap; fungsi alat lama dipertahankan.
3. Bar countdown dan loop UI dihapus. Jadwal event server tetap berjalan; notifikasi sementara awal/akhir yang menyebut nama event tetap memakai jalur server yang sudah ada. Reward saat selesai dan notifikasi non-event tetap dipertahankan.
4. Index menerbitkan atribut IsOpen. Saat terbuka, tombol Ranks tersembunyi/tidak interaktif dan panel leaderboard disembunyikan. Saat ditutup, keadaan panel sebelumnya dipulihkan. Sinkronisasi membaca status awal sehingga tidak bergantung urutan startup script. DisplayOrder Index dinaikkan ke 30 di atas UI v9 (15); WorldModel, kamera dan ViewportFrame lama dipertahankan.

Catatan ini menggantikan uraian auto-buy dan pemeriksaan countdown pada V9-VERIFICATION.md versi sebelumnya.

## Bukti lokal

- `/home/hatch/.local/bin/rojo build -o game.rbxl`: sukses, artifact game.rbxl diperbarui.
- `/home/hatch/.local/bin/luau-compile` terhadap seluruh 27 file script: sukses, nol error.
- `python3 tests/v9-regression.py`: PASS 10.305 assertion data/event/admin; PASS pemulihan profil mutasi, save, discovery merge, inventory removal dan join lock.
- `git diff --check`: sukses.
- Pencarian source: tidak ada auto-buy, autoButtons, remote action auto, maupun bar Next event tersisa.
- Audit seluruh pembukaan DataStore: hanya tiga lokasi (init.server.lua, CollectionService.lua, MutationService.lua); semuanya berada di dalam fungsi dan dibungkus pcall. Tidak menambahkan atau mengubah akses DataStore.

Regresi mock yang tersedia tidak menguji rendering, klik UI atau fisika gear. Build/syntax juga tidak membuktikan perilaku runtime Roblox.

## Uji pemain yang masih diperlukan

- Gerakkan kamera dekat/jauh dan sudut rendah di seluruh pola tanah; periksa kedipan, jalur, pintu dan tabrakan tanah.
- Dekati penjaga dari jalur, baca papan, gunakan prompt pada keyboard/touch/gamepad; pastikan membuka panel tidak mengurangi uang. Uji tiap tombol beli, uang kurang, duplikasi dan berjalan menjauh sebelum membeli. Pastikan tidak terjadi pembelian saat diam, kehilangan alat atau respawn.
- Dua pemain: slap mengembalikan cargo, coil equip/unequip, trap membekukan lawan dan batas dua trap tetap berfungsi.
- Tunggu event biasa dan mulai/stop event admin: tidak ada countdown menetap; pesan bernama event muncul sementara saat mulai/selesai.
- Buka Index dengan Ranks tertutup dan terbuka; pastikan tombol/panel Ranks hilang dan tidak dapat diklik, viewport 3D terlihat, lalu tutup Index dan periksa pemulihan keadaan semula. Ulangi di ponsel dan setelah respawn.
- Jalankan server Studio dengan API DataStore tersedia/tidak tersedia. Tidak ada Studio, sesi multiplayer, atau layanan DataStore nyata yang dijalankan di lingkungan ini.
