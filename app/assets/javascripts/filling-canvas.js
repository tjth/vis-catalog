$.widget("widgets.fillingCanvas", {

    _create: function() {
        this.element.css({width: "100%", height:"100%"});
        
        var that = this;
        jQuery(window).resize(function() {
            that._fill();
        });
        that._fill();
    },

    _fill: function() {
        this.element.get(0).width  = this.element.get(0).offsetWidth;
        this.element.get(0).height = this.element.get(0).offsetHeight;
    },
});
