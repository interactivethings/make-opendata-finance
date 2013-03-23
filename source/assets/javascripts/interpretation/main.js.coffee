#= require ./timeline

console.log "The main.js for the interpretation page has been loaded."

d3.csv "assets/data/fichier1.csv", (error, data) ->
  
  timeline = app.timeline()
    .width(960)
    .height(300)

  d3.select(".timeline")
    .datum(data)
    .call(timeline)
