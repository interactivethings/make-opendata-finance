# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"
A = 137.508 / 180 * Math.PI

app.timelineFocus = ->
  root = null
  width = 960
  height = 200
  domain = []
  x = d3.time.scale()
  r = d3.scale.sqrt()

  focus = (g) ->
    root = g.each (days) ->

      x.domain(domain).range([0, width])
      markerWidth = x(d3.time.day.offset(domain[0], 1)) - x.range()[0]

      maxPerDay = d3.max(days, (d) -> d.values.length)

      fill = d3.scale.linear()
        .domain([0, maxPerDay])
        .range(["#fff", "#f00"])

      r.domain([0, maxPerDay]).range([0, Math.min(height / 2, markerWidth / 2)])

      # Detail groups
      groups = g.selectAll(".group")
        .data(days, (d) -> d.key)

      groups.enter().append("g")
        .attr
          class: "group"
          transform: (d) -> t(x(d3.time.hour.offset(parseDate(d.key), 12)), height/2)
      .append("circle")
        .attr
          class: "marker-sum"
          r: (d) -> r(d.values.length)

      groups.exit().remove()

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
    r.range([0, Math.min(height / 2, markerWidth / 2)])
    if root?
      root.selectAll(".group")
        .attr
          transform: (d) -> t(x(parseDate(d.key)) + markerWidth / 2, height / 2)
      .select(".marker-sum")
        .attr
          r: (d) -> r(d.values.length)
    focus

  # Event handlers

  focus.brushstart = ->
    group = d3.selectAll(".group.active")
      .classed("active", false)
    group.select(".marker-sum").transition().duration(100)
      .attr("r", (d) -> r(d.values.length))
    group.selectAll(".detail")
      .remove()
    focus

  focus.brushend = ->
    group = d3.selectAll(".group").filter (d) ->
      day = d3.time.day(parseDate(d.key))
      d3.time.hour.offset(domain[0], 12).getTime() is day.getTime()

    group
      .classed("active", true)

    group.select(".marker-sum").transition().duration(100)
      .attr("r", 0)

    details = group.selectAll(".detail")
      .data((d) -> d.values)

    details.enter().append("circle")
      .attr
        class: "detail"
        transform: (d, i) -> 
          n = i + 1
          angle = n * A
          radius = 8 * Math.sqrt(n)
          t(Math.cos(angle) * radius, Math.sin(angle) * radius)
        r: 5
      .style
        opacity: 0

    details.transition().duration(10).delay((d, i) -> 100 + i * 1)
      .style
        opacity: 1


    focus

  focus