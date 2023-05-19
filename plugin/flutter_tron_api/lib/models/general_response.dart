class GeneralResponse {
  int? result;
  int? status;
  String? message;

  GeneralResponse({
    this.result,
    this.status,
    this.message,
  });

  static GeneralResponse? fromMap(Map? map) {
    if (map == null) return null;
    return GeneralResponse(
      result: map['result'] as int?,
      status: map['status'] as int?,
      message: map['message'] as String?,
    );
  }
}
