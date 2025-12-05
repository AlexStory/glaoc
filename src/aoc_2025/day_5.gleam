import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Range {
  Range(min: Int, max: Int)
}

pub fn parse(input: String) -> #(List(Range), List(Int)) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> parse_data()
}

pub fn pt_1(input: #(List(Range), List(Int))) {
  let #(ranges, ids) = input
  ids
  |> list.filter(is_fresh(ranges, _))
  |> list.length
}

pub fn pt_2(input: #(List(Range), List(Int))) {
  let #(ranges, _) = input
  ranges
  |> merge
  |> count_ranges
}

fn parse_data(input: List(String)) -> #(List(Range), List(Int)) {
  let ranges =
    {
      let ranges = list.take_while(input, fn(s) { s != "" })
      use split <- list.map(ranges)
      let shaped = case string.split(split, "-") {
        [first, second] -> Ok(#(first, second))
        _ -> Error(Nil)
      }
      use tup <- result.try(shaped)
      case int.parse(tup.0), int.parse(tup.1) {
        Ok(x), Ok(y) -> Ok(Range(min: x, max: y))
        _, _ -> Error(Nil)
      }
    }
    |> result.values

  let nums =
    list.drop_while(input, fn(s) { s != "" })
    |> list.map(int.parse)
    |> result.values

  #(ranges, nums)
}

fn is_fresh(good: List(Range), id: Int) -> Bool {
  case good {
    [] -> False
    [head, ..] if head.min <= id && head.max >= id -> True
    [_, ..tail] -> is_fresh(tail, id)
  }
}

fn merge(input: List(Range)) -> Set(Range) {
  do_merge(input, set.new())
}

fn do_merge(input: List(Range), acc: Set(Range)) -> Set(Range) {
  case input {
    [] -> acc
    [head, ..tail] -> do_merge(tail, add_range(acc, head))
  }
}

fn add_range(ranges: Set(Range), item: Range) {
  case find_match(ranges, item) {
    Ok(range) -> replace_range(ranges, range, merge_range(range, item))
    Error(_) -> set.insert(ranges, item)
  }
}

fn find_match(ranges: Set(Range), item: Range) -> Result(Range, Nil) {
  do_find_match(set.to_list(ranges), item)
}

fn do_find_match(ranges: List(Range), item: Range) -> Result(Range, Nil) {
  case ranges {
    [] -> Error(Nil)
    [head, ..tail] ->
      case overlap(head, item) {
        True -> Ok(head)
        _ -> do_find_match(tail, item)
      }
  }
}

fn overlap(a: Range, b: Range) -> Bool {
  { a.min <= b.min && a.max >= b.min }
  || { b.min <= a.min && b.max >= a.min }
  || { a.min <= b.max && a.max >= b.max }
  || { b.min <= a.max && b.max >= a.max }
}

fn merge_range(a: Range, b: Range) -> Range {
  Range(min: int.min(a.min, b.min), max: int.max(a.max, b.max))
}

fn replace_range(ranges: Set(Range), old: Range, new: Range) -> Set(Range) {
  ranges
  |> set.delete(old)
  |> add_range(new)
}

fn count_ranges(ranges: Set(Range)) -> Int {
  do_count_ranges(set.to_list(ranges), 0)
}

fn do_count_ranges(ranges: List(Range), count: Int) -> Int {
  case ranges {
    [] -> count
    [head, ..tail] -> do_count_ranges(tail, count + { head.max - head.min } + 1)
  }
}
