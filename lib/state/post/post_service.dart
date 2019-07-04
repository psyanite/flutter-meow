import 'package:crust/models/post.dart';
import 'package:crust/services/toaster.dart';
import 'package:crust/utils/enum_util.dart';

class PostService {
  const PostService();

  static Future<bool> deletePhoto(int id) async {
    String query = """
      mutation {
        deletePhoto(id: $id) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    if (response == null) return null;
    var json = response['deletePhoto'];
    return json['id'] == id;
  }

  static Future<bool> deletePost(int postId, int myId) async {
    String query = """
      mutation {
        deletePost(postId: $postId, myId: $myId) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    if (response == null) return null;
    var json = response['deletePost'];
    return json['id'] == postId;
  }

  static Future<Post> updateReviewPost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"${post.postReview.body}"' : null;
    String query = """
      mutation {
        updatePost(
          id: ${post.id},
          body: $body,
          overallScore: ${EnumUtil.format(post.postReview.overallScore.toString())},
          tasteScore: ${EnumUtil.format(post.postReview.tasteScore.toString())},
          serviceScore: ${EnumUtil.format(post.postReview.serviceScore.toString())},
          valueScore: ${EnumUtil.format(post.postReview.valueScore.toString())},
          ambienceScore: ${EnumUtil.format(post.postReview.ambienceScore.toString())},
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(", ")}],
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    if (response == null) return null;
    var json = response['updatePost'];
    return Post.fromToaster(json);
  }

  static Future<Post> submitReviewPost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"${post.postReview.body}"' : null;
    String query = """
      mutation {
        addReviewPost(
          hidden: false,
          storeId: ${post.store.id},
          body: $body,
          overallScore: ${EnumUtil.format(post.postReview.overallScore.toString())},
          tasteScore: ${EnumUtil.format(post.postReview.tasteScore.toString())},
          serviceScore: ${EnumUtil.format(post.postReview.serviceScore.toString())},
          valueScore: ${EnumUtil.format(post.postReview.valueScore.toString())},
          ambienceScore: ${EnumUtil.format(post.postReview.ambienceScore.toString())},
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(", ")}],
          postedById: ${post.postedBy.id}
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    if (response == null) return null;
    var json = response['addReviewPost'];
    return Post.fromToaster(json);
  }

  Future<List<Post>> fetchPostsByUserId(int userId) async {
    String query = """
    query {
      postsByUserId(userId: $userId) {
        ${Post.attributes}
      }
    }
  """;
    final response = await Toaster.get(query);
    if (response == null) return null;
    var json = response['postsByUserId'];
    return (json as List).map((p) => Post.fromToaster(p)).toList();
  }
}
