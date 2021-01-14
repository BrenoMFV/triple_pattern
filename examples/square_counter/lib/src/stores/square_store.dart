import 'package:square_counter/src/errors/errors.dart';
import 'package:flutter_triple/flutter_triple.dart';

import 'home_store.dart';

class SquareStore extends NotifierStore<SquareError, int> {
  final HomeStore homeStore;
  final int index;

  SquareStore(this.homeStore, {required this.index}) : super(0);

  increment() {
    if (state < 20) {
      update(state + 1);
    } else {
      homeStore.setError(SquareError('Square $index chegou ao limite!'));
    }
  }

  reset() => update(0);
}
