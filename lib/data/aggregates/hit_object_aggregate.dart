import 'package:diffcalc_graph/data/aggregates/timed_aggregate.dart';
import 'package:diffcalc_graph/data/taiko_difficulty_hit_object.dart';
import 'package:diffcalc_graph/data/timed.dart';

/// An aggregate that contains [TaikoDifficultyHitObject]s, either directly
/// or indirectly
abstract class HitObjectAggregate<ChildrenType extends Timed>
    extends LinkedTimedAggregate<ChildrenType> {
  HitObjectAggregate({required super.previous});

  TaikoDifficultyHitObject get firstHitObject;

  Iterable<TaikoDifficultyHitObject> get allHitObjects;
}

/// A simple [HitObjectAggregate] that contains [TaikoDifficultyHitObject]s
/// directly
class SimpleHitObjectAggregate
    extends HitObjectAggregate<TaikoDifficultyHitObject> {
  SimpleHitObjectAggregate({required super.previous});

  @override
  TaikoDifficultyHitObject get firstHitObject => elements.first;

  @override
  Iterable<TaikoDifficultyHitObject> get allHitObjects => elements;
}

/// A composite [HitObjectAggregate] that contains [HitObjectAggregate]s
class CompositeHitObjectAggregate
    extends HitObjectAggregate<HitObjectAggregate> {
  CompositeHitObjectAggregate({required super.previous});

  @override
  TaikoDifficultyHitObject get firstHitObject => elements.first.firstHitObject;

  @override
  Iterable<TaikoDifficultyHitObject> get allHitObjects =>
      elements.expand((element) => element.allHitObjects);
}

/// [SimpleHitObjectAggregate] mixed in with [LinkedFlatTimedAggregate]
class FlatSimpleHitObjectAggregate extends SimpleHitObjectAggregate
    with FlatTimedAggregate<TaikoDifficultyHitObject> {
  FlatSimpleHitObjectAggregate({required super.previous});
}

/// [CompositeHitObjectAggregate] mixed in with [LinkedFlatTimedAggregate]
class FlatCompositeHitObjectAggregate extends CompositeHitObjectAggregate
    with FlatTimedAggregate<HitObjectAggregate> {
  FlatCompositeHitObjectAggregate({required super.previous});
}
