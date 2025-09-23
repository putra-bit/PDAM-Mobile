import 'package:flutter/material.dart';
import 'package:pdam_mobile/Backend/pembayaran_service.dart';

class CekTagihanPage extends StatefulWidget {
  const CekTagihanPage({super.key});

  @override
  State<CekTagihanPage> createState() => _CekTagihanPageState();
}

class _CekTagihanPageState extends State<CekTagihanPage> {
  final _controller = TextEditingController();
  final _service = PembayaranService();

  Map<String, dynamic>? data;
  bool isLoading = false;

  void _cekData() async {
    setState(() {
      isLoading = true;
    });

    final result =
        await _service.cekTagihanLengkap(int.parse(_controller.text));

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cek Tagihan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nomor Sambungan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cekData,
              child: const Text("Cek Data"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (data != null && data!['status'] == true) ...[
              Text("Nama: ${data!['pelanggan']['nama']}"),
              Text("Alamat: ${data!['pelanggan']['alamat']}"),
              const SizedBox(height: 12),
              Text("Total Bayar: Rp ${data!['total_bayar']}"),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: data!['tagihan'].length,
                  itemBuilder: (context, index) {
                    final t = data!['tagihan'][index];
                    return ListTile(
                      title: Text("Periode: ${t['periode']}"),
                      subtitle: Text("Pakai: ${t['pakai']} m³"),
                      trailing: Text(t['status_pembayaran']),
                    );
                  },
                ),
              ),
            ],
            if (data != null && data!['status'] == false) ...[
              Text(data!['message']),
            ]
          ],
        ),
      ),
    );
  }
}
