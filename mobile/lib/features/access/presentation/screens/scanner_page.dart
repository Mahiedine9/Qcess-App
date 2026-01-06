import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_bloc.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_event.dart';
import 'package:mobile/features/access/logic/bloc/scan/access_state.dart';
import 'package:mobile/features/access/presentation/widgets/access_result_dialog.dart';
import 'package:mobile/features/access/presentation/widgets/scannerWidget.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR Code'), centerTitle: true),
      body: BlocConsumer<AccessBloc, AccessState>(
        listener: (context, state) {
          if (state is AccessSuccess) {
            final accessBloc = context.read<AccessBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AccessResultDialog(
                granted: true,
                zoneName: state.response.zoneName,
                reason: state.response.reason,
                onClose: () {
                  Navigator.of(dialogContext).pop();
                  accessBloc.add(ResetAccessEvent());
                },
              ),
            );
          } else if (state is AccessDenied) {
            final accessBloc = context.read<AccessBloc>();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AccessResultDialog(
                granted: false,
                zoneName: state.response.zoneName,
                reason: state.response.reason,
                onClose: () {
                  Navigator.of(dialogContext).pop();
                  accessBloc.add(ResetAccessEvent());
                },
              ),
            );
          } else if (state is AccessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            context.read<AccessBloc>().add(ResetAccessEvent());
          }
        },
        builder: (context, state) {
          if (state is AccessScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Vérification en cours...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Scanner un QR Code',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Placez le QR code dans le cadre pour scanner',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerWidget(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ouvrir le scanner'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
