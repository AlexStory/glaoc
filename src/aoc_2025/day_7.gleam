import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Node {
  Empty
  Starter
  Splitter
  Beam
}

pub type Point =
  #(Int, Int)

pub type Board =
  Dict(Point, Node)

pub fn parse(input: String) -> Board {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.to_graphemes)
  |> to_nodes
}

pub fn pt_1(input: Board) {
  let start = find_start(input)
  fill_with_count(input, start)
  |> pair.second
}

pub fn pt_2(input: Board) {
  let start = find_start(input)
  traverse_timelines(input, start)
}

fn to_nodes(input: List(List(String))) -> Dict(Point, Node) {
  list.index_fold(input, dict.new(), fn(m, row, y) {
    list.index_fold(row, m, fn(acc, col, x) {
      case col {
        "." -> dict.insert(acc, #(x, y), Empty)
        "S" -> dict.insert(acc, #(x, y), Starter)
        "^" -> dict.insert(acc, #(x, y), Splitter)
        _ -> acc
      }
    })
  })
}

fn find_start(input: Board) -> Point {
  input
  |> dict.to_list
  |> list.find(fn(x) { x.1 == Starter })
  |> result.map(pair.first)
  |> result.unwrap(#(-1, -1))
}

fn fill_with_count(input: Board, start: Point) {
  do_fill_with_count(input, start, 0)
}

fn do_fill_with_count(input: Board, start: Point, count: Int) -> #(Board, Int) {
  let focus_point = #(start.0, start.1 + 1)
  case dict.get(input, focus_point) {
    Error(_) -> #(input, count)
    Ok(point) ->
      case point {
        Beam | Starter -> #(input, count)
        Empty -> {
          let new = dict.upsert(input, focus_point, fn(_) { Beam })
          do_fill_with_count(new, focus_point, count)
        }
        Splitter -> {
          let #(board, count) =
            do_fill_with_count(
              input,
              #(focus_point.0 - 1, focus_point.1 - 1),
              count + 1,
            )
          do_fill_with_count(
            board,
            #(focus_point.0 + 1, focus_point.1 - 1),
            count,
          )
        }
      }
  }
}

fn traverse_timelines(input: Board, start: Point) -> Int {
  do_traverse_timelines(input, start, 0, dict.new())
  |> pair.second
}

fn do_traverse_timelines(
  input: Board,
  start: Point,
  count: Int,
  memo: Dict(Point, Int),
) -> #(Dict(Point, Int), Int) {
  let focus_point = #(start.0, start.1 + 1)
  case dict.get(memo, focus_point) {
    Ok(n) -> #(memo, n)
    Error(_) ->
      case dict.get(input, focus_point) {
        Error(_) -> #(memo, 1)
        Ok(point) ->
          case point {
            Starter -> #(memo, count)
            Beam | Empty -> {
              let #(memo, count) =
                do_traverse_timelines(input, focus_point, count, memo)
              let memo = dict.insert(memo, focus_point, count)
              #(memo, count)
            }
            Splitter -> {
              let #(memo, add_count) =
                do_traverse_timelines(
                  input,
                  #(focus_point.0 - 1, focus_point.1 - 1),
                  count,
                  memo,
                )
              let #(memo, more_count) =
                do_traverse_timelines(
                  input,
                  #(focus_point.0 + 1, focus_point.1 - 1),
                  count,
                  memo,
                )

              let memo =
                dict.insert(memo, focus_point, count + add_count + more_count)
              #(memo, count + add_count + more_count)
            }
          }
      }
  }
}
