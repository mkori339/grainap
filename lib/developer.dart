import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperProfilePage extends StatelessWidget {
  const DeveloperProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.white),
        backgroundColor: Colors.blueGrey.shade900,
        title: Text(
          'About Developer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: DeveloperProfileCard(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade900,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '© 2025 Hafidhi Mkori - All Rights Reserved',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class DeveloperProfileCard extends StatelessWidget {
  const DeveloperProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('images/image1.webp'),
          ),
          SizedBox(height: 20),
          Text(
            'Hafidhi Mkori',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Software Developer',
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Passionate about building beautiful and functional mobile applications. Loves to explore new technologies and solve real-world problems.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Phone no: 0785226584',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialMediaButton(
                icon: Icons.facebook,
                onPressed: () async {
                  const url = 'https://www.facebook.com/profile.php?id=61557046421220';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SizedBox(width: 10),
              SocialMediaButton(
                icon: Icons.link,
                onPressed: () async {
                  const url = 'https://portifolio-psi-fawn-94.vercel.app/#pigraHome';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SizedBox(width: 10),
              SocialMediaButton(
                icon: Icons.email,
                onPressed: () async {
                  const email = 'mailto:mkorihafidhi@gmail.com';
                  if (await canLaunchUrl(Uri.parse(email))) {
                    await launchUrl(Uri.parse(email));
                  } else {
                    throw 'Could not launch $email';
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialMediaButton({super.key, 
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.blueGrey.shade700,
        size: 30,
      ),
      onPressed: onPressed,
    );
  }
}
