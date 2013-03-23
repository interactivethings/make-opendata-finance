(function() {
/* SETUP
/////////////////////////////////////////////////////////////////*/
var yAxisWidth = 40,
    xAxisHeight = 20,
    margin = {top: 0, right: 0, bottom: 0, left: 0},
    marginFocus = {top: margin.top, right: margin.right, bottom: margin.bottom + xAxisHeight, left: margin.left + yAxisWidth},
    marginContext = {top: margin.top, right: margin.right, bottom: margin.bottom +  + xAxisHeight, left: margin.left + yAxisWidth},
    width = 938 - marginFocus.left - marginFocus.right,
    heightFocus = 500 - marginFocus.top - marginFocus.bottom,
    heightContext = 50 + marginContext.top + marginContext.bottom,
    height = heightFocus + heightContext + margin.bottom,
    years = [2011],
    dataset = [],
    startDate,
    endDate,
    max,
    dayWidth,
    balance = balanceChart();

var xScaleFocus = d3.time.scale().range([0, width]),
    xScaleContext = d3.time.scale().range([0, width]),
    yScaleFocus = d3.scale.linear().range([0, heightFocus/2]),
    yScaleContext = d3.scale.linear().range([0, heightContext/2]);

var xAxis = d3.svg.axis().scale(xScaleFocus).orient("bottom"),
    yAxis = d3.svg.axis().scale(yScaleFocus).orient("left").tickSize(-width),
    xAxisContext = d3.svg.axis().scale(xScaleContext).orient("bottom");

var brush = d3.svg.brush()
    .x(xScaleContext)
    .on("brushstart", brushstart)
    .on("brush", brushmove)
    .on("brushend", brushend);

var vis = d3.select("#chart").append('svg')
    .attr("width", width + marginFocus.left + marginFocus.right)
    .attr("height", height + marginFocus.top + marginFocus.bottom)

vis.append("defs").append("clipPath")
  .attr("id", "clip")
.append("rect")
  .attr("width", width)
  .attr("height", heightFocus);

var focus = vis.append("g")
  .attr("class", "focus")
  .attr("transform", "translate(" + marginFocus.left + "," + marginFocus.top + ")");

focus.append("g")
  .attr("class", "x axis focus-axis")
  .attr("transform", "translate(0," + heightFocus + ")");

focus.append("g")
  .attr("class", "y axis earning_axis");

focus.append("g")
  .attr("class", "y axis spending_axis")
  .attr("transform", "translate(0," + heightFocus /2 + ")");

var context = vis.append("g")
  .attr("class", "context")
  .attr("transform", "translate(" + marginContext.left + "," + marginContext.top + ")");

context.append("g")
  .attr("class", "x axis context-axis")
  .attr("transform", "translate(0," + (heightFocus + xAxisHeight + heightContext) + ")");

context.append("g")
  .attr("class", "x brush")
  .call(brush)
  .selectAll("rect")
  .attr("y", heightFocus + xAxisHeight)
  .attr("height", heightContext);

context.selectAll(".resize").append("path")
  .attr("transform", "translate(0," + (heightFocus + xAxisHeight) + ")")
  .attr("d", resizePath);

function resizePath(d) {
  var e = +(d == "e"),
  x = e ? 1 : -1,
  y = heightContext / 3;
  return "M" + (.5 * x) + "," + y
  + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
  + "V" + (2 * y - 6)
  + "A6,6 0 0 " + e + " " + (.5 * x) + "," + (2 * y)
  + "Z"
  + "M" + (2.5 * x) + "," + (y + 8)
  + "V" + (2 * y - 8)
  + "M" + (4.5 * x) + "," + (y + 8)
  + "V" + (2 * y - 8);
}

/* LOAD DATA
/////////////////////////////////////////////////////////////////*/
queue()
  .defer(d3.csv, "/assets/data/fichier1.csv")
  .await(function(error, data) { 
    if (error) console.error("Noooo!", error);
    onLoad();
  });
function onLoad(){
  refineData();
  drawVisualization();
}
function refineData(){
  buildDataset();
}
function buildDataset(_values){
  _.each(years, function(year){
    dataset = d3.time.days(new XDate(year, 0, 1), new XDate(year + 1, 0, 1));
  });
  _.each(dataset, function(day){
    day.date = new XDate(day);
    day.municipalities = 1;
  });
  startDate = d3.min(dataset, function(d){
    return d.date;
  });
  endDate = d3.max(dataset, function(d){
    return d.date;
  });
  max = d3.max(dataset, function(d) { return d.municipalities; });
}
function drawVisualization(){
  balance.data(dataset);
  balance(vis);
  addInteractivity();
}
/* VISUALIZATION
/////////////////////////////////////////////////////////////////*/
function balanceChart(){
  var data = [];
  var chart = function(vis){

    xScaleContext.domain(d3.extent(dataset.map(function(d) { return d; })));
    yScaleContext.domain([0, max]);
    xScaleFocus.domain(d3.extent(data.map(function(d) { return d; })));
    yScaleFocus.domain([0, max]);
    dayWidth = xScaleFocus(d3.time.day.offset(startDate, 1));
    
    // CHART
    var days = focus.selectAll(".day")
      .data(data)
    
    days.enter().append("rect")
      .attr("class", "day")
      .attr("clip-path", "url(#clip)")
      .attr("x", function(d) { return xScaleFocus(d.date) - dayWidth; })
      .attr("y", function(d) { return 50; })
      .attr("width", dayWidth)
      .attr("height", 50)
      .style("fill", "slategray");
    
    // BRUSH
    var daysContext = context.selectAll(".day-context")
      .data(data)
      
    daysContext.enter().append("rect")
      .attr("class", "day-context")
      .attr("x", function(d) { return xScaleContext(d.date) - dayWidth; })
      .attr("y", function(d) { return heightFocus + xAxisHeight; })
      .attr("width", dayWidth)
      .attr("height", 20)
      .style("fill", "silver");
          
    var b = context.select('.x.brush').node()
    b.parentNode.appendChild(b);

    focus.select('.x.axis.focus-axis').transition().call(xAxis);
    focus.select('.y.axis.focus-axis').transition().duration(750).call(yAxis);
    context.select('.x.axis.context-axis').transition().call(xAxisContext);
  }
  chart.data = function(value) {
    if(!arguments.length) return data;
    data = value;
    return chart;
  }
  return chart;
}

/* INTERACTIVITY
/////////////////////////////////////////////////////////////////*/
function brushstart() {
  vis.classed("selecting", true);
}
function brushmove() {
  xScaleFocus.domain(brush.empty() ? xScaleContext.domain() : brush.extent());
  focus.select(".x.axis").call(xAxis);
  dayWidth = xScaleFocus(d3.time.day.offset(xScaleFocus.domain()[0], 1));
  focus.selectAll(".day")
    .attr("x", function(d) { return xScaleFocus(d.date) - dayWidth; })
    .attr("width", dayWidth);
}
function brushend() {
  vis.classed("selecting", !d3.event.target.empty());
}
function addInteractivity(){
}
})()