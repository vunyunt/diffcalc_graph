import 'package:diffcalc_graph/data/timed.dart';

class LinkedTimedAggregate<DataType extends Timed>
    extends LinkedTimed<LinkedTimedAggregate<DataType>> {
  final List<DataType> elements = [];

  LinkedTimedAggregate({super.previous});

  @override
  int get startTime => elements.first.startTime;
}

class LinkedFlatTimedAggregate<DataType extends Timed>
    extends LinkedTimedAggregate<DataType> {
  int? get childrenInterval {
    if (elements.length <= 2) {
      return null;
    }

    return elements[1].startTime - elements[0].startTime;
  }
}
