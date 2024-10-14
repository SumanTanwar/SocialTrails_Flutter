class DataOperationCallback<T> {
  final void Function(T data) onSuccess;
  final void Function(String error) onFailure;

  DataOperationCallback({required this.onSuccess, required this.onFailure});
}