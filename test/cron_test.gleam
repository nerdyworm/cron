import cron.{type Cron, Any, Cron, List}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn invalid_parse_test() {
  let result = cron.parse("")
  should.be_error(result)
}

pub fn parse_test() {
  cron.parse("0 12 * * *")
  |> should.be_ok()
  |> should.equal(Cron(List([0]), List([12]), Any, Any, Any))
}

@external(erlang, "erlang", "universaltime")
fn erlang_datetime() -> #(#(Int, Int, Int), #(Int, Int, Int))

pub fn datetime_test() {
  let #(#(_, _, _), #(_, _, _)) = erlang_datetime()
}

pub fn cron_now_test() {
  let datetime = #(#(2024, 1, 31), #(12, 0, 0))

  cron.parse_bang("* * * * *")
  |> cron.is_now_datetime(datetime)
  |> should.be_true()

  cron.parse_bang("0 12 * * *")
  |> cron.is_now_datetime(datetime)
  |> should.be_true()

  cron.parse_bang("0 10 * * *")
  |> cron.is_now_datetime(datetime)
  |> should.be_false()

  cron.parse_bang("0 12 31 1 *")
  |> cron.is_now_datetime(datetime)
  |> should.be_true()

  cron.parse_bang("0 10,11,12 31 1 *")
  |> cron.is_now_datetime(datetime)
  |> should.be_true()
}
