// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';

// class PantauOltScreen extends StatefulWidget {
//   const PantauOltScreen({super.key});

//   @override
//   State<PantauOltScreen> createState() => _PantauOltScreenState();
// }

// class _PantauOltScreenState extends State<PantauOltScreen> {
//   List<dynamic> _listOlt = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOlt();
//   }

//   Future<void> _fetchOlt() async {
//     setState(() => _isLoading = true);
//     final res = await ApiService().get('/owner/olt-status');
//     if (mounted) {
//       setState(() {
//         _listOlt = res ?? [];
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E2C),
//       appBar: AppBar(
//         title: const Text('Status Redaman OLT'),
//         backgroundColor: const Color(0xFF2A2D3E),
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.amber))
//           : RefreshIndicator(
//               onRefresh: _fetchOlt,
//               color: Colors.amber,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(15),
//                 itemCount: _listOlt.length,
//                 itemBuilder: (context, index) {
//                   final olt = _listOlt[index];
//                   // parse ke double buat ngecek kritis apa ngga
//                   final rxVal = double.tryParse(olt['rx_power'].toString().replaceAll(' dBm', '')) ?? 0.0;
//                   final isKritis = rxVal < -25.0;

//                   return Card(
//                     color: const Color(0xFF2A2D3E),
//                     margin: const EdgeInsets.only(bottom: 10),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       leading: CircleAvatar(
//                         backgroundColor: isKritis ? Colors.redAccent.withOpacity(0.2) : Colors.green.withOpacity(0.2),
//                         child: Icon(Icons.router, color: isKritis ? Colors.redAccent : Colors.green),
//                       ),
//                       title: Text('PON ${olt['pon']} - ONU ${olt['onu']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       subtitle: Text(
//                         isKritis ? 'Sinyal Kritis / Redaman Jelek' : 'Sinyal Normal',
//                         style: TextStyle(color: isKritis ? Colors.redAccent : Colors.white54, fontSize: 12),
//                       ),
//                       trailing: Text(
//                         olt['rx_power'],
//                         style: TextStyle(
//                           color: isKritis ? Colors.redAccent : Colors.amber,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }