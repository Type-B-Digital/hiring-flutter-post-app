import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:postsapp/core/constants/app_colors.dart';
import 'package:postsapp/core/constants/app_text_styles.dart';
import 'package:postsapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:postsapp/features/posts/presentation/posts_screen.dart';
import 'package:postsapp/shared/widgets/custom_text_field.dart';
import 'package:postsapp/shared/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginButtonClickedEvent(
          _usernameController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: screenWidth,
              height: 300,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                children: [
                  Spacer(),
                  SvgPicture.asset(
                    'assets/app_logo/app_logo.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text('NewsBay', style: AppTextStyles.title),
                  SizedBox(height: 25),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticatedState) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const PostsScreen(),
                          ),
                        );
                      }
                      if (state is AuthErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.failure.message)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                'Welcome Back',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Spacer(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Username is required'
                                : null,
                            hint: 'Username',
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Password is required'
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            hint: 'Password',
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: (s) {
                                    setState(() {
                                      rememberMe = s!;
                                    });
                                  },
                                  activeColor: AppColors.primaryGreen,
                                  checkColor: Colors.white,
                                  side: const BorderSide(
                                    color: AppColors.secondary,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Remember me',
                                style: AppTextStyles.captionLight,
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Coming soon',
                                        style: AppTextStyles.footnoteMedium
                                            .copyWith(color: AppColors.white),
                                      ),
                                      backgroundColor: AppColors.primaryBlack,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: AppTextStyles.captionLight.copyWith(
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            label: 'Login',
                            isLoading: false,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                'Or',
                                style: AppTextStyles.captionLight.copyWith(
                                  color: AppColors.blue,
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 52,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(
                                color: AppColors.line,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/google.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Coming soon',
                                          style: AppTextStyles.footnoteMedium
                                              .copyWith(color: AppColors.white),
                                        ),
                                        backgroundColor: AppColors.primaryBlack,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login with Google',
                                    style: AppTextStyles.footnoteMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                'Not a member?',
                                style: AppTextStyles.footnoteRegular,
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Coming soon',
                                        style: AppTextStyles.footnoteMedium
                                            .copyWith(color: AppColors.white),
                                      ),
                                      backgroundColor: AppColors.primaryBlack,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up',
                                  style: AppTextStyles.footnoteMedium.copyWith(
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
