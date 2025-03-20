import 'package:flutter/material.dart';

class Constants {
  static final Color primaryColor = Colors.blue; // Change color as needed
  static final Color blackColor = Colors.black;
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Flexible(
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Constants.primaryColor.withOpacity(.5),
                      width: 5.0,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage: ExactAssetImage('assets/profile.png'), // Update with a valid asset
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // User Name and Verification Icon
              SizedBox(
                width: size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        color: Constants.blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 24.0,
                      child: Image.asset("assets/profile.png"), // Update with a valid asset
                    ),
                  ],
                ),
              ),

              // Email
              Text(
                'johndoe@gmail.com',
                style: TextStyle(color: Constants.blackColor.withOpacity(.3)),
              ),

              const SizedBox(height: 30.0),

              // Profile Options
              SizedBox(
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileWidget(icon: Icons.person, title: 'My Profile'),
                    ProfileWidget(icon: Icons.settings, title: 'Settings'),
                    ProfileWidget(icon: Icons.notifications, title: 'Notifications'),
                    ProfileWidget(icon: Icons.chat, title: 'FAQs'),
                    ProfileWidget(icon: Icons.share, title: 'Share'),
                    ProfileWidget(icon: Icons.logout, title: 'Log out'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Option Widget
class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileWidget({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Constants.blackColor.withOpacity(.5), size: 24.0),
              const SizedBox(width: 16.0),
              Text(
                title,
                style: TextStyle(
                  color: Constants.blackColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Constants.blackColor.withOpacity(.3),
            size: 16.0,
          ),
        ],
      ),
    );
  }
}
