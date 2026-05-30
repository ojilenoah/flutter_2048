import 'package:flutter_riverpod/flutter_riverpod.dart';

//Conditional import: dart:io exists on Android/iOS/desktop (the mobile impl
//uses AdMob), and is absent on web (the stub is used instead).
import 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart';

export 'ad_service_stub.dart'
    if (dart.library.io) 'ad_service_mobile.dart' show AdService;

final adServiceProvider = Provider<AdService>((ref) => AdService());
