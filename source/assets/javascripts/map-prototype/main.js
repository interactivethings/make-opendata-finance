
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

var daysByBfsNo = {};

d3.csv('assets/data/fichier1.csv', function (error, fichier) {

    fichier.forEach(function(d) { 
        daysByBfsNo[d['BFS/OFS-No']] = d['Dauer (Tage)/Durée (jours)'];
    });
});

d3.json('assets/geodata/topojson/swiss-municipalities-simplified.json', function(error, municipalities) {

    svg.selectAll('path')
        .data(topojson.object(municipalities, municipalities.objects['swiss-municipalities']).geometries)
        .enter().append('path')
        .attr('class', 'municipality')
        .style('fill', function(d) {
            return 'rgba(49,163,84,' + (daysByBfsNo[d.properties.bfsNo] / 60) + ')';
        })
        .attr('d', path);
});
