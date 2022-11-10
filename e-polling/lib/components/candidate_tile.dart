import 'package:e_polling/constants.dart';
import 'package:e_polling/controllers/user_controller.dart';
import 'package:e_polling/models/candidate.dart';
import 'package:e_polling/screens/edit_candidate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import 'package:provider/provider.dart';

import '../helpers.dart';
import '../models/user.dart';
import '../models/voting.dart';
import '../screens/auth/otp_send_and_verify.dart';

class CandidateTile extends StatelessWidget {
  final Voting voting;
  final bool forEdit;
  final Candidate candidate;
  final void Function(Candidate)? afterEdit;
  final void Function()? onDelete;
  const CandidateTile({
    required this.voting,
    this.afterEdit,
    this.onDelete,
    required this.candidate,
    this.forEdit = false,
    Key? key,
  }) : super(key: key);

  bool hasVoted(User? session) {
    if (session == null) return false;

    return session.votedCandidates.contains(candidate.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(builder: (context, userController, child) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
              width: hasVoted(userController.session!) ? 2 : 1,
              color: hasVoted(userController.session!)
                  ? Colors.orange
                  : Colors.black.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(
          top: 12,
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: candidate.image != null
                    ? null
                    : Colors.grey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1000),
                image: candidate.image == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(candidate.image!),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              candidate.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (candidate.description != null)
              Padding(
                padding: const EdgeInsets.all(
                  12,
                ),
                child: Text(
                  candidate.description!,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
            if (!forEdit)
              hasVoted(userController.session!)
                  ? Container(
                      height: 40,
                      color: Colors.orange,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check),
                            SizedBox(
                              width: 8,
                            ),
                            Text("Your Choice"),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.resolveWith(
                          (states) => Size(
                            double.infinity,
                            40,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                                "Are you sure you want to vote for ${candidate.name}?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                    builder: (context) => OTPSendAndVerify(
                                      onOTPVerified: (otp, ctx) {
                                        Navigator.of(ctx).push(
                                          MaterialPageRoute(
                                            builder: (c) => Scaffold(
                                              body: FutureBuilder(
                                                future: jsendResponse
                                                    .fromAPIRequest(
                                                  APIRequest(
                                                      path:
                                                          "/votings/${candidate.voting}/candidates/${candidate.id}/vote",
                                                      method: "POST",
                                                      payload: {
                                                        "otpId": otp,
                                                      }),
                                                )
                                                    .then(
                                                  (resp) {
                                                    if (resp.status !=
                                                        'success') {
                                                      throw Exception(
                                                          resp.message ??
                                                              "Error occurred");
                                                    }

                                                    Provider.of<UserController>(
                                                            context,
                                                            listen: false)
                                                        .markVotingDone(
                                                            voting, candidate);

                                                    return true;
                                                  },
                                                ),
                                                builder: (c, snapshot) {
                                                  if (snapshot.hasData) {
                                                    Future.microtask(() {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      showSnackBar(
                                                          "Voting Successful.");
                                                    });
                                                    return Center(
                                                      child: Icon(Icons.check),
                                                    );
                                                  } else if (snapshot
                                                      .hasError) {
                                                    Future.microtask(() {
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      print(snapshot.error
                                                          .toString());
                                                      showSnackBar(
                                                          "Errored out: " +
                                                              snapshot.error
                                                                  .toString());
                                                    });
                                                    return Center(
                                                      child: Icon(Icons.error),
                                                    );
                                                  }
                                                  return Center(
                                                    child:
                                                        CupertinoActivityIndicator(
                                                      radius: 20,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      purpose: OTPPurpose.voting,
                                    ),
                                  ));
                                  Navigator.of(context).pop();
                                },
                                child: Text("Yes, Vote"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stream_sharp),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            "Vote",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    )
            else
              Column(
                children: [
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditCandidate(
                                candidate: candidate,
                              ),
                            ),
                          );
                          Navigator.of(context).pop(candidate);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: primaryColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete ${candidate.name} ?"),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      showSnackBar("Deleting...");
                                      Navigator.of(context).pop();
                                      var resp =
                                          await jsendResponse.fromAPIRequest(
                                        APIRequest(
                                          path:
                                              "/votings/${candidate.voting}/candidates/${candidate.id}",
                                          method: "DELETE",
                                        ),
                                      );

                                      if (resp.status != 'success') {
                                        throw Exception(
                                            resp.message ?? "Error occurred");
                                      }
                                      if (onDelete != null) {
                                        onDelete!();
                                      }
                                    } catch (e) {
                                      showSnackBar(e.toString());
                                    }
                                  },
                                  child: Text("Yes, Delete"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
