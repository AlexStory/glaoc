import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Sign {
  Times
  Plus
}

pub type Input(a) =
  List(#(Sign, List(a)))

pub fn parse(input: String) {
  let input =
    input
    |> string.split("\n")
    |> list.reverse
  let assert [head, ..tail] = input

  let signs =
    head
    |> string.trim()
    |> string.to_graphemes
    |> list.map(parse_sign)
    |> result.values

  let values =
    tail
    |> list.map(string.split(_, " "))
    |> list.map(list.map(_, int.parse))
    |> list.map(result.values)
    |> list.transpose

  let pt1 = list.zip(signs, values)

  let second =
    tail
    |> list.map(string.split(_, ""))
    |> list.transpose
    |> list.map(
      list.filter(_, fn(x) {
        case x {
          " " -> False
          "\r" -> False
          _ -> True
        }
      }),
    )
    |> list.map(string.join(_, ""))
    |> list.map(string.reverse)
    |> split_empties
    |> list.map(list.map(_, int.parse))
    |> list.map(result.values)

  let pt2 = list.zip(signs, second)

  #(pt1, pt2)
}

pub fn pt_1(input: #(Input(Int), Input(Int))) {
  input.0
  |> list.map(handle)
  |> int.sum
}

pub fn pt_2(input: #(Input(Int), Input(Int))) {
  input.1
  |> list.map(handle)
  |> int.sum
}

fn parse_sign(input: String) -> Result(Sign, Nil) {
  case input {
    "*" -> Ok(Times)
    "+" -> Ok(Plus)
    _ -> Error(Nil)
  }
}

fn handle(input: #(Sign, List(Int))) -> Int {
  let #(sign, nums) = input
  case sign {
    Plus -> int.sum(nums)
    Times -> int.product(nums)
  }
}

fn split_empties(input: List(String)) -> List(List(String)) {
  do_split_empties(input, [], [])
}

fn do_split_empties(
  input: List(String),
  acc: List(List(String)),
  current: List(String),
) -> List(List(String)) {
  case input {
    [] -> list.append(acc, [current])
    [head, ..tail] if head == "" ->
      do_split_empties(tail, list.append(acc, [current]), [])
    [head, ..tail] -> do_split_empties(tail, acc, list.append(current, [head]))
  }
}
