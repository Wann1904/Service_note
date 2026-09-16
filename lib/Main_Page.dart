import 'package:Project_Uas/Diagnose.dart';
import 'package:Project_Uas/dbHelp.dart';
import 'package:flutter/material.dart';
import 'package:Project_Uas/login.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Controller
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController nomorController = TextEditingController();
  final TextEditingController keluhanController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final currencyFormatter = NumberFormat("#,##0", "id_ID");

  final List<String> statusList = ["Done", "Undone"];
  final List<String> kategoriList = ["Handphone", "Laptop", "Others"];

  String selectedKategori = "Others";
  String selectedStatus = "Undone";

  bool isSearching = false;

  List<Map<String, dynamic>> servisList = [];
  DbHelper db = DbHelper();

  @override
  void dispose() {
    nominalController.dispose();
    namaController.dispose();
    modelController.dispose();
    nomorController.dispose();
    keluhanController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadServis() async {
    final data = await db.getServis();

    setState(() {
      servisList = data;
    });
  }

  //fitur search
  void searchServis(String query) async {
    db
        .searchData(query)
        .then(
          (results) {
            setState(() {
              servisList = results;
            });
          },
          onError: (error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Gagal mencari data")));
          },
        );
  }

  void showEditDialog(Map<String, dynamic> servis) {
    namaController.text = servis['nama'];
    nomorController.text = servis['no_hp'];
    modelController.text = servis['model'];
    keluhanController.text = servis['keluhan'];
    nominalController.text = currencyFormatter.format(servis['biaya']);

    selectedKategori = servis['kategori'];
    selectedStatus = servis['status'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A22),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text(
                "Edit Servis",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: buildInputDecoration("Nama", Icons.person),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: nomorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: buildInputDecoration(
                        "Nomor Telepon",
                        Icons.phone,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: modelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: buildInputDecoration("Model", Icons.devices),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: keluhanController,
                      style: const TextStyle(color: Colors.white),
                      decoration: buildInputDecoration(
                        "Keluhan",
                        Icons.warning_amber_rounded,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: buildInputDecoration(
                        "Biaya",
                        Icons.attach_money,
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      dropdownColor: const Color(0xFF1A1A22),
                      style: const TextStyle(color: Colors.white),
                      items: kategoriList.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dialogSetState(() {
                          selectedKategori = value!;
                        });
                      },
                      decoration: buildInputDecoration(
                        "Kategori",
                        Icons.phone_android,
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF1A1A22),
                      style: const TextStyle(color: Colors.white),
                      items: statusList.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dialogSetState(() {
                          selectedStatus = value!;
                        });
                      },
                      decoration: buildInputDecoration(
                        "Status",
                        Icons.category,
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),

                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                  onPressed: () async {
                    await db.updateServis(servis['id'], {
                      'nama': namaController.text.trim(),
                      'no_hp': nomorController.text.trim(),
                      'model': modelController.text.trim(),
                      'keluhan': keluhanController.text.trim(),
                      'kategori': selectedKategori,
                      'biaya':
                          int.tryParse(
                            nominalController.text
                                .replaceAll(".", "")
                                .replaceAll("Rp ", ""),
                          ) ??
                          0,
                      'status': selectedStatus,
                    });

                    await loadServis();

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadServis();
  }

  // Helper method untuk menampilkan detail servis
  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label : ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value?.toString() ?? "-",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void showDetailServis(Map<String, dynamic> servis) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A22),

          title: Text(
            servis['nama'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailRow("No HP", servis['no_hp']),
                detailRow("Model", servis['model']),
                detailRow("Kategori", servis['kategori']),
                detailRow("Keluhan", servis['keluhan']),
                detailRow("Diagnosa", servis['diagnosa'] ?? "-"),
                detailRow("Status", servis['status']),
                detailRow(
                  "Biaya",
                  "Rp ${currencyFormatter.format(servis['biaya'])}",
                ),
                detailRow(
                  "Tanggal",
                  DateFormat(
                    "dd/MM/yyyy HH:mm",
                  ).format(DateTime.parse(servis['tanggal_masuk'])),
                ),
              ],
            ),
          ),

          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);

                // TODO: Edit Data
                showEditDialog(servis);
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),

            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Hapus Data"),
                      content: const Text("Yakin ingin menghapus data ini?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("Hapus"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await db.deleteServis(servis['id']);

                  await loadServis();

                  if (mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data berhasil dihapus")),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Future<void> simpanCatatan() async {
    String nama = namaController.text.trim();
    String nomor = nomorController.text.trim();
    String model = modelController.text.trim();
    String nominalText = nominalController.text
        .trim()
        .replaceAll("Rp ", "")
        .replaceAll(".", "");
    int nominal = int.tryParse(nominalText) ?? 0;

    if (nama.isEmpty || nomor.isEmpty || model.isEmpty || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi dengan benar")),
      );
      return;
    }

    // Simpan catatan ke database atau state management
    await db.tambahServis({
      'nama': nama,
      'no_hp': nomor,
      'model': model,
      'keluhan': keluhanController.text.trim(),
      'kategori': selectedKategori,
      'biaya': nominal,
      'status': selectedStatus,
      'tanggal_masuk': DateTime.now().toIso8601String(),
    });
    await loadServis();

    // Contoh: CatatanServis baruCatatan = CatatanServis(nama, nomor, model, nominal, selectedKategori, selectedStatus);
    // Database.saveCatatan(baruCatatan);

    // Bersihkan form setelah simpan
    namaController.clear();
    nomorController.clear();
    modelController.clear();
    nominalController.clear();
    keluhanController.clear();
    setState(() {
      selectedKategori = "Others";
      selectedStatus = "Undone";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Catatan berhasil disimpan")));
  }

  void tampilkanForm() {
    namaController.clear();
    nomorController.clear();
    modelController.clear();
    nominalController.clear();
    keluhanController.clear();
    setState(() {
      selectedKategori = "Others";
      selectedStatus = "Undone";
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const Text(
                      "Tambah Catatan Servis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nominal field
                    const SizedBox(height: 16),

                    TextField(
                      controller: namaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nama",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nomorController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nomor Telepon",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.add_ic_call_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: modelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Model",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.app_registration_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: keluhanController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Keluhan",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.announcement_rounded,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'id',
                          symbol: '',
                          decimalDigits: 0,
                        ),
                      ],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nominal",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixText: "Rp ",
                        prefixStyle: const TextStyle(color: Color(0xFF6C63FF)),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      dropdownColor: const Color(0xFF1A1A22),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: const Color(0xFF6C63FF),
                      items: kategoriList.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),
                      onChanged: (value) {
                        modalSetState(() {
                          selectedKategori = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_android,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF1A1A22),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: const Color(0xFF6C63FF),
                      items: statusList.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        modalSetState(() {
                          selectedStatus = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Status",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.category,
                          color: Color(0xFF6C63FF),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);

                          simpanCatatan();
                        },
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 65),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A22),
        elevation: 0,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Cari pelanggan...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  searchServis(value);
                },
              )
            : const Text(
                "Catatan Servis",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Diagnose()),
              );
            },
          ),
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),

          if (isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchController.clear();
                });

                loadServis();
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
          ),
        ],
      ),
      body: servisList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada data servis",
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: servisList.length,
              itemBuilder: (context, index) {
                final servis = servisList[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showDetailServis(servis);
                  },
                  child: Card(
                    color: const Color(0xFF1A1A22),
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              servis['nama'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: servis['status'] == "Done"
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              servis['status'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${servis['model']} • ${servis['kategori'].toLowerCase()}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        "Rp ${currencyFormatter.format(servis['biaya'])}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: tampilkanForm,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
