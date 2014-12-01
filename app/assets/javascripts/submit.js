app.controller('submitAdvertController', function($scope, $rootScope, $route) {
    $rootScope.page = {title: "Submit Advert", headerClass:"submit-advert", searchEnabled : false, class:"submit"}
});

app.controller('submitVisualisationController', function($scope, $rootScope, $route) {
    $rootScope.page = {title: "Submit Visualisation",  headerClass:"submit-visualisation", searchEnabled : false, class:"submit"}
    $scope.submit = { img:"assets/camera.png" }
    $scope.submitVisualistion = function() {
        var fd = new FormData(document.getElementById("submit-visualisation"));
	var content_type = document.getElementById("content_type");
	var value = content_type.options[content_type.selectedIndex].value;
	fd.append('visualisation[vis_type]', 'vis');
  fd.append('visualisation[content_type]', value);
	if (value == 'weblink'){
      console.log("HELLO");
	    fd.append('visualisation[content]', '');
	} else {
	    fd.append('visualisation[link]', '');
	}
	$.ajax({
	    url: "/visualisations",
	    data: fd,
	    cache: false,
	    contentType: false,
	    processData: false,
	    type: 'POST'
	});
      
    }
});

