    
app.controller('scheduleController', function($scope, $rootScope, Timeslot) {
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}
    $scope.days = [1, 2, 3, 4, 5, 6, 0]; // The make Monday start of week
    $scope.startOfWeek = moment().startOf('isoweek');
    $scope.activeTimeslot = null;

    $scope.timeslots = [ {startTime:"2014-11-13T10:00:00Z", endTime:"2014-11-13T11:00:00Z", visualisations: [1, 2, 3], adverts:[5, 6, 7]} ];
    //$scope.timeslots = Timeslot.query({startOfWeek: $scope.startOfWeek.format()});

    $scope.getShortWeekdayName = function(day) {
        return moment().day(day).format("ddd")   
    }

    $scope.formatWeek = function() {
        return $scope.startOfWeek.format("Do MMMM") + " - " +  $scope.startOfWeek.clone().add(7, "days").format("Do MMMM")
    }

    $scope.nextWeek = function() {
        $scope.startOfWeek.add(7, "days");
        //$scope.timeslots = Timeslot.query({startOfWeek: $scope.startOfWeek.format()});
    }   
    $scope.previousWeek = function() {
        $scope.startOfWeek.add(-7, "days");
        //$scope.timeslots = Timeslot.query({startOfWeek: $scope.startOfWeek.format()});
    }
    $scope.addTimeslot = function(day) {
           Timeslot.add({date: $scope.getDateForDay(day).format()}); 
    }
    $scope.removeTimeslot = function(day) {
        if ($scope.activeTimeslot != null) {
            Timeslot.remove({id: activeTimeslot.id});   
        }
    } 
    $scope.getDateForDay = function(day) {
        return $scope.startOfWeek.clone().add(day, "days");   
    }
});

    
app.directive('timeslotEditor', function() {
    return {
        scope: {item:'='},
        controller: ['$scope', "$location", function($scope, $location) {
            $scope.editTimeslot = function(timeslot) {
                $location.path('/schedule/timeslot/' + timeslot.id);  
                $scope.$apply();
            }
        }],

        link: function(scope, element, attrs) {
            $(element).timesloteditor({ timeslotclicked : function(event, data) {
                scope.editTimeslot(data.timeslot);
            }});
            $(element).timesloteditor("setStartTime", moment(attrs["startOfWeek"]).add(attrs["day"], "days"));
        }
    }; 
}); 