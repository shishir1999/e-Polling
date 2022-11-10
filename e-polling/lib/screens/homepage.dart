import 'package:e_polling/constants.dart';
import 'package:e_polling/controllers/user_controller.dart';
import 'package:e_polling/screens/add_voting.dart';
import 'package:e_polling/screens/admin_page.dart';
import 'package:e_polling/screens/auth/profile.dart';
import 'package:e_polling/screens/results.dart';
import 'package:e_polling/screens/votings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

const userPages = [
  {
    "title": "Votings",
    "icon": Icons.poll,
    "widget": Votings(),
  },
  {
    "title": "Results",
    "icon": Icons.bar_chart,
    "widget": ResultsPage(),
  },
  {
    "title": "Profile",
    "icon": Icons.person,
    "widget": Profile(),
  },
];

const adminPages = [
  {
    "title": "All Votings",
    "icon": Icons.admin_panel_settings,
    "widget": AdminPage(),
  },
  {
    "title": "Profile",
    "icon": Icons.person,
    "widget": Profile(),
  },
];

class _HomePageState extends State<HomePage> {
  late List<Map> pages = userPages;
  late String selectedTitle = pages[0]["title"]!.toString();

  @override
  void initState() {
    super.initState();
    if (Provider.of<UserController>(context, listen: false).sessionExists) {
      if (Provider.of<UserController>(context, listen: false).session!.role ==
              'admin' &&
          pages != adminPages) {
        setState(() {
          pages = adminPages;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pages
            .where((element) => element['title'] == selectedTitle)
            .first['title']
            .toString()),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: pages
            .where((element) => element["title"] == selectedTitle)
            .first["widget"],
      ),
      floatingActionButton: pages
              .where((element) => element["title"] == selectedTitle)
              .first["widget"] is AdminPage
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => AddVoting()));
              },
              child: Icon(
                Icons.add,
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: pages.map((e) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTitle = e["title"]!.toString();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      e["icon"],
                      color: selectedTitle == e['title']!.toString()
                          ? primaryColor
                          : Colors.grey,
                      size: selectedTitle == e['title']!.toString() ? 28 : null,
                    ),
                    Text(e['title']!.toString()),
                  ],
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }
}
