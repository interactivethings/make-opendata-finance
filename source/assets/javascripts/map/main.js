#= require ./map

(function() {
  
  app.map().load();

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

})();
