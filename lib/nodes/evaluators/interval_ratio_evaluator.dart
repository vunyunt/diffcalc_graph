import 'dart:math';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/data/indexed.dart';
import 'package:diffcalc_graph/nodes/ui_node.dart';

import '../../data/timed.dart';

class IntervalRatioEvaluator extends Node with UiNodeMixin {
  late final InPort<Indexed<int, Timed>, IntervalRatioEvaluator> indexedInput;

  late final OutPort<Indexed<int, double>, IntervalRatioEvaluator>
      indexedOutput;

  IntervalRatioEvaluator(super.graph, {super.id});

  /// Multiplier for a given denominator term.
  double _termPenalty(
      double ratio, int denominator, double power, double multiplier) {
    return -multiplier * pow(cos(denominator * pi * ratio), power);
  }

  /// Gives a bonus for target ratio using a bell-shaped function.
  double _targetedBonus(
      double ratio, double targetRatio, double width, double multiplier) {
    return multiplier * exp(e * -(pow(ratio - targetRatio, 2) / pow(width, 2)));
  }

  /// Calculate difficulty from interval ratio
  double _ratioDifficulty(double ratio, int terms) {
    // Sum of n = 8 terms of periodic penalty. A more common denominator will be penalized multiple time, hence
    // simpler rhythm change will be penalized more.
    // Note that to penalize 1/4 properly, a power-of-two n is required.
    double difficulty = 0;

    for (int i = 1; i <= terms; ++i) {
      difficulty += _termPenalty(ratio, i, 2, 1);
    }

    difficulty += terms;

    // Give bonus to near-1 ratios
    difficulty += _targetedBonus(ratio, 1, 0.5, 1);

    // Penalize ratios that are VERY near 1
    difficulty -= _targetedBonus(ratio, 1, 0.3, 1);

    // Penalize 1/2s specifically
    difficulty -= _targetedBonus(ratio, 0.5, 0.1, 0.2);

    return difficulty / sqrt(8);
  }

  @override
  Iterable<InPort<dynamic, Node>> createInPorts() {
    indexedInput = InPort(
        node: this,
        name: 'Input',
        onDataStreamAvailable: (eventsDataStream) {
          Indexed<int, Timed>? previousEvent;

          eventsDataStream.listen((event) {
            if (previousEvent?.value.interval == null) {
              previousEvent = event;
              return;
            }

            final ratio =
                event.value.interval! / previousEvent!.value.interval!;

            sendTo(indexedOutput,
                Indexed(event.index, _ratioDifficulty(ratio, 8)));
          });
        });

    return [indexedInput];
  }

  @override
  Iterable<OutPort<dynamic, Node>> createOutPorts() {
    indexedOutput = OutPort(node: this, name: 'Output');

    return [indexedOutput];
  }

  @override
  String get typeName => "IntervalRatioEvaluator";
}
