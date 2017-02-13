$(document).ready(function(){

	//$("a").attr("target", "_self");
  	//$("table.dataTable tbody td:first-of-type").text("");

  	var allSubHeaders = $(".subheader");
  	var allMenuItems = $(".sidebar-menu li");

  	//set menuitem ids
  	allMenuItems[0].id = "diff-menu";
  	allMenuItems[1].id = "hitting-menu";
  	allMenuItems[2].id = "pitching-menu";

  	//for click function
  	menuTo = {
  		"diff-menu":{
  			id:"diff",
  			showID: "theStat",
  			hideIDs:["xyHitting", "xyPitching"]
  		},
  		"hitting-menu":{
  			id:"corr-hitting",
  			showID: "xyHitting",
  			hideIDs: ["theStat", "xyPitching"]
  		},
  		"pitching-menu":{
  			id:"corr-pitching",
  			showID: "xyPitching",
  			hideIDs: ["theStat", "xyHitting"]
  		}
  	}

  	//handle clicks of menu
  	allMenuItems.each(function(idx, obj){

  		$(obj).click(function(){
  			change(menuTo[this.id].id);
  			showProperControl(menuTo[this.id].id);
  		});
  	});


  	var idToMapping = {
  		"diff": {
  			"menuitem": $(allMenuItems[0]),
  			"upindex": false
  		},
  		"corr-hitting": {
  			"menuitem": $(allMenuItems[1]),
  			"upindex": "diff"
  		},
  		"corr-pitching": {
  			"menuitem": $(allMenuItems[2]),
  			"upindex": "corr-hitting"
  		}
  	}

  	var listenToElement = function(elem){
  		var h = 30;
  		var pageTop = $(window).scrollTop() + h;
  		var pageBottom = $(window).height() - 2*h;
  		var pageHalf = 0.5 * (pageBottom - h);
  		var elemTop = $(elem).offset().top - pageTop;


  		elemID = elem.attr("id");

  		/*console.log("\n")
  		console.log(elemID + "\t" + elemTop)
  		console.log("t:\t" + pageTop)
  		console.log("m:\t" + pageHalf)
  		console.log("b:\t" + pageBottom)
  		console.log("\n")*/

		var isElemOnPage = (0 < elemTop && elemTop < pageBottom);

		if(isElemOnPage && (elemTop < pageHalf)){
			//highlight the menu item of this element
			change(elemID);
			showProperControl(elemID)
		} else if((elemID !== "diff") && isElemOnPage && (elemTop > pageHalf)){
			//highlight the menu item one above the element's
			//except for "diff" because nothing is above it
			change(idToMapping[elemID].upindex);
			showProperControl(idToMapping[elemID].upindex);
		}
  	}

  	//change the menu item
  	var change = function(changeID){
  		idToMapping[changeID].menuitem.css("background-color", "#cc0000");

  		nonElems = allSubHeaders.each(function(index, value){
	  		if(value.id !== changeID){
	  			idToMapping[value.id].menuitem.css("background-color", "inherit");
	  		} 
  		});
  	}

  	var showProperControl = function(elemID){
  		m = idToMapping[elemID].menuitem.attr("id");
  		showID = menuTo[m].showID;
  		hideIDs = menuTo[m].hideIDs


  		$("[for="+showID+"]").parent().show();

  		$(hideIDs).each(function(i,v){
  			$("[for="+v+"]").parent().hide();
  		});
  	}

  	//page initial
  	change("diff")
  	showProperControl("diff");


	$(window).scroll(function() {
		listenToElement($("#diff"))
		listenToElement($("#corr-hitting"))
		listenToElement($("#corr-pitching"))
    });
});
