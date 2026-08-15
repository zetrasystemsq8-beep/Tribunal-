// update_gate.dart
// ============================================================================
// Checks Supabase for the latest app version on launch. If this device is
// behind, shows a dismissible banner. After 3 days of being behind, blocks
// the entire app with a full-screen "Update Required" page until the user
// updates. Wraps the whole app — no other file needs to change except main.dart.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;
  const UpdateGate({Key? key, required this.child}) : super(key: key);

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  static const _gracePeriod = Duration(days: 3);
  static const _prefVersionKey = 'update_first_seen_version';
  static const _prefTimeKey = 'update_first_seen_at';

  bool _loading = true;
  bool _blocked = false;
  bool _bannerVisible = false;
  bool _bannerDismissed = false;
  String? _apkUrl;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final row = await Supabase.instance.client
          .from('app_config')
          .select()
          .eq('id', 1)
          .single();

      final latestVersion = row['latest_version'] as String;
      final apkUrl = row['apk_url'] as String;

      final isBehind = _isOlder(currentVersion, latestVersion);

      if (!isBehind) {
        setState(() => _loading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final storedVersion = prefs.getString(_prefVersionKey);
      final storedAt = prefs.getInt(_prefTimeKey);

      DateTime firstSeenAt;
      if (storedVersion == latestVersion && storedAt != null) {
        firstSeenAt = DateTime.fromMillisecondsSinceEpoch(storedAt);
      } else {
        firstSeenAt = DateTime.now();
        await prefs.setString(_prefVersionKey, latestVersion);
        await prefs.setInt(_prefTimeKey, firstSeenAt.millisecondsSinceEpoch);
      }

      final elapsed = DateTime.now().difference(firstSeenAt);

      setState(() {
        _apkUrl = apkUrl;
        _loading = false;
        if (elapsed >= _gracePeriod) {
          _blocked = true;
        } else {
          _bannerVisible = true;
        }
      });
    } catch (e) {
      // Never block the app if the check itself fails (offline, etc).
      setState(() => _loading = false);
    }
  }

  bool _isOlder(String current, String latest) {
    final c = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final l = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final len = c.length > l.length ? c.length : l.length;
    for (var i = 0; i < len; i++) {
      final cv = i < c.length ? c[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (cv != lv) return cv < lv;
    }
    return false;
  }

  Future<void> _openDownload() async {
    if (_apkUrl == null) return;
    final uri = Uri.parse(_apkUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0B0F14),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF60A5FA)),
          ),
        ),
      );
    }

    if (_blocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BlockedScreen(onDownload: _openDownload),
      );
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_bannerVisible && !_bannerDismissed)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: _UpdateBanner(
                onDownload: _openDownload,
                onDismiss: () => setState(() => _bannerDismissed = true),
              ),
            ),
          ),
      ],
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onDismiss;

  const _UpdateBanner({required this.onDownload, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2530),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3844)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.system_update_rounded, color: Color(0xFF60A5FA)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'A new version of Tribunal is available',
              style: TextStyle(color: Color(0xFFF5F7FA), fontSize: 13.5),
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: const Text('Later', style: TextStyle(color: Color(0xFF8B96A3))),
          ),
          ElevatedButton(
            onPressed: onDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _BlockedScreen extends StatelessWidget {
  final VoidCallback onDownload;
  const _BlockedScreen({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                  ),
                  child: const Icon(Icons.system_update_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Update Required',
                  style: TextStyle(
                    color: Color(0xFFF5F7FA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You're on an old version of Tribunal. Please update to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8B96A3), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Download Update',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
