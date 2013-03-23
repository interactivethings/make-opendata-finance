# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"

app.timelineFocus = ->
  width = 960
  height = 200

  focus = (g) ->
    g.each (data) ->

    focus


  # Accessors

  focus.width = (value) ->
    return width unless arguments.length
    width = value
    focus

  focus.height = (value) ->
    return height unless arguments.length
    height = value
    focus

  focus