import 'package:e_polling/constants.dart';
import 'package:e_polling/helpers.dart';
import 'package:e_polling/models/voting.dart';
import 'package:e_polling/screens/edit_single_voting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jsend/jsend.dart';

class AddVoting extends StatefulWidget {
  const AddVoting({super.key});

  @override
  State<AddVoting> createState() => _AddVotingState();
}

class _AddVotingState extends State<AddVoting> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(Duration(days: 5));

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add new Voting")),
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
                            firstDate:
                                DateTime.now().subtract(Duration(days: 120)),
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
                            firstDate: _fromDate,
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
                            'from': _fromDate.millisecondsSinceEpoch,
                            'to': _toDate.millisecondsSinceEpoch,
                          };

                          var resp = await jsendResponse.fromAPIRequest(
                              APIRequest(
                                  path: "/votings",
                                  method: "POST",
                                  payload: toSend));

                          if (resp.status != 'success') {
                            throw Exception(resp.message ?? "Error Occurred");
                          }

                          var voting = Voting.fromJson(resp.data);

                          var value = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditSingleVoting(
                                voting: voting,
                              ),
                            ),
                          );
                          Navigator.of(context).pop(value);
                        } catch (e) {
                          showSnackBar(e.toString());
                        }
                      } else {
                        showSnackBar("Check your inputs");
                      }
                    },
                    child: Text("Add"),
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
