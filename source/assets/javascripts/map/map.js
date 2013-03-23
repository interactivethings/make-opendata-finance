
var app = app || {};

app.map = function () {

  var width = 960,
    height = 500,
    grossIncome = '60000',
    socialGroup = '1',
    nestedData,
    geometries,
    projection,
    path,
    svg,
    scale,
    map;

  projection = d3.geo.albers()
    .rotate([0, 0])
    .center([8.43, 46.8])
    .scale(13600);

  path = d3.geo.path()
    .projection(projection);

  svg = d3.select("#map").append("svg")
    .attr("width", width)
    .attr("height", height);

  scale = d3.scale.linear()
    .range([0, 1]);

  map = function () {
    return map;
  };

  map.load = function () {
    
    d3.json('assets/geodata/topojson/swiss-municipalities-simplified.json', map.draw);

    d3.csv('assets/data/fichier.csv', map.ready);
  };

  map.ready = function (error, fichier) {

    var keys, domain, demographics;

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

    keys = d3.keys(nestedData);

    domain = d3.extent(fichier, function (d) {
      return parseInt(d['timespan'], 10);
    });
    scale.domain(domain);

    function renderIncomeValue(i) {
      var value = keys[i];
      $('#income_value').text('CHF ' + value);
      grossIncome = value;
      map.render();
    }
    
    $('#income_slider')
      .slider({
        orientation: 'horizontal',
        max: keys.length - 1,
        value: 4,
        step: 1,
        slide: function(e, ui) { renderIncomeValue(ui.value); }
      });
    renderIncomeValue($('#income_slider').slider('value'));

    $('input[name="demographics"]').on('change', function () {
      socialGroup = $(this).val();
      map.render();
    });
  };

  map.draw = function (municipalities) {

    geometries = topojson.object(municipalities, municipalities.objects['swiss-municipalities']).geometries;

    svg.selectAll('path')
      .data(geometries)
      .enter().append('path')
      .attr('class', 'municipality')
      .attr('data-bfsno', function (d) {
        return d.properties.bfsNo;
      })
      .style('fill', function (d) {
        return 'rgb(255, 255, 255)';
      })
      .attr('d', path)
      .append('title').text(function (d) {
        return d.properties.name;
      });

  };

  map.render = function () {

    var data, domain;

    data = d3.map(nestedData[grossIncome][socialGroup]);

    domain = d3.extent(data.values(), function (d) {
      return parseInt(d['timespan'], 10);
    });
    scale.domain(domain);

    d3.selectAll('path').style('fill', function (d) {
      var bfsNo, alpha;
      bfsNo = d.properties.bfsNo
      if (data.has(bfsNo)) {
        alpha = scale(parseInt(data.get(bfsNo).timespan, 10));
        return 'rgba(49,163,84,' + alpha + ')';
      }
      return 'rgb(214,234,247)';
    });
  };

  return map;
};
