import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/blood_pressure_controller.dart';
import '../models/blood_pressure_reading.dart';
import 'package:intl/intl.dart';

class LiveTrendChart extends StatelessWidget {
  const LiveTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, child) {
        final readings = controller.historicalReadings;

        if (readings.isEmpty) return _buildNoDataState(context);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Trend',
                  style: AppTextStyles.heading3
                      .copyWith(color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),
              _buildLegend(context),
              const SizedBox(height: 16),
              Expanded(child: _buildChart(context, readings)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, 'Systolic', AppColors.systolic),
        const SizedBox(width: 24),
        _buildLegendItem(context, 'Diastolic', AppColors.diastolic),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 4,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context))),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<BloodPressureReading> readings) {
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    for (int i = 0; i < readings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), readings[i].systolic.toDouble()));
      diastolicSpots
          .add(FlSpot(i.toDouble(), readings[i].diastolic.toDouble()));
    }

    final allValues = [
      ...readings.map((r) => r.systolic),
      ...readings.map((r) => r.diastolic),
    ];
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 10).toDouble();
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 10).toDouble();
    final dividerColor = AppColors.divider(context);
    final labelColor = AppColors.textSecondary(context);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: readings.length > 1 ? readings.length / 6 : 1,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: dividerColor, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: readings.length > 1 ? readings.length / 3 : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < readings.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm')
                          .format(readings[value.toInt()].timestamp),
                      style: AppTextStyles.bodySmall
                          .copyWith(fontSize: 12, color: labelColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 20,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: AppTextStyles.bodySmall
                    .copyWith(fontSize: 12, color: labelColor),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: dividerColor, width: 1),
        ),
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        lineBarsData: [
          _line(systolicSpots, AppColors.systolic),
          _line(diastolicSpots, AppColors.diastolic),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toInt()}',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart,
                size: 64,
                color: AppColors.textHint(context)),
            const SizedBox(height: 16),
            Text('No trend data available yet',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
