import 'package:a_living_dictionary/PROVIDERS/dictionaryItemInfo.dart';
import 'package:a_living_dictionary/UI/RestaurantPage.dart';
import 'package:a_living_dictionary/UI/Supplementary/CheckClick.dart';
import 'package:a_living_dictionary/UI/Supplementary/DictionaryCardPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../DB/CommunityItem.dart';
import '../DB/QuestionItem.dart';
import 'Supplementary//ThemeColor.dart';
import 'Supplementary/PageRouteWithAnimation.dart';

import 'package:provider/provider.dart';
import 'package:a_living_dictionary/PROVIDERS/loginedUser.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;


ThemeColor themeColor = ThemeColor();
const version = '1.0.0';



class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with TickerProviderStateMixin{
  final formKey = GlobalKey<FormState>();
  late String myNickname, myEmail, askTitle, askContent;
  TextEditingController newPassword = TextEditingController();
  TextEditingController equalPassword = TextEditingController();
  TextEditingController _nickNameController = TextEditingController(); 
  // TextEditingController _emailController = TextEditingController(); 
  final CheckClick clickCheck = CheckClick();

  String defaultImgUrl = 'https://firebasestorage.googleapis.com/v0/b/a-living-dictionary.appspot.com/o/techmo.png?alt=media&token=d8bf4d4e-cc31-4523-8cba-8694e6572260';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        children: [

          appID(),
          appDictionary(),
          appCommunity(),
          appMap(),
          appAccount(),
          appGuide(),
          appLogout(),

        ],
      ),
    );
  }


  Widget appID() { //프로필 사진 + 닉네임
    return Consumer<Logineduser>(
        builder: (context, userProvider, child) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xffe0e0e0),
                  child: CircleAvatar(
                    radius: 19.5,
                    backgroundImage: NetworkImage(userProvider.profileImageUrl), //프로필 사진
                ),
                ),
                title: Text(userProvider.nickName, style: const TextStyle(fontWeight: FontWeight.bold),), //닉네임 출력
              ),
              const Divider(thickness: 0.5,),
            ],
          );
        }
    );
  }

  Widget appDictionary() { //백과사전 설정
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text('백과사전',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeColor.getColor(),
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textScaleFactor: 0.9), visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text('백과사전 스크랩 목록'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myScrap());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        const Divider(thickness: 0.5,),
      ],
    );
  }

  Widget appCommunity() { //커뮤니티 설정
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text('커뮤니티',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeColor.getColor(),
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textScaleFactor: 0.9), visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text('작성한 게시물'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myPosting());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        ListTile(title: const Text('댓글 단 게시물'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myComment());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        const Divider(thickness: 0.5,),
      ],
    );
  }

  Widget appMap() { //맛집지도 설정
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text('맛집지도',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeColor.getColor(),
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textScaleFactor: 0.9), visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text('맛집 좋아요 목록'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myLike());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        const Divider(thickness: 0.5,),
      ],
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.setLanguageCode("kr");
      await FirebaseAuth.instance.sendPasswordResetEmail(email:email);
      snackBar('작성하신 이메일로 비밀번호를 전송했습니다');
    } on FirebaseAuthException catch(_)  {
      snackBar('잘못된 이메일입니다');
    }

    
  }


  Widget appAccount() { //계정 설정
    return Consumer<Logineduser>(   // 로그인된 사용자 받아오기위한 provider consumer
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(title: Text('계정 설정',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor.getColor(),
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                textScaleFactor: 0.9), visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
            ListTile(
              title: const Text('비밀번호 변경'), 
              onTap: (){
                if (userProvider.uid.substring(0,5) == 'kakao' || userProvider.uid.substring(0,5) == 'naver') { // 소셜 로그인 유저
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("소셜 로그인 유저는 비밀번호를 변경할 수 없습니다"),));
                } else {    // 이메일 로그인 유저
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => AlertDialog(
                  //     title: Text('비밀번호 변경',
                  //         style: TextStyle(
                  //             color: themeColor.getMaterialColor(),
                  //             fontWeight: FontWeight.bold)),

                  //     content: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Form(
                  //           key: this.formKey,
                  //           autovalidateMode: AutovalidateMode.always,
                  //           child: TextFormField(
                  //             controller: _emailController,
                  //             onSaved: (email) {myEmail = email!;},
                  //             keyboardType: TextInputType.emailAddress,
                  //             validator: (value) => validateEmail(value),
                  //             cursorColor: themeColor.getMaterialColor(),
                  //             decoration: InputDecoration(
                  //               hintText: '이메일 입력',      //  (abcd@naver.com)
                  //               filled: true,
                  //               fillColor: Colors.white,
                  //               enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor.getMaterialColor(),)),
                  //               focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: themeColor.getMaterialColor(),)),
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(height: 10,),
                  //         Align(
                  //           alignment: Alignment.centerLeft,
                  //           child: Text(
                  //             "- 비밀번호 재설정 메일을 보냅니다" ,
                  //             style: TextStyle(
                  //               color: themeColor.getMaterialColor(),
                  //               fontWeight: FontWeight.normal,
                  //               fontSize: 12)
                  //           ),
                  //         ),
                  //         Align(
                  //           alignment: Alignment.centerLeft,
                  //           child: Text(
                  //             "- 메일이 오지 않는다면 스팸함을 확인해주세요",
                  //             style: TextStyle(
                  //               color: themeColor.getMaterialColor(),
                  //               fontWeight: FontWeight.normal,
                  //               fontSize: 12)
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     actions: [
                  //       TextButton(child: Text('취소',
                  //         style: TextStyle(color: themeColor.getMaterialColor(),
                  //           fontWeight: FontWeight.bold,),),
                  //           onPressed: () { Navigator.pop(context); }),
                  //       TextButton(child: Text('확인', //'전송'
                  //         style: TextStyle(color: themeColor.getMaterialColor(),
                  //           fontWeight: FontWeight.bold,
                  //           )
                  //           ,), onPressed: () {
                  //         //이메일 형식을 잘 입력했으면
                  //           if(this.formKey.currentState!.validate()) {

                  //             resetPassword(_emailController.text);
                  //             _emailController.clear();

                  //             Navigator.pop(context);
                  //             // snackBar('작성하신 이메일로 비밀번호를 전송했습니다');
                  //           }
                  //       })
                  //     ],
                  //   ),
                  // );
                
                 showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('비밀번호 재설정 메일을 보냅니다',
                          style: TextStyle(
                              color: themeColor.getMaterialColor(),
                              fontWeight: FontWeight.bold)),

                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          //SizedBox(height: 10,),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "※ 계정에 등록된 이메일 주소로 메일을 보냅니다" ,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,), textScaleFactor: 0.8
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "※ 메일이 오지 않는다면 스팸함을 확인해주세요",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,), textScaleFactor: 0.8
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(child: Text('취소',
                          style: TextStyle(color: themeColor.getMaterialColor(),
                            fontWeight: FontWeight.bold,),),
                            onPressed: () { Navigator.pop(context); }),
                        TextButton(child: Text('확인', //'전송'
                          style: TextStyle(color: themeColor.getMaterialColor(),
                            fontWeight: FontWeight.bold,
                          )
                          ,), onPressed: () {

                          resetPassword(userProvider.email);
                          // _emailController.clear();
                          Navigator.pop(context);
                        }
                        ),
                      ],
                    ),
                  );
                }
              }
            ),
            ListTile(title: const Text('닉네임 변경'), onTap: (){
              PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myNicknamed());
              Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
            }),
            ListTile(title: const Text('프로필 이미지 변경'), onTap: (){
              PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myProfileImg());
              Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
            }),
            const Divider(thickness: 0.5,),
          ],
        );
      }
    );
  }

  Widget appGuide() { //이용 안내
    return Column(
      children: [
        ListTile(title: Text('이용 안내',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeColor.getColor(),
              leadingDistribution: TextLeadingDistribution.even,
            ),
            textScaleFactor: 0.9), visualDensity: const VisualDensity(horizontal: 0, vertical: -3)),
        ListTile(title: const Text('앱 이용규칙'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myAppRule());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        ListTile(title: const Text('문의하기'), onTap: (){
          PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(myAsk());
          Navigator.push(context, pageRouteWithAnimation.slideRitghtToLeft());
        }),
        ListTile(title: const Text('버전 정보'), trailing: const Text(version, style: TextStyle(color: Colors.grey)), //버전 설정
          onTap: (){ snackBar('현재 버전은 $version 입니다'); }
        ), //클릭 시 스낵바에 현재 버전 출력



        const Divider(thickness: 0.5,)
      ],
    );
  }

  Widget appLogout() { //로그아웃
    return Column(
      children: [
        ListTile(
          title: Text('로그아웃',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeColor.getColor(),
            ),),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text('로그아웃하시겠습니까?'),
                actions: [
                  TextButton(child: Text('아니오',
                    style: TextStyle(color: themeColor.getMaterialColor(),
                      fontWeight: FontWeight.bold,),),
                      onPressed: () { Navigator.pop(context); }),
                  TextButton(child: Text('예',
                    style: TextStyle(color: themeColor.getMaterialColor(),
                      fontWeight: FontWeight.bold,),), onPressed: () { Navigator.pop(context); FirebaseAuth.instance.signOut(); }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }




  /* -------------------------------------------------------------------------------- 화면전환 페이지 */

  Widget myLike() {
    late Logineduser user = Provider.of<Logineduser>(context, listen: false);
    String userDocID = user.doc_id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 좋아요 목록'),
        elevation: 0.0,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('userInfo').doc(userDocID).collection('MapLikeList').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final userDocuments = snapshot.data!.docs;

          if (userDocuments.length == 0) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline_rounded, size: 60, color: Colors.grey,),
                Text("좋아요 누른 목록이 없습니다", textScaleFactor: 1.2, style: TextStyle(color: Colors.grey),),
              ],
            ));
          }

          return SingleChildScrollView(
            child:Column(
              children: [
                for (int i=0; i<userDocuments.length; i++)
                  restaurantMapState().nearbyPlacesWidget(userDocuments[i]['store']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget myPosting() {
    late Logineduser user = Provider.of<Logineduser>(context, listen: false);
    return Scaffold(
        appBar: AppBar(title: const Text('작성한 게시물'), elevation: 0.0),
        body: Column(
          children: [
            Expanded(child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('CommunityDB').where('writer_id', isEqualTo: user.uid).orderBy('time', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("DB Error, 개발팀에 문의하세요."));
                  } else if (snapshot.hasData) {
                    final documents = snapshot.data!.docs;
                    if(documents.isNotEmpty) {
                      return ListView(
                          children: documents.map((doc) {
                            CommunityItem item = CommunityItem.getDataFromDoc(doc);
                            return item.build(context);
                          }).toList());
                    }else {
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error_outline_rounded, size: 60, color: Colors.grey,),
                          Text("작성한 게시물이 없습니다", textScaleFactor: 1.2, style: TextStyle(color: Colors.grey),),
                        ],
                      ));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })
            )
          ],
        ));
  }

  Widget myComment() {
    late Logineduser user = Provider.of<Logineduser>(context, listen: false);
    String userDocID = user.doc_id;
    return Scaffold(
        appBar: AppBar(title: const Text('댓글 단 게시물'), elevation: 0.0),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('userInfo').doc(userDocID).collection("CommentList").orderBy('time', descending: true).snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userDocuments = snap.data!.docs;

              if(userDocuments.isEmpty){
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline_rounded, size: 60, color: Colors.grey,),
                    Text("댓글 단 목록이 없습니다", textScaleFactor: 1.2, style: TextStyle(color: Colors.grey),),
                  ],
                ));
              }
              return ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                itemCount: userDocuments.length,
                itemBuilder: (context, index) {
                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('CommunityDB').where('doc_id', isEqualTo: userDocuments[index]['community_id']).snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const CircularProgressIndicator();
                        }
                        if (snap.hasError) {
                          return const CircularProgressIndicator();
                        }
                        final itemDocuments = snap.data!.docs;
                        if (itemDocuments.isNotEmpty) {
                          return Container(
                              child: CommunityItem.getDataFromDoc(itemDocuments.first)
                                  .build(context, commentItemID: userDocuments[index]['comment_id']));
                        } else {
                          return const Center();
                        }
                      });
                },
              );
            }));
  }

  Future<List<String>> get() async {
    late Logineduser user = Provider.of<Logineduser>(context, listen: false);
    String uid = user.uid;
    List<String> commentList = <String>[];
    final instance = FirebaseFirestore.instance.collection('userInfo').doc(uid).collection('CommentList');
    await for (var snapshot in instance.snapshots()){
      for (var doc in snapshot.docs){
        commentList.add(doc.get('community_id'));
      }
    }
    return commentList;
  }


  Widget myScrap () {
    final deviceSize = MediaQuery.of(context).size;
    var width = deviceSize.width; // 세로모드 및 가로모드 높이

    var height = deviceSize.height;
    var portraitH = deviceSize.height / 3.5; // 세로모드 높이
    var landscapeH = deviceSize.height / 1.2; // 가로모드 높이
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var user = Provider.of<Logineduser>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('백과사전 스크랩 목록'), elevation: 0.0),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('userInfo').doc(
              user.doc_id).collection("ScrapList").snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userDocuments = snap.data!.docs;

            if (userDocuments.isEmpty) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const  [
                  Icon(Icons.error_outline_rounded, size: 60, color: Colors.grey,),
                  Text("스크랩한 목록이 없습니다", textScaleFactor: 1.2, style: TextStyle(color: Colors.grey),),
                ],
              ));
            } else {
              return ListView(
                children: [
                  Material(
                      color: Colors.white,
                      child: GridView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        itemCount: userDocuments.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection(
                                  'dictionaryItem')
                                  .where('__name__',
                                  isEqualTo: userDocuments[index]['docID'])
                                  .snapshots(),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final itemDocuments = snap.data!.docs;

                                DictionaryCardPage card = DictionaryCardPage(
                                    width, height, portraitH, landscapeH,
                                    isPortrait);
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 0),
                                  width: width / 2,
                                  height: width * (101515),
                                  child: InkWell(
                                    onTap: () {
                                      String clickedId = itemDocuments[0]
                                          .id; // 지금 클릭한 dictionaryItem의 item_id
                                      Provider.of<DictionaryItemInfo>(
                                          context, listen: false).setInfo(
                                          clickedId,
                                          itemDocuments[0]['author'],
                                          itemDocuments[0]['card_num'],
                                          itemDocuments[0]['date'],
                                          itemDocuments[0]['hashtag'],
                                          itemDocuments[0]['scrapnum'],
                                          itemDocuments[0]['thumbnail'],
                                          itemDocuments[0]['title']);
                                      PageRouteWithAnimation pageRouteWithAnimation = PageRouteWithAnimation(
                                          card.pageView(context));
                                      Navigator.push(
                                          context, pageRouteWithAnimation
                                          .slideLeftToRight());
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10.0),
                                            child: Image.network(
                                                itemDocuments[0]['thumbnail']), // TODO 임시 사진, 썸네일로 바꿔야함
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                                            // 게시글 제목 여백
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                                                  child: Text(
                                                    "#${itemDocuments[0]['hashtag']}",
                                                    style: TextStyle(
                                                      color: themeColor
                                                          .getColor(),
                                                    ),
                                                    textScaleFactor: 1,
                                                  ),
                                                ),
                                                Text(
                                                  // snapshot.data!.docs[0]['title']
                                                    itemDocuments[0]['title'])
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          );
                        },
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 10 / 9 // 가로 세로 비율
                        ),
                      )
                  ),
                ],
              );
            }
          })
    );
  }

  Widget myNicknamed() {
    return Scaffold(
      appBar: AppBar(title: const Text('닉네임 변경'), elevation: 0.0, actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 50,
            height: 10,
            child: Consumer<Logineduser>(
              builder: (context, userProvider, child) {
                return TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: themeColor.getMaterialColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
                    ),


                    
                  ),
                  child: const Text('완료', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    String inputText = _nickNameController.text.trim();
                    

                    if(this.formKey.currentState!.validate()) {

                      //닉네임 중복 확인
                      bool isduplicate = false;

                      await FirebaseFirestore.instance.collection('userInfo').where("nickName", isEqualTo: inputText).get().then((value) {
                        if (value.docs.isNotEmpty) {
                          isduplicate = true;
                        }
                      });

                      if (inputText.length < 2) {
                        snackBar('닉네임을 두 글자 이상 입력해주세요');
                      } else if (isduplicate) {
                        snackBar('중복된 닉네임입니다! 다른 닉네임을 입력해주세요');
                      }
                      else {
                        Provider.of<Logineduser>(context, listen: false).setNickName(inputText);
                        FirebaseFirestore.instance.collection('userInfo').doc(userProvider.doc_id).update({'nickName': inputText});
                        Navigator.pop(context);
                        snackBar('닉네임 변경이 완료되었습니다');
                      }
                    }
                  },
                );
              }

            ),
          ),
        ),
      ],),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Form(
                    key: this.formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Consumer<Logineduser>(
                      builder: (context, userProvider, child) {
                        _nickNameController = TextEditingController(text: userProvider.nickName); 

                        return TextFormField(
                          controller: _nickNameController,
                          // initialValue: userProvider.nickName, initialvalue와 controllerㄹ를 같이 사용할 수 없음
                          onSaved: (name) {myNickname = name!;},
                          validator: (value) {
                            if(value!.isEmpty) {
                              return '닉네임을 입력하세요';
                            } else {
                              return null;
                            }
                          },
                          cursorColor: themeColor.getMaterialColor(),
                          decoration: InputDecoration(
                            hintText: '닉네임',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor.getMaterialColor()),
                              //border: InputBorder.none,
                              //focusedBorder: InputBorder.none,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: themeColor.getMaterialColor()),
                            ),),
                        );
                      }
                    ),
                  ),
                ),
                const Text('※ 욕설, 비하, 성적 수치심을 유발하는 닉네임은 관리자가 임의로 변경하오니 주의 바랍니다.',
                    style: TextStyle(color: Colors.grey), textScaleFactor: 0.9)
              ],
            ),
          ),
        ],
      )
    );
  }

    // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource, user_doc_id) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);
 
      if (pickedImage != null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            Future.delayed(const Duration(seconds: 3), () {
                Navigator.of(context).pop(true);
              });
            return WillPopScope(
                onWillPop: () async {
                  snackBar("잠시만 기다려주세요");
                  return false;
                },
                child : const AlertDialog(content: Text('로딩 중...'))
            );
          }
        );
      }

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        Reference ref = FirebaseStorage.instance.ref(fileName);
        UploadTask uploadTask = ref.putFile( 
          imageFile,
          SettableMetadata(customMetadata: {
            'uploaded_by': 'user',
            'description': 'userProfileImage'
          })
        );
        var dowurl = await (await uploadTask).ref.getDownloadURL();
        
        String imgUrl = dowurl.toString();
        
        Provider.of<Logineduser>(context, listen: false).setProfileImageUrl(imgUrl);

        await FirebaseFirestore.instance.collection('userInfo').doc(user_doc_id).update({
          'profileImageUrl': imgUrl,
        });

      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Widget myProfileImg() {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 이미지 변경'), elevation: 0.0, actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 50,
            height: 10,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeColor.getMaterialColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1000),
                ),
              ),
              child: const Text('완료', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
                snackBar('프로필 이미지 변경이 완료되었습니다');
              },
            ),
          ),
        ),
      ],),
      body: Consumer<Logineduser>(
        builder: (context, userProvider, child) {
          return ListView(
            children: [
              
            Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: CircleAvatar(
                  minRadius: 80.5,
                  maxRadius: 120.5,
                  backgroundColor: const Color(0xffe0e0e0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userProvider.profileImageUrl), //TODO: 프로필 이미지
                    minRadius: 80,
                    maxRadius: 120,
                  ),
                )
              ),),
              
              TextButton(
                  child: Text('프로필 이미지 변경하기',
                      style: TextStyle(fontWeight: FontWeight.bold, color: themeColor.getMaterialColor()),
                      textScaleFactor: 1.2),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {

                        return Wrap(
                          children: [
                            ListTile(leading: const Icon(Icons.photo_library), title: const Text('갤러리'),
                              onTap: () async{
                                Navigator.pop(context);
                                _upload('gallery', userProvider.doc_id);
                              },
                            ),
                            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('카메라'),
                              onTap: () {
                                Navigator.pop(context);
                                _upload('camera', userProvider.doc_id);
                              },
                              
                            ),
                            ListTile(leading: const Icon(Icons.image_not_supported), title: const Text('프로필 이미지 삭제하기'),
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('프로필 이미지 삭제',
                                      style: TextStyle(
                                        color: themeColor.getMaterialColor(),
                                        fontWeight: FontWeight.bold)),
                                        content: const Text('정말로 삭제하겠습니까?'),
                                        actions: [
                                          TextButton(
                                            child: Text('취소',
                                              style: TextStyle(
                                                color: themeColor.getMaterialColor(),
                                                fontWeight: FontWeight.bold,),),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }
                                          ),
                                          TextButton(child: Text('확인',
                                            style: TextStyle(
                                              color: themeColor.getMaterialColor(),
                                              fontWeight: FontWeight.bold,),),
                                              onPressed: () async {

                                                // Reference storageRef = await FirebaseStorage.instance.ref(userProvider.profileImageUrl);

                                                // final desertRef = storageRef.child("images/desert.jpg");

                                                // // Delete the file
                                                // await desertRef.delete();

                                                await FirebaseFirestore.instance.collection('userInfo').doc(userProvider.doc_id).update({
                                                  'profileImageUrl': defaultImgUrl,
                                                });
                                                

                                                Provider.of<Logineduser>(context, listen: false).setProfileImageUrl(defaultImgUrl);
                                                Navigator.pop(context);
                                                snackBar('프로필 이미지 삭제가 완료되었습니다');
                                              }),
                                        ],
                                      ),
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                        
                      }
                    );
                  }
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                  child: Text('※ 욕설, 비하, 성적 수치심을 유발하는 이미지는 관리자가 임의로 변경하오니 주의 바랍니다.',
                         style: TextStyle(color: Colors.grey), textScaleFactor: 0.9))
            ],
          );
        }
      )
    );
  }

  Widget myAppRule() {
    return Scaffold(
      appBar: AppBar(title: const Text('앱 이용규칙'), elevation: 0.0),
      body: ListView(
        children: [
          LiteraryWorld('앱 이용규칙', appRuleText),
          LiteraryWorld('백과사전 이용규칙', dictionaryRuleText),
          LiteraryWorld('커뮤니티 이용규칙', communityRuleText),
          LiteraryWorld('맛집지도 이용규칙', mapRuleText),
          LiteraryWorld('금지사항', dontDoingText),
          LiteraryWorld('기타', otherRuleText)
        ],
      ),
    );
  }

  Widget LiteraryWorld(String subTitle, String content) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              subTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: 1.3
          ),
          const SizedBox(height: 10,),
          Text(content)
        ],
      ),
    );
  }

  Widget myAsk() {
    TextEditingController emailController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    Logineduser user = Provider.of<Logineduser>(context, listen: false);
    QuestionItem item = QuestionItem(
      writerID: user.uid,
      writerNickname: user.nickName,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('문의하기'), elevation: 0.0, actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 50,
            height: 10,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: themeColor.getMaterialColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1000),
                ),
              ),
              child: const Text('완료', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if(this.formKey.currentState!.validate()) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('개인정보 수집 및 이용 동의 안내',
                              style: TextStyle(
                                  color: themeColor.getMaterialColor(),
                                  fontWeight: FontWeight.bold)),
                          content: const Text('문의 처리를 위해 문의 내용에 포함된 이메일, 회원정보 등 '
                                        '개인정보가 포함된 문의 내용을 수집하며 개인정보처리방침에 따라 3년 후 파기됩니다.\n\n'
                                        '동의하시겠습니까?\n비동의 시 문의 접수가 제한됩니다.'),
                          actions: [
                            TextButton(child: Text('비동의',
                              style: TextStyle(
                                color: themeColor.getMaterialColor(),
                                fontWeight: FontWeight.bold,),),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            TextButton(
                                child: Text('동의',
                                  style: TextStyle(
                                    color: themeColor.getMaterialColor(),
                                    fontWeight: FontWeight.bold,),),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AlertDialog(
                                          content: const Text('문의하기가 완료되었습니다.\n'
                                                        '영업일 기준 2~7일 이내 작성하신 이메일로 답변드리겠습니다.'),
                                          actions: [
                                            TextButton(
                                                child: Text('예',
                                                  style: TextStyle(
                                                    color: themeColor
                                                        .getMaterialColor(),
                                                    fontWeight: FontWeight
                                                        .bold,),),
                                                onPressed: () {
                                                  item.title = titleController.text;
                                                  item.content = contentController.text;
                                                  item.writerEmail = emailController.text;
                                                  item.add(DateTime.now());

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);

                                                })
                                          ],
                                        ),
                                  );
                                })
                          ],
                        ),
                  );
                
                }},
            ),
          ),
        ),
      ],),

      body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: this.formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      children: [
                        TextFormField(
                          onSaved: (email) {myEmail = email!;},
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => validateEmail(value),
                          cursorColor: themeColor.getMaterialColor(),
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: '연락받을 이메일 (abcd@naver.com)',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        const Divider(thickness: 0.5),
                        TextFormField(
                          onSaved: (title) {askTitle = title!;},
                          cursorColor: themeColor.getMaterialColor(),
                          validator: (value) {
                            if(value!.isEmpty) {
                              return '내용을 입력하세요';
                            } else {
                              return null;
                            }
                          },
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: '제목',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        const Divider(thickness: 0.5),
                        SizedBox(
                          width: double.infinity,
                          height: 430,
                          child: TextFormField(
                            onSaved: (content) {askContent = content!;},
                            validator: (value) {
                              if(value!.isEmpty) {
                                return '내용을 입력하세요';
                              } else {
                                return null;
                              }
                            },
                            cursorColor: themeColor.getMaterialColor(),
                            maxLines: 100,
                            controller: contentController,
                            decoration: const InputDecoration(
                              hintText: '문의할 내용을 입력하세요',
                              filled: true,
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    )
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10,10,10,20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('※ 문의 답변 시간 안내',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          textScaleFactor: 0.9,
                        ),
                        Text('월, 화, 수, 목, 금 09:00 ~ 18:00\n'
                            '토, 일, 공휴일 휴무\n\n'
                            '(금요일 18:00 이후부터 일요일까지 접수된 문의는 월요일부터 순차적으로 답변드립니다.)',
                          style: TextStyle(color: Colors.grey),
                          textScaleFactor: 0.9,
                        ),
                      ],
                    ),),
                ],
              ),
            ),
          ]),
    );
  }
  



  /* -------------------------------------------------------------------------------- 다른 함수들 */

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return '잘못된 이메일 형식입니다';
    } else {
      return null;
    }
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(String text) {
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text), //내용
          duration: const Duration(seconds: 2), //올라와 있는 시간
        )
    );
  }

  String appRuleText = '''
자취 백과사전 이용규칙은 쾌적한 서비스 운영을 위해 주기적으로 업데이트됩니다.
회사는 이용자가 커뮤니티 운영 시스템, 금지 행위, 게시물 작성 · 수정 · 삭제 규칙 등 커뮤니티 이용규칙을 숙지하지 않아 발생하는 피해에 대하여 회사의 고의 또는 중대한 과실이 없는 한 어떠한 책임도 지지 않습니다.

이 커뮤니티 이용규칙은 2022년 11월 25일에 개정되었습니다.
''';

  String dictionaryRuleText = '''
백과사전 이용규칙은 자취 생활에 대한 정보를 쾌적하게 얻을 수 있도록 하기 위해 제정되었습니다.
서비스 내 모든 정보는 백과사전 이용규칙에 의해 운영되므로, 이용자는 백과사전 이용 전 반드시 모든 내용을 숙지하여야 합니다.

모든 정보는 관리자가 직접 내용을 선별하여 업로드하는 형식입니다.
정보를 타 사이트로 이동할 시 '자취 백과사전'이라는 출처를 반드시 명시해주시기 바랍니다.
''';

  String communityRuleText = '''
커뮤니티 이용규칙은 누구나 기분 좋게 참여할 수 있는 커뮤니티를 만들기 위해 제정되었습니다.
서비스 내 모든 커뮤니티는 커뮤니티 이용규칙에 의해 운영되므로, 이용자는 커뮤니티 이용 전 반드시 모든 내용을 숙지하여야 합니다.

방송통신심의위원회의 정보통신에 관한 심의규정, 현행 법률, 서비스 이용약관 및 커뮤니티 이용규칙을 위반하거나 사회 통념 및 관련 법령을 기준으로 타 이용자에게 악영향을 끼치는 경우, 게시물이 삭제되고 서비스 이용이 일정 기간 제한될 수 있습니다.

커뮤니티 이용규칙은 불법 행위, 각정 차별 및 혐오, 사회적 갈등 조장, 타인의 권리 침해, 다른 이용자에게 불쾌감을 주는 행위, 커뮤니티 유출 행위, 시스템 장애를 유발하는 비정상 행위 등 커뮤니티 분위기 형성과 운영에 악영향을 미치는 행위들을 제한하기 위해 지속적으로 개정됩니다.

중대한 변경 사항이 있는 경우에는 공지사항을 통해 고지하므로 반드시 확인해주시기 바랍니다.
''';

  String mapRuleText = '''
맛집지도 이용규칙은 주변 맛집에 대한 정보를 쾌적하게 얻을 수 있도록 하기 위해 제정되었습니다.
서비스 내 모든 후기는 맛집지도 이용규칙에 의해 운영되므로, 이용자는 맛집지도 이용 전 반드시 모든 내용을 숙지하여야 합니다.

허위정보로 후기를 작성하는 경우, 별도의 통지 없이 후기글이 삭제되고 서비스 이용이 일정 기간 제한될 수 있습니다.
''';

  String dontDoingText = '''
밑의 사항은 반드시 숙지하시기 바랍니다.
준수하지 않을 경우, 별도의 통지 없이 서비스 이용이 일정 기간 제한될 수 있습니다.
  
① 욕설, 비하, 차별, 혐오, 폭력이 관련된 내용 금지
② 음란물, 성적 수치심을 유발하는 내용 금지
③ 영화, 드라마, 도서 등 내용 스포일러 하기 금지 (스포일러가 포함된 내용이라는 것을 미리 알린 경우 제외)
④ 정치, 사회 관련 내용 금지
⑤ 홍보, 판매 관련 내용 금지 (자취 백과사전과 사전에 미리 협의된 경우 제외)
⑥ 불법 촬영물 유통 금지
''';

  String otherRuleText = ''' 
자취 백과사전 이용규칙은 쾌적한 서비스 운영을 위해 주기적으로 업데이트 됩니다.
회사는 이용자가 커뮤니티 운영 시스템, 금지 행위, 게시물 작성, 수정, 삭제 규칙 등 커뮤니티 이용규칙을 숙지하지 않아 발생하는 피해에 대하여 회사의 고의 또는 중대한 과실이 없는 한 어떠한 책임도 지지 않습니다.

이 커뮤니티 이용규칙은 2022년 11월 25일에 개정되었습니다.
''';
  
}
