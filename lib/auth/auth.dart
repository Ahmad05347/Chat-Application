import 'dart:io';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreens extends StatefulWidget {
  const AuthScreens({super.key});

  @override
  State<AuthScreens> createState() => _AuthScreensState();
}

class _AuthScreensState extends State<AuthScreens> {
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = "";
  var _enteredPasswords = "";
  var _enteredUsername = "";
  File? _selectedImage;
  var _isAuthenticating = false;

  var _isLoggedIn = true;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLoggedIn && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLoggedIn) {
        final userCredentials = _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPasswords);
        print(userCredentials);
      } else {
        final usersCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPasswords);
        print(usersCredentials);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("users_images")
            .child("${usersCredentials.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(usersCredentials.user!.uid)
            .set({
          "username": _enteredUsername,
          "e-mail": _enteredEmail,
          "image-url": imageURL
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use" ||
          error.code == "wrong email or password") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication Failed"),
        ),
      );
      setState(() {
        _isAuthenticating = false;
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
                width: 200,
                margin: const EdgeInsets.only(
                    top: 30, right: 20, left: 20, bottom: 20),
                child: Image.asset("lib/images/ideogram (1).jpeg"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLoggedIn)
                          UserImagePicker(
                            onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: "Email"),
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains("@")) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                          onSaved: (newvalue) {
                            _enteredEmail = newvalue!;
                          },
                        ),
                        if (!_isLoggedIn)
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Username"),
                            style: const TextStyle(color: Colors.white),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 4 ||
                                  value.isEmpty) {
                                return "Please enter atleast 4 letters";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Password"),
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "Password must contain atleast 6 letters";
                            }
                            return null;
                          },
                          onSaved: (newvalue) {
                            _enteredPasswords = newvalue!;
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(
                              _isLoggedIn ? "LogIn" : "SignUp",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoggedIn = !_isLoggedIn;
                              });
                            },
                            child: Text(_isLoggedIn
                                ? "Create an account"
                                : "SignIn with an exsisting account"),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
