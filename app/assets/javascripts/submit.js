app.controller('submitAdvertController', function($scope, $rootScope, $route) {
    $rootScope.page = {title: "Submit Advert", headerClass:"submit-advert", searchEnabled : false, class:"submit"}
});

app.controller('submitVisualisationController', function($scope, $rootScope, $route, $location) {
    $rootScope.page = {title: "Submit Visualisation",  headerClass:"submit-visualisation", searchEnabled : false, class:"submit"}
    $scope.submit = { img:"assets/camera.png" }
    $scope.submitVisualistion = function() {
        var fd = new FormData(document.getElementById("submit-visualisation"));
	var content_type = document.getElementById("content_type");
	var value = content_type.options[content_type.selectedIndex].value;
	fd.append('visualisation[vis_type]', 'vis');
  fd.append('visualisation[content_type]', value);
	if (value == 'weblink'){
	    fd.append('visualisation[content]', '');
	} else {
	    fd.append('visualisation[link]', '');
	}
  if (document.getElementById('screenshot').value == ''){
      alert("Please submit a screenshot");
  } else if (document.getElementById('name').value == ''){
      alert("Please submit a name");
  } else if (document.getElementById('url').value == '' && value == 'weblink'){
      alert("Please submit a url");
  } else if (document.getElementById('content').value == '' && value == 'file'){
      alert("Please submit a file");
  }
  else {

      $.ajax({
	        url: "/visualisations",
    	    data: fd,
    	    cache: false,
	        contentType: false,
    	    processData: false,
    	    type: 'POST'
    	});
      $location.path('/');
      $route.reload();
  }

      
    }
});

