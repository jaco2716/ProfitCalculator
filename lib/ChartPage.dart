import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/ObjectManager.dart';
import 'Model/Ingredient.dart';
import 'Model/Meal.dart';
import 'Model/EnvironmentConfig.dart' as config;

class ChartPage extends StatefulWidget {
  ChartPage({Key key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  // List<Meal> mealList = List<Meal>();
  double maxy = 10;
  double miny = 50;
  List<FlSpot> chartList;
  List<FlSpot> secoundaryChartList = List<FlSpot>();
  List<String> chartListTitles = List<String>();
  List<Meal> mealList;
  String dropDownValue = "Profit Margin";
  String chartTitle = 'Profit Margin';
  String chartSubtitle;

  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  String mealJsonFile = config.mealJsonFile;
  String ingredientJsonFile = config.ingredientJsonFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charts')),
      backgroundColor: Colors.blueGrey[900],
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fileManagement.readFile(mealJsonFile),
          initialData: '',
          builder: (context, mealJsonSnapshot) {
            if (mealJsonSnapshot.hasError) return Text('Something went wrong');
            if (mealJsonSnapshot.connectionState == ConnectionState.waiting)
              return Container(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()));

            mealList = objManager.jsonToListMeal(mealJsonSnapshot.data);

            return FutureBuilder(
                future: fileManagement.readFile(ingredientJsonFile),
                builder: (context, ingredientJsonSnapshot) {
                  if (ingredientJsonSnapshot.hasError)
                    return Center(child: Text('Something went wrong'));
                  if (ingredientJsonSnapshot.connectionState ==
                      ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

//Map data from firestore to list.
                  List<Ingredient> mealIngredients = objManager
                      .jsonToListIngredient(ingredientJsonSnapshot.data);

//Change to updated Kgprice - Like JOIN
                  mealList.forEach((m) {
                    m.ingredients.forEach((i) {
                      mealIngredients.forEach((mi) {
                        if (i.id == mi.id) {
                          i.kgPrice = mi.kgPrice;
                        }
                      });
                    });
                  });

//Check what chart is selected
                  if (dropDownValue == "Total Cost / Sale Price")
                    _changeToSaleCost();
                  else if (dropDownValue == "Profit Margin")
                    _changeToProfitMargin();
                  else
                    _changeToProfit();

                  return _chartWidget(
                      chartList, chartListTitles, maxy, miny, chartTitle,
                      secoundChartList: secoundaryChartList,
                      subtitle: chartSubtitle);
                });
          },
        ),
      ),
    );
  }

// The Chart widget builder.
  Widget _chartWidget(List<FlSpot> _chartList, List<String> _chartListTitles,
      double _maxy, double _miny, String _title,
      {List<FlSpot> secoundChartList, String subtitle}) {
// Check the max and min values for the charts
    _chartList.forEach((e) {
      if (_maxy < e.y + 1) _maxy = e.y.roundToDouble();
      if (_miny > e.y - 1) _miny = e.y.roundToDouble();
    });

    secoundChartList?.forEach((e) {
      if (_maxy < e.y + 1) _maxy = e.y.roundToDouble();
      if (_miny > e.y - 1) _miny = e.y.roundToDouble();
    });

// Find chart height.
    double _chartHeight = _maxy - _miny;
    if (_chartHeight > 100) {
      _miny -= 20;
      _maxy += 20;
    } else {
      _miny -= 2;
      _maxy += 2;
    }

// Set interval that is used on y-axis
    double _nrInterval = 0;
    if (_chartHeight > 1000)
      _nrInterval = 200;
    else if (_chartHeight > 250)
      _nrInterval = 50;
    else if (_chartHeight > 100)
      _nrInterval = 10;
    else if (_chartHeight > 50)
      _nrInterval = 5;
    else if (_chartHeight > 20)
      _nrInterval = 2;
    else if (_chartHeight <= 20) _nrInterval = 1;

    return Center(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.all(10)),
          Text(
            _title,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.cyan[400], fontWeight: FontWeight.w900),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.deepOrange[400], fontWeight: FontWeight.w900),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: 800),
            height: 520,
            width: double.infinity,
            padding: EdgeInsets.only(top: 10, bottom: 70, right: 30, left: 15),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: _chartList.length.toDouble() - 1,
                minY: _miny,
                maxY: _maxy,
                titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(
                      margin: 10,
                      interval: 1,
                      getTextStyles: (_) =>
                          TextStyle(color: Colors.white, fontSize: 12),
                      showTitles: true,
                      getTitles: (value) {
//Y-axis numbers in interval
                        if (value % _nrInterval == 0)
                          return value.round().toString();
                        else
                          return '';
                      },
                    ),
                    bottomTitles: SideTitles(
                        margin: 25,
                        rotateAngle: 80,
                        getTextStyles: (_) =>
                            TextStyle(color: Colors.white, fontSize: 12),
                        showTitles: true,
                        getTitles: (value) {
// x-Axis titels
                          String itemName = _chartListTitles[value.toInt()];

                          if (itemName.length > 17) {
                            itemName = itemName.replaceRange(
                                15, itemName.length, "...");
                          }
                          return '$itemName';
                        })),
                gridData: FlGridData(
                  horizontalInterval: 1,
                  show: true,
                  getDrawingHorizontalLine: (value) {
// When to draw the horizontal chart lines with interval
                    FlLine thickLine = FlLine(
                      color: Colors.white38,
                      strokeWidth: 1,
                    );
//Draw thick line at 0
                    if (value == 0) {
                      return FlLine(
                        color: Colors.white,
                        strokeWidth: 2,
                      );
                    } else if (value % _nrInterval == 0) {
                      return thickLine;
                    } else {
                      return FlLine(
                        color: Colors.white12,
                        strokeWidth: 0.001,
                      );
                    }
                  },
                  drawVerticalLine: true,
                  getDrawingVerticalLine: (value) {
//Draw vertical lines on chart
                    return FlLine(
                      color: Colors.white54,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1)),
//Populate chart with data.
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 6,
                    colors: [
                      Colors.cyan[400],
                    ],
                    belowBarData: BarAreaData(show: true, colors: [
                      Colors.cyan[600].withOpacity(0.2),
                      Colors.cyan[200].withOpacity(0.2),
                    ]),
                    spots: _chartList,
                  ),
// Check if there is 2 charts
                  if (secoundChartList != null)
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 6,
                      colors: [
                        Colors.deepOrange[400],
                      ],
                      belowBarData: BarAreaData(show: true, colors: [
                        Colors.red[600].withOpacity(0.2),
                        Colors.red[200].withOpacity(0.2),
                      ]),
                      spots: secoundChartList,
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: _customDropDownButton(),
          ),
        ],
      ),
    );
  }

//Button to choose what chart to see
  Widget _customDropDownButton() {
    return Card(
      color: Colors.blue,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: 200,
          child: DropdownButton(
            value: dropDownValue,
            style: TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            dropdownColor: Colors.blue,
            items: <String>[
              "Total Cost / Sale Price",
              "Profit Margin",
              "Profit",
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                dropDownValue = newValue;
              });
            },
          )),
    );
  }

//Round a double with n amount of decimals
  double _roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

//change UI show profitmargin chart
  _changeToProfitMargin() {
    chartTitle = 'Profit Margin';
    chartSubtitle = null;

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>((v) =>
            FlSpot(v.key.toDouble(), _roundDouble(v.value.profitMargin, 2)))
        ?.toList();

    secoundaryChartList = null;

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }

//change UI show Sale/Cost chart
  _changeToSaleCost() {
    chartTitle = 'Sale Price';
    chartSubtitle = 'Total Cost';

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.salePrice, 2)))
        ?.toList();
    secoundaryChartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.totalCost, 2)))
        ?.toList();

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }

//change UI show profit chart
  _changeToProfit() {
    chartTitle = 'Profit';
    chartSubtitle = null;

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.profit, 2)))
        ?.toList();

    secoundaryChartList = null;

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }
}
