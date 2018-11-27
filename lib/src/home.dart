import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:owl/src/home-controller.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final HomeController bloc = BlocProvider.of<HomeController>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Owl'),
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: bloc.outDataStatus,
            builder: (contex, snap) {
              if (!snap.hasData) {
                return Center(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: Text(
                    "Conectando, aguarde...",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ));
              } else if (snap.hasData) {
                return Center(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: Text(
                    "${snap.data}",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ));
              } else if (snap.data
                  .toString()
                  .toUpperCase()
                  .contains("CONNECTED")) {
                return StreamBuilder(
                  stream: bloc.outDataStatus,
                  builder: (contex, snap) {
                    if (!snap.hasData) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (contex, inex) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            margin: EdgeInsets.all(20.0),
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: <Widget>[
                                Text("blabla"),
                                Row(
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {},
                                    ),
                                    RaisedButton(
                                      onPressed: () {},
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              }
            }));
  }
}
