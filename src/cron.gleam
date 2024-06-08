import gleam/bool
import gleam/int
import gleam/list
import gleam/regex
import gleam/result.{try}
import gleam/string

pub type CronField {
  Any
  Range(Int, Int)
  List(List(Int))
}

pub type Cron {
  Cron(
    minute: CronField,
    hour: CronField,
    day: CronField,
    month: CronField,
    weekday: CronField,
  )
}

pub fn is_now(cron: Cron) {
  is_now_datetime(cron, utc_datetime())
}

pub fn is_now_datetime(
  cron: Cron,
  datetime: #(#(Int, Int, Int), #(Int, Int, Int)),
) -> Bool {
  let #(#(_, month, day), #(hour, minute, _)) = datetime
  use <- bool.guard(when: !includes(cron.month, month), return: False)
  use <- bool.guard(when: !includes(cron.day, day), return: False)
  use <- bool.guard(when: !includes(cron.hour, hour), return: False)
  use <- bool.guard(when: !includes(cron.minute, minute), return: False)
  True
}

pub fn parse(expression: String) {
  let parts = expression |> string.split(" ")

  case parts {
    [minute, hour, day, month, weekday] -> {
      use minute <- try(parse_cron_field(minute))
      use hour <- try(parse_cron_field(hour))
      use day <- try(parse_cron_field(day))
      use month <- try(parse_cron_field(month))
      use weekday <- try(parse_cron_field(weekday))
      Ok(Cron(minute, hour, day, month, weekday))
    }

    _ -> {
      Error("expected 5 parts got: " <> string.inspect(list.length(parts)))
    }
  }
}

pub fn parse_bang(expression: String) {
  let assert Ok(cron) = parse(expression)
  cron
}

fn parse_cron_field(field: String) -> Result(CronField, String) {
  let assert Ok(literal) = regex.from_string("^\\d+$")
  // let assert Ok(step) = regex.from_string("^\\d+(-\\d+)$")

  let maybe_list = string.contains(field, ",")
  let maybe_literal = regex.check(literal, field)

  case field, maybe_list, maybe_literal {
    "*", _, _ -> Ok(Any)

    _, True, _ -> {
      Ok(List(parse_list(field)))
    }

    _, _, True -> {
      case int.parse(field) {
        Error(_) -> Error("could not parse literal")
        Ok(int) -> Ok(List([int]))
      }
    }

    _, _, _ -> Error(field <> " is not a valid cron expression")
  }
}

fn parse_list(field: String) {
  let parts = string.split(field, ",")
  list.fold(parts, [], fn(acc, maybe) {
    case int.parse(maybe) {
      Ok(i) -> [i, ..acc]
      Error(_) -> acc
    }
  })
}

fn includes(field, value: Int) {
  case field {
    Any -> True
    List(items) -> list.contains(items, value)
    _ -> False
  }
}

@external(erlang, "erlang", "universaltime")
fn utc_datetime() -> #(#(Int, Int, Int), #(Int, Int, Int))
