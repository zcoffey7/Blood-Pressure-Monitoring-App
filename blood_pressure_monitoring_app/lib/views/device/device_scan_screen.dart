import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/device_controller.dart';

/// Screen for discovering and connecting to an ESP32 BLE device.
class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  StreamSubscription<List<ScanResult>>? _scanSub;
  List<ScanResult> _results = [];
  bool _connecting = false;
  late final DeviceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<DeviceController>();
    _startScan();
  }

  Future<void> _startScan() async {
    final bluetoothOn = await FlutterBluePlus.adapterState.first;
    if (bluetoothOn != BluetoothAdapterState.on) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable Bluetooth to scan for devices.'),
          ),
        );
      }
      return;
    }

    _scanSub?.cancel();
    _scanSub = _controller.scanResults.listen((results) {
      if (mounted) setState(() => _results = results);
    });

    try {
      await _controller.startScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('permission')
                  ? 'Bluetooth permissions are required to scan for devices. '
                    'Please grant permissions in Settings.'
                  : 'Failed to start scan: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(ScanResult result) async {
    if (_connecting) return;

    setState(() => _connecting = true);

    _controller.selectDevice(result.device);
    final success = await _controller.connect();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _connecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error ?? 'Failed to connect'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _controller.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Device'),
        actions: [
          Consumer<DeviceController>(
            builder: (context, controller, _) {
              return IconButton(
                onPressed: controller.isScanning ? null : _startScan,
                icon: controller.isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: _connecting
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text('Connecting...',
                      style: AppTextStyles.heading3
                          .copyWith(color: colorScheme.onSurface)),
                ],
              ),
            )
          : _results.isEmpty
              ? _buildEmptyState(context)
              : _buildDeviceList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<DeviceController>(
      builder: (context, controller, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.isScanning
                      ? Icons.bluetooth_searching
                      : Icons.bluetooth_disabled,
                  size: 64,
                  color: controller.isScanning
                      ? AppColors.primary
                      : AppColors.disconnected,
                ),
                const SizedBox(height: 24),
                Text(
                  controller.isScanning
                      ? 'Scanning for devices...'
                      : 'No devices found',
                  style: AppTextStyles.heading3
                      .copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.isScanning
                      ? 'Make sure your BP Monitor is powered on and nearby.'
                      : 'Tap the refresh button to scan again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _DeviceTile(
          result: result,
          onTap: () => _connectToDevice(result),
        );
      },
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const _DeviceTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown Device';
    final rssi = result.rssi;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bluetooth,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    result.device.remoteId.toString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            ),
            _SignalIndicator(rssi: rssi),
          ],
        ),
      ),
    );
  }
}

class _SignalIndicator extends StatelessWidget {
  final int rssi;
  const _SignalIndicator({required this.rssi});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (rssi) {
      > -60 => (Icons.signal_cellular_alt, AppColors.connected),
      > -80 => (Icons.signal_cellular_alt_2_bar, AppColors.warning),
      _ => (Icons.signal_cellular_alt_1_bar, AppColors.danger),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text('${rssi}dBm',
            style: AppTextStyles.bodySmall.copyWith(color: color)),
      ],
    );
  }
}
