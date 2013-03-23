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
    .defer(d3.csv, 'assets/data/fichier.csv')
    .defer(d3.json, 'assets/geodata/topojson/swiss-municipalities-simplified.json')
    .await(ready);

  function ready (error, fichier, municipalities) {

    var indexByBfsNo = {},
      min = 365,
      max = 0,
      diff = 0;

    fichier.forEach(function(d) {
      if (d['gross_income'] == '60000' && d['social_group'] == '1') {
        var days = d['timespan'];
        indexByBfsNo[d['bfs_number']] = d;
        if (days > max) {
          max = days;
        }
        if (days < min) {
          min = days;
        }
      }
    });
    diff = max - min;

    svg.selectAll('path')
      .data(topojson.object(municipalities, municipalities.objects['swiss-municipalities']).geometries)
      .enter().append('path')
      .attr('class', 'municipality')
      .attr('data-bfsno', function (d) {
        return d.properties.bfsNo;
      })
      .style('fill', function (d) {
        var bfsNo = d.properties.bfsNo,
          alpha;
        if (bfsNo in indexByBfsNo) {
          alpha = (indexByBfsNo[bfsNo]['timespan'] - min) / diff;
          return 'rgba(49,163,84,' + (1 - alpha) + ')';
        }
        return 'rgb(214,234,247)';
      })
      .attr('d', path)
      .append('title').text(function (d) {
        var bfsNo = d.properties.bfsNo,
          title = d.properties.name,
          taxFreedomDay;
        if (bfsNo in indexByBfsNo) {
          taxFreedomDay = indexByBfsNo[bfsNo]['tax_freedom_day'];
          2012-01-01
          title += ', ' + taxFreedomDay.substring(8, 10) + '.' + taxFreedomDay.substring(5, 7) + '.' + taxFreedomDay.substring(0, 4);
        }
        return title;
      });
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