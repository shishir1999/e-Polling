import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';

import '../components/voting_tile.dart';
import '../models/voting.dart';

class Votings extends StatefulWidget {
  const Votings({super.key});

  @override
  State<Votings> createState() => _VotingsState();
}

class _VotingsState extends State<Votings> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: jsendResponse
            .fromAPIRequest(
          APIRequest(path: "/votings", method: "GET"),
        )
            .then(
          (response) {
            if (response.status != 'success') {
              throw Exception("Error: " + (response.message ?? ""));
            } else {
              return (response.data as List)
                  .map((e) => Voting.fromJson(e))
                  .toList();
            }
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: (snapshot.data as List<Voting>)
                  .map(
                    (e) => VotingTile(
                      voting: e,
                    ),
                  )
                  .toList(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
