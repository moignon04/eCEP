// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:device_info_plus/src/device_info_plus_web.dart';
import 'package:flutter_inappwebview_web/web/main.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:package_info_plus/src/package_info_plus_web.dart';
import 'package:pdfx/src/renderer/web/pdfx_plugin.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:printing/printing_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:syncfusion_pdfviewer_web/pdfviewer_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:video_player_web/video_player_web.dart';
import 'package:wakelock_plus/src/wakelock_plus_web_plugin.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  DeviceInfoPlusWebPlugin.registerWith(registrar);
  InAppWebViewFlutterPlugin.registerWith(registrar);
  FluttertoastWebPlugin.registerWith(registrar);
  PackageInfoPlusWebPlugin.registerWith(registrar);
  PdfxPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  PrintingPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  SyncfusionFlutterPdfViewerPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  VideoPlayerPlugin.registerWith(registrar);
  WakelockPlusWebPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
