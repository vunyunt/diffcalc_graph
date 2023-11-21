import 'dart:collection';

/// A limited capacity queue where, if filled, a head element will be discarded
/// whenever a new element is added to the tail
class LimitedCapacityQueue<T> implements Queue<T> {
  final int capacity;

  late final List<T?> _content;

  /// Points to the head element + 1
  var _head = 0;

  /// Points to the tail element
  var _tail = 0;

  LimitedCapacityQueue.fromBackingList(this.capacity,
      {required List<T?> backingList, required int head, required int tail}) {
    this._content = backingList;
    this._head = head;
    this._tail = tail;
  }

  LimitedCapacityQueue(this.capacity) {
    /// For easy of implementation, the list is created with capacity + 1. This
    /// means head should always point to a null element.
    _content = List<T?>.filled(capacity + 1, null);
    _tail = this.capacity - 1;
    _head = _tail;
  }

  /// Returns a new index moved forward with wrapping considerations.
  int _moveForward(int index, {int steps = 1}) {
    index += steps;
    index %= _content.length;
    return index;
  }

  /// Returns a new index moved backward with wrapping considerations.
  int _moveBackward(int index, {int steps = 1}) {
    index -= steps;
    index %= _content.length;
    return index;
  }

  @override
  void add(T value) {
    _tail = _moveForward(_tail);
    _content[_tail] = value;
    if (_tail == _head) {
      _head = _moveForward(_head);
    }
  }

  @override
  void addAll(Iterable<T> iterable) {
    for (T value in iterable) {
      add(value);
    }
  }

  @override
  void addFirst(T value) {
    /// Unsupported for now, a behaviour can be defined in the future if this is needed
    throw UnsupportedError(
        "Cannot add element to the head of a LimitedCapacityQueue");
  }

  @override
  void addLast(T value) {
    add(value);
  }

  @override
  bool any(bool Function(T element) test) {
    int index = _tail;
    bool result = false;

    while (index != _head) {
      result |= test(_content[_tail] as T);
    }

    return result;
  }

  @override
  Queue<R> cast<R>() {
    return LimitedCapacityQueue.fromBackingList(capacity,
        backingList: _content.map((e) => e as R).toList(),
        head: _head,
        tail: _tail);
  }

  @override
  void clear() {
    _content.clear();
  }

  @override
  bool contains(Object? element) {
    if (element is T) {
      return any((internalElement) => internalElement == element);
    }

    return false;
  }

  @override
  T elementAt(int index) {
    return _content[_moveForward(_head, steps: index + 1)] as T;
  }

  @override
  bool every(bool Function(T element) test) {
    int index = _tail;
    bool result = true;

    while (index != _head) {
      result &= test(_content[_tail] as T);
    }

    return result;
  }

  @override
  Iterable<T1> expand<T1>(Iterable<T1> Function(T element) toElements) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T get first {
    if (isEmpty) throw StateError("Queue is empty");
    return _content[_moveForward(_head)] as T;
  }

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T1 fold<T1>(
      T1 initialValue, T1 Function(T1 previousValue, T element) combine) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> followedBy(Iterable<T> other) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  void forEach(void Function(T element) action) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  bool get isEmpty => _head == _tail;

  @override
  bool get isNotEmpty => _head != _tail;

  @override
  Iterator<T> get iterator => throw UnsupportedError("Unsupported for now");

  @override
  String join([String separator = ""]) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T get last {
    if (isEmpty) throw StateError("Queue is empty");

    final value = _content[_tail];
    if (value == null) throw StateError("Queue is empty");

    return value;
  }

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  int get length => (_tail - _head) % _content.length;

  @override
  Iterable<T1> map<T1>(T1 Function(T e) toElement) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T reduce(T Function(T value, T element) combine) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  bool remove(Object? value) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T removeFirst() {
    T element = first;
    _head = _moveForward(_head);
    _content[_head] = null;
    return element;
  }

  @override
  T removeLast() {
    T element = last;
    _content[_tail] = null;
    _tail = _moveBackward(_tail);
    return element;
  }

  @override
  void removeWhere(bool Function(T element) test) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  void retainWhere(bool Function(T element) test) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  T get single {
    if (this.length > 1) {
      throw StateError("Queue has more than one element");
    }

    return first;
  }

  @override
  T singleWhere(bool Function(T element) test, {T Function()? orElse}) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> skip(int count) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> skipWhile(bool Function(T value) test) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> take(int count) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> takeWhile(bool Function(T value) test) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  List<T> toList({bool growable = true}) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Set<T> toSet() {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T> where(bool Function(T element) test) {
    throw UnsupportedError("Unsupported for now");
  }

  @override
  Iterable<T1> whereType<T1>() {
    throw UnsupportedError("Unsupported for now");
  }
}
