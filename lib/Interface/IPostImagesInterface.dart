
import '../ModelData/PostImages.dart';
import 'DataOperationCallback.dart';
import 'OperationCallback.dart';

abstract class IPostImagesInterface {
  void addPostPhotos(PostImages model, OperationCallback callback);
  void uploadImages(String postId, List<Uri> imageUris, OperationCallback callback);
  void getAllPhotosByPostId(String postId, DataOperationCallback<List<String>> callback);
}

