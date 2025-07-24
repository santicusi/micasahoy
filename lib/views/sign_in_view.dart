import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_system_flutter/routes/routes.dart';
import 'package:booking_system_flutter/strapi_service.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  // Paleta de colores GEOCAT
  static const Color primaryGreen = Color(0xFF7CB342);
  static const Color darkGreen = Color(0xFF558B2F);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFC62828);
  static const Color primaryBrown = Color(0xFF8D6E63);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color accentGold = Color(0xFFFBC02D);
  static const Color darkGold = Color(0xFFF9A825);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF666666);

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa tu correo y contraseña'),
          backgroundColor: darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final strapiService = StrapiService();
    final response = await strapiService.loginUser(email, password);

    if (response['success']) {
      final user = response['data']['user'];
      final jwt = response['data']['jwt'];
      final userId = user['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', jwt);
      await prefs.setInt('userId', userId);

      final verifyResponse = await strapiService.verifyToken();

      if (verifyResponse['success']) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
      } else {
        await strapiService.deleteToken();
        final errorMessage = verifyResponse['message'];
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } else {
      final errorMessage = response['message'];
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo y branding
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título principal
                        const Text(
                          'Sistema de Registro de Predios',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtítulo
                        const Text(
                          'Gestiona tus propiedades de forma segura',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryBrown,
                            height: 1.4,
                          ),
                        ),

                        // Línea decorativa
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          height: 1,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentGold.withOpacity(0.3),
                                accentGold,
                                accentGold.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),

                        // Campo de email
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: darkBrown,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle: TextStyle(
                              color: primaryBrown.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: primaryGreen,
                              size: 22,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: lightGrey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: lightGrey, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryGreen, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: darkRed, width: 1.5),
                            ),
                            filled: true,
                            fillColor: pureWhite,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo de contraseña
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            fontSize: 16,
                            color: darkBrown,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                              color: primaryBrown.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: primaryGreen,
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _obscurePassword ? primaryBrown : primaryGreen,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: lightGrey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: lightGrey, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryGreen, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: darkRed, width: 1.5),
                            ),
                            filled: true,
                            fillColor: pureWhite,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de login
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: pureWhite,
                              disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                              elevation: 4,
                              shadowColor: primaryGreen.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                darkGreen.withOpacity(0.1),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: pureWhite,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Texto descriptivo
                        Text(
                          'Accede al sistema para administrar la información de tus propiedades.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Link de registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿No tienes cuenta? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBrown,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.signUp);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: primaryRed,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Crea una aquí',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
