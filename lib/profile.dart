import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/post_widgets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  User? get _currentUser => _auth.currentUser;

  Future<void> _showEditProfileDialog(Map<String, dynamic> userData) async {
    final nameController = TextEditingController(text: (userData['name'] ?? '').toString());
    final emailController = TextEditingController(text: (userData['email'] ?? '').toString());

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  await _currentUser?.updateDisplayName(nameController.text.trim());
                  if ((_currentUser?.email ?? '') != emailController.text.trim()) {
                    await _currentUser?.updateEmail(emailController.text.trim());
                  }
                  await _firestore.collection('users').doc(_currentUser!.uid).set({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                  }, SetOptions(merge: true));

                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated.')),
                  );
                } on FirebaseAuthException catch (error) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message ?? 'Unable to update profile.')),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await _currentUser?.sendEmailVerification();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email sent to ${_currentUser?.email}.')),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Unable to send email.')),
      );
    }
  }

  Future<void> _showDeleteDialog() async {
    final passwordController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('This action is permanent. Enter your password to continue.'),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  final credential = EmailAuthProvider.credential(
                    email: _currentUser!.email!,
                    password: passwordController.text,
                  );
                  await _currentUser!.reauthenticateWithCredential(credential);
                  await _firestore.collection('users').doc(_currentUser!.uid).delete();
                  await _currentUser!.delete();

                  if (!mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (error) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message ?? 'Unable to delete account.')),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: MarketBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _firestore.collection('users').doc(user.uid).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.data() ?? <String, dynamic>{};
                    final verified = user.emailVerified;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        MarketPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white.withOpacity(0.08),
                                    child: const Icon(Icons.person_outline_rounded, size: 36),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          (data['name'] ?? user.displayName ?? 'Trader').toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          (data['email'] ?? user.email ?? '').toString(),
                                          style: TextStyle(color: Colors.white.withOpacity(0.68)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: verified
                                          ? Colors.green.withOpacity(0.14)
                                          : Colors.orange.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          verified
                                              ? Icons.verified_outlined
                                              : Icons.mark_email_unread_outlined,
                                          size: 16,
                                          color: verified ? Colors.greenAccent : Colors.orangeAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          verified ? 'Verified' : 'Pending',
                                          style: TextStyle(
                                            color: verified ? Colors.greenAccent : Colors.orangeAccent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: <Widget>[
                                  InfoPill(
                                    icon: verified ? Icons.verified_outlined : Icons.mark_email_unread_outlined,
                                    label: verified ? 'Email verified' : 'Verification optional',
                                  ),
                                  if (!verified)
                                    InfoPill(
                                      icon: Icons.send_outlined,
                                      label: 'Send verification link',
                                    ),
                                ],
                              ),
                              if (!verified) ...<Widget>[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _sendVerificationEmail,
                                  icon: const Icon(Icons.mail_outline_rounded),
                                  label: const Text('Send verification email'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        MarketPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SectionHeader(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Account actions',
                                subtitle: 'Manage your identity and security settings.',
                              ),
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: () => _showEditProfileDialog(data),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit profile'),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _showDeleteDialog,
                                icon: const Icon(Icons.delete_outline_rounded),
                                label: const Text('Delete account'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
