(function() {
  /* MAP
  /////////////////////////////////////////////////////////////////*/
  var width = 960,
  height = 500;

  var projection = d3.geo.albers()
    .rotate([0, 0])
    .center([8.43, 46.8])
    .scale(13600);

  var path = d3.geo.path()
    .projection(projection);

  var svg = d3.select("#map").append("svg")
    .attr("width", width)
    .attr("height", height);

  queue()
    .defer(d3.csv, 'assets/data/fichier1.csv')
    .defer(d3.json, 'assets/geodata/topojson/swiss-municipalities-simplified.json')
    .await(ready);

  function ready (error, fichier, municipalities) {
    var daysByBfsNo = {};
    fichier.forEach(function(d) { 
      daysByBfsNo[d['BFS/OFS-No']] = d['Dauer (Tage)/Durée (jours)'];
    });
    svg.selectAll('path')
    .data(topojson.object(municipalities, municipalities.objects['swiss-municipalities']).geometries)
    .enter().append('path')
    .attr('class', 'municipality')
    .style('fill', function(d) {
      return 'rgba(49,163,84,' + (daysByBfsNo[d.properties.bfsNo] / 60) + ')';
    })
    .attr('d', path);
  }

  /* LOCATION BY TEXT
  /////////////////////////////////////////////////////////////////*/
  $('#location_txt').autocomplete({
    source: function(request, response){
      // TODO: We need an API for the municipalities
      $.get('http://9kl.be/locations.php?callback=?', {
        query: request.term,
        type: 'station'
      }, function(data){
        response($.map(data.stations, function(station){
          return {
            label: station.name,
            station: station
          }
        }));
      }, 'json');
    },
    select: function(event, ui){
      console.log(ui.item.station, ui.item.station.coordinate.x, ui.item.station.coordinate.y);
      map.center({
        lat: ui.item.station.coordinate.y,
        lon: ui.item.station.coordinate.x
      });
      map.zoom(14);
    }
  });
  /* LOCATION BY AUTODETECT
  /////////////////////////////////////////////////////////////////*/
  $('#location_btn').click(function(e) {
    e.preventDefault();
    navigator.geolocation.getCurrentPosition(function(position) {
      var x = position.coords.longitude;
      var y = position.coords.latitude;
      console.log(x,y);
      $('#location_txt').val(y+','+x);
    }, function() {});
  });

})()