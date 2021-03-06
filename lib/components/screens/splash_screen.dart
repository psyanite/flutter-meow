import 'dart:async';

import 'package:crust/main.dart';
import 'package:crust/models/curate.dart';
import 'package:crust/presentation/theme.dart';
import 'package:crust/state/app/app_state.dart';
import 'package:crust/state/feed/feed_actions.dart';
import 'package:crust/state/me/me_actions.dart';
import 'package:crust/state/reward/reward_actions.dart';
import 'package:crust/state/reward/reward_service.dart';
import 'package:crust/state/store/store_actions.dart';
import 'package:crust/utils/general_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:redux/redux.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  initState() {
    super.initState();
    _redirect();
  }

  _redirect() async {
    Timer(Duration(milliseconds: 500), () {
      Navigator.popAndPushNamed(context, MainRoutes.home);
    });
  }

  _getMyAddress() async {
    var enabled = await Geolocator().isLocationServiceEnabled();
    if (enabled == false) return null;
    var address = await Utils.getGeoAddress(5);
    return address;
  }

  _fetchRewardsNearMe(Store<AppState> store, myAddress) async {
    var address = myAddress ?? store.state.me.address ?? Utils.defaultAddress;
    var rewards = await RewardService.fetchRewards(limit: 12, offset: 0, address: address);
    if (rewards != null) store.dispatch(FetchRewardsNearMeSuccess(rewards));
  }

  _setupFcm(Store<AppState> store) {
    if (store.state.me.user != null) {
      store.dispatch(CheckFcmToken());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      onInit: (Store<AppState> store) async {
        store.dispatch(InitFeed());
        store.dispatch(FetchTopStores());
        store.dispatch(FetchTopRewards());

        if (store.state.me.user != null) Utils.fetchUserData(store);

        store.dispatch(FetchCurate(Curate(tag: 'coffee', title: 'Coffee At First Sight')));
        store.dispatch(FetchCurate(Curate(tag: 'fancy', title: 'Absolutely Stunning')));
        store.dispatch(FetchCurate(Curate(tag: 'cheap', title: 'Cheap Eats')));
        store.dispatch(FetchCurate(Curate(tag: 'bubble', title: 'It\'s Bubble O\'clock')));
        store.dispatch(FetchCurate(Curate(tag: 'brunch', title: 'Brunch Spots')));
        store.dispatch(FetchCurate(Curate(tag: 'sweet', title: 'Sweet Tooth')));

        store.dispatch(FetchFamousStores());

        var myAddress = await _getMyAddress();
        if (myAddress != null) store.dispatch(SetMyAddress(myAddress));

        _fetchRewardsNearMe(store, myAddress);

        _setupFcm(store);
      },
      converter: (Store<AppState> store) => 1,
      builder: (BuildContext context, int props) {
        return _presenter();
      },
    );
  }

  Widget _presenter() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Burnt.burntGradient),
        child: Center(
          child: Image.asset('assets/images/loading-icon.png', height: 200.0),
        ),
      ),
    );
  }
}
