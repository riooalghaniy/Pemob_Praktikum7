import 'package:flutter/material.dart'; // Import library untuk menggunakan Flutter UI framework.
import 'package:http/http.dart' as http; // Import library untuk HTTP requests.
import 'dart:convert'; // Import library untuk mengonversi data JSON.
import 'package:provider/provider.dart'; // Import library untuk state management dengan Provider.

// Kelas untuk merepresentasikan data universitas.
class University {
  String name; // Nama universitas.
  String website; // Situs web universitas.

  University(
      {required this.name,
      required this.website}); // Konstruktor untuk membuat objek University.

  // Factory method untuk membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Ambil nama universitas dari JSON.
      website: json['web_pages'].isNotEmpty
          ? json['web_pages'][0]
          : "", // Ambil situs web universitas dari JSON.
    );
  }
}

// Kelas untuk menyediakan data universitas menggunakan Provider.
class UniversityProvider extends ChangeNotifier {
  late List<University> _universities; // Daftar universitas.

  List<University> get universities =>
      _universities; // Getter untuk daftar universitas.

  // Metode untuk mengambil data universitas dari API berdasarkan negara.
  void fetchData(String country) async {
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL API dengan parameter negara.

    final response =
        await http.get(Uri.parse(url)); // Kirim permintaan HTTP GET ke URL.

    if (response.statusCode == 200) {
      // Jika permintaan berhasil:
      List<dynamic> data =
          jsonDecode(response.body); // Decode data JSON dari respons.
      _universities = data
          .map((uni) => University.fromJson(uni))
          .toList(); // Buat objek University dari data JSON.
      notifyListeners(); // Beri tahu pendengar bahwa data telah diperbarui.
    } else {
      // Jika permintaan gagal:
      throw Exception(
          'Failed to load universities'); // Buang pengecualian dengan pesan kesalahan.
    }
  }
}

// Kelas utama aplikasi Flutter.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities di ASEAN', // Judul aplikasi.
      home: ChangeNotifierProvider(
        // Gunakan ChangeNotifierProvider sebagai root widget.
        create: (context) =>
            UniversityProvider(), // Buat instance dari UniversityProvider.
        child: HomePage(), // Gunakan HomePage sebagai child widget.
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _aseanCountries = [
    // Daftar negara-negara ASEAN.
    'Singapore',
    'Malaysia',
    'Indonesia',
    'Thailand',
    'Vietnam',
    'Philippines',
    'Brunei',
    'Myanmar',
    'Cambodia',
    'Laos'
  ];
  String _selectedCountry = 'Singapore'; // Negara yang dipilih secara default.

  @override
  void initState() {
    super.initState();
    Provider.of<UniversityProvider>(context, listen: false).fetchData(
        _selectedCountry); // Ambil data universitas saat inisialisasi.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold adalah wadah utama untuk layout.
      appBar: AppBar(
        // AppBar untuk menampilkan judul.
        title: Text('Universities di ASEAN'), // Judul AppBar.
        backgroundColor: Colors.red, // Warna latar belakang AppBar.
      ),
      body: Column(
        // Column untuk tata letak vertikal.
        children: [
          DropdownButton<String>(
            // DropdownButton untuk memilih negara ASEAN.
            value: _selectedCountry, // Nilai yang dipilih saat ini.
            onChanged: (String? newValue) {
              // Ketika nilai dipilih berubah:
              setState(() {
                _selectedCountry = newValue!; // Perbarui negara yang dipilih.
                Provider.of<UniversityProvider>(context, listen: false).fetchData(
                    newValue); // Ambil data universitas untuk negara yang dipilih.
              });
            },
            items:
                _aseanCountries.map<DropdownMenuItem<String>>((String value) {
              // Buat item untuk dropdown dari daftar negara ASEAN.
              return DropdownMenuItem<String>(
                value: value, // Nilai item dropdown.
                child: Text(value), // Teks yang ditampilkan.
              );
            }).toList(),
          ),
          Expanded(
            // Expanded untuk menyesuaikan ruang sisa.
            child: Consumer<UniversityProvider>(
              // Consumer untuk mendengarkan perubahan pada UniversityProvider.
              builder: (context, provider, _) {
                if (provider.universities.isEmpty) {
                  // Jika daftar universitas kosong:
                  return Center(
                    // Tengahkan tampilan.
                    child:
                        CircularProgressIndicator(), // Tampilkan indikator loading.
                  );
                } else {
                  // Jika ada universitas yang tersedia:
                  return ListView.builder(
                    // ListView untuk menampilkan daftar universitas.
                    itemCount: provider
                        .universities.length, // Jumlah item dalam daftar.
                    itemBuilder: (context, index) {
                      // Builder untuk setiap item dalam daftar.
                      return ListTile(
                        // ListTile untuk menampilkan data universitas.
                        title: Text(provider
                            .universities[index].name), // Nama universitas.
                        subtitle: Text(provider.universities[index]
                            .website), // Situs web universitas.
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp()); // Jalankan aplikasi Flutter.
}
