import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/providers/app_provider.dart';

final appStateProvider =
    ChangeNotifierProvider.autoDispose<AppStateProvider>((ref) {
  return AppStateProvider();
});
