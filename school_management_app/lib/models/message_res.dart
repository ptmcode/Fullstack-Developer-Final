class MessageRes {
  String? code;
  String? message;
  String? messageKh;
  dynamic data;

  MessageRes({this.code, this.message, this.messageKh, this.data});

  // The API uses "200" in some controllers and "SUC-000" in others.
  bool get isSuccess => code == "200" || code == "SUC-000";

  factory MessageRes.fromJson(Map<String, dynamic> json) {
    return MessageRes(
      code: json["code"],
      message: json["message"],
      messageKh: json["messageKh"],
      data: json["data"],
    );
  }
}
