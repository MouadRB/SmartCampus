import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_event.dart';
import 'package:smart_campus/features/auth/presentation/bloc/auth_state.dart';
import 'package:smart_campus/features/auth/presentation/widgets/auth_mode_toggle.dart';
import 'package:smart_campus/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:smart_campus/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:smart_campus/features/auth/presentation/widgets/social_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onSwitchToSignUp});

  final VoidCallback onSwitchToSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _email.text,
          password: _password.text,
        ));
  }

  void _goToSignUp() => widget.onSwitchToSignUp();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome back',
      subtitle:
          'Sign in to access your schedule, alerts, and campus life.',
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) => c is AuthError && p is! AuthError,
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                backgroundColor: AppColors.errorBg,
                content: Text(
                  state.message,
                  style: AppTextStyles.bodyPrimary
                      .copyWith(color: AppColors.error),
                ),
                behavior: SnackBarBehavior.floating,
              ));
            context.read<AuthBloc>().add(const AuthErrorCleared());
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthModeToggle(
                mode: AuthMode.signIn,
                onChanged: (m) {
                  if (m == AuthMode.signUp) _goToSignUp();
                },
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              AuthTextField(
                controller: _email,
                hint: 'student@campus.edu',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              SizedBox(height: 12.h),
              AuthTextField(
                controller: _password,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscure,
                onToggleObscure: () =>
                    setState(() => _obscure = !_obscure),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RememberMe(
                    checked: _remember,
                    onChanged: (v) => setState(() => _remember = v),
                  ),
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.navLabel
                          .copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              _PrimaryButton(
                label: 'Sign In',
                loading: loading,
                onPressed: loading ? null : _submit,
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              const _OrDivider(),
              SizedBox(height: 14.h),
              Row(
                children: [
                  const Expanded(
                    child: SocialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Expanded(
                    child: SocialButton(
                      icon: Icons.public,
                      label: 'Google',
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              Center(
                child: GestureDetector(
                  onTap: _goToSignUp,
                  behavior: HitTestBehavior.opaque,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySecondary,
                      children: [
                        const TextSpan(text: 'New to campus? '),
                        TextSpan(
                          text: 'Create an account',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18.r,
            height: 18.r,
            decoration: BoxDecoration(
              color: checked ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: checked ? AppColors.accent : AppColors.border,
              ),
            ),
            child: checked
                ? Icon(
                    Icons.check,
                    size: 14.r,
                    color: AppColors.background,
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text('Remember me', style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          boxShadow: disabled ? const [] : glow.accentGlowLg,
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor:
                AppColors.accent.withValues(alpha: 0.50),
            foregroundColor: AppColors.background,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
            ),
          ),
          child: loading
              ? SizedBox(
                  height: 20.r,
                  width: 20.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.background),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.bodyPrimary.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text('OR CONTINUE WITH', style: AppTextStyles.eyebrow),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}
