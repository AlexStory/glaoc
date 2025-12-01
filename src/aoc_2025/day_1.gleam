import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Rotation {
  Left(Int)
  Right(Int)
}

pub fn pt_1(input: String) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(parse_rotation)
  |> result.values
  |> dial
}

pub fn pt_2(input: String) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(parse_rotation)
  |> result.values
  |> dial_with_count
}

fn parse_rotation(input: String) -> Result(Rotation, String) {
  case input {
    "L" <> num ->
      case int.parse(num) {
        Ok(n) -> Ok(Left(n))
        Error(_) -> Error("failed to parse int")
      }
    "R" <> num ->
      case int.parse(num) {
        Ok(n) -> Ok(Right(n))
        Error(_) -> Error("failed to parse int")
      }
    _ -> Error("failed to parse rotation")
  }
}

/// #(Value, Zeroes)
fn dial(input: List(Rotation)) -> #(Int, Int) {
  list.fold(input, #(50, 0), fn(acc, rotation) {
    let #(value, zeroes) = acc
    let result = rotate(value, rotation)
    case result {
      0 -> #(0, zeroes + 1)
      _ -> #(result, zeroes)
    }
  })
}

/// #(Value, Zeroes)
fn dial_with_count(input: List(Rotation)) -> #(Int, Int) {
  list.fold(input, #(50, 0), fn(acc, rotation) {
    let #(value, zeroes) = acc
    let #(result, new_zeroes) = rotate_with_count(value, rotation, zeroes)
    echo #(result, new_zeroes)
  })
}

fn rotate(start: Int, rotation: Rotation) -> Int {
  case rotation {
    Left(0) | Right(0) -> start
    Left(n) -> rotate(turn_left(start), Left(n - 1))
    Right(n) -> rotate(turn_right(start), Right(n - 1))
  }
}

fn rotate_with_count(start: Int, rotation: Rotation, zeroes: Int) -> #(Int, Int) {
  case start, rotation {
    _, Left(0) | _, Right(0) -> #(start, zeroes)
    0, Left(n) -> rotate_with_count(turn_left(start), Left(n - 1), zeroes + 1)
    0, Right(n) ->
      rotate_with_count(turn_right(start), Right(n - 1), zeroes + 1)
    _, Left(n) -> rotate_with_count(turn_left(start), Left(n - 1), zeroes)
    _, Right(n) -> rotate_with_count(turn_right(start), Right(n - 1), zeroes)
  }
}

fn turn_left(value: Int) -> Int {
  case value {
    0 -> 99
    _ -> value - 1
  }
}

fn turn_right(value: Int) -> Int {
  case value {
    99 -> 0
    _ -> value + 1
  }
}
