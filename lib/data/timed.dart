abstract class Timed {
  int get startTime;

  /// The interval between this and the previous instance
  int? get interval;
}

/// A class that adds a back link to the previous instance to [Timed]
/// T is the concrete type
abstract class LinkedTimed<T extends Timed> implements Timed {
  final T? previous;

  LinkedTimed({required this.previous});

  @override
  get interval {
    if (previous == null) {
      return null;
    } else {
      return startTime - previous!.startTime;
    }
  }
}
