// @dart=2.9

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/manage_user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  get child => null;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<Favorites>(
              create: (_) => Favorites(favorites: []), child: MyApp());
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          // Add the 3 lines from here...
          primaryColor: Colors.red,
        ),
        home: RandomWords());
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  var login;
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  AuthRepository auth = AuthRepository.instance();
  bool isLogedIn = false;
  var password;
  String verified_password;
  SnappingSheetController snappingSheetController;

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.4,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Align(
                    alignment: Alignment.topCenter,
                    child: Text("Please confirm your password below:")),
                SizedBox(height: 40),
                Consumer<Favorites>(builder: (context, fav, _) {
                  return Align(
                    alignment: Alignment.center,
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                          errorStyle: TextStyle(),
                          errorText:
                              Provider.of<Favorites>(context, listen: false)
                                      .wrong_password
                                  ? 'Passwords must match'
                                  : null),
                      onChanged: (String str) {
                        verified_password = str;
                        print(verified_password);
                      },
                    ),
                  );
                }),
                SizedBox(height: 10),
                Align(
                  heightFactor: 1.5,
                  alignment: Alignment.bottomCenter,
                  child: FlatButton(
                    onPressed: () {
                      if (verified_password == passwordController.text) {
                        Provider.of<Favorites>(context, listen: false)
                            .wrongPasswordFalse();
                        auth.signUp(
                            emailController.text, passwordController.text);
                        _userLogin();
                      } else {
                        Provider.of<Favorites>(context, listen: false)
                            .wrongPasswordTrue();
                      }
                    },
                    color: Colors.teal,
                    child: Container(
                        width: 100,
                        height: 20,
                        child: Center(
                            child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ))),
                  ),
                ),
              ]),
            ),
          );
        });
  }

  @override
  void initState() {
    snappingSheetController = SnappingSheetController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user_name;
    user_name = isLogedIn ? auth.user.email : "";
    var snapping_sheet = SnappingSheet(
      controller: snappingSheetController,
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: 0.0,
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        SnappingPosition.pixels(
          positionPixels: 150,
          // snappingDuration: Duration(milliseconds: 1750),
        ),
      ],
      child: _buildSuggestions(),
      grabbingHeight: 75,
      // TODO: Add your grabbing widget here,
      grabbing: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        color: Colors.grey,
        child: Center(
          child: Row(children: <Widget>[
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Welcome back, " + user_name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  snappingSheetController.setSnappingSheetPosition(150);
                  Feedback.forTap(context);
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.black,
                ),
              ),
            )
          ]),
        ),
      ),
      sheetBelow: SnappingSheetContent(
        sizeBehavior: SheetSizeStatic(height: 150),
        draggable: true,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Consumer<Favorites>(builder: (context, fav, _) {
                  return Container(
                      width: 65.0,
                      height: 65.0,
                      decoration: new BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.color,
                          shape: BoxShape.circle,
                          image: Provider.of<Favorites>(context, listen: false)
                                      .image !=
                                  null
                              ? DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(Provider.of<Favorites>(
                                          context,
                                          listen: false)
                                      .image))
                              : null));
                }),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: <Widget>[
                    Align(
                      //alignment: Alignment(-1.0, -1.0),
                      child: SizedBox(
                          width: 250.0,
                          height: 25,
                          child: Text(
                            '    ' + user_name,
                            overflow: TextOverflow.ellipsis,
                            style: _biggerFont,
                            maxLines: 1,
                            softWrap: false,
                          )),
                    ),
                    // ignore: deprecated_member_use
                    FlatButton(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      onPressed: () async {
                        final result = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                        );
                        if (result != null) {
                          var file = File(result.path);
                          final _firebaseStorage = FirebaseStorage.instance;
                          var snapshot = await _firebaseStorage
                              .ref()
                              .child('images/' + auth.user.uid.toString() + '/photo.jpg')
                              .putFile(file)
                              .whenComplete(() => null);
                          var downloadUrl = await snapshot.ref.getDownloadURL();
                          Provider.of<Favorites>(context, listen: false)
                              .updateImage(downloadUrl.toString());
                        } else {
                          // User canceled the picker
                          final snackBar =
                              SnackBar(content: Text('No image selected'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      color: Colors.teal,
                      child: Container(
                          width: 100,
                          height: 20,
                          child: Center(
                              child: Text(
                            "Change avatar",
                            style: TextStyle(color: Colors.white),
                          ))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      // Add from here...
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          Builder(
              builder: (context) => IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: _pushSaved,
                    color: Colors.white,
                  )),
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(isLogedIn ? Icons.exit_to_app : Icons.login),
                  onPressed: isLogedIn ? _pressLogOut : _handleLogin))
        ],
      ),
      body: Builder(
          builder: (context) =>
              isLogedIn ? snapping_sheet : _buildSuggestions()),
    );
  }

  void _pressLogOut() async {
    Provider.of<Favorites>(context, listen: false).logInStatusFlip();
    Provider.of<Favorites>(context, listen: false).removeAll();
    setState(() {
      isLogedIn = false;
    });
    await auth.signOut();
  }

  void _handleLogin() {
    var logInButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.red,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: _userLogin,
        child: Text(
          "Log in",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    var signUpButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.teal,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () => displayBottomSheet(context),
        child: Text(
          "New user? Click to sign up",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final opening =
              Text('Welcome to Startup Names Generator, please log in below');
          final email = TextField(
            controller: emailController,
            onChanged: (text) {
              emailController.text = text;
              emailController.selection = TextSelection.fromPosition(
                  TextPosition(offset: emailController.text.length));
            },
            //textDirection: TextDirection.rtl,
            obscureText: false,
            //autocorrect: false,
            decoration: InputDecoration(
              hintText: "Email",
            ),
          );

          password = TextField(
            onChanged: (text) {
              //setState(() {
              passwordController.text = text;
              passwordController.selection = TextSelection.fromPosition(
                  TextPosition(offset: passwordController.text.length));
              //});
            },
            controller: passwordController,
            obscureText: true,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Password",
            ),
          );

          var logInScreen = Center(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(children: <Widget>[
                  opening,
                  email,
                  password,
                  SizedBox(height: 10.0),
                  Consumer<Favorites>(builder: (context, fav, _) {
                    return Provider.of<Favorites>(context, listen: false)
                                .tryLogin ==
                            true
                        ? CircularProgressIndicator()
                        : logInButton;
                  }),
                  SizedBox(height: 5),
                  signUpButton,
                ]),
              ),
            ),
          );

          return Scaffold(
              appBar: AppBar(
                title: Text('Login'),
                centerTitle: true,
              ),
              body: logInScreen);
        }, // ...to here.
      ),
    );
  }

  void _userLogin() async {
    Provider.of<Favorites>(context, listen: false).logInStatusFlip();
    bool logInSucceed;
    logInSucceed =
        await auth.signIn(emailController.text, passwordController.text);
    if (logInSucceed) {
      List<QueryDocumentSnapshot> savedFavorites = (await FirebaseFirestore
              .instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser.uid.toString())
              .collection("favorites")
              .get())
          .docs;
      var storedSuggestions = savedFavorites.map((e) => WordPair(
          e.data().entries.first.value.toString(),
          e.data().entries.last.value.toString()));
      var fav = storedSuggestions.toList();
      Provider.of<Favorites>(context, listen: false)
          .favorites
          .forEach((line) async {
        var alreadySaved = storedSuggestions.contains(line);
        if (!alreadySaved) {
          fav.add(line);
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser.uid.toString())
              .collection("favorites")
              .doc(line.toString())
              .set({"first": line.first, "second": line.second});
        }
      });
      Provider.of<Favorites>(context, listen: false).removeAll();
      Provider.of<Favorites>(context, listen: false).addAllFav(fav);

      setState(() {
        isLogedIn = true;
      });
      final _firebaseStorage = FirebaseStorage.instance;
      var downloadUrl;
      var ref = _firebaseStorage.ref().child('images/' + auth.user.uid.toString() + '/photo.jpg');
      try {
        downloadUrl = await ref.getDownloadURL();
      } catch(err) {
        downloadUrl = null;
      }
      Provider.of<Favorites>(context, listen: false).updateImage(downloadUrl);
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      Provider.of<Favorites>(context, listen: false).logInStatusFlip();
      final snackBar =
          SnackBar(content: Text('There was an error logging into the app'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Consumer<Favorites>(builder: (context, fav, _) {
            final tiles =
                Provider.of<Favorites>(context, listen: false).favorites.map(
              (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                  trailing: Icon(Icons.delete_outline, color: Colors.red),
                  onTap: () async {
                    Provider.of<Favorites>(context, listen: false)
                        .removeFavorite(pair);
                    if (isLogedIn) {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser.uid.toString())
                          .collection("favorites")
                          .doc(pair.toString())
                          .delete();
                    }
                  },
                );
              },
            );
            List<Widget> divided = [];
            if (tiles.isNotEmpty) {
              divided = ListTile.divideTiles(
                context: context,
                tiles: tiles,
              ).toList();
            }
            return Scaffold(
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: ListView(children: divided),
            );
          });
        }, // ...to here.
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    return Consumer<Favorites>(
      builder: (context, fav, _) {
        final alreadySaved = Provider.of<Favorites>(context, listen: false)
            .favorites
            .contains(pair);
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onTap: () async {
            if (alreadySaved) {
              Provider.of<Favorites>(context, listen: false)
                  .removeFavorite(pair);
              if (isLogedIn) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser.uid.toString())
                    .collection("favorites")
                    .doc(pair.toString())
                    .delete();
              }
            } else {
              Provider.of<Favorites>(context, listen: false).addFavorite(pair);
              if (isLogedIn) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser.uid.toString())
                    .collection("favorites")
                    .doc(pair.toString())
                    .set({"first": pair.first, "second": pair.second});
              }
            }
          },
        );
      },
    );
  }
}
