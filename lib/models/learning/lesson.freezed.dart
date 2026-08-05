// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  set subtitle(String value) => throw _privateConstructorUsedError;
  List<Challenge> get challenges => throw _privateConstructorUsedError;
  set challenges(List<Challenge> value) => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  set xpReward(int value) => throw _privateConstructorUsedError;
  int get estimatedMinutes => throw _privateConstructorUsedError;
  set estimatedMinutes(int value) => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  set completed(bool value) => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  set correctAnswers(int value) => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  set totalQuestions(int value) => throw _privateConstructorUsedError;

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    List<Challenge> challenges,
    int xpReward,
    int estimatedMinutes,
    bool completed,
    int correctAnswers,
    int totalQuestions,
  });
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? challenges = null,
    Object? xpReward = null,
    Object? estimatedMinutes = null,
    Object? completed = null,
    Object? correctAnswers = null,
    Object? totalQuestions = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: null == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String,
            challenges: null == challenges
                ? _value.challenges
                : challenges // ignore: cast_nullable_to_non_nullable
                      as List<Challenge>,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedMinutes: null == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
    _$LessonImpl value,
    $Res Function(_$LessonImpl) then,
  ) = __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    List<Challenge> challenges,
    int xpReward,
    int estimatedMinutes,
    bool completed,
    int correctAnswers,
    int totalQuestions,
  });
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
    _$LessonImpl _value,
    $Res Function(_$LessonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? challenges = null,
    Object? xpReward = null,
    Object? estimatedMinutes = null,
    Object? completed = null,
    Object? correctAnswers = null,
    Object? totalQuestions = null,
  }) {
    return _then(
      _$LessonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: null == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String,
        challenges: null == challenges
            ? _value.challenges
            : challenges // ignore: cast_nullable_to_non_nullable
                  as List<Challenge>,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedMinutes: null == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonImpl extends _Lesson {
  _$LessonImpl({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.challenges,
    this.xpReward = 15,
    this.estimatedMinutes = 3,
    this.completed = false,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
  }) : super._();

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  String id;
  @override
  String title;
  @override
  String subtitle;
  @override
  List<Challenge> challenges;
  @override
  @JsonKey()
  int xpReward;
  @override
  @JsonKey()
  int estimatedMinutes;
  @override
  @JsonKey()
  bool completed;
  @override
  @JsonKey()
  int correctAnswers;
  @override
  @JsonKey()
  int totalQuestions;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, subtitle: $subtitle, challenges: $challenges, xpReward: $xpReward, estimatedMinutes: $estimatedMinutes, completed: $completed, correctAnswers: $correctAnswers, totalQuestions: $totalQuestions)';
  }

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(this);
  }
}

abstract class _Lesson extends Lesson {
  factory _Lesson({
    required String id,
    required String title,
    required String subtitle,
    required List<Challenge> challenges,
    int xpReward,
    int estimatedMinutes,
    bool completed,
    int correctAnswers,
    int totalQuestions,
  }) = _$LessonImpl;
  _Lesson._() : super._();

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override
  String get title;
  set title(String value);
  @override
  String get subtitle;
  set subtitle(String value);
  @override
  List<Challenge> get challenges;
  set challenges(List<Challenge> value);
  @override
  int get xpReward;
  set xpReward(int value);
  @override
  int get estimatedMinutes;
  set estimatedMinutes(int value);
  @override
  bool get completed;
  set completed(bool value);
  @override
  int get correctAnswers;
  set correctAnswers(int value);
  @override
  int get totalQuestions;
  set totalQuestions(int value);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
