enum UserTypes {
  farmer,
  inspector,
  shopOwner,
}

UserTypes userTypesFromJson(int value) {
  return UserTypes.values[value];
}

int userTypesToJson(UserTypes userType) {
  return userType.index;
}
