// Import library yang diperlukan untuk Flutter
import 'package:flutter/material.dart';
import 'dart:math';

// Fungsi utama untuk menjalankan aplikasi
void main() {
  runApp(const SeatRandomizerApp());
}

// Widget utama aplikasi, bersifat stateless karena tidak berubah
class SeatRandomizerApp extends StatelessWidget {
  const SeatRandomizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi yang akan muncul di tab browser
      title: 'Aplikasi Acak Kursi',
      // Mengatur tema visual aplikasi
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Mengatur tema AppBar secara global
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto', // Contoh font, bisa diganti
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // Menghilangkan banner debug
      debugShowCheckedModeBanner: false,
      // Halaman utama aplikasi
      home: const RandomizerScreen(),
    );
  }
}

// Widget untuk halaman utama, bersifat stateful karena kontennya bisa berubah
class RandomizerScreen extends StatefulWidget {
  const RandomizerScreen({super.key});

  @override
  State<RandomizerScreen> createState() => _RandomizerScreenState();
}

class _RandomizerScreenState extends State<RandomizerScreen> {
  // Controller untuk mengelola input teks dari user
  final TextEditingController _nimController = TextEditingController();

  // Variabel untuk menyimpan hasil nomor kursi yang diacak
  String _seatResult = '';

  // Map untuk menyimpan NIM yang sudah mendapatkan kursi (Key: NIM, Value: Nomor Kursi)
  final Map<String, int> _assignedSeats = {};

  // List untuk menyimpan nomor kursi yang masih tersedia
  final List<int> _availableSeats = [];

  // Jumlah total kursi yang tersedia. Anda bisa mengubah nilai ini.
  final int _totalSeats = 200;

  @override
  void initState() {
    super.initState();
    // Mengisi daftar kursi yang tersedia dari 1 sampai _totalSeats
    _resetSeatData();
  }

  // Fungsi untuk mereset data kursi (jika diperlukan)
  void _resetSeatData() {
    setState(() {
      _availableSeats.clear();
      _assignedSeats.clear();
      _availableSeats.addAll(List.generate(_totalSeats, (index) => index + 1));
      _seatResult = 'Data kursi telah direset. Silakan mulai pengacakan.';
    });
  }

  // Fungsi untuk menghasilkan nomor kursi acak
  void _generateRandomSeat() {
    final nim = _nimController.text.trim();

    // 1. Memeriksa apakah input NIM tidak kosong
    if (nim.isEmpty) {
      setState(() {
        _seatResult = 'Silakan masukkan NIM Anda terlebih dahulu.';
      });
      return;
    }

    // 2. Validasi format dan awalan NIM menggunakan regular expression
    final RegExp nimRegex = RegExp(r'^24010110\d{3}$');
    if (!nimRegex.hasMatch(nim)) {
      setState(() {
        _seatResult =
            'Format NIM tidak valid. NIM harus diawali "24010110" dan diikuti 3 angka (contoh: 24010110001).';
      });
      return;
    }

    // 3. Memeriksa apakah NIM tersebut sudah pernah mendapatkan kursi
    if (_assignedSeats.containsKey(nim)) {
      setState(() {
        final assignedSeat = _assignedSeats[nim];
        _seatResult =
            'NIM $nim sudah mendapatkan kursi nomor: $assignedSeat. Tidak bisa mengambil kursi lagi.';
      });
      return;
    }

    // 4. Memeriksa apakah masih ada kursi yang tersedia
    if (_availableSeats.isEmpty) {
      setState(() {
        _seatResult =
            'Maaf, semua kursi sudah terisi. Tidak ada kursi lagi yang tersedia.';
      });
      return;
    }

    // 5. Proses pengacakan kursi
    final random = Random();
    final randomIndex = random.nextInt(_availableSeats.length);
    final newSeatNumber = _availableSeats.removeAt(randomIndex);

    // Simpan data NIM dan kursi yang didapat
    _assignedSeats[nim] = newSeatNumber;

    // Memperbarui state untuk menampilkan hasil di UI
    setState(() {
      _seatResult =
          'Selamat! Mahasiswa dengan NIM $nim mendapatkan kursi nomor: $newSeatNumber';
    });

    _nimController.clear(); // Bersihkan input field setelah berhasil
  }

  @override
  void dispose() {
    _nimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Kursi Acak Mahasiswa'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Reset semua data kursi',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetSeatData,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Menampilkan informasi sisa kursi dan kursi terisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Sisa Kursi: ${_availableSeats.length}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    Text(
                      'Kursi Terisi: ${_assignedSeats.length}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _nimController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nomor Induk Mahasiswa (NIM)',
                    hintText: 'Contoh: 24010110001',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generateRandomSeat,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Dapatkan Kursi Acak'),
                ),
                const SizedBox(height: 32),
                if (_seatResult.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Text(
                      _seatResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ),

                // Daftar mahasiswa yang sudah mendapatkan kursi
                if (_assignedSeats.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Column(
                      children: [
                        const Text(
                          'Daftar Kursi Terisi',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 300, // Tinggi area daftar agar bisa di-scroll
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            itemCount: _assignedSeats.length,
                            itemBuilder: (context, index) {
                              final nim = _assignedSeats.keys.elementAt(index);
                              final seat = _assignedSeats[nim];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  // ===== KODE DIUBAH DI SINI =====
                                  // Mengembalikan CircleAvatar untuk menampilkan nomor kursi.
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.indigo,
                                    child: Text(
                                      seat.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text('NIM: $nim'),
                                  subtitle: Text('Menduduki kursi nomor $seat'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
