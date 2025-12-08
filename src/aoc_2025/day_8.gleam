import gleam/float
import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Box {
  Box(x: Int, y: Int, z: Int)
}

pub type Circuit =
  Set(Set(Box))

pub fn parse(input: String) -> List(Box) {
  input
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.map(string.split(_, ","))
  |> list.map(parse_box)
  |> result.values
}

pub fn pt_1(input: List(Box)) {
  let sorted =
    input
    |> list.combinations(2)
    |> list.map(to_pair)
    |> result.values
    |> list.map(fn(t) { get_length(t.0, t.1) })
    |> list.sort(sort_box_length)

  let head =
    sorted
    |> list.take(1000)
    |> make_circuits

  let tail =
    remove_connected(head, input)
    |> list.map(fn(x) { set.new() |> set.insert(x) })

  list.fold(tail, head, set.insert)
  |> set.to_list
  |> list.map(set.size)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> int.product
}

pub fn pt_2(input: List(Box)) {
  let sorted =
    input
    |> list.combinations(2)
    |> list.map(to_pair)
    |> result.values
    |> list.map(fn(t) { get_length(t.0, t.1) })
    |> list.sort(sort_box_length)

  let end = merge_all(sorted, input)
  { end.0 }.x * { end.1 }.x
}

fn remove_connected(circuit: Circuit, boxes: List(Box)) -> List(Box) {
  boxes
  |> list.filter(fn(x) { !has_box(circuit, x) })
}

fn has_box(circuit: Circuit, box: Box) -> Bool {
  circuit
  |> set.to_list
  |> list.any(set.contains(_, box))
}

fn parse_box(input: List(String)) -> Result(Box, Nil) {
  case input {
    [xs, ys, zs] ->
      case int.parse(xs), int.parse(ys), int.parse(zs) {
        Ok(x), Ok(y), Ok(z) -> Ok(Box(x:, y:, z:))
        _, _, _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn get_length(a: Box, b: Box) -> #(Float, Box, Box) {
  let x = a.x |> int.to_float
  let y = a.y |> int.to_float
  let z = a.z |> int.to_float
  let x2 = b.x |> int.to_float
  let y2 = b.y |> int.to_float
  let z2 = b.z |> int.to_float
  let xd = { x -. x2 } *. { x -. x2 }
  let yd = { y -. y2 } *. { y -. y2 }
  let zd = { z -. z2 } *. { z -. z2 }
  let d =
    float.square_root(xd +. yd +. zd)
    |> result.unwrap(-1.0)

  #(d, a, b)
}

fn to_pair(input: List(a)) -> Result(#(a, a), Nil) {
  case input {
    [fst, snd] -> Ok(#(fst, snd))
    _ -> Error(Nil)
  }
}

fn sort_box_length(a: #(Float, Box, Box), b: #(Float, Box, Box)) -> Order {
  case a.0 <. b.0 {
    True -> order.Lt
    False -> order.Gt
  }
}

fn make_circuits(input: List(#(Float, Box, Box))) -> Circuit {
  do_make_circuits(input, set.new())
}

fn do_make_circuits(input: List(#(Float, Box, Box)), acc: Circuit) -> Circuit {
  case input {
    [] -> acc
    [head, ..tail] -> do_make_circuits(tail, merge(acc, #(head.1, head.2)))
  }
}

fn merge(circuit: Circuit, boxes: #(Box, Box)) -> Circuit {
  let as_list = set.to_list(circuit)
  case
    list.find(as_list, set.contains(_, boxes.0)),
    list.find(as_list, set.contains(_, boxes.1))
  {
    Error(_), Error(_) ->
      set.new()
      |> set.insert(boxes.0)
      |> set.insert(boxes.1)
      |> set.insert(circuit, _)
    Ok(set), Error(_) -> update_circuit(circuit, set, boxes)
    Error(_), Ok(set) -> update_circuit(circuit, set, boxes)
    Ok(set1), Ok(set2) -> merge_sets(circuit, set1, set2)
  }
}

fn update_circuit(
  circuit: Circuit,
  set: Set(Box),
  boxes: #(Box, Box),
) -> Circuit {
  let new_set =
    set
    |> set.insert(boxes.0)
    |> set.insert(boxes.1)

  circuit
  |> set.delete(set)
  |> set.insert(new_set)
}

fn merge_sets(circuit: Circuit, set1: Set(Box), set2: Set(Box)) -> Circuit {
  circuit
  |> set.delete(set1)
  |> set.delete(set2)
  |> set.insert(set.union(set1, set2))
}

fn merge_all(input: List(#(Float, Box, Box)), boxes: List(Box)) -> #(Box, Box) {
  do_merge_all(input, set.new(), set.from_list(boxes), #(empty(), empty()))
}

fn do_merge_all(
  input: List(#(Float, Box, Box)),
  circuit: Circuit,
  boxes: Set(Box),
  last: #(Box, Box),
) -> #(Box, Box) {
  case set.size(circuit), set.size(boxes) {
    1, 0 -> last
    _, _ -> {
      let assert [head, ..tail] = input
      let circuit = merge(circuit, #(head.1, head.2))
      let boxes =
        set.delete(boxes, head.1)
        |> set.delete(head.2)
      do_merge_all(tail, circuit, boxes, #(head.1, head.2))
    }
  }
}

fn empty() -> Box {
  Box(-1, -1, -1)
}
