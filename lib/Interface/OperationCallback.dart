class OperationCallback {
  final void Function() onSuccess;
  final void Function(String error) onFailure;

  OperationCallback({required this.onSuccess, required this.onFailure});
}

