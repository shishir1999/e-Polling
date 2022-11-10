import 'package:e_polling/constants.dart';
import 'package:e_polling/screens/add_candidate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jsend/jsend.dart';

import '../components/candidate_tile.dart';
import '../helpers.dart';
import '../models/candidate.dart';
import '../models/voting.dart';

class EditSingleVoting extends StatefulWidget {
  final Voting voting;

  const EditSingleVoting({super.key, required this.voting});

  @override
  State<EditSingleVoting> createState() => _EditSingleVotingState();
}

class _EditSingleVotingState extends State<EditSingleVoting> {
  late Voting _votingToShow = widget.voting;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _fromDate = DateTime.parse(_votingToShow.from);
  late DateTime _toDate = DateTime.parse(_votingToShow.to);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _status = 'shown';

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = _votingToShow.title;
      _descriptionController.text = _votingToShow.description ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop("refresh");
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Voting Details"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    "Set Details:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Title",
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    decoration: kInputDecoration,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Description",
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    maxLines: 3,
                    decoration: kInputDecoration,
                    controller: _descriptionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Active Period",
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        child: Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                            .format(
                              _fromDate,
                            )
                            .toString()),
                        onPressed: () async {
                          var d = await showDialog(
                            context: context,
                            builder: (context) => DatePickerDialog(
                              helpText: "Voting Start Date",
                              initialDate: _fromDate,
                              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                              // firstDate:
                              //     DateTime.now().subtract(Duration(days: 120)),
                              lastDate: DateTime.now().add(
                                Duration(
                                  days: 120,
                                ),
                              ),
                            ),
                          );

                          if (d != null) {
                            setState(() {
                              _fromDate = d!;
                            });
                          }
                        },
                      ),
                      Text("to"),
                      TextButton(
                        child: Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                            .format(
                              _toDate,
                            )
                            .toString()),
                        onPressed: () async {
                          var d = await showDialog(
                            context: context,
                            builder: (context) => DatePickerDialog(
                              helpText: "Voting End Date",
                              initialDate: _toDate,
                              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                              lastDate: DateTime.now().add(
                                Duration(
                                  days: 120,
                                ),
                              ),
                            ),
                          );

                          if (d != null) {
                            setState(() {
                              _toDate = d!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status: $_status"),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor: _status != "shown"
                              ? null
                              : MaterialStateProperty.resolveWith(
                                  (states) => Colors.red,
                                ),
                        ),
                        onPressed: (() {
                          setState(() {
                            _status = _status == 'shown' ? 'hidden' : 'shown';
                          });
                        }),
                        child: Text(_status == 'shown' ? "Hide" : "Show"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            var toSend = {
                              "title": _nameController.text,
                              'description': _descriptionController.text,
                              'from':
                                  _fromDate.toUtc().toLocal().toIso8601String(),
                              'to': _toDate.toUtc().toLocal().toIso8601String(),
                              'status': _status,
                            };

                            var resp = await jsendResponse.fromAPIRequest(
                                APIRequest(
                                    path: "/votings/${widget.voting.id}",
                                    method: "PUT",
                                    payload: toSend));

                            if (resp.status != 'success') {
                              throw Exception(resp.message ?? "Error Occurred");
                            }

                            var voting = Voting.fromJson(resp.data);

                            setState(() {
                              _votingToShow = voting;
                            });
                            showSnackBar("Edited");
                          } catch (e) {
                            showSnackBar(e.toString());
                          }
                        } else {
                          showSnackBar("Check your inputs");
                        }
                      },
                      child: Text("Save Changes"),
                    ),
                  ),
                  Divider(),
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Candidates:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          var newCandidate = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddCandidate(
                                votingId: _votingToShow.id,
                              ),
                            ),
                          );

                          if (newCandidate is Candidate) {
                            _votingToShow.candidates.add(newCandidate);
                            setState(() {});
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            Text("New"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  for (Candidate c in _votingToShow.candidates)
                    CandidateTile(
                      voting: widget.voting,
                      onDelete: () {
                        setState(() {
                          _votingToShow.candidates = _votingToShow.candidates
                              .where((element) => element.id != c.id)
                              .toList();
                        });
                      },
                      candidate: c,
                      forEdit: true,
                      afterEdit: (cd) {
                        setState(() {
                          _votingToShow.candidates =
                              _votingToShow.candidates.map((e) {
                            if (e.id == cd.id) {
                              return cd;
                            } else {
                              return e;
                            }
                          }).toList();
                        });
                      },
                    ),
                  SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
