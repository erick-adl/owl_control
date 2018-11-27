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

    
    List<String> lista = ["Um", "Dois", "tres", "quatro"];
    return Scaffold(
        appBar: AppBar(
          title: Text('Owl'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: bloc.outDataStatus,
              builder: (contex, snap) {
                return Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Container(
                    alignment: Alignment(0, -1),
                    child: Text(
                      "Status: ${snap.data}",
                      style: TextStyle(fontSize: 20.0, color: Colors.brown),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder(
                stream: bloc.oudataOnlineBoardsController,                
                builder: (contex, snap) {
                  return Container(
                    padding: EdgeInsets.only(top: 80.0),
                    child: ListView.builder(
                      itemCount: snap.data == null ? 0 : bloc.listLenght(),
                      itemBuilder: (context, index) {
                        return buildCard(snap.data[index]);
                      },
                    ),
                  );
                }),
          ],
        ));
  }

  Widget buildCard(text) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0)),
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text(
            text,
            style: TextStyle(fontSize: 26.0, color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40.0,
                  child: RaisedButton(
                    child: Text(
                      "Editar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40.0,
                  child: RaisedButton(
                    child: Text(
                      "Iniciar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
