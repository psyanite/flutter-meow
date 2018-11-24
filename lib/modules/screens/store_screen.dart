import 'package:crust/app/app_state.dart';
import 'package:crust/models/Post.dart';
import 'package:crust/models/store.dart' as MyStore;
import 'package:crust/modules/home/home_actions.dart';
import 'package:crust/modules/post/post_list.dart';
import 'package:crust/modules/screens/settings_screen.dart';
import 'package:crust/presentation/components.dart';
import 'package:crust/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class StoreScreen extends StatelessWidget {
  final int storeId;

  StoreScreen({Key key, this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      onInit: (Store<AppState> store) => store.dispatch(FetchPostsByStoreIdRequest(storeId)),
      converter: (Store<AppState> store) => _Props.fromStore(store, storeId),
      builder: (context, props) => _Presenter(store: props.store));
  }
}

class _Presenter extends StatelessWidget {
  final MyStore.Store store;

  _Presenter({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomScrollView(slivers: <Widget>[_appBar(), _body()]));
  }

  Widget _appBar() {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 100.0,
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: NetworkImage(store.coverImage),
                      fit: BoxFit.cover,
                    ),
                  )),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Builder(
                        builder: (context) =>
                          IconButton(
                            icon: Icon(CupertinoIcons.ellipsis),
                            color: Colors.white,
                            iconSize: 40.0,
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
                          )),
                    ],
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(store.name, style: TextStyle(fontSize: 28.0, fontWeight: Burnt.fontBold)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[Icon(CupertinoIcons.phone), Text(store.phoneNumber)]),
                          Row(children: <Widget>[Icon(CupertinoIcons.person), Text(store.cuisines.join(', '))]),
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Icon(CupertinoIcons.location), _address()])
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          _ratingCount(store.heartCount, Score.good),
                          _ratingCount(store.okayCount, Score.okay),
                          _ratingCount(store.burntCount, Score.bad),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        )));
  }

  Widget _ratingCount(int count, Score score) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: <Widget>[Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Text(count.toString()),
        ), ScoreIcon(score: score, size: 25.0)
        ],
      ),
    );
  }

  Widget _address() {
    var children = <Widget>[];
    store.address.firstLine != null ?? children.add(Text(store.address.firstLine));
    store.address.secondLine != null ?? children.add(Text(store.address.secondLine));
    children.add(Text("${store.address.streetNumber} ${store.address.streetName}"));
    children.add(Text(store.location ?? store.suburb));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _body() {
    if (store.posts == null) return LoadingSliver();
    if (store.posts.length == 0)
      return SliverSafeArea(
        top: false,
        minimum: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate(<Widget>[Text('No posts')]),
        ),
      );
    return PostList(posts: store.posts, postListType: PostListType.forStore);
  }
}

class _Props {
  final MyStore.Store store;

  _Props({this.store});

  static fromStore(Store<AppState> store, int storeId) {
    return _Props(store: store.state.home.stores[storeId]);
  }
}