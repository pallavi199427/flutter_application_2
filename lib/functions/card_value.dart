// card_values.dart

String parseCardValue(String value) {
  switch (value) {
    case '02':
      return 'two';
    case '03':
      return 'three';
    case '04':
      return 'four';
    case '05':
      return 'five';
    case '06':
      return 'six';
    case '07':
      return 'seven';
    case '08':
      return 'eight';
    case '09':
      return 'nine';
    case '10':
      return 'ten';
    case 'jack':
      return 'jack';
    case 'queen':
      return 'queen';
    case 'king':
      return 'king';
    case 'ace':
      return 'ace';
    default:
      throw ArgumentError('Invalid card value: $value');
  }
}
