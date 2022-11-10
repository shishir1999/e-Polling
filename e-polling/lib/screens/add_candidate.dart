import 'package:e_polling/constants.dart';
import 'package:e_polling/models/candidate.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';

import '../helpers.dart';

class AddCandidate extends StatefulWidget {
  final String votingId;
  const AddCandidate({super.key, required this.votingId});

  @override
  State<AddCandidate> createState() => _AddCandidateState();
}

class _AddCandidateState extends State<AddCandidate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Candidate")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              SizedBox(
                height: 12,
              ),
              SizedBox(height: 12),
              Text(
                "Name",
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
              Divider(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        var toSend = {
                          "name": _nameController.text,
                          'description': _descriptionController.text,
                        };

                        var resp = await jsendResponse.fromAPIRequest(
                            APIRequest(
                                path: "/votings/${widget.votingId}/candidates",
                                method: "POST",
                                payload: toSend));

                        if (resp.status != 'success') {
                          throw Exception(resp.message ?? "Error Occurred");
                        }

                        var candidate = Candidate.fromJson(resp.data);

                        Navigator.of(context).pop(candidate);
                      } catch (e) {
                        showSnackBar(e.toString());
                      }
                    } else {
                      showSnackBar("Check your inputs");
                    }
                  },
                  child: Text("Add Candidate"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
