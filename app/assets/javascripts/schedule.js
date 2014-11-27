app.controller('scheduleController', function($scope, $rootScope, Timeslot) {
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}
    $scope.days = [1, 2, 3, 4, 5, 6, 0]; // The make Monday start of week
    $scope.activeTimeslot = null;
    
    $scope.getShortWeekdayName = function(day) {
        return moment().day(day).format("ddd")   
    }

    $scope.formatWeek = function() {
        return $scope.startOfWeek.format("Do MMMM") + " - " +  $scope.startOfWeek.clone().add(7, "days").format("Do MMMM")
    }
    
    $scope.nextWeek = function() {
        $scope.startOfWeek.add(7, "days");
    }   
    
    $scope.previousWeek = function() {
        $scope.startOfWeek.add(-7, "days");
    }
    
    $scope.addTimeslot = function(day, start, end) {
        Timeslot.new({date:date.format(), start:start.format(), end:end.format()}); 
    }
    $scope.removeTimeslot = function(day) {
        if ($scope.activeTimeslot != null) {
            Timeslot.remove({id: activeTimeslot.id});   
        }
    } 
    $scope.getDateForDay = function(day) {
        return $scope.startOfWeek.clone().add(day, "days");   
    }    
    
    $scope.getTimeslotsForWeek = function(startOfWeek) {
        var timeslots = {};
        for (i = 0; i < 7; i++) {
            var date = startOfWeek.clone().add(i, "days");
            var dayTimeslots = Timeslot.query({date: date.format()});
            timeslots[date.format()] = dayTimeslots;
        }
        return timeslots;
    }
    
    // Watchers
    $scope.$watch("startOfWeek", function(newStartOfWeek) {
        $scope.timeslots = $scope.getTimeslotsForWeek($scope.startOfWeek);  
    });
    
    $scope.startOfWeek = moment().startOf('isoweek');
});

app.controller('editTimeslotController', function($scope, $rootScope, $routeParams, Timeslot) {
    $rootScope.page = {title: "Schedule Content",  headerClass:"schedule", class:"schedule"}

    $scope.timeslot = Timeslot.get({ id:$routeParams.id});
    
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
    
    $scope.content = Visualisation.query();
});

    
app.directive('timeslotEditor', function() {
    return {
        scope: {item:'='},
        controller: ['$scope', "$location", function($scope, $location) {
            $scope.editTimeslot = function(timeslot) {
                $location.path('/schedule/timeslot/' + timeslot.id);  
                $scope.$apply();
            }
            
            $scope.$parent.$watch("timeslots", function(newTimeslots) {
                if ($scope.editor != undefined || newTimeslots != undefined) return;
                
                $($scope.editor).timesloteditor("setTimeslots", newTimeslots.get(scope.day));   
            });
            
            $scope.$parent.$watch("startOfWeek", function(newStartOfWeek) {
                if (newStartOfWeek == undefined) return;
                
                $scope.date = newStartOfWeek.clone().add($scope.day, "days");  
                $scope.editor.timesloteditor("setStartTime", $scope.date);
            });
        }],

        link: function(scope, element, attrs) {
            scope.day = attrs.day;
            
            scope.editor = $(element).timesloteditor({ 
                timeslotclicked : function(event, data) {
                    scope.editTimeslot(data.timeslot);
                },
                timeslotRequested : function(event, data) {
                    var id = scope.createTimeslot(data.start, data.end);
                    $(element).timesloteditor("create", id, data.start, data.end);
                },
                timeslotTimeChanged : function(event, data) {
                    scope.changeTimeslotTime(data.id, data.start, data.end);
                },
                timeslotDeleted : function(event, data) {
                    scope.deleteTimeslot(data.id);
                },
            }); 
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

app.directive('slider', function() {
    return {
        scope: {
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
            }).on('slide', function() {
                $(this).find(".noUi-handle").html(scope.formatVal($(this).val()));
            }).val(parseInt(attrs.start));
        }
    }; 
}); 

app.filter('visualisations', function() {
  return function(content, showVisualisations) {
      var show = true;
      if (showVisualisations) {
          show = show && content.type == "visualisation";
      }
      return show;
  };
});

app.filter('adverts', function() {
  return function(content, showAdverts) {
      var show = true;
      if (showAdverts) {
          show = show && content.type == "adverts";
      }
      return show;
  };
});