// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyWorkoutsHash() => r'55f846fba4d28e434b04337d239c1d21e902ed5f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [monthlyWorkouts].
@ProviderFor(monthlyWorkouts)
const monthlyWorkoutsProvider = MonthlyWorkoutsFamily();

/// See also [monthlyWorkouts].
class MonthlyWorkoutsFamily extends Family<AsyncValue<List<WorkoutSession>>> {
  /// See also [monthlyWorkouts].
  const MonthlyWorkoutsFamily();

  /// See also [monthlyWorkouts].
  MonthlyWorkoutsProvider call(
    DateTime month,
  ) {
    return MonthlyWorkoutsProvider(
      month,
    );
  }

  @override
  MonthlyWorkoutsProvider getProviderOverride(
    covariant MonthlyWorkoutsProvider provider,
  ) {
    return call(
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyWorkoutsProvider';
}

/// See also [monthlyWorkouts].
class MonthlyWorkoutsProvider
    extends AutoDisposeFutureProvider<List<WorkoutSession>> {
  /// See also [monthlyWorkouts].
  MonthlyWorkoutsProvider(
    DateTime month,
  ) : this._internal(
          (ref) => monthlyWorkouts(
            ref as MonthlyWorkoutsRef,
            month,
          ),
          from: monthlyWorkoutsProvider,
          name: r'monthlyWorkoutsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyWorkoutsHash,
          dependencies: MonthlyWorkoutsFamily._dependencies,
          allTransitiveDependencies:
              MonthlyWorkoutsFamily._allTransitiveDependencies,
          month: month,
        );

  MonthlyWorkoutsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<List<WorkoutSession>> Function(MonthlyWorkoutsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyWorkoutsProvider._internal(
        (ref) => create(ref as MonthlyWorkoutsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkoutSession>> createElement() {
    return _MonthlyWorkoutsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyWorkoutsProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlyWorkoutsRef on AutoDisposeFutureProviderRef<List<WorkoutSession>> {
  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthlyWorkoutsProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkoutSession>>
    with MonthlyWorkoutsRef {
  _MonthlyWorkoutsProviderElement(super.provider);

  @override
  DateTime get month => (origin as MonthlyWorkoutsProvider).month;
}

String _$dailyWorkoutsHash() => r'fe7b5cc04eeff3b6b2585b2a42d14bcff5aaa4b9';

/// See also [dailyWorkouts].
@ProviderFor(dailyWorkouts)
const dailyWorkoutsProvider = DailyWorkoutsFamily();

/// See also [dailyWorkouts].
class DailyWorkoutsFamily extends Family<AsyncValue<List<WorkoutSession>>> {
  /// See also [dailyWorkouts].
  const DailyWorkoutsFamily();

  /// See also [dailyWorkouts].
  DailyWorkoutsProvider call(
    DateTime day,
  ) {
    return DailyWorkoutsProvider(
      day,
    );
  }

  @override
  DailyWorkoutsProvider getProviderOverride(
    covariant DailyWorkoutsProvider provider,
  ) {
    return call(
      provider.day,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyWorkoutsProvider';
}

/// See also [dailyWorkouts].
class DailyWorkoutsProvider
    extends AutoDisposeFutureProvider<List<WorkoutSession>> {
  /// See also [dailyWorkouts].
  DailyWorkoutsProvider(
    DateTime day,
  ) : this._internal(
          (ref) => dailyWorkouts(
            ref as DailyWorkoutsRef,
            day,
          ),
          from: dailyWorkoutsProvider,
          name: r'dailyWorkoutsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyWorkoutsHash,
          dependencies: DailyWorkoutsFamily._dependencies,
          allTransitiveDependencies:
              DailyWorkoutsFamily._allTransitiveDependencies,
          day: day,
        );

  DailyWorkoutsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
  }) : super.internal();

  final DateTime day;

  @override
  Override overrideWith(
    FutureOr<List<WorkoutSession>> Function(DailyWorkoutsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyWorkoutsProvider._internal(
        (ref) => create(ref as DailyWorkoutsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WorkoutSession>> createElement() {
    return _DailyWorkoutsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyWorkoutsProvider && other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DailyWorkoutsRef on AutoDisposeFutureProviderRef<List<WorkoutSession>> {
  /// The parameter `day` of this provider.
  DateTime get day;
}

class _DailyWorkoutsProviderElement
    extends AutoDisposeFutureProviderElement<List<WorkoutSession>>
    with DailyWorkoutsRef {
  _DailyWorkoutsProviderElement(super.provider);

  @override
  DateTime get day => (origin as DailyWorkoutsProvider).day;
}

String _$createPlanFromRoutineHash() =>
    r'e7581527e9bbdf167ac1053628780ddb015b90e2';

/// See also [createPlanFromRoutine].
@ProviderFor(createPlanFromRoutine)
const createPlanFromRoutineProvider = CreatePlanFromRoutineFamily();

/// See also [createPlanFromRoutine].
class CreatePlanFromRoutineFamily extends Family<AsyncValue<WorkoutSession>> {
  /// See also [createPlanFromRoutine].
  const CreatePlanFromRoutineFamily();

  /// See also [createPlanFromRoutine].
  CreatePlanFromRoutineProvider call(
    WorkoutRoutine routine,
    DateTime date,
    String? note,
  ) {
    return CreatePlanFromRoutineProvider(
      routine,
      date,
      note,
    );
  }

  @override
  CreatePlanFromRoutineProvider getProviderOverride(
    covariant CreatePlanFromRoutineProvider provider,
  ) {
    return call(
      provider.routine,
      provider.date,
      provider.note,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'createPlanFromRoutineProvider';
}

/// See also [createPlanFromRoutine].
class CreatePlanFromRoutineProvider
    extends AutoDisposeFutureProvider<WorkoutSession> {
  /// See also [createPlanFromRoutine].
  CreatePlanFromRoutineProvider(
    WorkoutRoutine routine,
    DateTime date,
    String? note,
  ) : this._internal(
          (ref) => createPlanFromRoutine(
            ref as CreatePlanFromRoutineRef,
            routine,
            date,
            note,
          ),
          from: createPlanFromRoutineProvider,
          name: r'createPlanFromRoutineProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createPlanFromRoutineHash,
          dependencies: CreatePlanFromRoutineFamily._dependencies,
          allTransitiveDependencies:
              CreatePlanFromRoutineFamily._allTransitiveDependencies,
          routine: routine,
          date: date,
          note: note,
        );

  CreatePlanFromRoutineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routine,
    required this.date,
    required this.note,
  }) : super.internal();

  final WorkoutRoutine routine;
  final DateTime date;
  final String? note;

  @override
  Override overrideWith(
    FutureOr<WorkoutSession> Function(CreatePlanFromRoutineRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreatePlanFromRoutineProvider._internal(
        (ref) => create(ref as CreatePlanFromRoutineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routine: routine,
        date: date,
        note: note,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WorkoutSession> createElement() {
    return _CreatePlanFromRoutineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatePlanFromRoutineProvider &&
        other.routine == routine &&
        other.date == date &&
        other.note == note;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routine.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, note.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreatePlanFromRoutineRef on AutoDisposeFutureProviderRef<WorkoutSession> {
  /// The parameter `routine` of this provider.
  WorkoutRoutine get routine;

  /// The parameter `date` of this provider.
  DateTime get date;

  /// The parameter `note` of this provider.
  String? get note;
}

class _CreatePlanFromRoutineProviderElement
    extends AutoDisposeFutureProviderElement<WorkoutSession>
    with CreatePlanFromRoutineRef {
  _CreatePlanFromRoutineProviderElement(super.provider);

  @override
  WorkoutRoutine get routine =>
      (origin as CreatePlanFromRoutineProvider).routine;
  @override
  DateTime get date => (origin as CreatePlanFromRoutineProvider).date;
  @override
  String? get note => (origin as CreatePlanFromRoutineProvider).note;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
