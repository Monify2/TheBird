import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker extends StatefulWidget {
  final Widget child;
  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  bool _updateAvailable = false;
  String _downloadUrl = '';
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final url = Uri.parse('https://raw.githubusercontent.com/Monify2/TheBird/main/version.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final remoteVersion = data['version'] as String;
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        final downloadUrl = data['download_url'] as String;

        if (remoteVersion != currentVersion) {
          setState(() {
            _updateAvailable = true;
            _downloadUrl = downloadUrl;
          });
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_downloadUrl.isEmpty) return;
    setState(() => _downloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/TheBird.apk';
      final file = File(filePath);
      final request = await http.get(Uri.parse(_downloadUrl));
      await file.writeAsBytes(request.bodyBytes);

      final uri = Uri.parse('file://$filePath');
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch installer');
      }
    } catch (e) {
      debugPrint('Download/Install failed: $e');
    } finally {
      setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateAvailable)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'New Update Available',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A new version of TheBird is ready. Tap "Update Now" to download and install it.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _updateAvailable = false),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Later'),
                          ),
                          ElevatedButton(
                            onPressed: _downloading ? null : _downloadAndInstall,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D5FEF),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(_downloading ? 'Downloading...' : 'Update Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
