/// A mixin that provides conversion methods between entity and model objects.
///
/// The `EntityConvertible` mixin defines two methods:
/// - `toEntity()`: Converts the implementing object to an entity object.
/// - `fromEntity()`: Converts an entity object to the implementing object.
///
/// Example usage:
/// ```dart
/// class User {
///   final String id;
///   final String name;
///
///   User(this.id, this.name);
/// }
///
/// class UserModel with EntityConvertible<User, UserModel> {
///   final String id;
///   final String name;
///
///   UserModel(this.id, this.name);
///
///   @override
///   User toEntity() {
///     return User(id, name);
///   }
///
///   @override
///   UserModel fromEntity(User entity) {
///     return UserModel(entity.id, entity.name);
///   }
/// }
/// ```
mixin EntityConvertible<I, O> {
  O toEntity();
  I fromEntity(O model) => throw UnimplementedError();
}
