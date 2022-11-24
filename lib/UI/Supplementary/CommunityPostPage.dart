import 'package:a_living_dictionary/DB/CommunityItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import 'Search.dart';
import 'ThemeColor.dart';

ThemeColor themeColor = ThemeColor();


class CommunityPostPage extends StatefulWidget {
  const CommunityPostPage(this.tabName, this.doc_id, {Key? key}) : super(key: key);
  final String tabName;
  final String doc_id;
  @override
  State<CommunityPostPage> createState() => _CommunityPostPageState(tabName, doc_id);
}

class _CommunityPostPageState extends State<CommunityPostPage> {
  _CommunityPostPageState(this.tabName, this.doc_id);

  final String tabName, doc_id;
  Icon likeIcon = Icon(Icons.thumb_up_off_alt);
  late var width, height;
  bool isClicked = false;
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return MaterialApp(
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: child!);
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: themeColor.getWhiteMaterialColor(),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text(tabName, style: TextStyle(color: Colors.black)),
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                  icon: new Icon(Icons.search),
                  onPressed: () => {
                    //showSearch(context: context, delegate:Search(null))
                  },
                )
              ],
            ),
            //Body : 싱글 스크롤
            body: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("CommunityDB")
                        .doc(doc_id).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final item = snapshot.data!;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: (width > 750) ? (750) : (width),
                          color: Colors.white,
                          child: ListView(
                            children: [
                              getTitleWidget(item['title'], item['writer_id']),
                              getBodyWidget(item['body']),
                              getLikeWidget(),
                              Divider(
                                thickness: 1.0,
                                color: Color(0xaadddddd),
                              ),
                              getCommentWriteWidget(),
                              getCommentWidget()
                            ],
                          ),
                        ),
                      );
                    })
        )
    );
  }

  Widget getTitleWidget(String title, String writer) {
    return Column(children: [
      Container(
        width: (width > 750) ? (750) : (width),
        height: 40,
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xAAdadada), width: 1.5),
              bottom: BorderSide(color: Color(0xAAdadada), width: 1.3),
            ),
            color: Color(0xAAefefef)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
          child: Text(title, style: TextStyle(fontSize: 25)),
        ),
      ),
      Container(
        width: width,
        height: 30,
        alignment: Alignment.centerLeft,
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xAAdadada), width: 1.3))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
          child: Text(writer, style: TextStyle(fontSize: 15)),
        ),
      ),
    ]);
  }
  Widget getBodyWidget(String body) {
    return Container(
      width: (width > 750) ? (750) : (width),
      height: 300,
      padding: const EdgeInsets.fromLTRB(15, 5, 0, 0),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body , style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
  Widget getLikeWidget(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        children: [
          IconButton(
            icon: likeIcon,
            style: ButtonStyle(
              mouseCursor: MaterialStateProperty.all(MouseCursor.defer),
            ),
            //mouseCursor: MouseCursor,
            onPressed: (){
              setState(() {
                likeIcon = (isClicked)?(Icon(Icons.thumb_up_off_alt)):(Icon(Icons.thumb_up_off_alt_rounded));
                isClicked = !isClicked;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget getCommentWriteWidget(){
    return Container(
      width: (width > 750) ? (750) : (width),
      height: 100,
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xAAdadada), width: 1.0)
      ),
      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Row(
        children: [
          SizedBox(
            width: (width > 750) ? (650) : (width-100),
            height: 120,
            child: TextField(
              decoration: const InputDecoration(
                hintText: "댓글 입력",
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
              controller: commentController,
              maxLines: null,
              maxLength: 100,
              cursorColor: Colors.black,
            ),
          ),
          TextButton(
              onPressed: (){
                final it = CommentItem(
                    writer_id: "a", body: commentController.text, time:DateTime.now()
                );
                it.add(doc_id);
                commentController.text = "";
              },
              child: Text("등록", style: TextStyle(color: Colors.black))
          )
        ],
      ),
    );
  }
  Widget getCommentWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('CommunityDB').doc(doc_id)
            .collection('CommentDB').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("has error");
          }

          final doc = snapshot.data!.docs;

          return Column(
            children: doc.map((e) => (buildComWidget(e))).toList(),
          );
        });
  }
  Widget buildComWidget(QueryDocumentSnapshot doc) {
    final it = CommentItem.getDatafromDoc(doc);
    return Column(
      children: [
        ListTile(
          title: Text(it.writer_id,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          subtitle: Text(it.body,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          leading: const Icon(Icons.account_box),
          minVerticalPadding: 0,
        ),
        const Divider(thickness: 0.7)
      ],
    );
  }
}



