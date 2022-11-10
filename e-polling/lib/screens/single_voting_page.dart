import 'package:e_polling/components/candidate_tile.dart';
import 'package:e_polling/models/candidate.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/voting.dart';

class SingleVotingPage extends StatefulWidget {
  final Voting voting;
  const SingleVotingPage({super.key, required this.voting});

  @override
  State<SingleVotingPage> createState() => _SingleVotingPageState();
}

class _SingleVotingPageState extends State<SingleVotingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.voting.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 12,
              ),
              if (widget.voting.description != null)
                Text(
                  widget.voting.description!,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (widget.voting.description != null)
                SizedBox(
                  height: 12,
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
                  Text("From "),
                  Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                      .format(DateTime.parse(widget.voting.from))),
                  Text(" to "),
                  Text(DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY)
                      .format(DateTime.parse(widget.voting.to))),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "Choose your candidate:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              for (Candidate c in widget.voting.candidates)
                CandidateTile(
                  candidate: c,
                  voting: widget.voting,
                ),
              SizedBox(
                height: 45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
