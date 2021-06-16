import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/FileManagement.dart';
import 'package:profit_calculator/Handlers/ObjectManager.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Model/Catering.dart';
import 'package:profit_calculator/Model/Extra.dart';
import 'package:profit_calculator/Model/Menu.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyDeleteIconButton.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/ProfitMarginPercentageWidget.dart';
import 'package:profit_calculator/MyWidgets/SingleElementWidgets/SingleElementPriceCard.dart';
import 'package:profit_calculator/Pages/ExtraPages/CreateExtraPage.dart';
import '../../Model/EnvironmentConfig.dart' as config;

class SingleExtraPage extends StatefulWidget {
  final Extra extra;

  SingleExtraPage(this.extra);

  @override
  _SingleExtraPageState createState() => _SingleExtraPageState();
}

class _SingleExtraPageState extends State<SingleExtraPage> {
  SharedValueHandler sharedVH = SharedValueHandler();
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();
  final String mealJsonFile = config.mealJsonFile;
  final String extraJsonFile = config.extraJsonFile;
  final String menuJsonFile = config.menuJsonFile;
  final String cateringJsonFile = config.cateringJsonFile;

  Extra extra;
  String _name;
  double _salePrice;
  double _costPrice;
  double _profitMargin;
  double _profit;
  int _vatPercent;

  void initState() {
    super.initState();
    extra = widget.extra;
  }

  @override
  Widget build(BuildContext context) {
    _name = extra.name;
    _salePrice = extra.salePrice;
    _costPrice = extra.costPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                Extra newEditedExtra;
                newEditedExtra = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateExtra(
                          editExtra: extra,
                          editMode: true,
                        )));
                if (newEditedExtra != null) {
                  extra = newEditedExtra;
                }
                setState(() {});
              })
        ],
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: _sharedValueHandler.getIntSharedP('VATPercent', 25),
              builder: (context, vatSnapshot) {
                if (vatSnapshot.connectionState == ConnectionState.waiting) {
                  return MyLoadingCircle(500);
                }
                _vatPercent = vatSnapshot.data;
                return FutureBuilder(
                    future: _sharedValueHandler.getStringSharedP('CurrencyChosen', 'DKK'),
                    initialData: '',
                    builder: (context, currencySnapshot) {
                      if (currencySnapshot.connectionState == ConnectionState.waiting) {
                        return MyLoadingCircle(500);
                      }

                      _profit = extra.profit(_vatPercent);
                      _profitMargin = extra.profitMargin(_vatPercent);
                      return Column(
                        children: [
                          SingleElementPriceCard('Cost:', null, '${_costPrice.toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.red),
                          SingleElementPriceCard('Net Price:', null,
                              '${(_salePrice / (_vatPercent / 100 + 1)).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.indigo),
                          SingleElementPriceCard(
                              'Sale Price:', '($_vatPercent% VAT)', '${(_salePrice).toStringAsFixed(2)},- ${currencySnapshot.data}', Colors.blue),
                          SingleElementPriceCard('Profit:', null, '${_profit.toStringAsFixed(2)},- ${currencySnapshot.data}',
                              _profitMargin > 0 ? Colors.green : Colors.orange),
                          _profitMargin < 0
                              ? ProfitMarginPercentageWidget(-_profitMargin, Colors.orange[700], '-')
                              : ProfitMarginPercentageWidget(_profitMargin, Colors.green[700], ''),
                          MyDeleteIconButton(
                            myOnPressed: () => _deleteExtraDialog(context),
                          ),
                        ],
                      );
                    });
              })),
    );
  }

  _deleteExtraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Delete',
          content: 'Are you sure you want to delete $_name?',
          cancelText: 'cancel',
          confirmText: 'Delete',
          myOnPressed: () => _deleteExtra(context, extra),
        );
      },
    );
  }

  void showCouldNotDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return MyAlertDialog(
          title: 'Error',
          content: 'Could not delete extra, because one or more menus or caterings are using it.',
          cancelText: 'Close',
          infoDialog: true,
        );
      },
    );
  }

  _deleteExtra(BuildContext context, Extra myExtra) async {
    String extraFileContent = await fileManagement.readFile(extraJsonFile);
    List<Extra> allExtrasFromFile = objManager.jsonToListExtra(extraFileContent);

    int extraFoundIndex = -1;
    String menuFileContent = await fileManagement.readFile(menuJsonFile);
    List<Menu> allMenusFromFile = objManager.jsonToListMenu(menuFileContent);
    if (allMenusFromFile != null) {
      for (var m in allMenusFromFile) {
        extraFoundIndex = m.extras.indexWhere((i) => i.id == myExtra.id);
        if (extraFoundIndex >= 0) {
          print(extraFoundIndex);
          break;
        }
      }
    }
    String cateringFileContent = await fileManagement.readFile(cateringJsonFile);
    List<Catering> allCateringsFromFile = objManager.jsonToListCatering(cateringFileContent);
    if (allCateringsFromFile != null) {
      for (var c in allCateringsFromFile) {
        extraFoundIndex = c.extras.indexWhere((i) => i.id == myExtra.id);
        if (extraFoundIndex >= 0) {
          print(extraFoundIndex);
          break;
        }
      }
    }
    if (extraFoundIndex != -1) {
      Navigator.of(context).pop();
      showCouldNotDeleteDialog();
    } else {
      int deleteIndex = allExtrasFromFile.indexWhere((element) => element.id == myExtra.id);
      allExtrasFromFile.removeAt(deleteIndex);

      fileManagement.writeFile(extraJsonFile, jsonEncode(allExtrasFromFile));
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${myExtra.name} was deleted.')));
    }
  }
  
}
