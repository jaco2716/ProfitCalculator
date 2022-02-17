
class BackupFileJson {
  String ingredientJson;
  String extraJson;
  String mealJson;
  String menuJson;
  String cateringJson;

  BackupFileJson({this.ingredientJson, this.extraJson, this.mealJson, this.menuJson, this.cateringJson});

  BackupFileJson.fromJson(Map<String, dynamic> json)
      : ingredientJson = json['ingredientJson'] ?? '',
        extraJson = json['extraJson'] ?? '',
        mealJson = json['mealJson'] ?? '',
        menuJson = json['menuJson'] ?? '',
        cateringJson = json['cateringJson'] ?? '';

  Map<String, dynamic> toJson() => {
        'ingredientJson': ingredientJson,
        'extraJson': extraJson,
        'mealJson': mealJson,
        'menuJson': menuJson,
        'cateringJson': cateringJson,
      };
}
