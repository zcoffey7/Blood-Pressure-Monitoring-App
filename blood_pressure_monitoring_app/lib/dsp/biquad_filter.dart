import 'dart:math';

/// Direct Form II Transposed biquad IIR filter section.
///
/// Transfer function:
///   H(z) = (b0 + b1·z⁻¹ + b2·z⁻²) / (1 + a1·z⁻¹ + a2·z⁻²)
///
/// Coefficients are pre-normalized (a0 = 1).
class BiquadFilter {
  final double b0, b1, b2;
  final double a1, a2;

  double _w1 = 0.0;
  double _w2 = 0.0;

  BiquadFilter({
    required this.b0,
    required this.b1,
    required this.b2,
    required this.a1,
    required this.a2,
  });

  /// Process a single input sample and return the filtered output.
  double process(double x) {
    final y = b0 * x + _w1;
    _w1 = b1 * x - a1 * y + _w2;
    _w2 = b2 * x - a2 * y;
    return y;
  }

  /// Drive the filter to steady state for a constant input [value].
  ///
  /// This eliminates startup transients by running the filter until
  /// the internal state converges, instead of starting from zero.
  void prime(double value, {int iterations = 200}) {
    for (int i = 0; i < iterations; i++) {
      process(value);
    }
  }

  void reset() {
    _w1 = 0.0;
    _w2 = 0.0;
  }

  /// 2nd-order Butterworth low-pass filter.
  ///
  /// [q] defaults to 1/√2 for a standard 2nd-order Butterworth.
  /// Use different Q values when cascading sections for higher-order filters.
  factory BiquadFilter.lowPass({
    required double sampleRate,
    required double cutoffHz,
    double q = 0.7071067811865476,
  }) {
    final omega = 2.0 * pi * cutoffHz / sampleRate;
    final cosW = cos(omega);
    final sinW = sin(omega);
    final alpha = sinW / (2.0 * q);

    final a0 = 1.0 + alpha;
    return BiquadFilter(
      b0: ((1.0 - cosW) / 2.0) / a0,
      b1: (1.0 - cosW) / a0,
      b2: ((1.0 - cosW) / 2.0) / a0,
      a1: (-2.0 * cosW) / a0,
      a2: (1.0 - alpha) / a0,
    );
  }

  /// 2nd-order Butterworth high-pass filter.
  ///
  /// [q] defaults to 1/√2 for a standard 2nd-order Butterworth.
  factory BiquadFilter.highPass({
    required double sampleRate,
    required double cutoffHz,
    double q = 0.7071067811865476,
  }) {
    final omega = 2.0 * pi * cutoffHz / sampleRate;
    final cosW = cos(omega);
    final sinW = sin(omega);
    final alpha = sinW / (2.0 * q);

    final a0 = 1.0 + alpha;
    return BiquadFilter(
      b0: ((1.0 + cosW) / 2.0) / a0,
      b1: (-(1.0 + cosW)) / a0,
      b2: ((1.0 + cosW) / 2.0) / a0,
      a1: (-2.0 * cosW) / a0,
      a2: (1.0 - alpha) / a0,
    );
  }
}
