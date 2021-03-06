import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/app_icon_header.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/footer.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/types/reference.dart';
import 'package:memorare/types/reference_type.dart';
import 'package:memorare/types/urls.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class AddQuoteLayout extends StatefulWidget {
  final Widget child;

  AddQuoteLayout({this.child});

  @override
  _AddQuoteLayoutState createState() => _AddQuoteLayoutState();
}

class _AddQuoteLayoutState extends State<AddQuoteLayout> {
  bool isLoading = false;
  bool isCompleted = false;
  String errorMessage = '';

  FirebaseUser userAuth;
  bool canManage = false;

  String fabText = 'Propose';
  Icon fabIcon = Icon(Icons.send);

  @override
  void initState() {
    super.initState();
    checkAuthStatus();

    if (AddQuoteInputs.id.isNotEmpty) {
      fabText = 'Save';
      fabIcon = Icon(Icons.save);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
      isLoading || isCompleted ?
      Padding(padding: EdgeInsets.zero,) :
      FloatingActionButton.extended(
        onPressed: () {
          proposeQuote();
        },
        label: Text(fabText),
        icon: fabIcon,
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: <Widget>[
          body(),
          Footer(),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return FullPageLoading(
        message: AddQuoteInputs.id.isEmpty ?
          'Proposing quote...' : 'Saving quote...',
      );
    }

    if (errorMessage.isNotEmpty) {
      return FullPageError(
        message: errorMessage,
      );
    }

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          children: <Widget>[
            AppIconHeader(),

            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(
                'Your quote has been successfully proposed!',
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Soon, a moderator will review it and it will ba validated if everything is alright.',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 100.0, bottom: 200.0),
              child: Wrap(
                spacing: 30.0,
                children: <Widget>[
                  navCard(
                    icon: Icon(Icons.dashboard, size: 40.0,),
                    title: 'Dashboard',
                    onTap: () => FluroRouter.router.navigateTo(context, DashboardRoute),
                  ),
                  navCard(
                    icon: Icon(Icons.add, size: 40.0,),
                    title: 'Add another quote',
                    onTap: () {
                      AddQuoteInputs.clearQuoteName();
                      AddQuoteInputs.clearTopics();
                      AddQuoteInputs.clearQuoteId();
                      AddQuoteInputs.clearComment();
                      FluroRouter.router.navigateTo(context, AddQuoteContentRoute);
                    },
                  ),

                  canManage ?
                    navCard(
                      icon: Icon(Icons.timer, size: 40.0,),
                      title: 'Temporary quotes',
                      onTap: () {
                        FluroRouter.router.navigateTo(context, AdminTempQuotesRoute);
                      },
                    ):
                    navCard(
                      icon: Icon(Icons.home, size: 40.0,),
                      title: 'Home',
                      onTap: () {
                        FluroRouter.router.navigateTo(context, HomeRoute);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  Widget navCard({Icon icon, Function onTap, String title,}) {
    return SizedBox(
      width: 200.0,
      height: 250.0,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Opacity(opacity: .8, child: icon),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future addNewTempQuote({
    List<String> comments,
    List<Reference> references,
    Map<String, bool> topics,
  }) async {

    await FirestoreApp.instance
      .collection('tempquotes')
      .add({
        'author'        : {
          'id'          : AddQuoteInputs.authorId,
          'job'         : AddQuoteInputs.authorJob,
          'jobLang'     : {},
          'name'        : AddQuoteInputs.authorName,
          'summary'     : AddQuoteInputs.authorSummary,
          'summaryLang' : {},
          'updatedAt'   : DateTime.now(),
          'urls': {
            'affiliate' : AddQuoteInputs.authorAffiliateUrl,
            'image'     : AddQuoteInputs.authorImgUrl,
            'website'   : AddQuoteInputs.authorUrl,
            'wikipedia' : AddQuoteInputs.authorWikiUrl,
          }
        },
        'comments'      : comments,
        'createdAt'     : DateTime.now(),
        'lang'          : AddQuoteInputs.lang,
        'name'          : AddQuoteInputs.name,
        'mainReference' : {
          'id'  : AddQuoteInputs.refId,
          'name': AddQuoteInputs.refName,
        },
        'references'    : references,
        'region'        : AddQuoteInputs.region,
        'topics'        : topics,
        'user': {
          'id': userAuth.uid,
        },
        'updatedAt'     : DateTime.now(),
        'validation'    : {
          'comment'     : {
            'name'      : '',
            'updatedAt' : DateTime.now(),
          },
          'status'      : 'proposed',
          'updatedAt'   : DateTime.now(),
        }
      });
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }

    final user = await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .get();

    if (!user.exists) { return; }

    setState(() {
      canManage = user.data()['rights']['user:managequote'] == true;
    });
  }

  void proposeQuote() async {
    if (AddQuoteInputs.name.isEmpty) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "The quote's content cannot be empty.",
      )
      ..show(context);

      return;
    }

    if (AddQuoteInputs.topics.length == 0) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        message: "You must select at least 1 topics for the quote.",
      )
      ..show(context);

      return;
    }

    setState(() {
      isLoading = true;
    });

    final comments = List<String>();

    if (AddQuoteInputs.comment.isNotEmpty) {
      comments.add(AddQuoteInputs.comment);
    }

    final references = List<Reference>();

    if (AddQuoteInputs.refName.isNotEmpty) {
      references.add(
        Reference(
          imgUrl      : AddQuoteInputs.refImgUrl,
          lang        : AddQuoteInputs.refLang,
          linkedRefs  : [],
          name        : AddQuoteInputs.refName,
          summary     : AddQuoteInputs.refSummary,
          type        : ReferenceType(
            primary   : AddQuoteInputs.refPrimaryType,
            secondary : AddQuoteInputs.refSecondaryType,
          ),
          urls        : Urls(
            affiliate : AddQuoteInputs.refAffiliateUrl,
            image     : AddQuoteInputs.refImgUrl,
            website   : AddQuoteInputs.refUrl,
            wikipedia : AddQuoteInputs.refWikiUrl,
          ),
        )
      );
    }

    final topics = Map<String, bool>();

    AddQuoteInputs.topics.forEach((topic) {
      topics[topic] = true;
    });

    try {
      // !NOTE: Use cloud function instead.
      final user = await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .get();

      int today = user.data()['quota']['today'];
      today++;

      int proposed = user.data()['stats']['proposed'];
      proposed++;

      await FirestoreApp.instance
        .collection('users')
        .doc(userAuth.uid)
        .update(data: {
          'quota.today': today,
          'stats.proposed': proposed,
        });

      if (AddQuoteInputs.id.isEmpty) {
        await addNewTempQuote(
          comments: comments,
          references: references,
          topics: topics,
        );

      } else {
        await saveExistingTempQuote(
          comments  : comments,
          references: references,
          topics    : topics,
        );
      }

      setState(() {
        isLoading = false;
        isCompleted = true;
      });

      Flushbar(
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
        message: AddQuoteInputs.id.isEmpty ?
          'Your quote has been successfully proposed.' :
          'Your quote has been successfully edited',
      )
      ..show(context);

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        isCompleted = true;
      });

      Flushbar(
        duration        : Duration(seconds: 5),
        backgroundColor : Colors.red,
        message         : 'There was an issue while proposing your new quote.',
      )
      ..show(context);
    }
  }

  Future saveExistingTempQuote({
    List<String> comments,
    List<Reference> references,
    Map<String, bool> topics,
  }) async {

    await FirestoreApp.instance
      .collection('tempquotes')
      .doc(AddQuoteInputs.id)
      .set({
        'author': {
          'id'          : AddQuoteInputs.authorId,
          'job'         : AddQuoteInputs.authorJob,
          'jobLang'     : {},
          'name'        : AddQuoteInputs.authorName,
          'summary'     : AddQuoteInputs.authorSummary,
          'summaryLang' : {},
          'updatedAt'   : DateTime.now(),
          'urls': {
            'affiliate' : AddQuoteInputs.authorAffiliateUrl,
            'image'     : AddQuoteInputs.authorImgUrl,
            'website'   : AddQuoteInputs.authorUrl,
            'wikipedia' : AddQuoteInputs.authorWikiUrl,
          }
        },
        'comments'      : comments,
        'createdAt'     : DateTime.now(),
        'lang'          : AddQuoteInputs.lang,
        'name'          : AddQuoteInputs.name,
        'mainReference' : {
          'id'  : AddQuoteInputs.refId,
          'name': AddQuoteInputs.refName,
        },
        'references'    : references,
        'region'        : AddQuoteInputs.region,
        'topics'        : topics,
        'user': {
          'id': userAuth.uid,
        },
        'updatedAt'     : DateTime.now(),
        'validation'    : {
          'comment': {
            'name'      : '',
            'updatedAt' : DateTime.now(),
          },
          'status'      : 'proposed',
          'updatedAt'   : DateTime.now(),
        }
      });
  }
}
