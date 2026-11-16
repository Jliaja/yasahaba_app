// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../../services/api_service.dart';

// class ScanSetoranScreen extends StatefulWidget {
//   const ScanSetoranScreen({super.key});

//   @override
//   State<ScanSetoranScreen> createState() => _ScanSetoranScreenState();
// }

// class _ScanSetoranScreenState extends State<ScanSetoranScreen> {
//   bool _isProcessing = false;
//   final MobileScannerController _scannerController = MobileScannerController();

//   Future<void> _prosesQrSetoran(String tokenQr) async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);

//     // ngirim token qr ke laravel buat diverifikasi
//     final res = await ApiService().post('/owner/acc-setoran', body: {
//       'penagih_id': 1, // aslinya backend lu harusnya ngebongkar payload tokenQr ini buat dapet ID nya
//       'token_verifikasi': tokenQr,
//       'jumlah_disetor': 0 // logic backend lu yang bakal ngitung validasinya
//     });

//     if (res != null && mounted) {
//       _scannerController.stop();
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           backgroundColor: const Color(0xFF2A2D3E),
//           title: const Text('Setoran Valid ✅', style: TextStyle(color: Colors.green)),
//           content: const Text('Duit udah di-acc masuk ke sistem brankas. Suruh penagihnya balik cuci muka sono.', style: TextStyle(color: Colors.white70)),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // tutup dialog
//                 Navigator.pop(context); // balik ke dashboard
//               },
//               child: const Text('Mantap'),
//             )
//           ],
//         )
//       );
//     } else {
//       setState(() => _isProcessing = false);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Code kaga valid blok, cek lagi!')));
//     }
//   }

//   @override
//   void dispose() {
//     _scannerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Scan QR Penagih'),
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             controller: _scannerController,
//             onDetect: (capture) {
//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 if (barcode.rawValue != null) {
//                   _prosesQrSetoran(barcode.rawValue!);
//                   break;
//                 }
//               }
//             },
//           ),
//           // Bikin overlay target kotak scan
//           Center(
//             child: Container(
//               width: 250,
//               height: 250,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.amber, width: 3),
//                 borderRadius: BorderRadius.circular(20)
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 50,
//             left: 0,
//             right: 0,
//             child: const Text('Arahin ke HP Penagih lu', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16)),
//           ),
//           if (_isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(child: CircularProgressIndicator(color: Colors.amber)),
//             )
//         ],
//       ),
//     );
//   }
// }