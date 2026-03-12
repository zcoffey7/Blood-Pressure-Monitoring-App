import 'dart:typed_data';

import '../constants/ble_constants.dart';

/// A single PPG notification packet parsed from the ESP32 binary format.
///
/// Wire format (all little-endian):
///   [0..3]  packet_seq   – uint32 sequence number
///   [4..5]  sample_count – uint16 number of samples
///   [6..]   samples      – sample_count × uint32
class PpgPacket {
  final int packetSeq;
  final List<int> samples;

  const PpgPacket({required this.packetSeq, required this.samples});

  int get sampleCount => samples.length;

  /// Parse raw BLE notification bytes into a [PpgPacket].
  /// Returns `null` if the data is malformed.
  static PpgPacket? tryParse(List<int> raw) {
    if (raw.length < BleConstants.packetHeaderBytes) return null;

    final bytes = Uint8List.fromList(raw);
    final view = ByteData.sublistView(bytes);

    final packetSeq = view.getUint32(0, Endian.little);
    final sampleCount = view.getUint16(4, Endian.little);

    if (sampleCount > BleConstants.maxSamplesPerPacket) return null;

    final expectedLength =
        BleConstants.packetHeaderBytes + (BleConstants.sampleBytes * sampleCount);
    if (bytes.length != expectedLength) return null;

    final samples = List<int>.generate(sampleCount, (i) {
      final offset = BleConstants.packetHeaderBytes + (i * BleConstants.sampleBytes);
      return view.getUint32(offset, Endian.little);
    });

    return PpgPacket(packetSeq: packetSeq, samples: samples);
  }

  @override
  String toString() =>
      'PpgPacket(seq=$packetSeq, samples=$sampleCount)';
}
