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

  final _sampleBuffer = Queue<double>();
  int _packetCount = 0;
  int _sampleCount = 0;
  int _gapCount = 0;
  int? _latestValue;
  bool _isPaused = false;
  bool _isDisposed = false;

  StreamSubscription<PpgPacket>? _ppgSub;
  StreamSubscription<PacketGap>? _gapSub;

  PpgController(this._repository) {
    _startListening();
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
    notifyListeners();
    await _repository.pauseNotifications();
  }

  Future<void> resume() async {
    _isPaused = false;
    notifyListeners();
    await _repository.resumeNotifications();
  }

  // ── Clear ────────────────────────────────────────────────────────

  void clear() {
    _sampleBuffer.clear();
    _packetCount = 0;
    _sampleCount = 0;
    _gapCount = 0;
    _latestValue = null;
    notifyListeners();
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

    notifyListeners();
  }

  void _onGap(PacketGap gap) {
    if (_isDisposed) return;
    _gapCount += gap.missedPackets;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ppgSub?.cancel();
    _gapSub?.cancel();
    super.dispose();
  }
}
