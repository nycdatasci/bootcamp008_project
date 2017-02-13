// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  $el = $(this);
  var lat = $el.data("lat");
  var long = $el.data("long");
  var zip = $el.data("zip");
  $($("#nav a")[0]).tab("show");
  Shiny.onInputChange("goto", {
    lat: lat,
    lng: long,
    zip: zip,
    nonce: Math.random()
  });
});

input[type="number"] {
  max-width: 80%;
}

div.outer {
  position: fixed;
  top: 41px;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
  padding: 0;
}

/* Customize fonts */
body, label, input, button, select { 
  font-family: 'Helvetica Neue', Helvetica;
  font-weight: 200;
}
h1, h2, h3, h4 { font-weight: 400; }

