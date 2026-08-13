import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),

        child: Column(
          children: [
            //notification row
            Container(
              height: size.height * 0.10,
              width: size.width,
              color: Colors.white,
              child: Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.notifications_active_outlined),
                  SizedBox(width: 5),
                  //profile
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0D1B2A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
