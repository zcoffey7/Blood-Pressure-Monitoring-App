import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/ppg_packet.dart';
import '../repositories/ble_device_repository.dart';
import '../services/bluetooth_service.dart';

/// Manages live PPG data from the ESP32 sensor board.
///
/// Maintains a rolling buffer of recent raw samples for chart rendering
/// and exposes stats (latest value, packet/sample counts, gaps).
class PpgController extends ChangeNotifier {
  final BleDeviceRepository _repository;

  static const int maxBufferSize = 1500;
  static const int inlineWindowSize = 300;

  static const _uiInterval = Duration(milliseconds: 16); // ~60 Hz

  final _sampleBuffer = Queue<double>();
  int _packetCount = 0;
  int _sampleCount = 0;
  int _gapCount = 0;
  int? _latestValue;
  bool _isPaused = false;
  bool _isDisposed = false;
  bool _dirty = false;
  Timer? _uiTimer;

  StreamSubscription<PpgPacket>? _ppgSub;
  StreamSubscription<PacketGap>? _gapSub;

  PpgController(this._repository) {
    _startListening();
    _uiTimer = Timer.periodic(_uiInterval, (_) {
      if (_dirty && !_isDisposed) {
        _dirty = false;
        super.notifyListeners();
      }
    });
  }

  // ── Getters ──────────────────────────────────────────────────────

  List<double> get samples => List.unmodifiable(_sampleBuffer);
  List<double> get recentSamples {
    if (_sampleBuffer.length <= inlineWindowSize) {
      return List.unmodifiable(_sampleBuffer);
    }
    return List.unmodifiable(
        _sampleBuffer.toList().sublist(_sampleBuffer.length - inlineWindowSize));
  }

  int get sampleBufferLength => _sampleBuffer.length;
  int? get latestValue => _latestValue;
  int get packetCount => _packetCount;
  int get totalSampleCount => _sampleCount;
  int get gapCount => _gapCount;
  bool get isPaused => _isPaused;
  bool get hasData => _sampleBuffer.isNotEmpty;

  // ── Pause / Resume ───────────────────────────────────────────────

  Future<void> pause() async {
    _isPaused = true;
    _notifyNow();
    await _repository.pauseNotifications();
  }

  Future<void> resume() async {
    _isPaused = false;
    _notifyNow();
    await _repository.resumeNotifications();
  }

  // ── Clear ────────────────────────────────────────────────────────

  void clear() {
    _sampleBuffer.clear();
    _packetCount = 0;
    _sampleCount = 0;
    _gapCount = 0;
    _latestValue = null;
    _notifyNow();
  }

  // ── Internal ─────────────────────────────────────────────────────

  void _startListening() {
    _ppgSub = _repository.ppgStream.listen(_onPacket);
    _gapSub = _repository.gapStream.listen(_onGap);
  }

  void _onPacket(PpgPacket packet) {
    if (_isDisposed || _isPaused) return;

    _packetCount++;
    _sampleCount += packet.sampleCount;

    for (final sample in packet.samples) {
      _sampleBuffer.addLast(sample.toDouble());
      if (_sampleBuffer.length > maxBufferSize) {
        _sampleBuffer.removeFirst();
      }
    }

    if (packet.samples.isNotEmpty) {
      _latestValue = packet.samples.last;
    }

    _dirty = true;
  }

  void _onGap(PacketGap gap) {
    if (_isDisposed) return;
    _gapCount += gap.missedPackets;
    _dirty = true;
  }

  void _notifyNow() {
    if (!_isDisposed) {
      _dirty = false;
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _uiTimer?.cancel();
    _ppgSub?.cancel();
    _gapSub?.cancel();
    super.dispose();
  }
}
