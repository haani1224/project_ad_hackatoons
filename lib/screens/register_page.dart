import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final icController =
      TextEditingController();

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  final authService = AuthService();

  bool loading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  Future<void> register() async {

    if (passwordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Passwords do not match'),
        ),
      );

      return;
    }

    try {
      setState(() => loading = true);

      await authService.register(
        icNumber: icController.text.trim(),
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      showDialog(
          context: context,
          barrierDismissible: false,

          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Registration Sent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),


              content: const Text(
                "Your account has been successfully submitted.\n\n"
                "Please wait for the principal to approve your account before logging in.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),


              actions: [

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF2E4365),

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: () {

                      Navigator.pop(context); // close dialog

                      Navigator.pop(context); // back to login

                    },

                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ],
            );
          },
        );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget _buildField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
}) {

  return TextField(
    controller: controller,
    obscureText: obscure,

    decoration: InputDecoration(

      labelText: label,

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF2E4365),
      ),

      filled: true,

      fillColor: Colors.grey.shade100,


      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide:
            BorderSide.none,
      ),


      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide:
            BorderSide(
          color: const Color(0xFF2E4365),
          width: 2,
        ),
      ),
    ),
  );
}

Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool hide,
  required VoidCallback onTap,
}) {

  return TextField(
    controller: controller,
    obscureText: hide,

    decoration: InputDecoration(

      labelText: label,

      prefixIcon: const Icon(
        Icons.lock_outline,
        color: const Color(0xFF2E4365),
      ),

      suffixIcon: IconButton(
        icon: Icon(
          hide
              ? Icons.visibility
              : Icons.visibility_off,
          color: Colors.grey,
        ),

        onPressed: onTap,
      ),

      filled: true,

      fillColor: Colors.grey.shade100,


      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: const Color(0xFF2E4365),
          width: 2,
        ),
      ),
    ),
  );
}

@override
void dispose() {
  icController.dispose();
  nameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();

  super.dispose();
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F6FB),
    appBar: AppBar(
      title: const Text(
        "Create Account",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFF2E4365),
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),

    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            const SizedBox(height: 20),

            // Logo Circle
            Hero(
              tag: "logo",
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Image.asset(
                      'assets/LOGO TADIKA AQIL MIQAIL.jpg',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ),


            const SizedBox(height: 18),


            const Text(
              "Join Genius Aqil OS",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4365),
              ),
            ),


            const SizedBox(height: 6),


            const Text(
              "Register your teacher account",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),


            const SizedBox(height: 25),


            // Register Card
            Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              child: Padding(
                padding: const EdgeInsets.all(22),

                child: Column(
                  children: [

                    _buildField(
                      controller: icController,
                      label: "IC Number",
                      icon: Icons.badge_outlined,
                    ),


                    const SizedBox(height: 15),


                    _buildField(
                      controller: nameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                    ),


                    const SizedBox(height: 15),


                    _buildField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                    ),


                    const SizedBox(height: 15),


                    _buildPasswordField(
                      controller: passwordController,
                      label: "Password",
                      hide: hidePassword,
                      onTap: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),


                    const SizedBox(height: 15),


                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: "Confirm Password",
                      hide: hideConfirmPassword,
                      onTap: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                    ),


                    const SizedBox(height: 25),


                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed:
                            loading ? null : register,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2E4365),

                          foregroundColor:
                              Colors.white,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),

                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 20),

          ],
        ),
      ),
    ),
  );
}
}