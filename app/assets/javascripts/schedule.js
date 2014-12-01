app.controller('scheduleController', function($scope, $rootScope, $location, Timeslot) {

    if ($rootScope.user == null || $rootScope.user == undefined || !$rootScope.user.admin) {
        $location.search("return", $location.path()); $location.path("sign-in"); return;
    }
    
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}
    $scope.days = [1, 2, 3, 4, 5, 6, 0]; // The make Monday start of week
    $scope.activeTimeslot = null;
    $scope.timeslots = [];
    
    $scope.getShortWeekdayName = function(day) {
        return moment().day(day).format("ddd")   
    }

    $scope.formatWeek = function() {
        return $scope.startOfWeek.format("Do MMMM") + " - " +  $scope.startOfWeek.clone().add(7, "days").format("Do MMMM")
    }
    
    $scope.nextWeek = function() {
        $scope.startOfWeek = $scope.startOfWeek.add(7, "days");
    }   
    
    $scope.previousWeek = function() {
        $scope.startOfWeek.add(-7, "days");
    }
    
    $scope.addTimeslot = function(start, end, element) {
        return Timeslot.new({start_time:start.format(), end_time:end.format()}, 
            // Success
            function(timeslot) {
            
                $(element).timesloteditor("addTimeslot", timeslot.id, start, end);
            }); 
    }
    
    $scope.removeTimeslot = function(id, element) {
        Timeslot.remove({id: id}, 
            // Success
            function(timeslot) {
                $(element).timesloteditor("removeTimeslot", id);
            }
        ); 
    }
    
    $scope.updateTimeslot = function(id, start, end) {
        Timeslot.update({id: id, start_time : start, end_time: end}); 
    }
    
    $scope.editTimeslot = function(id) {
        $location.path('/schedule/timeslot/' + id);  
    }
    
    $scope.getDateForDay = function(day) {
        return $scope.startOfWeek.clone().add(day, "days");   
    }    

    
    // Watchers
    $scope.$watch("startOfWeek", function(newStartOfWeek) {
        var timeslots = [];
        
        var done = 7;
        
        for (var i = 0; i < 7; i++) {
            var date = $scope.startOfWeek.clone().add(i, "days");
            
            Timeslot.query({startOfDay: date.format()},   
                // Success      
                (function(i) {
                    return function(dayTimeslots) {
                        
                        timeslots[i] = dayTimeslots;
                        done--;

                        if (done == 0) {
                            $scope.timeslots = timeslots;  
                        }
                    }
                })(i)
            );
        } 
    }, true);
    
    $scope.startOfWeek = moment().startOf('isoweek');
    
    $scope.scrolled = false;
});

app.controller('editTimeslotController', function($scope, $rootScope, $routeParams, $location, Visualisation, Timeslot, Programme) {
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}

    Timeslot.get({id:$routeParams.id}, 
        // Success
        function(timeslot) {
            $scope.timeslot = timeslot;
        }                             
    );
    
    $scope.formatDay = function(date) {
        if (date == undefined) return "";
        return date.format("ddd").toUpperCase();
    }
    
    $scope.formatTime = function(start, end) {
        if (start == undefined || end == undefined) return "";
        return start.format("HH:mm") + " - " +  end.format("HH:mm")
    }
    
    $scope.formatType = function(type) {
        if (type == "vis") {
            return "Visualisation";   
        }
        if (type == "advert") {
            return "Advert"   
        }
    }
    
    $scope.containsContentItem = function(content_id) {
        for (i = 0; i < $scope.programmes.length; i++) {
            if ($scope.programmes[i].content_id == content_id) {
                return true;
            }
        }
        return false;
    }
    
    $scope.addProgramme = function(content) {
        Programme.new({content_id:content.id, timeslot_id:$scope.timeslot.id, 
                       authentication_key : localStorage.getItem("authentication_key")},
            // Success
            function(programme) {
                $scope.programmes.push(programme);
            }
        );
    }

    $scope.onFieldChanged = function(field, val) {
        var params = {id:activeProgramme.id, authentication_key:$rootScope.user.authentication_key};

        if (field == "priority") {
            params.priority = val;
        } else if (field == "screens") {
            params.screens = val;
        }

        Programme.update(params, 
            // Success
            function(programme) {
            
            }
        );
    }
    
    $scope.programmes = []
    $scope.activeProgramme = null;
    
    $scope.content = Visualisation.query();
    
    $scope.showAdverts = true;
    $scope.showVisualisations = true;
    
    $scope.$watch("activeProgramme", function() {
        if ($scope.activeProgramme == null) return;
        
        $scope.programmes = Programme.query({timeslot_id:$scope.activeProgramme.id, authentication_key:$rootScope.user.authentication_key});
    });
});

    
app.directive('timeslotEditor', function() {
    return {
        scope: {item:'='},
        controller: ['$scope', "$location", function($scope, $location) {
            $scope.$parent.$watch("timeslots", function() {
                if ($scope.editor == undefined || $scope.$parent.timeslots.length == 0) return;
                
                $($scope.editor).timesloteditor("setTimeslots", $scope.$parent.timeslots[$scope.day]);   
            });
            
            $scope.$parent.$watch("startOfWeek", function() {
                if ($scope.$parent.startOfWeek == undefined) return;
                
                $scope.date = $scope.$parent.startOfWeek.clone().add($scope.day, "days");  
                $scope.editor.timesloteditor("setStartTime", $scope.date);
            }, true);
        }],

        link: function(scope, element, attrs) {
            scope.day = attrs.day;
            
            scope.editor = $(element).timesloteditor({ 
                timeslotClicked : function(event, id) {
                    scope.$parent.editTimeslot(id);
                },
                timeslotAddRequested : function(event, data) {
                    scope.$parent.addTimeslot(data.start, data.end, $(element));
                },
                timeslotChanged : function(event, data) {
                    scope.$parent.updateTimeslot(data.id, data.start, data.end);
                },
                timeslotRemoveRequested : function(event, id) {
                    scope.$parent.removeTimeslot(id, $(element));
                },
            }); 
            
            if (!scope.$parent.scrolled) {
                $(".scroll").animate({scrollLeft:scope.editor.timesloteditor("getStartPosition")}, 0);
                scope.$parent.scrolled = true;
            }
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

                if (!scope.containsContentItem(scope.timeslotContent, content)) {
                    scope.addProgramme(content);
                }
                
                element.removeClass("dragover");
                element.parent().removeClass("dragover");
            });
        }
    }; 
}); 

app.directive('contentItem', function() {
    return {
        scope: {
            contentItem: '=data'
        },
        link: function(scope, element, attrs) {
            $(element).addClass("content-item").addClass("card");
            
            $("<div></div>").addClass("screenshot")
                            .css("background-image", "url('" + scope.contentItem.screenshot + "')")
                            .appendTo(element);            
            
            var text = $("<div></div>").addClass("text")
                                       .appendTo(element);
            
            $("<div></div>").addClass("name")
                            .html(scope.contentItem.name)
                            .appendTo(text);
            
            $("<div></div>").addClass("author")
                            .html(scope.contentItem.author.name)
                            .appendTo(text);
            
            $(element).bind("dragstart", function(e) {
                
                e.originalEvent.dataTransfer.setData('text/json', JSON.stringify(scope.contentItem)); 
                
                if ($(element).parent().hasClass("content-drop-target")) {

                    for (var i = 0; i < scope.$parent.programmes; i++) {
                        if (scope.$parent.programmes[i].content.id == scope.contentItem.id) {
                            Programme.remove({id : scope.$parent.programmes[i].id, authentication_key:$rootScope.user.authentication_key});
                            scope.$parent.programmes.splice(index, 1);
                        }
                    }

                }
            });
            
            $(element).bind("dragend", function(e) {
                 scope.$parent.$apply();
            });
        }
    }; 
}); 

app.directive('slider', function() {
    return {
        scope: {
            field:"="
        },
        link: function(scope, element, attrs) {
            scope.formatVal = function(value) {
                var val = parseInt(value);
                return val.toFixed(0);
            };
            
            $(element).noUiSlider({
                start: [ parseInt(attrs.start) ],
                step: parseInt(attrs.step),
                range: {
                    'min':  parseInt(attrs.min),
                    'max':  parseInt(attrs.max)
                },
                connect: "lower"
            }).noUiSlider_pips({
                mode: 'steps',
                density:1
            }).on('set', function() {
                $(this).find(".noUi-handle").html(scope.formatVal($(this).val()));

		        scope.$parent.onFieldChanged(scope.field, $(this).val());
            }).on('slide', function() {
                $(this).find(".noUi-handle").html(scope.formatVal($(this).val()));
            }).val(parseInt(attrs.start));
        }
    }; 
}); 

app.filter('visualisations', function() {
    return function(content, showVisualisations) {
        var filtered = []

        for (var i = 0; i < content.length; i++) {
            if (content[i].vis_type == "vis" && !showVisualisations) continue;
            filtered.push(content[i]);
        }

        return filtered;
    };
});

app.filter('adverts', function() {
    return function(content, showAdverts) {
        var filtered = []

        for (var i = 0; i < content.length; i++) {
            if (content[i].vis_type == "advert" && !showAdverts) continue;
            filtered.push(content[i]);
        }

        return filtered;
  };
});
