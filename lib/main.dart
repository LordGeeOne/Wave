import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'services/playback_manager.dart';

export 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PlaybackManager.instance.init();
  runApp(const MyApp());
}
