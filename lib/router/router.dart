import 'package:smarttalk/features/AutorisationScreen/Autorisation.dart';
import 'package:smarttalk/features/FriendsListScreen/friendsList.dart';
import 'package:smarttalk/features/RegisterScreen/Register.dart';
import 'package:smarttalk/features/SearchScreen/Search.dart';
import 'package:smarttalk/features/UsersMessageScreen/UsersMessage.dart';

final router = {
  '/login': (context) => AutorisationScreen(),
  '/friend_list': (context) => FriendsListScreen(),
  '/register': (context) => RegisterScreen(),
  '/message': (context) => UsersMessageScreen(usersName: ''),
  '/search': (context) => SearchScreen(),
};
