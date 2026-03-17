/// Compile-time feature flags.
///
/// Flip [enableDsp] to `true` to activate bandpass filtering,
/// peak detection, and heart-rate estimation on the PPG stream.
class FeatureFlags {
  FeatureFlags._();

  static const bool enableDsp = false;
}
