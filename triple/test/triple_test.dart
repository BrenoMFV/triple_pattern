import 'package:test/test.dart';
import 'package:triple/triple.dart';

void main() {
  late TestImplements<int, MyException> store;

  setUp(() {
    store = TestImplements(0);
  });

  test('check implementation. setState', () {
    store.setState(1);
    expect(store.propagated, Triple<int, MyException>(state: 1));
  });

  test('check implementation. setLoading', () {
    store.setLoading(true);
    expect(
        store.propagated,
        Triple<int, MyException>(
            state: 0, loading: true, event: TripleEvent.loading));
  });

  test('check implementation. setError', () {
    store.setError(const MyException('error'));
    expect(
        store.propagated,
        Triple<int, MyException>(
            state: 0,
            error: const MyException('error'),
            event: TripleEvent.error));
  });

  test('check implementation. disctinct setState', () {
    store.setError(const MyException('error'));
    final triple = store.propagated;
    store.setState(0);
    expect(store.propagated.hashCode, triple.hashCode);
  });
}

class TestImplements<State extends Object, Error extends Object>
    extends Store<State, Error> {
  TestImplements(State initialState) : super(initialState);

  late Triple<State, Error> propagated = triple;

  @override
  Future destroy() async {}

  @override
  Disposer observer({
    void Function(State state)? onState,
    void Function(bool loading)? onLoading,
    void Function(Error error)? onError,
  }) {
    return () async {};
  }

  @override
  void propagate(Triple<State, Error> triple) {
    propagated = triple;
  }
}

class MyException implements Exception {
  final String message;

  const MyException(this.message);
}