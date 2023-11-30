import 'package:diffcalc_graph/data/timed.dart';

class LinkedTimedAggregate<DataType extends Timed>
    extends LinkedTimed<LinkedTimedAggregate<DataType>> {
  final List<DataType> elements = [];

  LinkedTimedAggregate({required super.previous});

  @override
  int get startTime => elements.first.startTime;
}

/// A mixin on [LinkedTimedAggregate] that requires that elements are flat-timed.
/// A getter is defined for [childrenInterval]
mixin FlatTimedAggregate<DataType extends Timed>
    on LinkedTimedAggregate<DataType> {
  int? get childrenInterval {
    if (elements.length <= 2) {
      return null;
    }

    return elements[1].startTime - elements[0].startTime;
  }
}

/// A defined [LinkedTimedAggregate] class with the [FlatTimedAggregate] mixin
class LinkedFlatTimedAggregate<DataType extends Timed>
    extends LinkedTimedAggregate<DataType> with FlatTimedAggregate<DataType> {
  LinkedFlatTimedAggregate({required super.previous});
}
