import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class Favorites with ChangeNotifier {
  Favorites({required this.favorites});
  List<WordPair> favorites = [];
  bool tryLogin = false;
  bool wrong_password = false;
  String? image = null;

  void addFavorite(WordPair pair) {
    favorites.add(pair);
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void removeAll() {
    favorites.clear();
    notifyListeners();
  }

  void addAllFav(list) {
    favorites.addAll(list);
    notifyListeners();
  }

  void logInStatusFlip(){
    tryLogin = !tryLogin;
    notifyListeners();
  }

  void wrongPasswordTrue() {
    wrong_password = true;
    notifyListeners();
  }

  void wrongPasswordFalse() {
    wrong_password = false;
    notifyListeners();
  }

  void updateImage(file){
    image = file;
    notifyListeners();
  }
}
