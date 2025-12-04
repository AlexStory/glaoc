import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Map =
  Dict(#(Int, Int), Bool)

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.split(_, ""))
  |> to_dict
}

pub fn pt_1(input: Map) {
  input
  |> count_neighbors
  |> list.length
}

pub fn pt_2(input: Dict(#(Int, Int), Bool)) {
  input
  |> remove_paper
}

fn to_dict(input: List(List(String))) -> Map {
  list.index_fold(input, dict.new(), fn(m, row, y) {
    list.index_fold(row, m, fn(acc, col, x) {
      case col == "@" {
        True -> dict.insert(acc, #(x, y), True)
        False -> acc
      }
    })
  })
}

fn count_neighbors(input: Map) -> List(#(Int, Int)) {
  dict.fold(input, [], fn(acc, k, _v) {
    let #(x, y) = k
    let total =
      count_spot(input, #(x - 1, y - 1))
      + count_spot(input, #(x, y - 1))
      + count_spot(input, #(x + 1, y - 1))
      + count_spot(input, #(x - 1, y))
      + count_spot(input, #(x + 1, y))
      + count_spot(input, #(x - 1, y + 1))
      + count_spot(input, #(x, y + 1))
      + count_spot(input, #(x + 1, y + 1))

    case total < 4 {
      True -> [k, ..acc]
      False -> acc
    }
  })
}

fn count_spot(map: Map, location: #(Int, Int)) -> Int {
  case dict.get(map, location) {
    Ok(_) -> 1
    _ -> 0
  }
}

fn remove_paper(map: Map) -> Int {
  do_remove_paper(map, 0)
}

fn do_remove_paper(map: Map, count: Int) -> Int {
  let removable = count_neighbors(map)
  let num = list.length(removable)
  let cleaned = dict.drop(map, removable)

  case num {
    0 -> count
    _ -> do_remove_paper(cleaned, num + count)
  }
}
