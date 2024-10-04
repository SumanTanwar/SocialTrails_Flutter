
import '../ModelData/PostImages.dart';
import 'OperationCallback.dart';

abstract class IPostImagesInterface {
  void addPostPhotos(PostImages model, OperationCallback callback);
  void uploadImages(String postId, List<Uri> imageUris, OperationCallback callback);
}

