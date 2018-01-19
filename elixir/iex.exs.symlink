# Uncomment for projects
# global_settings = "~/.iex.exs"
# if File.exists?(global_settings), do: Code.require_file(global_settings)

IEx.configure(
  colors: [
    eval_result: [:cyan, :bright]
    # eval_errors: [[:red, :bright, "\n▶▶▶\n"]],
    # eval_info: [:yellow, :bright],
  ],
  inspect: [pretty: true],
  default_prompt:
    [
      # cursor ⇒ column 1
      "\e[G",
      :blue,
      "%prefix",
      :yellow,
      "|",
      :green,
      "[%counter]",
      " ",
      :yellow,
      "➜ ",
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)
