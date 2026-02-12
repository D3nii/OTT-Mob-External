class Pagination {
  int resultsPerpage;
  String nextPageToken;

  Pagination.init()
      : resultsPerpage = 0,
        nextPageToken = '';

  Pagination({
    required this.nextPageToken,
    required this.resultsPerpage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    String nextPageToken = json['nextPageToken'] ?? '';
    int resultsPerPage = json['resultsPerPage'] ?? 0;

    return Pagination(resultsPerpage: resultsPerPage, nextPageToken: nextPageToken);
  }
}
