// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_tracker_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HabitTrackerState {
  bool get isLoading => throw _privateConstructorUsedError;
  int get totalHabits => throw _privateConstructorUsedError;
  int get completedHabits => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of HabitTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitTrackerStateCopyWith<HabitTrackerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitTrackerStateCopyWith<$Res> {
  factory $HabitTrackerStateCopyWith(
    HabitTrackerState value,
    $Res Function(HabitTrackerState) then,
  ) = _$HabitTrackerStateCopyWithImpl<$Res, HabitTrackerState>;
  @useResult
  $Res call({
    bool isLoading,
    int totalHabits,
    int completedHabits,
    String? error,
  });
}

/// @nodoc
class _$HabitTrackerStateCopyWithImpl<$Res, $Val extends HabitTrackerState>
    implements $HabitTrackerStateCopyWith<$Res> {
  _$HabitTrackerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? totalHabits = null,
    Object? completedHabits = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalHabits: null == totalHabits
                ? _value.totalHabits
                : totalHabits // ignore: cast_nullable_to_non_nullable
                      as int,
            completedHabits: null == completedHabits
                ? _value.completedHabits
                : completedHabits // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HabitTrackerStateImplCopyWith<$Res>
    implements $HabitTrackerStateCopyWith<$Res> {
  factory _$$HabitTrackerStateImplCopyWith(
    _$HabitTrackerStateImpl value,
    $Res Function(_$HabitTrackerStateImpl) then,
  ) = __$$HabitTrackerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    int totalHabits,
    int completedHabits,
    String? error,
  });
}

/// @nodoc
class __$$HabitTrackerStateImplCopyWithImpl<$Res>
    extends _$HabitTrackerStateCopyWithImpl<$Res, _$HabitTrackerStateImpl>
    implements _$$HabitTrackerStateImplCopyWith<$Res> {
  __$$HabitTrackerStateImplCopyWithImpl(
    _$HabitTrackerStateImpl _value,
    $Res Function(_$HabitTrackerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HabitTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? totalHabits = null,
    Object? completedHabits = null,
    Object? error = freezed,
  }) {
    return _then(
      _$HabitTrackerStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalHabits: null == totalHabits
            ? _value.totalHabits
            : totalHabits // ignore: cast_nullable_to_non_nullable
                  as int,
        completedHabits: null == completedHabits
            ? _value.completedHabits
            : completedHabits // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$HabitTrackerStateImpl implements _HabitTrackerState {
  const _$HabitTrackerStateImpl({
    this.isLoading = false,
    this.totalHabits = 0,
    this.completedHabits = 0,
    this.error,
  });

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int totalHabits;
  @override
  @JsonKey()
  final int completedHabits;
  @override
  final String? error;

  @override
  String toString() {
    return 'HabitTrackerState(isLoading: $isLoading, totalHabits: $totalHabits, completedHabits: $completedHabits, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitTrackerStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.totalHabits, totalHabits) ||
                other.totalHabits == totalHabits) &&
            (identical(other.completedHabits, completedHabits) ||
                other.completedHabits == completedHabits) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, totalHabits, completedHabits, error);

  /// Create a copy of HabitTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitTrackerStateImplCopyWith<_$HabitTrackerStateImpl> get copyWith =>
      __$$HabitTrackerStateImplCopyWithImpl<_$HabitTrackerStateImpl>(
        this,
        _$identity,
      );
}

abstract class _HabitTrackerState implements HabitTrackerState {
  const factory _HabitTrackerState({
    final bool isLoading,
    final int totalHabits,
    final int completedHabits,
    final String? error,
  }) = _$HabitTrackerStateImpl;

  @override
  bool get isLoading;
  @override
  int get totalHabits;
  @override
  int get completedHabits;
  @override
  String? get error;

  /// Create a copy of HabitTrackerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitTrackerStateImplCopyWith<_$HabitTrackerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
