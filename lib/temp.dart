import 'dart:async';
import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import './colors.dart';
import './form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coaching',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Coaching: Igor - Trevor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Modal {
  mainBottomSheet(BuildContext context, Function onSubmit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return new ContributionForm(onSubmit);
      },
    );
  }
}

class TaskList extends StatefulWidget {
  final String type;

  TaskList(this.type);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  // QuerySnapshot data;

  List<_HomeItem> documents;

  @override
  initState() {
    super.initState();
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    update();
  }

  void update() async {
    QuerySnapshot response = await Firestore.instance
        .collection("items")
        .where("status", isEqualTo: widget.type)
        .getDocuments();

    List<_HomeItem> items = response.documents.map((item) {
      return _HomeItem.fromMap(item.data, item.documentID);
    }).toList();

    setState(() {
      documents = items;
    });
  }

  SlidableController slidableController;

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return documents == null
        ? Center(child: CircularProgressIndicator())
        : OrientationBuilder(
            builder: (context, orientation) {
              return ListView.builder(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  _HomeItem document = documents[index];

                  return Slidable(
                    key: Key(document.id), // document.documentID
                    controller: slidableController,
                    direction: Axis.horizontal,
                    dismissal: SlidableDismissal(
                      child: SlidableDrawerDismissal(),
                      onDismissed: (actionType) async {
                        // setState(() {
                        //   print(snapshot.data.documents);
                        //   snapshot.data.documents.removeWhere((current) {
                        //     return current.documentID == document.documentID;
                        //   });
                        //   print(snapshot.data.documents);
                        // });

                        // _showSnackBar(
                        //     context,
                        //     actionType == SlideActionType.primary
                        //         ? 'Challenge Done'
                        //         : 'Challenge Failed');

                        if (actionType == SlideActionType.primary) {
                          Firestore.instance
                              .collection("items")
                              .document(document.id)
                              .updateData({"status": "success"});
                        } else {
                          Firestore.instance
                              .collection("items")
                              .document(document.id)
                              .updateData({"status": "failure"});
                        }

                        // await Future.delayed(Duration(seconds: 25), () {
                        //   print("done");
                        // });
                      },
                    ),
                    actionPane: SlidableStrechActionPane(),
                    actionExtentRatio: 0.25,
                    child: HorizontalListItem(document),
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Done',
                        color: CustomColors.DiademGreen,
                        icon: Icons.done,
                        // onTap: () => _showSnackBar(context, 'Done'),
                      ),
                    ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Failed',
                        color: CustomColors.DiademRed,
                        icon: Icons.error,
                        // onTap: () => _showSnackBar(context, 'Failed'),
                      ),
                    ],
                  );
                },
              );
            },
          );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // final List<_HomeItem> items = List.generate(
  //   3,
  //   (i) => _HomeItem(
  //     i,
  //     'Tile n°$i',
  //     _getSubtitle(i),
  //     _getAvatarColor(i),
  //   ),
  // );

  SlidableController slidableController;

  @protected
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  void onSubmit(String title, int reward, String timeout) async {
    final DocumentReference balanceRef =
        Firestore.instance.document('balances/demo');
    final CollectionReference itemsRef = Firestore.instance.collection('items');

    DocumentSnapshot balanceSnapshot = await balanceRef.get();
    if (balanceSnapshot.exists && balanceSnapshot.data['balance'] >= reward) {
      print("creating...");
      await balanceRef.updateData(<String, dynamic>{
        'balance': balanceSnapshot.data['balance'] - reward
      });
      await itemsRef
          .add(_HomeItem.fromChallenge(title, reward, timeout).toJson());
    } else {
      print("overdrawn");
      _showSnackBar(context, "No challenge - deposit overdrawn!");
    }

    // Firestore.instance.runTransaction((Transaction tx) async {
    //   DocumentSnapshot balanceSnapshot = await tx.get(balanceRef);
    // });

    // List<dynamic> items = json.decode(widget.preferences.getString('items', defaultValue: "[]").getValue());
    // items.add(_HomeItem.fromChallenge(
    //   title, reward, timeout
    // ).toJson());
    // print(items);
    // widget.preferences.setString('items', json.encode(items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: CustomColors.DiademMain,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(thickness: 0),
            StreamBuilder<DocumentSnapshot>(
                stream:
                    Firestore.instance.document("balances/demo").snapshots(),
                builder: (context, snapshot) {
                  int balance = 0;
                  if (snapshot.hasData && snapshot.data != null) {
                    balance = snapshot.data["balance"];
                  }
                  return Container(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      "Available deposit: $balance coins",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: "worksans",
                      ),
                    ),
                  );
                }),
            Divider(thickness: 0),
            Container(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "Active challenges: ",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: "worksans",
                ),
              ),
            ),
            // _buildList(context, "default"),
            TaskList("default"),
            // Divider(thickness: 0),
            // Container(
            //     padding: EdgeInsets.only(left: 15),
            //     child: Text(
            //       "Done challenges: ",
            //       style: TextStyle(
            //         fontSize: 24,
            //         fontWeight: FontWeight.w700,
            //         fontFamily: "worksans",
            //       ),
            //     )),
            // _buildList(context, "success"),
            // Divider(thickness: 0),
            // Container(
            //   padding: EdgeInsets.only(left: 15),
            //   child: Text(
            //     "Failed challenges: ",
            //     style: TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.w700,
            //       fontFamily: "worksans",
            //     ),
            //   ),
            // ),
            // _buildList(context, "failure"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Modal().mainBottomSheet(context, onSubmit);
        },
        elevation: 5,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset('assets/fab-add.png'),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  CustomColors.GreenLight,
                  CustomColors.GreenDark
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(50.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: CustomColors.GreenShadow,
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                  offset: Offset(0.0, 0.0),
                ),
              ]),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, String filterStatus) {
    final stream = Firestore.instance
        .collection('items')
        .where(
          "status",
          isEqualTo: filterStatus,
        )
        .snapshots()
        .distinct((prev, next) {
      return prev.documents.length == next.documents.length;
    });

    return OrientationBuilder(
      builder: (context, orientation) {
        Axis direction = orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal;

        final Axis slidableDirection =
            direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;

        return StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data.documents != null)
              print("rebuild... ${snapshot.data.documents.length}");

            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: direction,
              children: snapshot.data.documents.map((document) {
                _HomeItem item =
                    _HomeItem.fromMap(document.data, document.documentID);

                if (filterStatus != "default") {
                  return slidableDirection == Axis.horizontal
                      ? VerticalListItem(item)
                      : HorizontalListItem(item);
                }

                return Slidable(
                  key: Key(document.documentID), // document.documentID
                  controller: slidableController,
                  direction: slidableDirection,
                  dismissal: SlidableDismissal(
                    child: SlidableDrawerDismissal(),
                    onDismissed: (actionType) async {
                      // setState(() {
                      //   print(snapshot.data.documents);
                      //   snapshot.data.documents.removeWhere((current) {
                      //     return current.documentID == document.documentID;
                      //   });
                      //   print(snapshot.data.documents);
                      // });

                      _showSnackBar(
                          context,
                          actionType == SlideActionType.primary
                              ? 'Challenge Done'
                              : 'Challenge Failed');

                      if (actionType == SlideActionType.primary) {
                        Firestore.instance
                            .collection("items")
                            .document(document.documentID)
                            .updateData({"status": "success"});
                      } else {
                        Firestore.instance
                            .collection("items")
                            .document(document.documentID)
                            .updateData({"status": "failure"});
                      }

                      await Future.delayed(Duration(seconds: 25), () {
                        print("done");
                      });

                      print("after done");

                      // print(widget.preferences);

                      // Preference<String> items = widget.preferences.getString("items", defaultValue: "[]");

                      // List<dynamic> parsedItems = json.decode(items.getValue());

                      // List<dynamic> updatedItems = parsedItems.map((current) {
                      //   if (current["id"] == item.id) {
                      //     current["status"] = actionType == SlideActionType.primary ? 'success' : 'failure';
                      //   }
                      //   return current;
                      // }).toList();

                      // print(updatedItems);

                      // String jsonUpdatedItems = json.encode(updatedItems);

                      // print(jsonUpdatedItems);

                      // widget.preferences.setString('items', jsonUpdatedItems);
                    },
                  ),
                  actionPane: _getActionPane(item.reward),
                  actionExtentRatio: 0.25,
                  child: slidableDirection == Axis.horizontal
                      ? VerticalListItem(item)
                      : HorizontalListItem(item),
                  actions: <Widget>[
                    IconSlideAction(
                      caption: 'Done',
                      color: CustomColors.DiademGreen,
                      icon: Icons.done,
                      onTap: () => _showSnackBar(context, 'Done'),
                    ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Failed',
                      color: CustomColors.DiademRed,
                      icon: Icons.error,
                      onTap: () => _showSnackBar(context, 'Failed'),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  static Widget _getActionPane(int index) {
    return SlidableStrechActionPane();
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class HorizontalListItem extends StatelessWidget {
  HorizontalListItem(this.item);
  final _HomeItem item;
  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    if (item.status == "success") color = CustomColors.DiademGreen;
    if (item.status == "failure") color = CustomColors.DiademRed;

    return Container(
      color: color,
      width: 160.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundColor: item.color,
              child: Text('${item.reward}'),
              foregroundColor: Colors.white,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                item.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.item);
  final _HomeItem item;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    if (item.status == "success") color = CustomColors.DiademGreen;
    if (item.status == "failure") color = CustomColors.DiademRed;

    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: color,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.color,
            child: Text('${item.reward}'),
            foregroundColor: Colors.black,
          ),
          title: Text(item.title, style: TextStyle(fontFamily: "worksans")),
          subtitle:
              Text(item.timeout, style: TextStyle(fontFamily: "worksans")),
        ),
      ),
    );
  }
}

class _HomeItem {
  const _HomeItem(
      this.reward, this.title, this.timeout, this.color, this.status,
      {this.id});
  final String id;
  final String status;
  final int reward;
  final String title;
  final String timeout;
  final Color color;

  factory _HomeItem.fromChallenge(String title, int reward, String timeout) {
    return new _HomeItem(
        reward, title, timeout, _HomeItem._getAvatarColor(reward), "default");
  }

  static Color _getAvatarColor(int index) {
    switch (index) {
      case 5:
        return CustomColors.YellowIcon;
      case 10:
        return CustomColors.GreenIcon;
      case 25:
        return CustomColors.PurpleIcon;
      case 50:
        return CustomColors.BlueIcon;
      default:
        return null;
    }
  }

  factory _HomeItem.fromJson(Map<String, dynamic> parsedJson) {
    return new _HomeItem(
        parsedJson["reward"] ?? 5,
        parsedJson["title"] ?? "No title",
        parsedJson["timeout"] ?? "No date",
        Color(int.parse(parsedJson["color"], radix: 16)) ??
            CustomColors.DiademOriginal,
        parsedJson["status"] ?? "default");
  }

  factory _HomeItem.fromMap(Map<String, dynamic> data, String id) {
    return new _HomeItem(
      data["reward"],
      data["title"],
      data["timeout"],
      Color(int.parse(data["color"], radix: 16)) ?? CustomColors.DiademOriginal,
      data["status"],
      id: id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": this.status,
      "reward": this.reward,
      "title": this.title,
      "timeout": this.timeout,
      "color": this.color.toString().split('(0x')[1].split(')')[0],
    };
  }
}
