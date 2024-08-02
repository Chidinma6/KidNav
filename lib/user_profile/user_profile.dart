import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidnav/user_profile/detail_text_box.dart';
import 'package:kidnav/user_profile/main_text_box.dart';
import 'package:intl/intl.dart'; // For date formatting

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // User
  final activeUser = FirebaseAuth.instance.currentUser!;
  // All users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  // Local state to hold user data
  Map<String, dynamic> userData = {};

  // Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Edit field method
  Future<void> editField(String field) async {
    String newValue = "";

    // If the field is Date of Birth, show date picker
    if (field.toLowerCase().contains("dob")) {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        newValue = DateFormat('yyyy-MM-dd').format(pickedDate);
      }
    } else {
      // Show dialog for text input
      newValue = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Color.fromARGB(255, 71, 26, 26)),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Color.fromARGB(255, 59, 46, 46)),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: const TextStyle(
                color: Color.fromARGB(148, 82, 59, 69),
              ),
            ),
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color.fromARGB(255, 73, 67, 67)),
              ),
            ),
            // Save button
            TextButton(
              onPressed: () => Navigator.of(context).pop(newValue),
              child: const Text(
                "Save",
                style: TextStyle(color: Color.fromARGB(255, 95, 61, 61)),
              ),
            ),
          ],
        ),
      );
    }

    // Update in Firestore and locally
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(activeUser.email).update({field: newValue});
      setState(() {
        userData[field] = newValue;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data from Firestore
  void fetchUserData() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(activeUser.email)
        .get()
        .then((snapshot) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Color(0xffdcdae7),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 50),

                // Profile pic
                const Icon(
                  Icons.person,
                  size: 72,
                ),

                // User email
                Text(
                  activeUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),

                const SizedBox(height: 50),

                // User details
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    "My Profile Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Username
                MyTextBox(
                  text: userData['username'] ?? 'No username',
                  sectionName: "Username",
                  onPressed: () => editField('username'),
                ),

                // Bio
                MyTextBox(
                  text: userData['bio'] ?? 'No bio',
                  sectionName: "Bio",
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 10),

                // Divider between bio and parent's information
                const Divider(
                  color: Colors.grey,
                  thickness: 8,
                  indent: 25.0,
                  endIndent: 25.0,
                ),

                // Parent's details
                DetailTextBox(
                  text:
                      'Parent\'s First Name: ${userData['Parent\'s First Name'] ?? 'No first name'}\n'
                      'Parent\'s Last Name: ${userData['Parent\'s Last Name'] ?? 'No last name'}\n'
                      'Parent\'s Phone Number: ${userData['Parent\'s Phone Number'] ?? 'No phone number'}',
                  sectionName: "Parent's or Guardian Information",
                  onPressed: (fieldName) => editField(fieldName),
                ),

                // Child's details
                DetailTextBox(
                  text:
                      'Child\'s First Name: ${userData['Child\'s First Name'] ?? 'No first name'}\n'
                      'Child\'s Last Name: ${userData['Child\'s Last Name'] ?? 'No last name'}\n'
                      'Child\'s DOB: ${userData['Child\'s DOB'] ?? 'No date of birth'}',
                  sectionName: "Child's Information",
                  onPressed: (fieldName) => editField(fieldName),
                ),
              ],
            ),
    );
  }
}
