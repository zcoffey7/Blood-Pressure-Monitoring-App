import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../controllers/ppg_controller.dart';

class LiveTrendChart extends StatelessWidget {
  const LiveTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PpgController>(
      builder: (context, controller, child) {
        final samples = controller.recentSamples;

        if (samples.isEmpty) return _buildNoDataState(context);

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
              Row(
                children: [
                  Text('PPG Waveform',
                      style: AppTextStyles.heading3.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const Spacer(),
                  Text('${controller.sampleBufferLength} pts',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary(context))),
                  const SizedBox(width: 8),
                  _ExpandButton(controller: controller),
                ],
              ),
              const SizedBox(height: 12),
              _buildLegend(context),
              const SizedBox(height: 12),
              Expanded(child: PpgChart(samples: samples)),
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
        Container(
          width: 20,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text('Raw PPG Signal',
            style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context))),
      ],
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
            Icon(Icons.sensors_off,
                size: 64, color: AppColors.textHint(context)),
            const SizedBox(height: 16),
            Text('No PPG data yet',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Connect to the sensor to see live data',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textHint(context)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final PpgController controller;
  const _ExpandButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.open_in_full_rounded, size: 20),
      tooltip: 'Full-screen view',
      color: AppColors.textSecondary(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: const _FullScreenChart(),
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenChart extends StatelessWidget {
  const _FullScreenChart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PPG Waveform'),
        actions: [
          Consumer<PpgController>(
            builder: (context, controller, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${controller.sampleBufferLength} samples',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Consumer<PpgController>(
            builder: (context, controller, _) {
              final samples = controller.samples;
              if (samples.isEmpty) {
                return Center(
                  child: Text('No data',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textSecondary(context))),
                );
              }
              return PpgChart(samples: samples);
            },
          ),
        ),
      ),
    );
  }
}

/// Shared chart widget used by both inline and full-screen views.
class PpgChart extends StatelessWidget {
  final List<double> samples;
  const PpgChart({super.key, required this.samples});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < samples.length; i++) {
      spots.add(FlSpot(i.toDouble(), samples[i]));
    }

    double minY = samples.first;
    double maxY = samples.first;
    for (final v in samples) {
      if (v < minY) minY = v;
      if (v > maxY) maxY = v;
    }
    final range = maxY - minY;
    final padding = range > 0 ? range * 0.1 : 100;
    minY -= padding;
    maxY += padding;

    final dividerColor = AppColors.divider(context);

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 0 ? range / 4 : 100,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: dividerColor, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: dividerColor, width: 1),
        ),
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: (samples.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
