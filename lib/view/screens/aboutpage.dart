import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "At Cubosquare, we specialize in transforming your ideas into reality. Whether you're looking for a SAAS, CRM, AI solution, web development, or mobile app, our expert team delivers tailored solutions to bring your vision to life. Like and share with your loved ones and let us help turn your dreams into innovation.",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
