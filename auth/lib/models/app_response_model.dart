class AppResponseModel {
  final dynamic error;
  final dynamic data;
  final dynamic message;

  AppResponseModel({this.data, this.error, this.message});

  Map<String, dynamic> toJson() => {
    "error": error ?? "", 
    "data": data ?? "", 
    "message": message ?? ""
  };
}
