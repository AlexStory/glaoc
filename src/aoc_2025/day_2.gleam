import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Range {
  Range(min: Int, max: Int)
}

pub fn parse(input: String) {
  input
  |> string.trim()
  |> string.split(",")
  |> list.map(string.split(_, "-"))
  |> list.map(parse_range)
  |> result.values
}

pub fn pt_1(input: List(Range)) {
  input
  |> list.map(range_to_ints)
  |> list.flatten
  |> list.filter_map(find_invalid)
  |> int.sum
}

pub fn pt_2(input: List(Range)) {
  input
  |> list.map(range_to_ints)
  |> list.flatten
  |> list.filter_map(find_complex_invalid)
  |> int.sum
}

fn parse_range(input: List(String)) -> Result(Range, Nil) {
  case input {
    [fst, snd] ->
      case int.parse(fst), int.parse(snd) {
        Ok(min), Ok(max) -> Ok(Range(min:, max:))
        _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn range_to_ints(input: Range) -> List(Int) {
  list.range(input.min, input.max)
}

fn find_invalid(n: Int) -> Result(Int, Nil) {
  let s = int.to_string(n)
  case string.length(s) % 2 == 0 {
    True -> Ok(s)
    _ -> Error(Nil)
  }
  |> result.try(fn(s) {
    let pivot = string.length(s) / 2
    let start = string.slice(s, 0, pivot)
    let end = string.slice(s, pivot, pivot)

    case start == end {
      True -> Ok(n)
      _ -> Error(Nil)
    }
  })
}

fn find_complex_invalid(n: Int) -> Result(Int, Nil) {
  let s = int.to_string(n)
  let half_len = string.length(s) / 2
  list.range(1, half_len)
  |> list.map(fn(i) {
    let segment = string.slice(s, 0, i)
    let multiples = string.length(s) / i
    let res = string.repeat(segment, multiples)

    case res == s && string.length(s) > 1 {
      True -> Ok(n)
      _ -> Error(Nil)
    }
  })
  |> result_any
}

fn result_any(input: List(Result(a, b))) -> Result(a, b) {
  case input {
    [r] -> r
    [Ok(x), ..] -> Ok(x)
    [_, ..rest] -> result_any(rest)
    _ -> panic as "uh oh"
  }
}
