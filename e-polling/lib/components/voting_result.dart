import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/voting.dart';

class VotingResult extends StatelessWidget {
  final Voting voting;
  const VotingResult({
    required this.voting,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> results = {};
    voting.candidates.sort(((a, b) => -a.votes + b.votes));
    for (var c in voting.candidates) {
      results[c.name] = c.votes + 0.0;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 6,
      ),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  voting.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                  "Closed on ${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(DateTime.parse(voting.to))}"),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          PieChart(
            dataMap: results,
            chartType: ChartType.disc,
          ),
        ],
      ),
    );
  }
}
