import 'package:crust/state/me/me_state.dart';
import 'package:crust/state/error/error_state.dart';
import 'package:crust/state/home/home_state.dart';
import 'package:crust/state/reward/reward_state.dart';
import 'package:crust/state/user/user_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final MeState me;
  final HomeState home;
  final UserState user;
  final RewardState reward;
  final ErrorState error;

  AppState({MeState me, HomeState home, UserState user, RewardState reward, ErrorState error})
      : me = me ?? MeState(),
        home = home ?? HomeState(),
        user = user ?? UserState(),
        reward = reward ?? RewardState(),
        error = error ?? ErrorState();

  static AppState rehydrate(dynamic json) {
    try {
      return AppState(
        me: json['me'] != null ? MeState.rehydrate(json['me']) : null
      );
    }
    catch (e) {
      print("Could not deserialize json from persistor: $e");
      return AppState();
    }
  }

  // Used by persistor
  Map<String, dynamic> toJson() => {'me': me.toPersist()};

  AppState copyWith({MeState me}) {
    return AppState(me: me ?? this.me);
  }

  @override
  String toString() {
    return '''{
      me: $me,
      home: $home,
      user: $user,
      reward: $reward,
      error: $error
    }''';
  }
}
