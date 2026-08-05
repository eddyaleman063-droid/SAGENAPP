// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Stage _$StageFromJson(Map<String, dynamic> json) {
  return _Stage.fromJson(json);
}

/// @nodoc
mixin _$Stage {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  @_ColorConverter()
  Color get accent => throw _privateConstructorUsedError;
  @_IconConverter()
  IconData get icon => throw _privateConstructorUsedError;
  List<Lesson> get lessons => throw _privateConstructorUsedError;
  bool get unlocked => throw _privateConstructorUsedError;
  List<Session> get sessions => throw _privateConstructorUsedError;

  /// Serializes this Stage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StageCopyWith<Stage> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StageCopyWith<$Res> {
  factory $StageCopyWith(Stage value, $Res Function(Stage) then) =
      _$StageCopyWithImpl<$Res, Stage>;
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    @_ColorConverter() Color accent,
    @_IconConverter() IconData icon,
    List<Lesson> lessons,
    bool unlocked,
    List<Session> sessions,
  });
}

/// @nodoc
class _$StageCopyWithImpl<$Res, $Val extends Stage>
    implements $StageCopyWith<$Res> {
  _$StageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? accent = null,
    Object? icon = null,
    Object? lessons = null,
    Object? unlocked = null,
    Object? sessions = null,
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
            accent: null == accent
                ? _value.accent
                : accent // ignore: cast_nullable_to_non_nullable
                      as Color,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            lessons: null == lessons
                ? _value.lessons
                : lessons // ignore: cast_nullable_to_non_nullable
                      as List<Lesson>,
            unlocked: null == unlocked
                ? _value.unlocked
                : unlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            sessions: null == sessions
                ? _value.sessions
                : sessions // ignore: cast_nullable_to_non_nullable
                      as List<Session>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StageImplCopyWith<$Res> implements $StageCopyWith<$Res> {
  factory _$$StageImplCopyWith(
    _$StageImpl value,
    $Res Function(_$StageImpl) then,
  ) = __$$StageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String subtitle,
    @_ColorConverter() Color accent,
    @_IconConverter() IconData icon,
    List<Lesson> lessons,
    bool unlocked,
    List<Session> sessions,
  });
}

/// @nodoc
class __$$StageImplCopyWithImpl<$Res>
    extends _$StageCopyWithImpl<$Res, _$StageImpl>
    implements _$$StageImplCopyWith<$Res> {
  __$$StageImplCopyWithImpl(
    _$StageImpl _value,
    $Res Function(_$StageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Stage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? accent = null,
    Object? icon = null,
    Object? lessons = null,
    Object? unlocked = null,
    Object? sessions = null,
  }) {
    return _then(
      _$StageImpl(
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
        accent: null == accent
            ? _value.accent
            : accent // ignore: cast_nullable_to_non_nullable
                  as Color,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        lessons: null == lessons
            ? _value._lessons
            : lessons // ignore: cast_nullable_to_non_nullable
                  as List<Lesson>,
        unlocked: null == unlocked
            ? _value.unlocked
            : unlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        sessions: null == sessions
            ? _value._sessions
            : sessions // ignore: cast_nullable_to_non_nullable
                  as List<Session>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StageImpl extends _Stage {
  _$StageImpl({
    required this.id,
    required this.title,
    required this.subtitle,
    @_ColorConverter() required this.accent,
    @_IconConverter() required this.icon,
    final List<Lesson> lessons = const [],
    this.unlocked = false,
    final List<Session> sessions = const [],
  }) : _lessons = lessons,
       _sessions = sessions,
       super._();

  factory _$StageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StageImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  @_ColorConverter()
  final Color accent;
  @override
  @_IconConverter()
  final IconData icon;
  final List<Lesson> _lessons;
  @override
  @JsonKey()
  List<Lesson> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  @override
  @JsonKey()
  final bool unlocked;
  final List<Session> _sessions;
  @override
  @JsonKey()
  List<Session> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  String toString() {
    return 'Stage(id: $id, title: $title, subtitle: $subtitle, accent: $accent, icon: $icon, lessons: $lessons, unlocked: $unlocked, sessions: $sessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.accent, accent) || other.accent == accent) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            (identical(other.unlocked, unlocked) ||
                other.unlocked == unlocked) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    subtitle,
    accent,
    icon,
    const DeepCollectionEquality().hash(_lessons),
    unlocked,
    const DeepCollectionEquality().hash(_sessions),
  );

  /// Create a copy of Stage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StageImplCopyWith<_$StageImpl> get copyWith =>
      __$$StageImplCopyWithImpl<_$StageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StageImplToJson(this);
  }
}

abstract class _Stage extends Stage {
  factory _Stage({
    required final String id,
    required final String title,
    required final String subtitle,
    @_ColorConverter() required final Color accent,
    @_IconConverter() required final IconData icon,
    final List<Lesson> lessons,
    final bool unlocked,
    final List<Session> sessions,
  }) = _$StageImpl;
  _Stage._() : super._();

  factory _Stage.fromJson(Map<String, dynamic> json) = _$StageImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get subtitle;
  @override
  @_ColorConverter()
  Color get accent;
  @override
  @_IconConverter()
  IconData get icon;
  @override
  List<Lesson> get lessons;
  @override
  bool get unlocked;
  @override
  List<Session> get sessions;

  /// Create a copy of Stage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StageImplCopyWith<_$StageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
