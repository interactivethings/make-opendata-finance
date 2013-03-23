# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"

app.timelineContext = ->
  width = 960
  height = 100
  domain = []
  dispatch = d3.dispatch("brushstart", "brush", "brushend")
  x = d3.time.scale()
  brush = d3.svg.brush()
    .x(x)
    .on("brushstart", dispatch.brushstart)
    .on("brushend", dispatch.brushend)
    .on("brush", -> if brush.empty() then dispatch.brush(x.domain()) else dispatch.brush(brush.extent()))

  context = (g) ->
    g.each (days) ->
        
      x.domain(domain).range([10, width - 10])
      markerWidth = x(d3.time.day.offset(domain[0], 1)) - x.range()[0]

      maxPerDay = d3.max(days, (d) -> d.values.length)
      # console.log "median", d3.median(days, (d) -> d.values.length)
      # console.log "mean", d3.mean(days, (d) -> d.values.length)

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

      # Brush
      g.selectAll(".brush").data([0]).enter().append("g")
        .attr
          class: "brush"
        .call(brush)
      .selectAll("rect")
        .attr
          height: height

    context

  # Accessors

  context.width = (value) ->
    return width unless arguments.length
    width = value
    context

  context.height = (value) ->
    return height unless arguments.length
    height = value
    context

  context.domain = (value) ->
    return domain unless arguments.length
    domain = value
    context

  d3.rebind(context, dispatch, "on")
  context