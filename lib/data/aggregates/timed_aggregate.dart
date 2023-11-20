import 'package:diffcalc_graph/data/timed.dart';

class TimedAggregate<DataType extends Timed> with Timed {
  final List<DataType> elements = [];

  @override
  int get startTime => elements.first.startTime;
}

class FlatTimedAggregate<DataType extends Timed>
    extends TimedAggregate<DataType> {
  int? get childrenInterval {
    if (elements.length <= 2) {
      return null;
    }

    return elements[1].startTime - elements[0].startTime;
  }
}
