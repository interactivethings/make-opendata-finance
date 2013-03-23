
var app = app || {};

app.map = function () {

  var width = 960,
    height = 500,
    grossIncome = '60000',
    socialGroup = '1',
    nestedData,
    geometries;

  var projection = d3.geo.albers()
    .rotate([0, 0])
    .center([8.43, 46.8])
    .scale(13600);
  
  var path = d3.geo.path()
    .projection(projection);
  
  var svg = d3.select("#map").append("svg")
    .attr("width", width)
    .attr("height", height);
  
  function getTimespan(d) {
    return d['timespan'];
  }

  var map = function () {

  };
  
  map.load = function () {
    queue()
      .defer(d3.csv, 'assets/data/fichier.csv')
      .defer(d3.json, 'assets/geodata/topojson/swiss-municipalities-simplified.json')
      .await(this.ready);
  };

  map.ready = function (error, fichier, municipalities) {

    nestedData = d3.nest()
      .key(function(d) {
        return d.gross_income;
      })
      .key(function(d) {
        return d.social_group;
      })
      .key(function(d) {
        return d.bfs_number;
      })
      .rollup(function(leaves) {
        return leaves[0];
      })
      .map(fichier);

    geometries = topojson.object(municipalities, municipalities.objects['swiss-municipalities']).geometries;

    map.render();
  };

  map.render = function () {
      
    var data = d3.map(nestedData[grossIncome][socialGroup]),
      values = data.values();

    var min = d3.min(values, getTimespan);
    var max = d3.max(values, getTimespan);
    var diff = max - min;

    svg.selectAll('path')
      .data(geometries)
      .enter().append('path')
      .attr('class', 'municipality')
      .attr('data-bfsno', function (d) {
        return d.properties.bfsNo;
      })
      .style('fill', function (d) {
        var bfsNo = d.properties.bfsNo,
          alpha;
        if (data.has(bfsNo)) {
          alpha = (data.get(bfsNo).timespan - min) / diff;
          return 'rgba(49,163,84,' + (1 - alpha) + ')';
        }
        return 'rgb(214,234,247)';
      })
      .attr('d', path)
      .append('title').text(function (d) {
        var bfsNo = d.properties.bfsNo,
          title = d.properties.name,
          taxFreedomDay;
        if (data.has(bfsNo)) {
          taxFreedomDay = data.get(bfsNo).tax_freedom_day;
          title += ', ' + taxFreedomDay.substring(8, 10) + '.' + taxFreedomDay.substring(5, 7) + '.' + taxFreedomDay.substring(0, 4);
        }
        return title;
      });
  };

  return map;
};
