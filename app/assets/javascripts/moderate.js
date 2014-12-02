
app.controller('moderateController', function(Visualisation, $scope, $rootScope) {
    if ($rootScope.user == null || $rootScope.user == undefined || !$rootScope.user.isAdmin) {
        showToast("Please log in as an administrator");
        $location.search("return", "/moderate"); $location.path("sign-in"); return;
    }
    
    $rootScope.page = {title: "Moderate Content",  headerClass:"moderate", searchEnabled : true, class:"moderate"}

    $scope.content = Visualisation.query({needsModeration : 'true', expandUser: 'true'})
    $scope.externalUsers = [];
    
    $scope.fadeOutRow = function(childElement, item) {
        var row = $(childElement).parents("tr");
        row.animate({opacity: 0}, 250);
        setTimeout(function() { 
            // Add in another element which we can animate, so table rows do not 'jump' up
            var shrinker = $("<div/>").addClass("shrinker").css({width : "100%", height : row.css("height")});
            $(shrinker).insertAfter(row);
            row.remove(); 
            shrinker.slideUp(250);

            setTimeout(function() { 
                shrinker.remove();

                // Remove content item from content
                $scope.content.splice($scope.content.indexOf(item), 1);

                $scope.$apply();
            }, 250);
        }, 250)
    }


    $scope.approve = function(event, item) {
        Visualisation.approve({id : item.id, authentication_key:$rootScope.user.authentication_key})
        $scope.fadeOutRow(event.target);
    }

    $scope.reject = function(event, item) {
        Visualisation.reject({id : item.id, authentication_key:$rootScope.user.authentication_key})
        $scope.fadeOutRow(event.target, item);
    }

});