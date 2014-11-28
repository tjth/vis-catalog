app.controller('signInController', function($scope, $rootScope, $http, $routeParams, $location) {
    $rootScope.page = {title: "Sign in",  headerClass:"visualisations", class:"visualisations"}
    
    $scope.signInLabel = "Sign In"

    $scope.authenticate = function(username, password) {
        $scope.signInLabel = "Signing in..."
        
        $http.post('/tokens.json', {username:username, password:password}).
            success(function(data, status, headers, config) {
                $scope.signInLabel = "Success!";
                
                localStorage.setItem("auth_token", data.token);
                $location.path($routeParams["return"]);
                $location.search("return", null);
            }).
            error(function(data, status, headers, config) {
                console.log("something bad happened");
                $scope.signInLabel = "Sign In"
            });
    }
});