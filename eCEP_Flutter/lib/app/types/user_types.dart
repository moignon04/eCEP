enum UserTypes 
{
  admin,
  user,
  guest
}

extension UserTypesExtension on UserTypes 
{
  String get name 
  {
    switch (this) 
    {
      case UserTypes.admin:
        return 'admin';
      case UserTypes.user:
        return 'user';
      case UserTypes.guest:
        return 'guest';
      default:
        return 'gest';
    }
  }
}
