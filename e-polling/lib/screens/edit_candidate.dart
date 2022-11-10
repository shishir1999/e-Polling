import 'dart:convert';

import 'package:mime/mime.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:http_parser/src/media_type.dart';
import 'package:e_polling/constants.dart';
import 'package:e_polling/models/candidate.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jsend/jsend.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../helpers.dart';

class EditCandidate extends StatefulWidget {
  final Candidate candidate;
  const EditCandidate({super.key, required this.candidate});

  @override
  State<EditCandidate> createState() => _EditCandidateState();
}

class _EditCandidateState extends State<EditCandidate> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isUploadingFile = false;

  final ImagePicker _picker = ImagePicker();

  late Candidate _candidateToShow = widget.candidate;

  @override
  void initState() {
    super.initState();
    _nameController.text = _candidateToShow.name;
    _descriptionController.text = _candidateToShow.description ?? "";
  }

  _asyncFileUpload(File file) async {
    try {
      setState(() {
        _isUploadingFile = true;
      });
      var uri = Uri.parse(
        APIRequest.base! +
            "votings/${widget.candidate.voting}/candidates/${widget.candidate.id}/setImage",
      );
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", uri);

      var mime = lookupMimeType(file.path);
      print(mime);

      //create multipart using filepath, string or bytes
      var pic = await http.MultipartFile.fromPath("image", file.path,
          contentType: MediaType(mime!.split("/")[0], mime.split("/")[1]));
      //add multipart to request
      request.files.add(
        pic,
      );
      var response = await request.send();

      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print(responseString);
      setState(() {
        _candidateToShow =
            Candidate.fromJson(jsonDecode(responseString)["data"]);
      });
      showSnackBar("File uploaded");
    } catch (e) {
      showSnackBar(e.toString());
    } finally {
      setState(() {
        _isUploadingFile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_candidateToShow);

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Edit Candidate")),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 190,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: _candidateToShow.image != null
                                ? null
                                : Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(1000),
                            image: _candidateToShow.image == null
                                ? null
                                : DecorationImage(
                                    image:
                                        NetworkImage(_candidateToShow.image!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      if (!_isUploadingFile)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () async {
                              XFile? file = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (file != null) {
                                print(file.path);
                                _asyncFileUpload(File(file.path));
                                // uploadFile(File(file.path));
                              }
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text("Edit"),
                                    ],
                                  ),
                                )),
                          ),
                        )
                      else
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
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

                          var resp = await jsendResponse.fromAPIRequest(APIRequest(
                              path:
                                  "/votings/${widget.candidate.voting}/candidates/${widget.candidate.id}",
                              method: "PUT",
                              payload: toSend));

                          if (resp.status != 'success') {
                            throw Exception(resp.message ?? "Error Occurred");
                          }

                          var candidate = Candidate.fromJson(resp.data);

                          setState(() {
                            _candidateToShow = candidate;
                          });

                          showSnackBar("Edited");
                        } catch (e) {
                          showSnackBar(e.toString());
                        }
                      } else {
                        showSnackBar("Check your inputs");
                      }
                    },
                    child: Text("Change Details"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
