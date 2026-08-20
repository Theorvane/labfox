// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 int get id; String get name;@JsonKey(name: 'path_with_namespace') String get pathWithNamespace; String? get description;// Always shown as a number in the UI, so absent means zero, not unknown.
@JsonKey(name: 'star_count') int get starCount; String? get visibility;@JsonKey(name: 'default_branch') String? get defaultBranch;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'web_url') String? get webUrl;@JsonKey(name: 'last_activity_at') DateTime? get lastActivityAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pathWithNamespace, pathWithNamespace) || other.pathWithNamespace == pathWithNamespace)&&(identical(other.description, description) || other.description == description)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,pathWithNamespace,description,starCount,visibility,defaultBranch,avatarUrl,webUrl,lastActivityAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, pathWithNamespace: $pathWithNamespace, description: $description, starCount: $starCount, visibility: $visibility, defaultBranch: $defaultBranch, avatarUrl: $avatarUrl, webUrl: $webUrl, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'path_with_namespace') String pathWithNamespace, String? description,@JsonKey(name: 'star_count') int starCount, String? visibility,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? pathWithNamespace = null,Object? description = freezed,Object? starCount = null,Object? visibility = freezed,Object? defaultBranch = freezed,Object? avatarUrl = freezed,Object? webUrl = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pathWithNamespace: null == pathWithNamespace ? _self.pathWithNamespace : pathWithNamespace // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'path_with_namespace')  String pathWithNamespace,  String? description, @JsonKey(name: 'star_count')  int starCount,  String? visibility, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'web_url')  String? webUrl, @JsonKey(name: 'last_activity_at')  DateTime? lastActivityAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.pathWithNamespace,_that.description,_that.starCount,_that.visibility,_that.defaultBranch,_that.avatarUrl,_that.webUrl,_that.lastActivityAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project extends Project {
  const _Project({required this.id, required this.name, @JsonKey(name: 'path_with_namespace') required this.pathWithNamespace, this.description, @JsonKey(name: 'star_count') this.starCount = 0, this.visibility, @JsonKey(name: 'default_branch') this.defaultBranch, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'web_url') this.webUrl, @JsonKey(name: 'last_activity_at') this.lastActivityAt}): super._();
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'path_with_namespace') final  String pathWithNamespace;
@override final  String? description;
// Always shown as a number in the UI, so absent means zero, not unknown.
@override@JsonKey(name: 'star_count') final  int starCount;
@override final  String? visibility;
@override@JsonKey(name: 'default_branch') final  String? defaultBranch;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'web_url') final  String? webUrl;
@override@JsonKey(name: 'last_activity_at') final  DateTime? lastActivityAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.pathWithNamespace, pathWithNamespace) || other.pathWithNamespace == pathWithNamespace)&&(identical(other.description, description) || other.description == description)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,pathWithNamespace,description,starCount,visibility,defaultBranch,avatarUrl,webUrl,lastActivityAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, pathWithNamespace: $pathWithNamespace, description: $description, starCount: $starCount, visibility: $visibility, defaultBranch: $defaultBranch, avatarUrl: $avatarUrl, webUrl: $webUrl, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'path_with_namespace') String pathWithNamespace, String? description,@JsonKey(name: 'star_count') int starCount, String? visibility,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'web_url') String? webUrl,@JsonKey(name: 'last_activity_at') DateTime? lastActivityAt
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? pathWithNamespace = null,Object? description = freezed,Object? starCount = null,Object? visibility = freezed,Object? defaultBranch = freezed,Object? avatarUrl = freezed,Object? webUrl = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pathWithNamespace: null == pathWithNamespace ? _self.pathWithNamespace : pathWithNamespace // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
