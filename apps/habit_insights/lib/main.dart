import 'package:flutter/material.dart';
import 'package:network_layer/network_layer.dart';
import 'package:network_layer/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sub_app_2_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const HabitInsightsApp());
}

class HabitInsightsApp extends StatelessWidget {
  const HabitInsightsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Insights',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NetworkStatusText(),
                SizedBox(height: 16),
                HabitInsightsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkStatusText extends StatelessWidget {
  const _NetworkStatusText();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: NetworkLayer.client.getStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Text('Checking API...');
        }
        if (snapshot.hasError) {
          return const Text('API error', style: TextStyle(color: Colors.red));
        }
        return Text('API: ${snapshot.data ?? 'Unknown'}');
      },
    );
  }
}
