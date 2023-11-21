import 'package:diffcalc_graph/data/collection/limited_capacity_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Element insertion & overwriting test', () {
    LimitedCapacityQueue<int> q = LimitedCapacityQueue(3);

    q.add(1);
    expect(q.first, 1);
    expect(q.length, 1);
    q.add(2);
    expect(q.first, 1);
    expect(q.length, 2);
    q.add(3);
    expect(q.first, 1);
    expect(q.length, 3);
    q.add(4);
    expect(q.first, 2);
    expect(q.length, 3);
  });

  test('Element popping test', () {
    LimitedCapacityQueue<int> q = LimitedCapacityQueue(3);

    q.add(1);
    q.add(2);
    q.add(3);

    expect(q.removeFirst(), 1);
    expect(q.first, 2);

    q.add(4);
    q.add(5); // 2 should be overwritten here

    expect(q.removeFirst(), 3);
    expect(q.removeFirst(), 4);
    expect(q.removeFirst(), 5);

    // All elements should be popped and queue should be empty here
    expect(q.isEmpty, true);
    expect(() => q.removeFirst(), throwsA(const TypeMatcher<StateError>()));
  });
}
