import 'package:e_polling/components/voting_tile.dart';
import 'package:e_polling/models/voting.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  get changeState => setState;
 final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: false,
      onRefresh: () async {
        setState(() {});
        _refreshController.refreshCompleted();
      },
      child: SingleChildScrollView(
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
                    .map((e) => VotingTile(
                          voting: e,
                          toEdit: true,
                          onChanged: () {
                            print("Change found");
                            changeState(() {});
                          },
                        ))
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
      ),
    );
  }
}
