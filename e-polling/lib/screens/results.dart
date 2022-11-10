import 'package:e_polling/components/voting_result.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import '../models/voting.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: jsendResponse
            .fromAPIRequest(
          APIRequest(path: "/votings/results", method: "GET"),
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
                    (e) => VotingResult(
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
