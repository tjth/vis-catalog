app.controller('signInController', function($scope, $rootScope, $http, $routeParams, $location) {
    if ($rootScope.user != null) {
        $location.path("/").search("return", null); return;
    }
    
    $rootScope.page = {title: "Sign in",  headerClass:"visualisations", class:"visualisations"}
    
    $scope.signInLabel = "Sign In"

    $scope.authenticate = function(username, password) {
        $scope.signInLabel = "Signing in..."
        
        $http.post('/tokens.json', {username:username, password:password}).
            success(function(data, status, headers, config) {
                $scope.signInLabel = "Success!";
                
                localStorage.setItem("authentication_key", data.token);
                $rootScope.user = {}; // make user non-null
                $rootScope.logIn();
            
                $location.path($routeParams["return"]);
                $location.search("return", null);
            }).
            error(function(data, status, headers, config) {
                $scope.signInLabel = "Sign In"
            });
    }
});