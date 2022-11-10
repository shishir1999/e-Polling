import 'package:e_polling/screens/edit_single_voting.dart';
import 'package:e_polling/screens/single_voting_page.dart';
import 'package:e_polling/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/voting.dart';

class VotingTile extends StatelessWidget {
  final Voting voting;
  final bool toEdit;
  final void Function()? onChanged;
  const VotingTile({
    this.toEdit = false,
    required this.voting,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SingleVotingPage(
                voting: voting,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 12, bottom: 12, top: 12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      voting.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.9),
                      ),
                    ),
                  ),
                  if (toEdit)
                    SizedBox(
                      width: 6,
                    ),
                  if (toEdit)
                    IconButton(
                      onPressed: () async {
                        var resp = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditSingleVoting(
                              voting: voting,
                            ),
                          ),
                        );
                        if (resp == "refresh" && onChanged != null) {
                          onChanged!();
                        }
                      },
                      icon: Icon(Icons.edit),
                    ),
                ],
              ),
              if (voting.description != null) Text(voting.description!),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("${voting.candidates.length} Candidates"),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                      .format(DateTime.parse(voting.from))),
                  Text(" to "),
                  Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                      .format(DateTime.parse(voting.to))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
