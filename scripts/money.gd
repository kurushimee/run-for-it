class_name Money

var hundreds: int
var thousands: int
var millions: int
var billions: int
var trillions: int


func _init(money: Variant = null) -> void:
  if money is String and len(money) > 0:
    from_string(money)
  elif money is int and money > 0:
    from_int(money)


func add(money: Variant) -> void:
  if money is Money:
    from_int(to_int() + money.to_int())
  elif money is int:
    add(Money.new(money))
  elif money is float:
    add(int(money))
  else:
    assert(false, "can't add unsupported type to Money")


func sub(money: Variant) -> void:
  if money is Money:
    from_int(to_int() - money.to_int())
  elif money is int:
    sub(Money.new(money))
  elif money is float:
    sub(int(money))
  else:
    assert(false, "can't subtract unsupported type from Money")


func mul(money: Variant) -> void:
  if money is Money:
    from_int(to_int() * money.to_int())
  elif (money is int) or (money is float):
    from_int(to_int() * money)
  else:
    assert(false, "can't multiply Money by unsupported type")


func div(money: Variant) -> void:
  if money is Money:
    from_int(to_int() / money.to_int())
  elif (money is int) or (money is float):
    from_int(to_int() / money)
  else:
    assert(false, "can't divide Money by unsupported type")


# Constructs Money from a string
# Example: "2.5K" -> Money(hundreds = 500, thousands = 2)
func from_string(string: String) -> void:
  if has_letters(string):
    var numbers := get_numbers_from_string(string, len(string) - 1)
    match string.to_upper()[-1]:
      "K":
        hundreds = numbers[1]
        thousands = numbers[0]
      "M":
        thousands = numbers[1]
        millions = numbers[0]
      "B":
        millions = numbers[1]
        billions = numbers[0]
      "T":
        billions = numbers[1]
        trillions = numbers[0]
      var postfix:
        assert(false, "unknown string postfix: " + str(postfix))
  else:
    var numbers := get_numbers_from_string(string, len(string))
    assert(numbers[1] == 0, "string can't be less than 1")
    hundreds = numbers[0]
  fix_format()


# Constructs Money from an integer
# Example: 15600 -> Money(hundreds = 600, thousands = 15)
func from_int(integer: int) -> void:
  var step := 1000
  hundreds = integer % step
  thousands = (integer / step) % step
  millions = (integer / step ** 2) % step
  billions = (integer / step ** 3) % step
  trillions = integer / step ** 4


func print() -> String:
  var string := "$"
  if trillions > 0:
    string += "%d.%dT" % [trillions, billions / 100]
  elif billions > 0:
    string += "%d.%dB" % [billions, millions / 100]
  elif millions > 0:
    string += "%d.%dM" % [millions, thousands / 100]
  elif thousands > 0:
    string += "%d.%dK" % [thousands, hundreds / 100]
  else:
    string += str(hundreds)
  return string


func to_int() -> int:
  var mult := 1000
  return (
    hundreds
    + (thousands * mult)
    + (millions * (mult ** 2))
    + (billions * (mult ** 3))
    + (trillions * (mult ** 4))
  )


# Fixes any value other than trillions to be less than 1000
# Example: Money(hundreds = 1600, thousands = 5) -> Money(hundreds = 600, thousands = 6)
func fix_format() -> void:
  if hundreds >= 1000:
    thousands += hundreds / 1000
    hundreds = hundreds % 1000
  if thousands >= 1000:
    millions += thousands / 1000
    thousands = thousands % 1000
  if millions >= 1000:
    billions += millions / 1000
    millions = millions % 1000
  if billions >= 1000:
    trillions += billions / 1000
    billions = billions % 1000


# Gets two numbers from a substring (defined by limit),
# one for the whole part and one for the decimal part
func get_numbers_from_string(string: String, limit: int) -> Array[int]:
  var numbers: Array[int] = [0, 0]
  var substring := string.substr(0, limit)
  var dot_index = substring.find(".")
  if dot_index != -1:
    # If there is a decimal part, assign it to the second number
    numbers[0] = int(substring.substr(0, dot_index))
    var decimal_part := substring.substr(dot_index + 1)
    assert(len(decimal_part) <= 3, "decimal part precision can't be more than 3")
    numbers[1] = int(decimal_part) * (10 ** (3 - len(decimal_part)))
  else:
    # Otherwise assign the entire substring to the first number
    numbers[0] = int(substring)
  return numbers


# Returns whether a given string contains any letters
func has_letters(string: String) -> bool:
  var regex := RegEx.new()
  regex.compile("[a-zA-Z]+")
  if regex.search(string):
    return true
  return false
