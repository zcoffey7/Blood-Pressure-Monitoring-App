import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/device_controller.dart';
import '../models/device_connection.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceController>(
      builder: (context, controller, child) {
        final connection = controller.connection;

        if (connection == null) return _buildLoading(context);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildConnectionIcon(connection),
              const SizedBox(width: 12),
              Text(
                connection.isConnected ? 'Connected' : 'Disconnected',
                style: AppTextStyles.connectionStatus
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const Spacer(),
              _buildBatteryIndicator(connection),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Row(
        children: [
          const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Loading...',
              style: AppTextStyles.connectionStatus
                  .copyWith(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildConnectionIcon(DeviceConnection connection) {
    final color =
        connection.isConnected ? AppColors.connected : AppColors.disconnected;
    IconData icon;
    switch (connection.connectionType) {
      case ConnectionType.bluetooth:
        icon = Icons.bluetooth_connected;
        break;
      case ConnectionType.wifi:
        icon = Icons.wifi;
        break;
      case ConnectionType.offline:
        icon = Icons.cloud_off;
        break;
    }
    return Icon(icon, color: color, size: 24);
  }

  Widget _buildBatteryIndicator(DeviceConnection connection) {
    Color batteryColor;
    switch (connection.batteryStatus) {
      case BatteryStatus.high:
        batteryColor = AppColors.batteryHigh;
        break;
      case BatteryStatus.medium:
        batteryColor = AppColors.batteryMedium;
        break;
      case BatteryStatus.low:
        batteryColor = AppColors.batteryLow;
        break;
    }

    return Row(
      children: [
        Icon(Icons.battery_std, color: batteryColor, size: 24),
        const SizedBox(width: 4),
        Text('${connection.batteryLevel}%',
            style: AppTextStyles.connectionStatus
                .copyWith(color: batteryColor)),
      ],
    );
  }
}
