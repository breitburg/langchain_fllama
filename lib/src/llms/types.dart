import 'package:flutter/foundation.dart';
import 'package:langchain_core/llms.dart';

/// {@template fllama_options}
/// Options to pass into the Fllama LLM.
///
/// For a complete documentation of each parameter, see the
/// [Fllama API documentation](https://github.com/Telosnex/fllama).
/// {@endtemplate}
@immutable
class FllamaOptions extends LLMOptions {
  /// {@macro fllama_options}
  const FllamaOptions({
    super.model,
    this.mmproj,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    int? numGpuLayers,
    int? numCtx,
    super.concurrencyLimit,
  })  : _temperature = temperature,
        _maxTokens = maxTokens,
        _topP = topP,
        _frequencyPenalty = frequencyPenalty,
        _presencePenalty = presencePenalty,
        _numGpuLayers = numGpuLayers,
        _numCtx = numCtx;

  final String? mmproj;

  final double? _temperature;
  final int? _maxTokens;
  final double? _topP;
  final double? _frequencyPenalty;
  final double? _presencePenalty;
  final int? _numGpuLayers;
  final int? _numCtx;

  double get temperature => _temperature ?? 0.3;
  int get maxTokens => _maxTokens ?? 512;
  double get topP => _topP ?? 1;
  double get frequencyPenalty => _frequencyPenalty ?? 0;
  double get presencePenalty => _presencePenalty ?? 1.1;
  int get numGpuLayers => _numGpuLayers ?? 99;
  int get numCtx => _numCtx ?? 512;

  @override
  FllamaOptions copyWith({
    String? model,
    int? concurrencyLimit,
    String? mmproj,
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    int? numGpuLayers,
    int? numCtx,
  }) {
    return FllamaOptions(
      model: model ?? this.model,
      mmproj: mmproj ?? this.mmproj,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      numGpuLayers: numGpuLayers ?? this.numGpuLayers,
      numCtx: numCtx ?? this.numCtx,
      concurrencyLimit: concurrencyLimit ?? this.concurrencyLimit,
    );
  }

  @override
  FllamaOptions merge(covariant final FllamaOptions? other) {
    return copyWith(
      model: other?.model,
      mmproj: other?.mmproj,
      temperature: other?.temperature,
      maxTokens: other?.maxTokens,
      topP: other?.topP,
      frequencyPenalty: other?.frequencyPenalty,
      presencePenalty: other?.presencePenalty,
      numGpuLayers: other?.numGpuLayers,
      numCtx: other?.numCtx,
      concurrencyLimit: other?.concurrencyLimit,
    );
  }

  @override
  bool operator ==(covariant final FllamaOptions other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            model == other.model &&
            mmproj == other.mmproj &&
            temperature == other.temperature &&
            maxTokens == other.maxTokens &&
            topP == other.topP &&
            frequencyPenalty == other.frequencyPenalty &&
            presencePenalty == other.presencePenalty &&
            numGpuLayers == other.numGpuLayers &&
            numCtx == other.numCtx;
  }

  @override
  int get hashCode {
    return model.hashCode ^
        mmproj.hashCode ^
        temperature.hashCode ^
        maxTokens.hashCode ^
        topP.hashCode ^
        frequencyPenalty.hashCode ^
        presencePenalty.hashCode ^
        numGpuLayers.hashCode ^
        numCtx.hashCode;
  }
}
