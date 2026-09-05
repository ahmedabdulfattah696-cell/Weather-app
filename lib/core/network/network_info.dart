abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// تنفيذ واجهة فحص الاتصال بالإنترنت
// ملاحظة: ليعمل هذا بشكل حقيقي 100% سنحتاج لاحقاً لحزمة مثل internet_connection_checker
// لكننا سنجهزه الآن ليتوافق مع Clean Architecture ويرجع true مؤقتاً
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // مؤقتاً نفترض أن هناك اتصال بالإنترنت حتى نضيف حزمة الفحص
    return true;
  }
}