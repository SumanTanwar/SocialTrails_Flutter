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
  factory PostImages.fromJson(Map<String, dynamic> json) {
    return PostImages(
      imageId: json['imageId'] as String?,
      postId: json['postId'] as String,
      imagePath: json['imagePath'] as String,
      order: json['order'] as int,
    );
  }
}