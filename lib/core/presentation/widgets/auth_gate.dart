import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smart_campus/core/presentation/widgets/authenticated_shell.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_bloc.dart';
import 'package:smart_campus/features/activities/presentation/bloc/activities_event.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:smart_campus/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_event.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_state.dart';
import 'package:smart_campus/features/auth/presentation/pages/auth_screen.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:smart_campus/features/timetable/presentation/bloc/timetable_event.dart';

/// Root route gate. Restores any in-memory session on first build and
/// swaps between [LoginPage] and [AuthenticatedShell] based on the
/// [AuthBloc]'s state.
///
/// On a returning-user login (`isFirstSession == false`) the gate
/// auto-fetches announcements / timetable / activities so the dashboard
/// has data immediately. After a fresh sign-up the gate stays hands-off
/// — the dashboard's Load Mocks button is the trigger.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthSessionRestored());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => c is Authenticated && p is! Authenticated,
      listener: (context, state) {
        if (state is Authenticated && !state.isFirstSession) {
          context
              .read<AnnouncementsBloc>()
              .add(const FetchAnnouncements());
          context.read<TimetableBloc>().add(const FetchTimetable());
          context.read<ActivitiesBloc>().add(const FetchActivities());
        }
      },
      builder: (context, state) {
        if (state is Authenticated) return const AuthenticatedShell();
        if (state is AuthInitial) return const _BootScreen();
        return const AuthScreen();
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}
