class ApplicationApiResponse<E> {
  bool result;
  int statusCode;
  String responseBody;
  E responseObject;
  String? nextPageToken;

  ApplicationApiResponse({
    required this.statusCode,
    required this.result,
    required this.responseBody,
    required this.responseObject,
    this.nextPageToken,
  });

  ApplicationApiResponse.init()
      : result = true,
        statusCode = 0,
        responseBody = "",
        responseObject = (null as dynamic) as E,
        nextPageToken = null;

  @override
  String toString() {
    return 'ResponseFromTheApiObject{\n'
        'result: $result,\n'
        ' statusCode: $statusCode,\n'
        ' responseBody: $responseBody,\n'
        ' responseObject: $responseObject}';
  }
}
