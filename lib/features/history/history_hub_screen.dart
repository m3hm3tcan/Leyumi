import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/history/tabs/feeding_tab.dart';
import 'package:babyfeedpro/features/history/tabs/growth_tab.dart';

class HistoryHubScreen extends StatelessWidget {
  const HistoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // ileride 3 (Diaper eklenecek)
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),

        appBar: AppBar(
          title: const Text("History Hub"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,

          bottom: const TabBar(
            indicatorColor: Color(0xff4DA3FF),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Feeding", icon: Icon(Icons.local_drink)),
              Tab(text: "Growth", icon: Icon(Icons.show_chart)),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            FeedingTab(),
            GrowthTab(),
          ],
        ),
      ),
    );
  }
}