# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"

app.timelineFocus = ->
  root = null
  width = 960
  height = 200
  domain = []
  x = d3.time.scale()

  focus = (g) ->
    root = g.each (days) ->

      x.domain(domain).range([0, width])
      markerWidth = x(d3.time.day.offset(domain[0], 1)) - x.range()[0]

      maxPerDay = d3.max(days, (d) -> d.values.length)

      fill = d3.scale.linear()
        .domain([0, maxPerDay])
        .range(["#fff", "#f00"])

      markers = g.selectAll("rect")
        .data(days, (d) -> d.key)

      markers.enter().append("rect")
        .attr
          transform: (d) -> t(x(parseDate(d.key)), 0)
          height: height
          width: markerWidth
        .style
          fill: (d) -> fill(d.values.length)

      markers.exit().remove()

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

  focus.domain = (value) ->
    return domain unless arguments.length
    domain = value
    x.domain(domain)
    markerWidth = x(d3.time.day.offset(domain[0], 1)) - x.range()[0]
    root?.selectAll("rect")
      .attr
        transform: (d) -> t(x(parseDate(d.key)), 0)
        width: markerWidth
    focus

  focus