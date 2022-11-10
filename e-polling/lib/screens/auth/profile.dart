import 'package:e_polling/components/voting_result.dart';
import 'package:e_polling/components/voting_tile.dart';
import 'package:e_polling/models/voting.dart';
import 'package:e_polling/screens/auth/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import 'package:provider/provider.dart';

import '../../../components/login_builder.dart';
import '../../../controllers/user_controller.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LoginBuilder(builder: (context, user) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              user.name,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Provider.of<UserController>(context,
                                        listen: false)
                                    .logout();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                    (route) => false);
                              },
                              child: Text("Logout"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: jsendResponse
                          .fromAPIRequest(APIRequest(
                              path: "/users/me/votings", method: "GET"))
                          .then((value) {
                        if (value.status != 'success') {
                          throw Exception(value.message ?? "Error");
                        }

                        return (value.data['votings'] as List)
                            .map((e) => Voting.fromJson(e))
                            .toList();
                      }),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          var past = (snapshot.data as List<Voting>)
                              .where((element) => DateTime.parse(element.to)
                                  .isBefore(DateTime.now()))
                              .toList();

                          var ongoing = (snapshot.data as List<Voting>)
                              .where((element) => DateTime.parse(element.to)
                                  .isAfter(DateTime.now()))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Involvements:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(thickness: 2),
                              ExpansionTile(
                                trailing: Text("${ongoing.length}"),
                                title: Text("Ongoing"),
                                children: ongoing
                                    .map((e) => VotingTile(voting: e))
                                    .toList(),
                              ),
                              ExpansionTile(
                                trailing: Text("${past.length}"),
                                title: Text("Past"),
                                children: past
                                    .map((e) => VotingResult(voting: e))
                                    .toList(),
                              ),
                            ],
                          );
                        }

                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      })),
                ],
              ),
            if (user == null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("Please Login First")),
                ],
              ),
          ],
        );
      }),
    );
  }
}
