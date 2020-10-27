import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meu_closet/services/auth.dart';

class DescPage extends StatefulWidget {
  var item;
  final BaseAuth auth;
  final String userId;
  DescPage({Key key, this.auth, this.userId, this.item}) : super(key: key);
  @override
  _DescPageState createState() => _DescPageState();
}

class _DescPageState extends State<DescPage> {
  var photo;

  @override
  initState() {
    this.loadImage();
    super.initState();
  }

  loadImage() async {
    var ref = FirebaseStorage().ref().child(widget.item['path']);
    var imageDownload = await ref.getDownloadURL();
    setState(() {
      this.photo = imageDownload;
    });
    print(this.photo);
    print(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    // loadImage();
    return this.photo != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.item['name'].toUpperCase()),
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            this.photo,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          "Size",
                          style: TextStyle(letterSpacing: 2.0),
                        ),
                        widget.item['description'] != null
                            ? Text(
                                widget.item['description'],
                                style: TextStyle(
                                    fontSize: 32.0, letterSpacing: 2.0),
                              )
                            : Container(),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Purchase Price",
                          style: TextStyle(letterSpacing: 2.0),
                        ),
                        widget.item['purchasePrice'] != null
                            ? Text(
                                "R\$ ${widget.item['purchasePrice']}",
                                style: TextStyle(
                                    fontSize: 32.0, letterSpacing: 2.0),
                              )
                            : Container(),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          "Sale Price",
                          style: TextStyle(letterSpacing: 2.0),
                        ),
                        widget.item['salePrice'] != null
                            ? Text(
                                "R\$ ${widget.item['salePrice']}",
                                style: TextStyle(
                                    fontSize: 32.0, letterSpacing: 2.0),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold();
  }
}
