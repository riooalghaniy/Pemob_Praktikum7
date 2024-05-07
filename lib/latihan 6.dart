import 'package:flutter/material.dart'; // Import library untuk menggunakan Flutter UI framework.
import 'package:http/http.dart' as http; // Import library untuk HTTP requests.
import 'dart:convert'; // Import library untuk mengonversi data JSON.

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

// Enum untuk daftar negara ASEAN.
enum AseanCountry {
  Indonesia,
  Singapore,
  Malaysia,
  Thailand,
  Philippines,
  Vietnam,
  Myanmar,
  Cambodia,
  Laos,
  Brunei
}

// Kelas untuk mengatur state aplikasi.
class UniversityBloc extends ChangeNotifier {
  late Future<List<University>>
      futureUniversities; // Variabel untuk menampung future hasil pengambilan data.

  // Method untuk mengambil data dari API berdasarkan negara.
  Future<List<University>> fetchData(AseanCountry country) async {
    String url =
        "http://universities.hipolabs.com/search?country=${country.toString().split('.').last}"; // URL API dengan parameter negara.
    final response =
        await http.get(Uri.parse(url)); // Melakukan HTTP GET request ke URL.

    if (response.statusCode == 200) {
      // Jika permintaan berhasil:
      List<dynamic> data =
          jsonDecode(response.body); // Decode data JSON dari respons.
      List<University> universities =
          []; // Inisialisasi list untuk menyimpan data universitas.

      data.forEach((university) {
        universities.add(University.fromJson(
            university)); // Menambahkan data universitas ke dalam list.
      });

      return universities; // Mengembalikan list universitas.
    } else {
      // Jika permintaan gagal:
      throw Exception(
          'Gagal load'); // Lemparkan exception jika terjadi error dalam pengambilan data.
    }
  }

  // Method untuk mendapatkan daftar universitas berdasarkan negara ASEAN.
  void getUniversitiesByAseanCountry(AseanCountry country) {
    futureUniversities =
        fetchData(country); // Menginisialisasi future untuk pengambilan data.
    notifyListeners(); // Memberitahu listener bahwa state telah berubah.
  }
}

// Kelas utama aplikasi Flutter.
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Mengembalikan state dari aplikasi.
  }
}

class MyAppState extends State<MyApp> {
  late UniversityBloc _universityBloc; // Bloc untuk mengatur state aplikasi.
  AseanCountry _selectedCountry =
      AseanCountry.Indonesia; // Negara ASEAN yang dipilih, default Indonesia.

  @override
  void initState() {
    super.initState();
    _universityBloc = UniversityBloc(); // Inisialisasi Bloc.
    _universityBloc.getUniversitiesByAseanCountry(
        _selectedCountry); // Ambil data universitas berdasarkan negara ASEAN yang dipilih.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities di ASEAN', // Judul aplikasi.
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Universities di ASEAN'), // Judul AppBar.
          backgroundColor: Colors.red, // Mengubah warna AppBar menjadi merah.
        ),
        body: Center(
          child: Column(
            children: [
              DropdownButton<AseanCountry>(
                value: _selectedCountry,
                items: AseanCountry.values.map((AseanCountry country) {
                  return DropdownMenuItem<AseanCountry>(
                    value: country,
                    child: Text(country.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (AseanCountry? newValue) {
                  setState(() {
                    _selectedCountry = newValue!;
                    _universityBloc.getUniversitiesByAseanCountry(
                        _selectedCountry); // Ambil data universitas berdasarkan negara ASEAN yang dipilih.
                  });
                },
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder<List<University>>(
                    future: _universityBloc
                        .futureUniversities, // Future yang akan dipantau.
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // Jika data tersedia, tampilkan ListView dengan data universitas.
                        return ListView.builder(
                          itemCount: snapshot
                              .data!.length, // Jumlah item dalam ListView.
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(snapshot.data![index]
                                      .name), // Menampilkan nama universitas.
                                  subtitle: Text(snapshot.data![index]
                                      .website), // Menampilkan situs web universitas.
                                ),
                                Divider(
                                  // Menambahkan garis batas antara setiap elemen ListView.
                                  height: 0,
                                  thickness: 1,
                                  color: Colors.grey[300],
                                ),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        // Jika terjadi error dalam pengambilan data, tampilkan pesan error.
                        return Text('${snapshot.error}');
                      }
                      // Default: menampilkan loading spinner.
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp()); // Menjalankan aplikasi Flutter.
}
