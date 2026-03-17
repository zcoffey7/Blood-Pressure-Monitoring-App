import 'dart:collection';

/// Real-time systolic peak detector for bandpass-filtered PPG signals.
///
/// Algorithm overview:
///   1. An adaptive amplitude envelope tracks typical peak height via
///      exponential decay, updated on each confirmed peak.
///   2. A three-state machine (waiting → rising → refractory) finds
///      local maxima that exceed a fraction of the envelope.
///   3. A refractory period enforces physiological limits (30–220 BPM).
///   4. Heart rate is derived from the median of the last [_ibiBufferSize]
///      inter-beat intervals for robustness against occasional outliers.
class PeakDetector {
  final double _sampleRate;

  late final int _refractorySamples; // min IBI (220 BPM)
  late final int _maxIbiSamples; // max IBI (30 BPM)

  // ── Adaptive threshold ──────────────────────────────────────────
  double _envelope = 0.0;
  static const double _envelopeDecay = 0.995;
  static const double _thresholdRatio = 0.4;
  static const double _peakBlend = 0.2;

  // ── State machine ───────────────────────────────────────────────
  _State _state = _State.waiting;
  double _candidateAmp = 0.0;
  int _candidateIdx = 0;
  int _sampleIdx = 0;
  int _lastPeakIdx = -1;

  // ── IBI ring buffer ─────────────────────────────────────────────
  static const int _ibiBufferSize = 8;
  final _ibis = Queue<int>();

  int? _bpm;

  PeakDetector({required double sampleRate}) : _sampleRate = sampleRate {
    _refractorySamples = (sampleRate * 60.0 / 220.0).round();
    _maxIbiSamples = (sampleRate * 60.0 / 30.0).round();
  }

  /// Current heart rate estimate, or `null` if insufficient beats detected.
  int? get heartRateBpm => _bpm;

  /// Feed one bandpass-filtered sample into the detector.
  void processSample(double value) {
    _sampleIdx++;
    _envelope *= _envelopeDecay;

    final thresh = _envelope * _thresholdRatio;

    switch (_state) {
      case _State.waiting:
        if (_envelope == 0.0 && value > 0) {
          _envelope = value * 2.0;
          break;
        }
        if (value > thresh && _envelope > 0) {
          _state = _State.rising;
          _candidateAmp = value;
          _candidateIdx = _sampleIdx;
        }

      case _State.rising:
        if (value > _candidateAmp) {
          _candidateAmp = value;
          _candidateIdx = _sampleIdx;
        } else if (value < _candidateAmp * 0.7) {
          _confirmPeak(_candidateIdx, _candidateAmp);
          _state = _State.refractory;
        }

      case _State.refractory:
        if (_sampleIdx - _lastPeakIdx >= _refractorySamples) {
          _state = _State.waiting;
        }
    }

    if (_lastPeakIdx > 0 && _sampleIdx - _lastPeakIdx > _maxIbiSamples) {
      _bpm = null;
      _ibis.clear();
    }
  }

  void _confirmPeak(int idx, double amp) {
    _envelope = _envelope * (1.0 - _peakBlend) + amp * _peakBlend;

    if (_lastPeakIdx > 0) {
      final ibi = idx - _lastPeakIdx;
      if (ibi >= _refractorySamples && ibi <= _maxIbiSamples) {
        _ibis.addLast(ibi);
        if (_ibis.length > _ibiBufferSize) _ibis.removeFirst();
        _recalcBpm();
      }
    }
    _lastPeakIdx = idx;
  }

  void _recalcBpm() {
    if (_ibis.length < 2) {
      _bpm = null;
      return;
    }
    final sorted = _ibis.toList()..sort();
    final mid = sorted.length ~/ 2;
    final median = sorted.length.isOdd
        ? sorted[mid].toDouble()
        : (sorted[mid - 1] + sorted[mid]) / 2.0;

    _bpm = (60.0 * _sampleRate / median).round();
  }

  void reset() {
    _envelope = 0.0;
    _state = _State.waiting;
    _candidateAmp = 0.0;
    _candidateIdx = 0;
    _sampleIdx = 0;
    _lastPeakIdx = -1;
    _ibis.clear();
    _bpm = null;
  }
}

enum _State { waiting, rising, refractory }
