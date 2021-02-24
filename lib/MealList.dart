import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/FileManagement.dart';
import 'package:profit_calculator/InitialFutureWidget.dart';
import 'package:profit_calculator/ObjectManager.dart';
import 'package:profit_calculator/SingleMeal.dart';
import 'Model/EnvironmentConfig.dart' as config;

import 'Model/Ingredient.dart';
import 'Model/Meal.dart';

class MealList extends StatefulWidget {
  MealList({Key key}) : super(key: key);

  @override
  _MealListState createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  bool isLoading = false;
  final String ingredientJsonFile = config.ingredientJsonFile;
  final String mealJsonFile = config.mealJsonFile;
  final FileManagement fileManagement = FileManagement();
  final ObjectManager objManager = ObjectManager();

  @override
  Widget build(BuildContext context) {
    // List<Meal> mealsnew = [
    //   Meal(1, "name", 12, [
    //     Ingredient(1, "name", 40.4, 4288585374, "Kg", amountInGrams: 100),
    //     Ingredient(2, "name2", 40.4, 4288585374, "Liter", amountInGrams: 100)
    //   ]),
    //   Meal(2, "name2", 12, [
    //     Ingredient(1, "name", 40.4, 4288585374, "Kg", amountInGrams: 100),
    //     Ingredient(2, "name2", 40.4, 4288585374, "Liter", amountInGrams: 100)
    //   ]),
    //   Meal(3, "name3", 12, [
    //     Ingredient(1, "name", 40.4, 4288585374, "Kg", amountInGrams: 100),
    //     Ingredient(2, "name2", 40.4, 4288585374, "Liter", amountInGrams: 100)
    //   ]),
    // ];

    // List<Ingredient> ingredientsnew = [
    //   Ingredient(1, "name", 12, 4288585374, "Kg", archived: true),
    //   Ingredient(2, "name2", 12, 4288585374, "Liter"),
    //   Ingredient(3, "name3", 12, 4288585374, "Kg"),
    // ];

    // fileManagement.writeFile(ingredientJsonFile, jsonEncode(ingredientsnew));
    // print(jsonEncode(ingredientsnew));

    // fileManagement.writeFile(mealJsonFile, jsonEncode(mealsnew));

//Show a loading circle if isLoading is true.
    return Scaffold(
      appBar: AppBar(
        title: Text('All Meals'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: FutureBuilder(
                    future: fileManagement.readFile(mealJsonFile),
                    initialData: '',
                    builder: (context, mealJsonSnapshot) {
                      // print(mealFileSnapshot.data);
                      if (mealJsonSnapshot.hasError) {
                        return Container(
                            height: 400,
                            child: Center(
                                child: Text(
                              'Something went wrong.\nPlease try restarting your app.',
                              textAlign: TextAlign.center,
                            )));
                      }

                      if (mealJsonSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                            height: 400,
                            child: Center(child: CircularProgressIndicator()));
                      }
                      if (mealJsonSnapshot.data.length == 0) {
                        return InitialFutureWidget();
                      }
                      //Map data from firestore to list of objects
                      List<Meal> meals =
                          objManager.jsonToListMeal(mealJsonSnapshot.data);

                      return FutureBuilder(
                          future: fileManagement.readFile(ingredientJsonFile),
                          initialData: '',
                          builder: (context, ingredientJsonSnapshot) {
                            if (ingredientJsonSnapshot.hasError) {
                              return Container(
                                  height: 400,
                                  child: Center(
                                      child: Text(
                                    'Something went wrong.\nPlease try restarting your app.',
                                    textAlign: TextAlign.center,
                                  )));
                            }
                            if (ingredientJsonSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                  height: 400,
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            }
                            //Mao ingredients from firestore to new list.
                            List<Ingredient> allIngredients =
                                objManager.jsonToListIngredient(
                                    ingredientJsonSnapshot.data);
                            // print(ingredientJsonSnapshot.data);
// print('1st: id: ${meals[0].ingredients[0].id}, name: ${meals[0].ingredients[0].name}, kg Price: ${meals[0].ingredients[0].kgPrice}');
                            //JOIN meals with updated ingredients because Firestore does not have SQL JOIN.
                            meals.forEach((meal) {
                              meal.ingredients.forEach((mIngredient) {
                                allIngredients.forEach((aIngredient) {
                                  if (mIngredient.id == aIngredient.id) {
                                    mIngredient.name = aIngredient.name;
                                    mIngredient.color = aIngredient.color;
                                    mIngredient.kgPrice = aIngredient.kgPrice;
                                    mIngredient.measureUnit =
                                        aIngredient.measureUnit;
                                  }
                                  // print('id ${mIngredient.kgPrice} + ${aIngredient.kgPrice}');
                                });
                              });
                            });
// print('2nd: id: ${meals[0].ingredients[0].id}, name: ${meals[0].ingredients[0].name}, kg Price: ${meals[0].ingredients[0].kgPrice}');

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: ListTile(
                                    visualDensity: VisualDensity.compact,
                                    title: Text('Name'),
                                    trailing: Text('Cost/Profit'),
                                    dense: true,
                                  ),
                                ),
                                // Divider(
                                //   thickness: 2,
                                // ),
                                ListView.builder(
                                  itemCount: meals.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return mealListTile(meals[index]);
                                  },
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                ),
                                // SizedBox(height: 20,),
                                // SizedBox(
                                //   height: 90,
                                //   width: double.infinity,
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         vertical: 20),
                                //     child: FlatButton(
                                //         shape: ContinuousRectangleBorder(),
                                //         color: Colors.blue,
                                //         child: Text('Set All Profit Margins'),
                                //         onPressed: () {
                                //           _showChangeProfitMargin(
                                //               context, meals);
                                //         }),
                                //   ),
                                // ),
                              ],
                            );
                          });
                    },
                  ),
                ),
              ),
            ),
    );
  }

//List Tile for every meal
  Widget mealListTile(Meal meal) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text('${meal.ingredients.length} Ingredients'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${meal.salePrice.toStringAsFixed(2)},-',
              style: TextStyle(color: Colors.blue),
            ),
            Text(' / '),
            Text(
              '${meal.profit.toStringAsFixed(2)},-',
              style: TextStyle(
                  color: meal.profit > 0 ? Colors.green : Colors.orange[700]),
            ),
          ],
        ),
        onTap: () {
//Go to meal page when tapped.
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (context) => SingleMeal(meal.name, meal),
          ))
              .then((context) {
            setState(() {});
          });
          print(meal.name + ' Tapped!');
        },
      ),
    );
  }
//TODO delete or fix change all profit margins.

//Show menu to change all profit margins
//   _showChangeProfitMargin(BuildContext context, List<Meal> meals) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController tec = TextEditingController();
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Calculate the Sale Price from a Profit Margin'),
//               Container(
//                   padding: EdgeInsets.all(5),
//                   width: 100,
//                   child: TextField(
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
//                     ],
//                     keyboardType: TextInputType.phone,
//                     maxLength: 2,
//                     maxLengthEnforced: true,
//                     controller: tec,
//                     decoration: InputDecoration(
//                         hintText: '%',
//                         border: OutlineInputBorder(),
//                         counterText: ''),
//                   )),
//             ],
//           ),
//           actions: [
//             FlatButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Cancel')),
//             RaisedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
// //set isLeading to true and update page so it shows a loading screen. then set to false again after async call.
//                 setState(() {
//                   isLoading = true;
//                 });
//                 await _changeAllProfitMargin(tec.text, meals);
//                 setState(() {
//                   isLoading = false;
//                 });
//               },
//               child: Text('Accept'),
//             )
//           ],
//         );
//       },
//     );
//   }

//TODO delete or fix change all profit margins.
//function to calculate all prices from profit margin and then save.
//   Future<bool> _changeAllProfitMargin(
//       String textFieldText, List<Meal> meals) async {
//     String textfield = textFieldText;
//     double profitMargin;
//     bool dbSucess = false;
//     if (textfield != null) profitMargin = double.tryParse(textfield);
//     if (profitMargin != null) {
//       for (var meal in meals) {
//         double newSalePrice =
//             ((meal.totalCost / (1 - profitMargin / 100)) * 100)
//                     .roundToDouble() /
//                 100;
//         print(newSalePrice);
//         // dbSucess =
//         //     await _saveProfitMarginToDB(meal.id.toString(), newSalePrice);
//         meal.salePrice = newSalePrice;
//         print(dbSucess);
//       }
// //show error or success message
//       if (dbSucess) {
//         // setState(() {});
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Profit Margin has been saved.'),
//         ));
//         print('success: ' + dbSucess.toString());
//         return true;
//       } else {
//         print('error: ' + dbSucess.toString());
//         // setState(() {});
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Something went wrong, please try again.'),
//         ));
//       }
//     }
//     return false;
//   }

//Save the profitmargins calculated to firestore database
  // Future<bool> _saveProfitMarginToDB(String id, double salePrice) {
  //   return FirestoreRef.mealRef
  //       .doc(id)
  //       .update({"salePrice": salePrice}).then((value) {
  //     print("DB updated");
  //     return true;
  //   }).catchError((error) {
  //     print("Failed to update salePrice in DB: $error");
  //     return false;
  //   });
  // }
}
