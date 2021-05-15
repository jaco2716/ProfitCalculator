import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProfitMarginPercentageWidget extends StatelessWidget {
  final double localProfitMargin;
  final Color indicatorColor;
  final String negative;
  ProfitMarginPercentageWidget(
      this.localProfitMargin, this.indicatorColor, this.negative);

  @override
  Widget build(BuildContext context) {
    double _profitMargin = localProfitMargin/100;
    return CircularPercentIndicator(
      radius: 170.0,
      lineWidth: 20.0,
      animation: true,
      percent: _profitMargin < 1 ? _profitMargin : 1,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text(
            "$negative${(_profitMargin * 100).round()}%",
            textAlign: TextAlign.center,
            style: new TextStyle(fontWeight: FontWeight.w300, fontSize: 30.0),
          ),
          Text('Profit'),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.blue[100],
      progressColor: indicatorColor,
    );
  }
}
