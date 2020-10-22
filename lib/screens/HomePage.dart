import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:meu_closet/screens/AddNewItem.dart';
import 'package:meu_closet/screens/Root.dart';
import 'package:meu_closet/services/auth.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbRef = FirebaseDatabase.instance.reference();
  bool dialVisible = true;
  @override
  void initState() {
    super.initState();
  }

  var collection;
  Future<bool> checkGallery() async {
    this.collection = dbRef.child(widget.userId).reference();
    this.collection.once().then((DataSnapshot snapshot) {
      var data = snapshot.value;
      if (data.containsKey('gallery')) {
        return true;
      }
      // print('Connected to second database and read ${snapshot.value}');
    });
    return false;
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.pink,
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewItemPage(
                  auth: new Auth(),
                  userId: widget.userId
                ),
              ),
            )
          },
          label: 'Add item',
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.pink,
        ),
        SpeedDialChild(
          child: Icon(Icons.search, color: Colors.white),
          backgroundColor: Colors.pink,
          onTap: () => print('SECOND CHILD'),
          label: 'Find',
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.pink,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(checkGallery());
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyCloset'),
          shadowColor: Colors.black,
          backgroundColor: Colors.pink,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                widget.auth.signOut();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RootPage(auth: new Auth())));
              },
            )
          ],
        ),
        body: this.checkGallery() == true
            ? Container()
            : Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "Your closet is empty :(",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0),
                  ),
                ),
              ),
        floatingActionButton: this.buildSpeedDial(),
      ),
    );
  }
}
