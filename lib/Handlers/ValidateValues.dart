class ValidateValues {
  //check if string is empty
  String validateString(String value) {
    return value.isEmpty ? 'Required' : null;
  }

  // Check if the number value is valid
  String validateDouble(String value) {
    try {
      value = value.replaceAll(',', '.');
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }

  // Check if the number value is valid
  String validateInt(String value, {int aboveValue, int bellowValue, bool canBeNull}) {
    try {
      if(value == '' && canBeNull) return null;
      int intValue = int.parse(value);
      if (aboveValue != null) {
        if (intValue <= aboveValue) {
          return "Must be greater than $aboveValue";
        }
      }
      if (bellowValue != null) {
        if (intValue >= bellowValue) {
          return "Must be less than $bellowValue";
        }
      }
      return null;
    } catch (error) {
      return "Invalid number.";
    }
  }
}
