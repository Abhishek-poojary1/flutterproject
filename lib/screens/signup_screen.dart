// File: lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterproject/%20blocs/auth_bloc.dart';
import '../widgets/dynamic_widget_renderer.dart';
import '../services/config_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Map<String, dynamic>? _uiConfig;
  bool _loadingConfig = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthenticationStatus());
    _loadUIConfig();
  }

  Future<void> _loadUIConfig() async {
    final configService = context.read<ConfigService>();
    try {
      final config = await configService.loadUIConfig('signup');
      setState(() {
        _uiConfig = config;
        _loadingConfig = false;
      });
    } catch (e) {
      setState(() {
        _loadingConfig = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadingConfig)
                    const Center(child: CircularProgressIndicator())
                  else if (_uiConfig != null)
                    DynamicWidgetRenderer(
                      jsonData: _uiConfig,
                      controllers: {
                        'name': _nameController,
                        'email': _emailController,
                        'password': _passwordController,
                        'confirmPassword': _confirmPasswordController,
                      },
                      onActionCallback: (actionType, actionData) {
                        if (actionType == 'signup') {
                          // Handle signup action
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            context
                                .read<AuthBloc>()
                                .add(SignUpWithEmailRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  name: _nameController.text.trim(),
                                ));
                          }
                        } else if (actionType == 'navigate') {
                          if (actionData['route'] == 'login') {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }
                      },
                    )
                  else
                    const Text('Create your account',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildSignupForm(state),
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Already have an account? Log in'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignupForm(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state is AuthLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      context.read<AuthBloc>().add(SignUpWithEmailRequested(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            name: _nameController.text.trim(),
                          ));
                    }
                  },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
