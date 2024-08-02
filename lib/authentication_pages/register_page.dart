import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:kidnav/login_components/my_button.dart";
import "package:kidnav/login_components/my_textfield.dart";

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final parentLNameController = TextEditingController();
  final parentFNameController = TextEditingController();
  final parentPhoneNoController = TextEditingController();
  final childLNameController = TextEditingController();
  final childFNameController = TextEditingController();
  final childDOBController = TextEditingController();

  //sign user up method
  Future signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try creating user account
    try {
      //check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        //create the user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //after creating the user, create a new document in cloud firstore called Users

        FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email)
            .set({
          "username": emailController.text.split('@')[0],
          "bio": "Empty bio...", //initially an empty bio
          //add any additional fields needed
          "Parent's Last Name": parentLNameController.text,
          "Parent's First Name": parentFNameController.text,
          "Parent's email address": emailController.text,
          "Parent's Phone Number": parentPhoneNoController.text,
          "Child's First Name": childFNameController.text,
          "Child's Last Name": childLNameController.text,
          "Child's DOB": childDOBController.text,
        });
      } else {
        //show error message, passwords don't match
        showErrorMessage("Passwords don't match");
      }
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);

      //show error message
      showErrorMessage(e.code);
    }
  }

  //error message to user
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  //date picker
  Future<void> selectDOB() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        childDOBController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),

                //logo
                Image.asset("lib/images/kidNav Logo.png"),

                const SizedBox(
                  height: 20,
                ),

                // Let's create an account for you!
                Text(
                  "Let\'s create an account for you!",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // PARENT'S INFORMATION
                const SizedBox(height: 15),

                const Text(
                  "Parent/Guardian Information",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 5),

                //first Name
                MyTextfield(
                  controller: parentFNameController,
                  hintText: "Guardian's First name",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //Last Name
                MyTextfield(
                  controller: parentLNameController,
                  hintText: "Gaurdian's Last Name",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // email textfield
                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                //Phone number
                MyTextfield(
                  controller: parentPhoneNoController,
                  hintText: "Phone Number",
                  obscureText: false,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),

                // password textfiled
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // confirm password textfiled
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

                // CHILD'S INFORMATION
                const SizedBox(height: 30),

                const Text(
                  "Child's Information",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),

                //First name
                MyTextfield(
                  controller: childFNameController,
                  hintText: "Child's First Name",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //Last Name
                MyTextfield(
                  controller: childLNameController,
                  hintText: "Child's Last Name",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //Date of Birth
                MyTextfield(
                  controller: childDOBController,
                  hintText: "Child's Date of Birth",
                  obscureText: false,
                  onTap: () {
                    selectDOB();
                  },
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 30),

                // sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: signUserUp,
                ),

                const SizedBox(height: 25),

                // not a memeber? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          color: Color(0xff3c2c74),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
