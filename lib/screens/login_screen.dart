import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterproject/%20blocs/auth_bloc.dart';
import '../widgets/dynamic_widget_renderer.dart';
import '../services/config_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Map<String, dynamic>? _uiConfig;
  bool _loadingConfig = true;
  bool _isPhoneVerification = false;
  String? _verificationId;

  // Controllers that will be connected to the dynamic form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthenticationStatus());
    _loadUIConfig();
  }

  Future<void> _loadUIConfig() async {
    final configService = context.read<ConfigService>();
    try {
      final config = await configService.loadUIConfig('login');
      print('Loaded UI config type: ${config.runtimeType}');
      print('Loaded UI config: $config');
      setState(() {
        _uiConfig = config;
        _loadingConfig = false;
      });
    } catch (e) {
      print('Error loading UI config: $e');
      setState(() {
        _loadingConfig = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is PhoneVerificationSent) {
            setState(() {
              _isPhoneVerification = true;
              _verificationId = state.verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification code sent to your phone')),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: _isPhoneVerification
                ? _buildPhoneVerificationForm(state)
                : _buildDynamicLoginUI(state),
          );
        },
      ),
    );
  }

  Widget _buildDynamicLoginUI(AuthState state) {
    if (_loadingConfig) {
      return const Center(child: CircularProgressIndicator());
    } else if (_uiConfig != null) {
      return DynamicWidgetRenderer(
        jsonData: _uiConfig,
        controllers: {
          'email': _emailController,
          'password': _passwordController,
          'phone': _phoneController,
        },
        onActionCallback: (actionType, actionData) {
          if (actionType == 'login') {
            _handleLoginAction(actionData, state);
          } else if (actionType == 'navigate') {
            if (actionData['route'] == 'signup') {
              Navigator.pushReplacementNamed(context, '/signup');
            }
          }
        },
      );
    } else {
      return const Center(
        child: Text('Failed to load the login interface. Please try again.'),
      );
    }
  }

  void _handleLoginAction(Map<String, dynamic> actionData, AuthState state) {
    if (state is AuthLoading) return;

    final method = actionData['method'];
    FocusScope.of(context).unfocus();

    switch (method) {
      case 'email':
        context.read<AuthBloc>().add(LoginWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ));
        break;
      case 'google':
        context.read<AuthBloc>().add(LoginWithGoogleRequested());
        break;
      case 'apple':
        context.read<AuthBloc>().add(LoginWithAppleRequested());
        break;
      case 'phone':
        final phoneNumber = _phoneController.text.trim();
        if (phoneNumber.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid phone number')),
          );
          return;
        }
        context.read<AuthBloc>().add(PhoneVerificationRequested(
              phoneNumber: phoneNumber,
            ));
        break;
    }
  }

  Widget _buildPhoneVerificationForm(AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the verification code sent to ${_phoneController.text}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _smsCodeController,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    context.read<AuthBloc>().add(
                          PhoneVerificationCodeSubmitted(
                            verificationId: _verificationId!,
                            smsCode: _smsCodeController.text.trim(),
                          ),
                        );
                  },
            child: const Text('Verify'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    setState(() {
                      _isPhoneVerification = false;
                      _verificationId = null;
                    });
                  },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }
}
