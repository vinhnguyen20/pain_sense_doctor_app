import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_notifier.g.dart';

@Riverpod(keepAlive: true)
class RouterNotifier extends _$RouterNotifier with ChangeNotifier {
  @override
  void build() {
    ref.listen<AuthViewState>(authProvider, (_, __) => notifyListeners());
  }
}
