import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.split(_, ""))
  |> list.map(list.filter_map(_, int.parse))
}

pub fn pt_1(input: List(List(Int))) {
  input
  |> list.map(get_highest)
  |> int.sum
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> list.map(get_best_twelve)
  |> int.sum
}

/// #(index, value)
fn max_index(input: List(Int)) -> #(Int, Int) {
  case input {
    [] -> #(-1, -1)
    [head, ..tail] -> do_max_index(tail, head, 0, 1)
  }
}

fn do_max_index(
  input: List(Int),
  max: Int,
  max_index: Int,
  index: Int,
) -> #(Int, Int) {
  case input {
    [] -> #(max_index, max)
    [head, ..tail] if head > max -> do_max_index(tail, head, index, index + 1)
    [_, ..tail] -> do_max_index(tail, max, max_index, index + 1)
  }
}

fn get_highest(input: List(Int)) -> Int {
  let #(max_idx, highest) = max_index(input)
  let #(before, after) = list.split(input, max_idx)
  let assert [_, ..rest] = after

  case rest == [] {
    False -> {
      let #(_, second) = max_index(rest)
      10 * highest + second
    }
    True -> {
      let #(_, second) = max_index(before)
      10 * second + highest
    }
  }
}

fn get_best_twelve(input: List(Int)) -> Int {
  let #(first, remaining) = find_highest(input, 12)
  let #(second, remaining) = find_highest(remaining, 11)
  let #(third, remaining) = find_highest(remaining, 10)
  let #(fourth, remaining) = find_highest(remaining, 9)
  let #(fifth, remaining) = find_highest(remaining, 8)
  let #(sixth, remaining) = find_highest(remaining, 7)
  let #(seventh, remaining) = find_highest(remaining, 6)
  let #(eighth, remaining) = find_highest(remaining, 5)
  let #(ninth, remaining) = find_highest(remaining, 4)
  let #(tenth, remaining) = find_highest(remaining, 3)
  let #(eleventh, remaining) = find_highest(remaining, 2)
  let #(twelth, _) = find_highest(remaining, 1)

  [
    first,
    second,
    third,
    fourth,
    fifth,
    sixth,
    seventh,
    eighth,
    ninth,
    tenth,
    eleventh,
    twelth,
  ]
  |> list_to_num
}

fn find_highest(input: List(Int), length: Int) -> #(Int, List(Int)) {
  do_find_highest(input, length, [])
}

fn do_find_highest(
  input: List(Int),
  length: Int,
  pad: List(Int),
) -> #(Int, List(Int)) {
  let #(idx, highest) = max_index(input)
  let #(before, after) = list.split(input, idx)

  case list.length(after) + list.length(pad) < length {
    True -> do_find_highest(before, length, list.append(after, pad))
    False -> {
      let assert [_, ..rest] = after
      let end = list.append(rest, pad)
      #(highest, end)
    }
  }
}

fn list_to_num(input: List(Int)) -> Int {
  list.fold(input, 0, fn(acc, x) { 10 * acc + x })
}
