#= require ./timeline

d3.csv "assets/data/fichier.csv", (error, data) ->
  
  timeline = app.timeline()
    .width(960)
    .height(300)

  d3.select(".timeline-vis")
    .datum(data)
    .call(timeline)
