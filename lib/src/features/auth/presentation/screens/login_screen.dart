import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_music/src/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SoundCloud Sign-In')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Center(
            child:
                state.isLoading
                    ? const CircularProgressIndicator()
                    : _buildSignInButton(),
          );
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton.icon(
      label: const Text('Sign in with SoundCloud'),
      onPressed: () {
        context.read<AuthBloc>().add(const SignInWithSoundCloudEvent());
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
