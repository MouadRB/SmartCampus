import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';
import 'package:smart_campus/core/injection/injection_container.dart' as di;
import 'package:smart_campus/core/presentation/widgets/auth_gate.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // Providers must wrap MaterialApp, not its `home`. `MaterialApp.home`
      // is the *first route inside the Navigator*, so anything mounted there
      // is invisible to routes pushed on top of it (Navigator.push). Lifting
      // the MultiBlocProvider above MaterialApp lets every pushed route
      // read these blocs through context.
      //
      // No eager fetches here — the AuthGate triggers data loads on returning
      // logins, and the dashboard's "Load Mocks" button triggers them after
      // a fresh sign-up.
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityBloc>.value(
            value: di.sl<ConnectivityBloc>(),
          ),
          BlocProvider<AuthBloc>.value(value: di.sl<AuthBloc>()),
          BlocProvider<AnnouncementsBloc>.value(
            value: di.sl<AnnouncementsBloc>(),
          ),
          BlocProvider<TimetableBloc>.value(
            value: di.sl<TimetableBloc>(),
          ),
          BlocProvider<ActivitiesBloc>.value(
            value: di.sl<ActivitiesBloc>(),
          ),
          BlocProvider<PermissionsBloc>(
            create: (_) => di.sl<PermissionsBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'SmartCampus Companion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
