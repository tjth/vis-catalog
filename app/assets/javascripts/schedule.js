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

app.controller('editTimeslotController', function($scope, $rootScope, Timeslot) {
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}
    
    
    $scope.timeslot = { date: moment(), start: moment(), end : moment().clone().add(1, "hours")};
    
    $scope.setActiveContentItem = function(contentItem) {
        $scope.activeContentItem = contentItem;  
    }
    
    $scope.formatDay = function(date) {
        return date.format("ddd").toUpperCase();
    }
    
    $scope.formatTime = function(start, end) {
        return start.format("HH:mm") + " - " +  end.format("HH:mm")
    }
    
    $scope.containsContent = function(list, content) {
        for (i = 0; i < list.length; i++) {
            if (list[i].id == content.id) {
                return true;
            }
        }
        return false;
    }
    
    $scope.timeslotContent = []
    $scope.activeContentItem = null;
    
    //$scope.content = Visualisation.query();
    
    $scope.content = [{ author: {name : "Tim 'The Power' van Bremen"}, name : "Traffic in Milan", img : "/assets/dummy/milan.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "1"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Green", img : "/assets/dummy/green.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "2"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "3"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "4"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Green", img : "/assets/dummy/green.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "5"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "6"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "7"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "8"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "9"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Traffic in Milan", img : "/assets/dummy/milan.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", url : "1"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Green", img : "/assets/dummy/green.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "10"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "11"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "12"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Green", img : "/assets/dummy/green.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "13"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "14"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "15"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Pink", img : "/assets/dummy/pink.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "16"},
                                   { author: {name : "Tim 'The Power' van Bremen"}, name : "Power", img : "/assets/dummy/power.png", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", id : "17"}];
    
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


app.directive('contentDropTarget', function() {
    return {
        link: function(scope, element, attrs) {
            $(element).addClass("content-drop-target");
            
            element.bind("dragenter", function(e) {
                element.addClass("dragover");
                element.parent().addClass("dragover");
            });            
            element.bind("dragleave", function(e) {
                element.removeClass("dragover");
                element.parent().removeClass("dragover");
            });                  
            element.bind("dragover", function(e) {
                e.preventDefault();
            });            

            element.bind("drop", function(e) {
                var content = JSON.parse(e.originalEvent.dataTransfer.getData('text/json'));
                
                if (!scope.containsContent(scope.timeslotContent, content)) {
                    scope.timeslotContent.push(content);
                }
                element.removeClass("dragover");
                element.parent().removeClass("dragover");
                scope.$apply();
            });
        }
    }; 
}); 

app.directive('contentItem', function() {
    return {
        scope: {
            content: '=content'
        },
        link: function(scope, element, attrs) {
            $(element).addClass("content-item").addClass("card");
            
            $("<div></div>").addClass("screenshot")
                            .css("background-image", "url('" + scope.content.img + "')")
                            .appendTo(element);            
            
            var text = $("<div></div>").addClass("text")
                                       .appendTo(element);
            
            $("<div></div>").addClass("name")
                            .html(scope.content.name)
                            .appendTo(text);
            
            $("<div></div>").addClass("author")
                            .html(scope.content.author.name)
                            .appendTo(text);
            
            $(element).bind("dragstart", function(e) {
                e.originalEvent.dataTransfer.setData('text/json', JSON.stringify(scope.content)); 
                
                
                if ($(element).parent().hasClass("content-drop-target")) {
                    var index = scope.$parent.timeslotContent.indexOf(scope.content);
                    scope.$parent.timeslotContent.splice(index, 1);
                }
            });
            
            $(element).bind("dragend", function(e) {
                 scope.$parent.$apply();
            });
        }
    }; 
}); 