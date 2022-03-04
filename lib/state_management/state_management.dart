import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/providers/app_provider.dart';

final appStateProvider =
    ChangeNotifierProvider.autoDispose<AppStateProvider>((ref) {
  return AppStateProvider();
});
