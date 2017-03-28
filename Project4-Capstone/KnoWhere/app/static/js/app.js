var myApp = angular.module('KnoWhere', ["ui.bootstrap"]);

myApp.controller('MainController', function MainController() {
  this.name = "KnoWhere";
});


function addZ(n){return n<10 ? '0' + n : ''+n;}
function dateToStr(d, fmt){
  if(fmt == "ymd"){
    return d.getFullYear() + "-" + addZ(d.getMonth()+1) + "-"  + addZ(d.getDate());
  } else {
    return d.toDateString();
  }
}

google.charts.setOnLoadCallback(drawDistanceChart);
google.charts.setOnLoadCallback(drawLocationChart);
google.charts.setOnLoadCallback(drawActivitiesChart);
var mot_panel = document.getElementById("mot-panel")
var activities_panel = document.getElementById("activities-panel")

function drawDistanceChart(hourly_distances) {
  if(hourly_distances === undefined){
    return 0;
  }
  var data = google.visualization.arrayToDataTable(hourly_distances);

  var options = {
    //title: 'Distance Traveled',
    //curveType: 'function',
    legend: { position: 'bottom' },
    hAxis: {title: "Date", slantedText:true, slantedTextAngle:90 },
    vAxis: {title: "Distance"},
    series: {0:{color: '#999999'}}
  };

  window.addEventListener('resize', function(){
    drawDistanceChart(hourly_distances);
  }, true);

  var chart = new google.visualization.LineChart(document.getElementById('distance_chart'));

  chart.draw(data, options);
}


function drawLocationChart(percent_home, percent_work, percent_other) {
  if(percent_home === undefined){
    return 0;
  }
  var data = google.visualization.arrayToDataTable([
    ["Location", "Percent"],
    ["Home", percent_home],
    ["Work", percent_work],
    ["Other", percent_other]
  ]);

  var options = {
    //title: 'Time Spent at Locations',
    //curveType: 'function',
    legend: { position: 'bottom' },
    vAxis: {title: "Percent", minValue:0, maxValue:100},
    series: {0:{color: '#999999'}}
  };

  window.addEventListener('resize', function(){
    drawLocationChart(percent_home, percent_work, percent_other);
  }, true);

  var chart = new google.visualization.ColumnChart(document.getElementById('location_chart'));

  chart.draw(data, options);
}

function drawActivitiesChart(activities) {
  if(activities === undefined){
    return 0;
  }
  var data = google.visualization.arrayToDataTable([
    ["Activity", "Percent"],
    ["Walking", activities.walking],
    ["Train", activities.train],
    ["Driving", activities.driving],
    ["Elevator", activities.elevator],
    ["Standing", activities.standing]
  ]);

  var options = {
    //title: 'Time Spent at Locations',
    //curveType: 'function',
    legend: { position: 'bottom' },
    vAxis: {title: "Percent", minValue:0, maxValue:100},
    series: {0:{color: '#999999'}}
  };

  window.addEventListener('resize', function(){
    drawActivitiesChart(activities);
  }, true);

  var chart = new google.visualization.ColumnChart(document.getElementById('activities_chart'));

  chart.draw(data, options);
}


/*** FORM ***/
myApp.service("shared", function($http){
  var users = []
  var usernames = []
  var the_username = undefined
  var the_user_id = undefined
  var user_data = undefined
  var user_data_first = undefined
  var first_date = undefined
  var user_data_last = undefined
  var last_date = undefined
  var map_latlong = undefined
  var d = new Date()
  var start_date = d
  var end_date = d
  var overviewdate=document.getElementById("overview-date")
  var mapdate=document.getElementById("map-date")
  var total_distance = "--"
  var hourly_distances = undefined
  var home_coord = undefined
  var work_coord = undefined
  var percent_home = "--"
  var percent_work = "--"
  var percent_other = "--"
  var the_animal = "--"
  var commute_time = "--"
  var commute_distance = "--"
  var animal_speed = "--"
  var animal_image_class = ""
  var activities_info = undefined

  var get_first_data = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return ("latitude" in entry) && (
          dateToStr(start_date,"ymd")==entry.date.substring(0,10) || 
              user_data[0].date.substring(0,10)==entry.date.substring(0,10)
        )
      });
    } else {
      return []
    }
  };

  var get_last_data = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return ("latitude" in entry) && (
          dateToStr(end_date,"ymd")==entry.date.substring(0,10) || 
              user_data[user_data.length-5].date.substring(0,10)==entry.date.substring(0,10)
        )
      });
    } else {
      return []
    }
  };

  var get_total_distance = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return "total_distance" in entry;
      });
    } else {
      return []
    }
  };

  var get_hourly_distances = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return "hourly_distances" in entry;
      });
    } else {
      return []
    }
  };

  var get_map_latlong = function(){
    if(user_data_last !== []){
      return user_data_last.map(function(entry){return [entry.latitude,entry.longitude]});
    } else{
      return [];
    }
  };

  var get_home_work_latlong = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return "work" in entry;
      });
    } else {
      return []
    }
  };

  var get_home_work_percent = function(){
    if(user_data !== []){
      return user_data.filter(function(entry){
        return "percent_work" in entry;
      });
    } else {
      return []
    }
  };

  function queryActivities() {
    return $http({
      method: "GET",
      url: "/query_activities"
    }).then(function(response){
      activities_info = response.data
      //console.log(activities_info)
    });
  };
  //static, one time call
  queryActivities();

  return {
    queryUsers: function() {
      return $http({
        method: "GET",
        url: "/query_users"
      }).then(function(response){
        users = response.data
        usernames = users.map(function(x){return x.username})
      });
    },
    queryAnimals: function() {
      return $http({
        method: "GET",
        url: "/query_animals"
      }).then(function(response){
        animal_info = response.data
        the_animal = animal_info["animal"][0].toUpperCase() + animal_info["animal"].substr(1,animal_info["animal"].length).toLowerCase()
        commute_time = animal_info["time"]
        commute_distance = animal_info["distance"]
        animal_speed = animal_info["speed"]
        animal_image_class = "sprite sprite-" + animal_info["animal"]
        //console.log(response.data)
      });
    },
    getTotalDistance: function() {return total_distance},
    getLocationPercents: function() {return {"home":percent_home, "work":percent_work, "other":percent_other}},
    getUser: function(){return the_username;},
    getUsers: function(){return users.map(function(u){return u.username})},
    getStartDate: function() {return start_date;},
    getEndDate: function(){return end_date;},
    getAnimalInfo: function() {return {"time":commute_time, "distance":commute_distance, "animal":the_animal, "speed":animal_speed, "class":animal_image_class}},
    getActivitiesInfo: function() {return activities_info},
    setUser: function(uname){
      if(usernames.indexOf(uname) > -1){
        the_username = uname;
        //the_user_id = users.filter(function(x){return x["username"]==uname})[0]._id;
      }
    },
    setStartDate: function(d){
      start_date = d;
      //console.log(d);
    },
    setEndDate: function(d){
      end_date = d;
      //console.log(d);
    },
    getData: function(){
      var s_date = start_date.getFullYear() + "-" + 
                  (start_date.getMonth()+1) + "-" + 
                  start_date.getDate() + 
                  " 00:00:00.000";
      var e_date_plus_1 = new Date(end_date);
      e_date_plus_1.setDate(e_date_plus_1.getDate() + 1)
      var e_date = e_date_plus_1.getFullYear() + "-" +
                  (e_date_plus_1.getMonth()+1) + "-" +
                  e_date_plus_1.getDate() +
                  " 00:00:00.000";

      return $http({
        method: "GET",
        url: "/query_iphone_test_GPS",
        params: {
          user_name: the_username,
          min_date: s_date,
          max_date: e_date
        }
      }).then(function(response){
        user_data = response.data;
        //console.log(user_data)
        user_data_first = get_first_data();
        user_data_last = get_last_data();
        first_date = new Date(user_data_first[0].date)
        last_date = new Date(user_data_last[0].date)
        //console.log(first_date)
        //console.log(last_date)
        map_latlong = get_map_latlong();
        overviewdate.innerText = dateToStr(first_date, "") + " \u2013 " + dateToStr(last_date, "");
        mapdate.innerText = dateToStr(last_date, "");
        total_distance = (get_total_distance()[0]["total_distance"]).toFixed(2);
        hourly_distances = get_hourly_distances()[0]["hourly_distances"];
        //console.log(hourly_distances)
        var hw = get_home_work_latlong()
        home_coord = [hw[0].home.lat, hw[0].home.long]
        work_coord = [hw[0].work.lat, hw[0].work.long]

        var hwp = get_home_work_percent()
        percent_home = hwp[0].percent_home
        percent_work = hwp[0].percent_work
        percent_other = hwp[0].percent_other


        if(the_username == "glen" && (new Date("2017-03-23 23:59:59")) < end_date && end_date < (new Date("2017-03-25 00:00:00"))){
          mot_panel.setAttribute("class", "col-lg-6");
          console.log(activities_panel)
          activities_panel.removeAttribute("hidden");
        } else {
          mot_panel.setAttribute("class", "col-lg-12");
          activities_panel.setAttribute("hidden", "hidden");

        }


        /*console.log(hwp)
        console.log(percent_home)
        console.log(percent_work)*/
        //console.log(total_distance)

        draw(map_latlong, home_coord, work_coord);
        drawDistanceChart(hourly_distances);
        drawLocationChart(percent_home, percent_work, percent_other);
        drawActivitiesChart(activities_info);
      });
    }
  }
});

myApp.controller("FormController", function($scope, shared, Users){
  shared.queryUsers()
  //this.selected_user = shared.getUser();
  d = new Date();
  this.today = dateToStr(d, "ymd")
  this.setStartDate = shared.setStartDate;
  this.setEndDate = shared.setEndDate;
  this.setUser = shared.setUser;
  this.getUsers = shared.getUsers

  this.start_date = shared.getStartDate();
  this.end_date = shared.getEndDate();
  this.getData = shared.getData
  //this.setStartDate(this.start_date)
  //this.setEndDate(this.end_date)
});

myApp.factory("Users", function($http){
  return {
    getUserData: function(fname) {
      return $http.get("/getData")
    }
  };
  //return ["Andrew", "Bill", "Emil", "Glen"];
});


myApp.factory("Dates", function(){
  return 0 //get min and max dates from the returned data;
});


/*** OVERVIEW ***/
myApp.controller("OverviewController", function($scope, shared){

  start_date = shared.getStartDate()
  end_date = shared.getEndDate()
  this.date_range = toDateRange(start_date, end_date);
  this.getTotalDistance = shared.getTotalDistance;
  this.getLocationPercents = shared.getLocationPercents;
  this.queryAnimals = shared.queryAnimals;
  this.getAnimalInfo = shared.getAnimalInfo
  this.getActivitiesInfo = shared.getActivitiesInfo
  
  $scope.$watch(function(){
    return shared.getStartDate();
  }, function (newVal, oldVal, scope){
    if(newVal !== undefined){
      start_date = newVal;
    }
    scope.overview.date_range = toDateRange(start_date, end_date);
  });

  $scope.$watch(function(){
    return shared.getEndDate();
  }, function (newVal, oldVal, scope){
    if(newVal !== undefined){
      end_date = newVal;
    }
    scope.overview.date_range = toDateRange(start_date, end_date)
  });

  function toDateRange(start_date, end_date){
    if(start_date == end_date){
      date_range = dateToStr(end_date, "");
    } else {
      date_range = dateToStr(start_date, "") + " \u2013 " + dateToStr(end_date, "");
    }

    return date_range
  }

});


/*** MAP ***/
myApp.controller("MapController", function($scope, shared){

  end_date = shared.getEndDate()
  this.date = dateToStr(end_date, "");
  
  $scope.$watch(function(){
    return shared.getEndDate();
  }, function (newVal, oldVal, scope){
    if(newVal !== undefined){
      end_date = newVal;
    }
    scope.map.date = dateToStr(end_date, "");
  });

});