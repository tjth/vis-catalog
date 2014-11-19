app.directive('toggleButton', function() {
return {
    scope: {item:'='},
    
    link: function(scope, element, attrs) {
        $(element).addClass("toggle-button")
    }
}});

app.directive('horizontalScroll', function() {
return {
    link: function(scope, element, attrs) {
        $(element).mousewheel(function(event, delta) {
          this.scrollLeft -= (delta * 30);
          event.preventDefault();
       });
    }
}});

app.directive('colorThief', function() {
    return {
        scope: {item:'='},

        controller: ['$scope', function($scope){
            $scope.setBackground = function(element, item) {
                $(element).css("background-color", item.bg);
                if (item.bgBright) {
                    $(element).addClass("bright-background");
                }   
            };
        }],

        link: function(scope, element, attrs) {
            if (scope.item.bg == undefined) {               
                var img = new Image();
                img.src = scope.item.link;

                $(img).on('load', function() {               
                    var color = new ColorThief().getColor(img);


                    var brightness = Math.sqrt( .241 * Math.pow(color[0], 2) + 
                                                .691 * Math.pow(color[1], 2) + 
                                                .068 * Math.pow(color[2], 2));

                    scope.item.bg = "rgb(" + color + ")";
                    scope.item.bgBright = brightness > 255/2;
                    scope.setBackground(element, scope.item);
                });
            } else {
                scope.setBackground(element, scope.item);   
            }
        }
    }; 
}); 