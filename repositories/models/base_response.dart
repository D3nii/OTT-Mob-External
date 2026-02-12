const String SUCCESS = 'SUCCESS';
const String ERROR = 'ERROR';
const String LOADING = 'LOADING';

class BaseResponse<E> {
  final E data;
  final String responseStatus;
  String errorText = '';

  BaseResponse(this.data, this.responseStatus);

  @override
  String toString() {
    return 'BaseResponse{data: $data, responseStatus: $responseStatus, errorText: $errorText}';
  }
}
