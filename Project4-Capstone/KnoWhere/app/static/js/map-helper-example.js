var access_token = ''
var mymap = L.map('mapid')//.setView([40.7530392755199 , -73.9934996106009], 12);
var layer = L.tileLayer('https://api.mapbox.com/styles/v1/mapbox/streets-v10/tiles/256/{z}/{x}/{y}?access_token='+access_token, {
	attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
	maxZoom: 18,
	accessToken: access_token
})

layer.addTo(mymap);

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

//latlongs = [[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75303928,-73.99349961],[40.75316818,-73.99348298],[40.75328664,-73.99346769],[40.75463194,-73.9937774],[40.75464674,-73.99378616],[40.75463194,-73.993749],[40.75463194,-73.99420346],[40.75463194,-73.99330114],[40.75463194,-73.99329492],[40.75463194,-73.99329448],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99329404],[40.75463194,-73.99374948],[40.75463194,-73.99374948],[40.75463194,-73.99374948],[40.75463194,-73.99385164],[40.69183001,-73.98584312],[40.69173645,-73.98625812],[40.6916709,-73.9862998],[40.69162911,-73.98632638],[40.69160247,-73.98634332],[40.69178687,-73.98581834],[40.69178569,-73.98582116]]

var polys = []

var get_polys = function(){
	return polys;
};

var reset_poly = function(){
	polys = [];
};

var append_to_poly = function(obj){
	polys.push(obj);
};

/*async function draw(points){
	p = get_polys();

	for(var i = 0; i < p.length; i++){
		p[i].removeFrom(mymap)
	}

	reset_poly();

	var markers = [L.marker(points[0])]
	var num_pts = points.length
	var ms = get_sleep_ms(num_pts)

	for(var i = 0; i < num_pts-1; i++){
		markers[i+1] = L.marker(points[i+1])
		var group = new L.featureGroup(markers);
		mymap.fitBounds(group.getBounds());
		await sleep(ms)
		var temp = L.polygon([points[i], points[i+1]]);
		temp.addTo(mymap);

		append_to_poly(i, temp);
	}
}

var get_sleep_ms = function(num_points){
	var num_seconds = 1;
	return (1000 * num_seconds) / num_points;
}
*/

async function draw(points, home_coords, work_coords){
	p = get_polys();

	for(var i = 0; i < p.length; i++){
		try{
			p[i].removeFrom(mymap)
		} catch(err) {}
		
	}

	reset_poly();

	var markers = []
	for(var idx in points){
		markers[idx] = L.marker(points[idx])
	}

	var group = new L.featureGroup(markers);
	mymap.fitBounds(group.getBounds());

	var temp = L.polygon(points);
	temp.addTo(mymap);

	var home = L.marker(home_coords);
	var work = L.marker(work_coords);
	home.addTo(mymap);
	work.addTo(mymap);
	home.bindPopup("home").openPopup();
	work.bindPopup("work");


	append_to_poly(temp);
	append_to_poly(home);
	append_to_poly(work);
	
}