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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                "About Weather Hub",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Weather Hub is your go-to app for accurate and real-time weather updates. Whether you’re planning your day, a trip, or just staying informed, Weather Hub provides:\n\n"
                "- Live Weather Updates: Access current weather conditions for any location.\n"
                "- Detailed Forecasts: Hourly and daily forecasts to help you plan ahead.\n"
                "- Customizable Locations: Save your favorite places for quick weather checks.\n"
                "- User-Friendly Interface: Designed for ease of use with clear visuals and data.\n\n"
                "Stay prepared with Weather Hub – your ultimate weather companion!",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
