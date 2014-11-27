app.controller('signInController', function($scope, $rootScope, $http) {
    $rootScope.page = {title: "Sign in",  headerClass:"", class:""}

    $scope.authenticate = function(username, password) {
        $http.post('/tokens.json', {username:username, password:password}).
            success(function(data, status, headers, config) {
                localStorage.setItem("auth_token", data.token);
            }).
            error(function(data, status, headers, config) {
                console.log("something bad happened")
            });
    }
});