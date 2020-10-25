import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meu_closet/screens/AddNewItem.dart';
import 'package:meu_closet/screens/DescPage.dart';
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
  var hasGallery = false;
  List gallery = [];
  final dbRef = FirebaseDatabase.instance.reference();
  List selected = [];
  bool dialVisible = true;
  List dataGallery = [];
  bool pressed = false;
  var emptySelected;
  var collection;

  Future<bool> checkGallery() async {
    this.collection = dbRef.child(widget.userId).reference();
    this.collection.once().then((DataSnapshot snapshot) async {
      var data = snapshot.value;
      // print(data);
      if (data.containsKey('gallery')) {
        if (!hasGallery) {
          setState(() {
            hasGallery = true;
          });
        }
        for (var item in data['gallery']) {
          try {
            var ref = FirebaseStorage().ref().child(item['path']);
            var imageDownload = await ref.getDownloadURL();

            if (gallery.contains(imageDownload)) {
              continue;
            } else {
              setState(() {
                gallery = [...gallery, imageDownload];
                this.selected.add(Colors.white);
              });
            }
          } catch (e) {
            print("AAAAAAAAAAAa");
            setState(() {
              this.gallery.remove(item);
            });
          }
        }
        var a = new List(this.selected.length);
        a.fillRange(0, this.selected.length, Colors.white);
        setState(() {
          emptySelected = a;
          dataGallery = data['gallery'];
        });
        return true;
      } else {
        setState(() {
          this.hasGallery = false;
          this.gallery = [];
        });
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
                builder: (context) =>
                    AddNewItemPage(auth: new Auth(), userId: widget.userId),
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

  List index = [];
  enableDelete(index) async {
    if (!this.index.contains(index)) {
      setState(() {
        this.pressed = true;
        this.index = [...this.index, index];
        this.selected[index] = Colors.grey;
      });
    }
  }

  delete() async {
    this.collection = dbRef.child(widget.userId).reference();
    this.collection.once().then((DataSnapshot snapshot) async {
      var data = snapshot.value;
      var a = List.from(data['gallery']);
      // var ref = await FirebaseStorage()
      //     .ref()
      //     .child(data['gallery'][this.index])
      //     .delete();
      var ga;
      var g;
      print(this.index);
      print(a);
      if (a.length != 0) {
        for (var idx in this.index) {
          if (a.length == 1) {
            a.removeAt(0);
          } else {
            a.removeAt(idx);
          }
          ga = {"gallery": a};
          g = new List.from(this.gallery);
          g.removeAt(idx);
          print("0");
        }
      } else {
        this.setState(() {
          // this.pressed = false;
          this.selected = [];
          this.gallery = [];
        });
      }
      print("2");
      await dbRef.child(widget.userId).reference().update(ga);
      print(this.gallery);
      this.setState(() {
        this.gallery = g;
        this.pressed = false;
        this.index = [];
      });
      this.checkGallery();
    });
  }

  @override
  Widget build(BuildContext context) {
    checkGallery();
    // print(this.gallery);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyCloset'),
          shadowColor: Colors.black,
          backgroundColor: Colors.pink,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            this.pressed
                ? Row(children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () => delete(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                      onPressed: () => {
                        this.setState(() {
                          this.pressed = false;
                          this.selected = this.emptySelected;
                        })
                      },
                    )
                  ])
                : IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      widget.auth.signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RootPage(auth: new Auth())));
                    },
                  )
          ],
        ),
        body: this.hasGallery
            ? GridView.count(
                crossAxisCount: 2,
                children: List.generate(this.gallery.length, (index) {
                  return InkWell(
                    onLongPress: () => enableDelete(index),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DescPage(
                                auth: widget.auth,
                                userId: widget.userId,
                                item: this.dataGallery[index])),
                      )
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: this.selected[index],
                        height: 70,
                        width: 70,
                        child: Image.network(
                          this.gallery[index],
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  );
                }),
              )
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
