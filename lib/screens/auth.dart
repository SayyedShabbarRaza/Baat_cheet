import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final firebase = FirebaseAuth.instance;
final storage = FirebaseStorage.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  var enteredEmail = '';
  var enteredPassword = '';
  var isLogin = true;
  File? pickedImageFile;
  String? imageUrl;
  var isAuthenticating = false;
  var enteredUsername;

  void pickImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
  }

  void submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    form.currentState!.save();
    try {
      setState(() {
        isAuthenticating = true;
      });
      if (isLogin) {
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('user_Images')
            .child('${userCredentials.user!.uid}.jpg');
        await imageRef.putFile(pickedImageFile!);
        imageUrl = await imageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredEmail,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      String message = 'Authentication failed';
      if (error.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (error.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (error.code == 'invalid-email') {
        message = 'Invalid email provided.';
      } else if (error.code == 'email-already-in-use') {
        message = 'The email is already in use by another account.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred')));

      setState(() {
        isAuthenticating = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/logo.png'),
              ),
              Card(
                margin: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLogin)
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey,
                                  foregroundImage: pickedImageFile != null
                                      ? FileImage(pickedImageFile!)
                                      : null,
                                ),
                                TextButton.icon(
                                  onPressed: pickImage,
                                  icon: Icon(Icons.image),
                                  label: Text(
                                    'Add Image',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                              ],
                            ),
                            if(!isLogin)
                            TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Username"),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 4) {
                                return 'Please enter at least 4 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredUsername = value!;
                            },
                          ),

                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Email Address"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid Email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Password"),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (isAuthenticating) CircularProgressIndicator(),
                          if (!isAuthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(isLogin ? "Login" : "Sign Up"),
                            ),
                          if (!isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(isLogin
                                  ? "Create an Account"
                                  : "Already have an account?"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
