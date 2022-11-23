import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Supplementary//ThemeColor.dart';
import '../DB/CommunityItem.dart';
import 'Supplementary/CommunityWritePage.dart';

ThemeColor themeColor = ThemeColor();

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyCommunity();
  }
}

class MyCommunity extends StatefulWidget {
  const MyCommunity({Key? key}) : super(key: key);

  @override
  State<MyCommunity> createState() => _MyComminityState();
}

class _MyComminityState extends State<MyCommunity> {
  CommunityItem p = CommunityItem();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        //color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextButton(
                onPressed: () {
                  setState(() {
                    //curPostList = genaralPostList;
                  });
                },
                child: Text('전체글'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(110, 37)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  alignment: Alignment(-1.0, -1.0),
                )),
            TextButton(
                onPressed: () {
                  setState(() {
                    //curPostList = hotPostList;
                  });
                },
                child: Text('인기글'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(110, 37)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  alignment: Alignment(0.0, -1.0),
                )),
            TextButton(
                onPressed: () {
                  setState(() {
                    //curPostList = noticePostList;
                  });
                },
                child: Text('공지글'),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(110, 37)),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  alignment: Alignment(1.0, -1.0),
                )),
          ],
        ),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('CommunityDB').snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return CircularProgressIndicator();
          }
          final documents = snapshot.data!.docs;
          return Expanded(
              child: ListView(
                  shrinkWrap: true,
                  children: documents.map((doc)=> p.build(doc, context)).toList()
              )
          );
        }),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: (){
              Navigator.pushNamed(context, '/communityWrite');
              //_addPost();
              //p.postAdd();
            },
            tooltip: 'write',
            child: Icon(Icons.add),
          ),
        ],
      )
    ]);
  }
}
