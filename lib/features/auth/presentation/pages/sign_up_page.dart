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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.onSwitchToSignIn});

  final VoidCallback onSwitchToSignIn;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_agreed) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(AuthSignUpRequested(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        ));
  }

  void _goToLogin() => widget.onSwitchToSignIn();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Join the campus',
      subtitle:
          'Create your account in 30 seconds and unlock your full campus experience.',
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
          final canSubmit = _agreed && !loading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthModeToggle(
                mode: AuthMode.signUp,
                onChanged: (m) {
                  if (m == AuthMode.signIn) _goToLogin();
                },
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              AuthTextField(
                controller: _name,
                hint: 'Full name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              SizedBox(height: 12.h),
              AuthTextField(
                controller: _email,
                hint: 'Campus email address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              SizedBox(height: 12.h),
              AuthTextField(
                controller: _password,
                hint: 'Create password',
                icon: Icons.lock_outline,
                obscure: _obscure,
                onToggleObscure: () =>
                    setState(() => _obscure = !_obscure),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
              ),
              SizedBox(height: 12.h),
              _TermsCheckbox(
                checked: _agreed,
                onChanged: (v) => setState(() => _agreed = v),
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              _PrimaryCta(
                label: 'Create Account',
                enabled: canSubmit,
                loading: loading,
                onPressed: canSubmit ? _submit : null,
              ),
              SizedBox(height: AppSpacing.sectionGap.h),
              const _OrDividerSignUp(),
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
                  onTap: _goToLogin,
                  behavior: HitTestBehavior.opaque,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySecondary,
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.r,
            height: 18.r,
            margin: EdgeInsets.only(top: 2.h),
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
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySecondary,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glow = Theme.of(context).extension<AppGlowTheme>()!;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard.r),
          boxShadow: enabled ? glow.accentGlowLg : const [],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: enabled
                ? AppColors.accent
                : AppColors.surface,
            disabledBackgroundColor: AppColors.surface,
            foregroundColor: AppColors.background,
            disabledForegroundColor: AppColors.textTertiary,
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
                    color: enabled
                        ? AppColors.background
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
        ),
      ),
    );
  }
}

class _OrDividerSignUp extends StatelessWidget {
  const _OrDividerSignUp();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text('OR SIGN UP WITH', style: AppTextStyles.eyebrow),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}
