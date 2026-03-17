import 'biquad_filter.dart';

/// Real-time PPG signal conditioner using cascaded IIR filters.
///
/// Default filter chain (bandpass 0.5 – 8 Hz):
///   1. 2nd-order Butterworth high-pass @ 0.5 Hz
///      → removes DC offset and slow baseline wander
///   2. 4th-order Butterworth low-pass @ 8 Hz (two cascaded biquads)
///      → removes sensor noise, EMI, and motion artifacts while
///        preserving waveform morphology (dicrotic notch, etc.)
///
/// The 4th-order Butterworth uses Q values of 0.5412 and 1.3066
/// derived from the standard Butterworth pole placement for n = 4.
class PpgSignalProcessor {
  static const double defaultSampleRate = 100.0;
  static const double defaultHighPassHz = 0.5;
  static const double defaultLowPassHz = 8.0;

  late final List<BiquadFilter> _chain;
  bool _primed = false;

  PpgSignalProcessor({
    double sampleRate = defaultSampleRate,
    double highPassHz = defaultHighPassHz,
    double lowPassHz = defaultLowPassHz,
  }) {
    _chain = [
      BiquadFilter.highPass(
        sampleRate: sampleRate,
        cutoffHz: highPassHz,
      ),
      // 4th-order Butterworth LP = two cascaded 2nd-order sections
      BiquadFilter.lowPass(
        sampleRate: sampleRate,
        cutoffHz: lowPassHz,
        q: 0.5412,
      ),
      BiquadFilter.lowPass(
        sampleRate: sampleRate,
        cutoffHz: lowPassHz,
        q: 1.3066,
      ),
    ];
  }

  /// Filter a single sample through the full chain.
  double processSample(double raw) {
    if (!_primed) {
      for (final f in _chain) {
        f.prime(raw);
      }
      _primed = true;
    }
    double v = raw;
    for (final f in _chain) {
      v = f.process(v);
    }
    return v;
  }

  /// Filter a batch of raw ADC samples, returning all filtered values.
  List<double> processBatch(List<int> rawSamples) {
    return rawSamples.map((s) => processSample(s.toDouble())).toList();
  }

  /// Reset all internal filter state. The next sample will re-prime.
  void reset() {
    for (final f in _chain) {
      f.reset();
    }
    _primed = false;
  }
}
