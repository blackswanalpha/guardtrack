import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../../../../main.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _twoFactorFocusNode = FocusNode();

  bool _showTwoFactorField = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _twoFactorController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _twoFactorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Darker blue for admin
              Color(0xFF3949AB), // Lighter blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAdminLogo(),
                  const SizedBox(height: AppConstants.largePadding * 2),
                  _buildAdminLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: AppColors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            size: 60,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'Admin Portal',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.white,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Secure Administrative Access',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // Handle different error types with appropriate colors and actions
          Color backgroundColor;
          IconData? icon;

          switch (state.type) {
            case AuthFailureType.validationError:
              backgroundColor = AppColors.warningAmber;
              icon = Icons.warning;
              break;
            case AuthFailureType.invalidCredentials:
              backgroundColor = AppColors.errorRed;
              icon = Icons.error;
              break;
            case AuthFailureType.twoFactorInvalid:
              backgroundColor = AppColors.warningAmber;
              icon = Icons.security;
              // Clear 2FA field on invalid code
              _twoFactorController.clear();
              _twoFactorFocusNode.requestFocus();
              break;
            case AuthFailureType.networkError:
              backgroundColor = AppColors.errorRed;
              icon = Icons.wifi_off;
              break;
            default:
              backgroundColor = AppColors.errorRed;
              icon = Icons.error;
          }

          // Get enhanced error message
          final enhancedMessage = AuthErrorMessages.getActionableMessage(
            state.type,
            state.message,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          enhancedMessage.split('\n\n').first,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  if (enhancedMessage.contains('\n\n')) ...[
                    const SizedBox(height: 4),
                    Text(
                      enhancedMessage.split('\n\n').last,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w300),
                    ),
                  ],
                ],
              ),
              backgroundColor: backgroundColor,
              duration: const Duration(
                  seconds: 6), // Longer duration for enhanced messages
              behavior: SnackBarBehavior.floating,
              action: state.type == AuthFailureType.networkError
                  ? SnackBarAction(
                      label: 'Retry',
                      textColor: AppColors.white,
                      onPressed: () => _handleAdminLogin(),
                    )
                  : null,
            ),
          );
        } else if (state is AuthSuccess) {
          // Check if user is admin and navigate accordingly
          if (state.user.user.isAdmin) {
            // Show success message and navigate to admin portal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Welcome to Admin Portal, ${state.user.user.firstName}!',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.accentGreen,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Clear the navigation stack and return to root
            // This allows AppNavigator to properly route to AdminMainNavigationPage
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AppNavigator()),
              (route) => false,
            );
          } else {
            // User is not admin - show error and logout
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: AppColors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Access denied. Admin privileges required.'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.errorRed,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Logout the user since they don't have admin privileges
            context.read<AuthBloc>().add(LogoutRequested());
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Administrator Login',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Enter your admin credentials',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.largePadding),
                CustomTextField(
                  label: 'Admin Email',
                  hint: 'Enter your admin email',
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.admin_panel_settings_outlined,
                  validator: _validateEmail,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  enabled: !isLoading,
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: _validatePassword,
                  onSubmitted: (_) => _showTwoFactorField
                      ? _twoFactorFocusNode.requestFocus()
                      : _handleAdminLogin(),
                  enabled: !isLoading,
                ),
                if (_showTwoFactorField) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  CustomTextField(
                    label: '2FA Code',
                    hint: 'Enter 6-digit code',
                    controller: _twoFactorController,
                    focusNode: _twoFactorFocusNode,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.security,
                    validator: _validateTwoFactor,
                    onSubmitted: (_) => _handleAdminLogin(),
                    enabled: !isLoading,
                    maxLength: 6,
                  ),
                ],
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                      activeColor: AppColors.primaryBlue,
                    ),
                    Text(
                      'Remember me',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.largePadding),
                CustomButton(
                  text: _showTwoFactorField ? 'Verify & Sign In' : 'Sign In',
                  onPressed: isLoading ? null : _handleAdminLogin,
                  isLoading: isLoading,
                  icon: Icons.login,
                  backgroundColor: const Color(0xFF1A237E),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                if (!_showTwoFactorField)
                  CustomButton(
                    text: 'Use 2FA (Optional)',
                    onPressed: isLoading ? null : _requestTwoFactorCode,
                    type: ButtonType.outline,
                    icon: Icons.security,
                  ),
                if (_showTwoFactorField)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Skip 2FA',
                          onPressed: isLoading ? null : _skipTwoFactor,
                          type: ButtonType.outline,
                          icon: Icons.skip_next,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: CustomButton(
                          text: 'Resend Code',
                          onPressed: isLoading ? null : _resendTwoFactorCode,
                          type: ButtonType.outline,
                          icon: Icons.refresh,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Admin email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  String? _validateTwoFactor(String? value) {
    if (value == null || value.isEmpty) {
      return '2FA code is required';
    }

    if (value.length != 6) {
      return '2FA code must be 6 digits';
    }

    return null;
  }

  void _handleAdminLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement admin login with 2FA
      context.read<AuthBloc>().add(
            AdminLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              twoFactorCode:
                  _showTwoFactorField ? _twoFactorController.text : null,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  void _requestTwoFactorCode() {
    // Validate email and password first
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your admin email first'),
          backgroundColor: AppColors.warningAmber,
        ),
      );
      _emailFocusNode.requestFocus();
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password first'),
          backgroundColor: AppColors.warningAmber,
        ),
      );
      _passwordFocusNode.requestFocus();
      return;
    }

    // Validate email format
    if (_validateEmail(_emailController.text.trim()) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.warningAmber,
        ),
      );
      _emailFocusNode.requestFocus();
      return;
    }

    // Validate password length
    if (_validatePassword(_passwordController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password must be at least ${AppConstants.minPasswordLength} characters'),
          backgroundColor: AppColors.warningAmber,
        ),
      );
      _passwordFocusNode.requestFocus();
      return;
    }

    // Show 2FA field and simulate sending code
    setState(() {
      _showTwoFactorField = true;
    });

    // TODO: Request 2FA code from server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            '2FA code sent to your email. Check your inbox and enter the 6-digit code below.'),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 4),
      ),
    );

    // Focus on 2FA field after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _twoFactorFocusNode.requestFocus();
    });
  }

  void _skipTwoFactor() {
    setState(() {
      _showTwoFactorField = false;
      _twoFactorController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            '2FA skipped. You can login without 2FA or use it later for enhanced security.'),
        backgroundColor: AppColors.primaryBlue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resendTwoFactorCode() {
    // TODO: Implement actual resend 2FA code logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('2FA code resent to your email. Please check your inbox.'),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 3),
      ),
    );

    // Clear the current 2FA input and refocus
    _twoFactorController.clear();
    _twoFactorFocusNode.requestFocus();
  }
}
