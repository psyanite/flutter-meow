import 'package:crust/models/Post.dart';

class FetchPostsForUserRequested {
  final int userAccountId;

  FetchPostsForUserRequested(this.userAccountId);
}

class FetchPostsForUserSuccess {
  final List<Post> posts;

  FetchPostsForUserSuccess(this.posts);
}