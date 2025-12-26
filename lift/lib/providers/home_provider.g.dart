// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentWorkoutsHash() => r'b5610ec5343619b09730c1e96f57ca63d4243ba9';

/// See also [recentWorkouts].
@ProviderFor(recentWorkouts)
final recentWorkoutsProvider =
    AutoDisposeFutureProvider<List<WorkoutSession>>.internal(
  recentWorkouts,
  name: r'recentWorkoutsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentWorkoutsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentWorkoutsRef = AutoDisposeFutureProviderRef<List<WorkoutSession>>;
String _$weeklyStatsHash() => r'5c33dc417802ed9507c3cd386f71f9a38bc46cd1';

/// See also [weeklyStats].
@ProviderFor(weeklyStats)
final weeklyStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  weeklyStats,
  name: r'weeklyStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$weeklyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeeklyStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
