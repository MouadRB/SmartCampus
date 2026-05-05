import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/connectivity/connectivity_bloc.dart';
import 'package:smart_campus/core/injection/injection_container.dart' as di;
import 'package:smart_campus/core/presentation/widgets/authenticated_shell.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:smart_campus/features/permissions/presentation/bloc/permissions_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_event.dart';

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
      builder: (context, _) => MaterialApp(
        title: 'SmartCampus Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ConnectivityBloc>.value(
              value: di.sl<ConnectivityBloc>(),
            ),
            BlocProvider<AnnouncementsBloc>(
              create: (_) => di.sl<AnnouncementsBloc>()
                ..add(const FetchAnnouncements()),
            ),
            BlocProvider<TimetableBloc>(
              create: (_) =>
                  di.sl<TimetableBloc>()..add(const FetchTimetable()),
            ),
            BlocProvider<PermissionsBloc>(
              create: (_) => di.sl<PermissionsBloc>(),
            ),
          ],
          child: const AuthenticatedShell(),
        ),
      ),
    );
  }
}
