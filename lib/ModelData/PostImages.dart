class PostImages {
  String? imageId;
  String postId;
  String imagePath;
  int order;

  PostImages({
    this.imageId,
    required this.postId,
    required this.imagePath,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'postId': postId,
      'imagePath': imagePath,
      'order': order,
    };
  }
}