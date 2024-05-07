import 'package:flutter/material.dart'; // Import library untuk menggunakan Flutter UI framework.
import 'package:http/http.dart' as http; // Import library untuk HTTP requests.
import 'dart:convert'; // Import library untuk mengonversi data JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library untuk Flutter Bloc.

// Kelas untuk merepresentasikan data universitas.
class University {
  String name; // Nama universitas.
  String website; // Situs web universitas.

  // Constructor dengan parameter wajib.
  University({required this.name, required this.website});

  // Factory method untuk membuat objek University dari JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Ambil nama universitas dari JSON.
      website: json['web_pages'].isNotEmpty
          ? json['web_pages'][0]
          : "", // Ambil situs web pertama, jika ada.
    );
  }
}

// Cubit untuk mengelola state aplikasi
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit()
      : super([]); // Inisialisasi state awal dengan daftar kosong.

  // Method untuk mengambil data universitas dari API berdasarkan negara
  Future<void> fetchUniversities(String country) async {
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL API dengan parameter negara.
    final response =
        await http.get(Uri.parse(url)); // Kirim permintaan HTTP GET ke URL.

    if (response.statusCode == 200) {
      // Jika permintaan berhasil:
      List<dynamic> data =
          jsonDecode(response.body); // Decode data JSON dari respons.
      List<University> universities = [];

      data.forEach((university) {
        // Iterasi melalui data universitas.
        universities.add(University.fromJson(
            university)); // Tambahkan universitas baru ke daftar.
      });

      emit(universities); // Mengupdate state dengan data universitas baru.
    } else {
      // Jika permintaan gagal:
      throw Exception(
          'Gagal load'); // Buang pengecualian dengan pesan kesalahan.
    }
  }
}

// Kelas utama aplikasi Flutter.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities di ASEAN', // Judul aplikasi.
      home: BlocProvider(
        // Menyediakan UniversityCubit ke UniversityPage.
        create: (context) =>
            UniversityCubit(), // Buat instance dari UniversityCubit.
        child: UniversityPage(), // Gunakan UniversityPage sebagai child widget.
      ),
    );
  }
}

class UniversityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit = BlocProvider.of<UniversityCubit>(
        context); // Mendapatkan instance UniversityCubit dari BlocProvider.

    return Scaffold(
      // Scaffold adalah wadah utama untuk layout.
      appBar: AppBar(
        // AppBar untuk menampilkan judul.
        title: const Text('Universities di ASEAN'), // Judul AppBar.
        backgroundColor: Colors.red, // Warna latar belakang AppBar.
      ),
      body: Column(
        // Column untuk tata letak vertikal.
        children: [
          Padding(
            // Padding untuk memberi jarak di sekitar DropdownButton.
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              // DropdownButton untuk memilih negara ASEAN.
              items: [
                DropdownMenuItem<String>(
                  child: Text('Indonesia'),
                  value: 'Indonesia',
                ),
                // Tambahkan DropdownMenuItem untuk negara ASEAN lainnya
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  universityCubit.fetchUniversities(
                      newValue); // Memanggil method untuk mengambil data universitas berdasarkan negara yang dipilih.
                }
              },
              hint: Text('Pilih negara ASEAN'), // Hint pada combobox.
            ),
          ),
          Expanded(
            // Expanded untuk menyesuaikan ruang sisa.
            child: BlocBuilder<UniversityCubit, List<University>>(
              // BlocBuilder untuk mendengarkan perubahan state dari UniversityCubit.
              builder: (context, universities) {
                return ListView.builder(
                  // ListView untuk menampilkan daftar universitas.
                  itemCount: universities.length, // Jumlah item dalam daftar.
                  itemBuilder: (context, index) {
                    // Builder untuk setiap item dalam daftar.
                    return Column(
                      children: [
                        ListTile(
                          // ListTile untuk menampilkan data universitas.
                          title: Text(
                              universities[index].name), // Nama universitas.
                          subtitle: Text(universities[index]
                              .website), // Situs web universitas.
                        ),
                        Divider(
                          // Divider untuk memisahkan item dalam daftar.
                          height: 0,
                          thickness: 1,
                          color: Colors.grey[300],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp()); // Menjalankan aplikasi Flutter.
}
