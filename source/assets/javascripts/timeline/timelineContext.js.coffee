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
    .on "brush", -> 
      if brush.empty()
        dispatch.brush(x.domain())
      else 
        extent = brush.extent()
        start = d3.time.hour.offset(d3.time.day.floor(extent[0]), -12)
        end = d3.time.day.offset(start, 2)
        brush.extent([start, end])
        dispatch.brush(brush.extent())

  context = (g) ->
    g.each (days) ->
        
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

      # Brush
      brush.extent([x.domain()[0], d3.time.day.offset(x.domain()[0], 2)])
      brushes = g.selectAll(".brush").data([0]).enter().append("g")
        .attr
          class: "brush"
        .call(brush)
      brushes.selectAll(".resize").remove()
      brushes.selectAll(".background")
        .style
          background: "transparent"
      brushes.selectAll("rect")
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