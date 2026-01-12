import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/blood_pressure_controller.dart';
import '../models/blood_pressure_reading.dart';
import 'package:intl/intl.dart';

/// Widget displaying live blood pressure trend chart
/// Follows SRP - Only responsible for displaying BP trend visualization
class LiveTrendChart extends StatelessWidget {
  const LiveTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BloodPressureController>(
      builder: (context, controller, child) {
        final readings = controller.historicalReadings;

        if (readings.isEmpty) {
          return _buildNoDataState();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart Title
              Text(
                'Live Trend',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              
              // Chart Legend
              _buildLegend(),
              const SizedBox(height: 16),
              
              // Chart
              Expanded(
                child: _buildChart(readings),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Systolic', AppColors.systolic),
        const SizedBox(width: 24),
        _buildLegendItem('Diastolic', AppColors.diastolic),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<BloodPressureReading> readings) {
    // Prepare data points
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];

    // Use index as x-axis for simplicity (we'll show time labels)
    for (int i = 0; i < readings.length; i++) {
      systolicSpots.add(FlSpot(i.toDouble(), readings[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(i.toDouble(), readings[i].diastolic.toDouble()));
    }

    // Calculate min and max for y-axis with padding
    final allValues = [
      ...readings.map((r) => r.systolic),
      ...readings.map((r) => r.diastolic),
    ];
    final minY = (allValues.reduce((a, b) => a < b ? a : b) - 10).toDouble();
    final maxY = (allValues.reduce((a, b) => a > b ? a : b) + 10).toDouble();

    return LineChart(
      LineChartData(
        // Grid
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: readings.length > 1 ? readings.length / 6 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
        
        // Title
        titlesData: FlTitlesData(
          show: true,
          // Right side titles (disabled)
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // Top titles (disabled)
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // Bottom titles (time)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: readings.length > 1 ? readings.length / 3 : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < readings.length) {
                  final reading = readings[value.toInt()];
                  final timeStr = DateFormat('HH:mm').format(reading.timestamp);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      timeStr,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Left titles (BP values)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Border
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        
        // Y-axis range
        minY: minY,
        maxY: maxY,
        
        // X-axis range
        minX: 0,
        maxX: (readings.length - 1).toDouble(),
        
        // Line chart data
        lineBarsData: [
          // Systolic line
          LineChartBarData(
            spots: systolicSpots,
            isCurved: true,
            color: AppColors.systolic,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.systolic,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
          // Diastolic line
          LineChartBarData(
            spots: diastolicSpots,
            isCurved: true,
            color: AppColors.diastolic,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.diastolic,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
        
        // Touch interaction
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()}',
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No trend data available yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

