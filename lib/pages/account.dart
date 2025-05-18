import 'package:ppbtest/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountDetail extends StatelessWidget {
  const AccountDetail({super.key});

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              title: const Text(
                'Profil Saya',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.cyan.shade700,
                    ),
                  ),

                  const SizedBox(height: 40),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Logged in as ',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        TextSpan(
                          text: snapshot.data?.email ?? '',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
