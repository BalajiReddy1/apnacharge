import 'package:ev_app/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.medgreen,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: const BoxDecoration(
            //   color: AppColors.lightgreen,
            // ),
            decoration: BoxDecoration(color: Colors.white),
            child: Image.asset(
              'assets/icons/new_logo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: Colors.white,
            ),
            title: Text('Favorites',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const FavoritesScreen(),
              //   ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const SettingsScreen(),
              //   ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: Text('About',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const AboutScreen(),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}
