import 'package:flutter/material.dart';
import 'package:simple_state_management_app/models/post.dart';
import 'package:simple_state_management_app/screens/post/post_form_screen.dart';
import 'package:simple_state_management_app/services/post_service.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var postService = PostService();
  List<Post> postList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAllPosts();
    super.initState();
  }

  _getAllPosts() async {
    setState(() {
      isLoading = true;
      postList = [];
    });

    var res = await postService.getPosts(size: 20);

    setState(() {
      isLoading = false;
      if (res.isSuccess) {
        postList = Post.listFromJson(res.data?["content"]);
      }
    });
    if (!res.isSuccess && mounted) {
      _showMessage(res.message ?? "Can not load posts", isError: true);
    }
  }

  _onReact(Post post, bool like) async {
    var res = like
        ? await postService.likePost(post.id!)
        : await postService.dislikePost(post.id!);
    if (res.isSuccess) {
      setState(() {
        if (like) {
          post.likes++;
        } else {
          post.dislikes++;
        }
      });
    }
  }

  _onDelete(Post post) async {
    var res = await postService.deletePost(post.id!);
    if (!mounted) return;
    if (res.isSuccess) {
      _showMessage(res.message ?? "Post deleted successfully!");
      _getAllPosts();
    } else {
      _showMessage(res.message ?? "Delete failed", isError: true);
    }
  }

  _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Posts", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostFormScreen()),
              ).then((onValue) {
                if (onValue == true) {
                  _getAllPosts();
                }
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.cyan))
          : RefreshIndicator(
              onRefresh: () async {
                _getAllPosts();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: postList.length,
                itemBuilder: (context, index) {
                  var post = postList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostFormScreen(post: post),
                              ),
                            ).then((onValue) {
                              if (onValue == true) {
                                _getAllPosts();
                              }
                            });
                          },
                          leading: post.image == null
                              ? Icon(Icons.article, color: Colors.cyan)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    post.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Icon(Icons.article, color: Colors.cyan),
                                  ),
                                ),
                          title: Text("${post.title}"),
                          subtitle: Text(
                            "${post.postCategory?.name ?? ""} • ${post.views ?? 0} views",
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _onDelete(post);
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _onReact(post, true);
                              },
                              icon: Icon(Icons.thumb_up,
                                  size: 18, color: Colors.cyan),
                              label: Text("${post.likes}",
                                  style: TextStyle(color: Colors.cyan)),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _onReact(post, false);
                              },
                              icon: Icon(Icons.thumb_down,
                                  size: 18, color: Colors.grey),
                              label: Text("${post.dislikes}",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
