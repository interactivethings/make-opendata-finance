# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"


app.timeline = ->
  width = 960
  height = 200

  timeline = (selection) ->
    selection.each (data) ->
      console.log this
      # Append an SVG, but only once
      vis = d3.select(this).selectAll("svg").data([0]).enter().append("svg")
        .attr
          width: width
          height: height

      data.forEach (d) ->
        d.timespan = +d.timespan

      days = d3.nest()
        .key((d) -> d.tax_freedom_day)
        .entries(data)

      timeExtent = d3.extent(days, (d) -> parseDate(d.key))
      # start = new Date(2011, 1, 1)
      # end = d3.time.year.offset(start, 1)
      # timeExtent = [start, end]

      x = d3.time.scale()
        .domain(timeExtent)
        .range([10, width - 10])

      console.log "max", maxPerDay = d3.max(days, (d) -> d.values.length)
      console.log "median", d3.median(days, (d) -> d.values.length)
      console.log "mean", d3.mean(days, (d) -> d.values.length)
      r = d3.scale.sqrt()
        .domain([0, maxPerDay])
        .range([1, 10])

      markers = vis.selectAll("circle")
        .data(days, (d) -> d.key)

      markers.enter().append("circle")
        .attr
          transform: (d) -> t(x(parseDate(d.key)), height/2)
          r: (d) -> r(d.values.length)

      markers.exit().remove()

    timeline

  # Accessors

  timeline.width = (value) ->
    return width unless arguments.length
    width = value
    timeline

  timeline.height = (value) ->
    return height unless arguments.length
    height = value
    timeline

  timeline