// استثناءات مخصصة لرمي الأخطاء قبل تحويلها إلى Failures
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}