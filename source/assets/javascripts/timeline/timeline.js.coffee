#= require ./timelineFocus
#= require ./timelineContext

# Some helpers
parseDate = d3.time.format("%Y-%m-%d").parse
t = (x, y) -> "translate(#{x},#{y})"

app.timeline = ->
  width = 960
  height = 300
  focus = app.timelineFocus()
    .width(width)
    .height(260)
  context = app.timelineContext()
    .width(width)
    .height(30)
    .on("brush", focus.domain)

  timeline = (selection) ->
    selection.each (data) ->
      # Mangle data, construct scales
      data.forEach (d) -> d.timespan = +d.timespan

      days = d3.nest()
        .key((d) -> d.tax_freedom_day)
        .entries(data)

      timeExtent = d3.extent(days, (d) -> parseDate(d.key))
      # start = new Date(2011, 1, 1)
      # end = d3.time.year.offset(start, 1)
      # timeExtent = [start, end]

      # Append an SVG, but only once
      vis = d3.select(this).selectAll("svg").data([0])
      visEnter = vis.enter().append("svg")
        .attr
          width: width
          height: height

      visEnter.append("g")
        .attr
          class: "timeline-focus"

      visEnter.append("g")
        .attr
          class: "timeline-context"
          transform: t(0, height - context.height())

      focus.domain(timeExtent)
      vis.select(".timeline-focus")
        .datum(days)
        .call(focus)

      context.domain(timeExtent)
      vis.select(".timeline-context")
        .datum(days)
        .call(context)

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