var MOVE = 0;
var RESIZE = 1;

var LEFT = 0;
var RIGHT = 1;


function isNear(x, y, x1, y1, tolerance, handle) {
    var diffX, diffY;

    if (handle == LEFT) diffX = x - x1;
    if (handle == RIGHT) diffX = x1 - x;
    
    diffY = Math.abs((y - y1) * 2);

    return diffX <= tolerance && diffX > 0 &&
           diffY <= tolerance && diffY > 0;
}

function Timeslot(start, end) {
    this.start = start;
    this.end = end;
}

Timeslot.prototype.moveMinutes = function(minutes) {
        this.start.add(minutes, "minutes");
        this.end.add(minutes, "minutes");
}

Timeslot.prototype.in = function(time) {
        return (start.diff(time, minutes) <= 0 && end.diff(time, "minutes") >= 0);
}

$.widget("widgets.timesloteditor", {

    options: {},
    BORDER_COLOURS : ["#999999", "#ebebeb", "#999999"],

    _create: function() {
        var that = this

        this.height = 0;
        this.timeslots = []

        this.mousedown = false
        this.dragXOffset = -1
        this.dragDirection = -1
        this.selected = null
        
        this.element.addClass("timeslot-editor");
        var canvas = $("<canvas></canvas>")
          .mousemove(function(event) { that._on_mousemove(that, event); })
          .mousedown(function(event) { that._on_mousedown(that, event); })
          .mouseup(function(event) { that._on_mouseup(that, event); })
          //.mouseover(function(event) { that._on_mouseover(that, event); })
          .dblclick(function(event) { that._on_doubleclick(that, event); })
          .attr("tabindex", "0")
          .keydown(function(event) { that._on_keyup(that, event); }) 
          .bind('selectstart', function(e) { e.preventDefault(); return false; })
          .appendTo(this.element);
        
        this.canvas = canvas.get(0);
        
         canvas.fillingCanvas({
            resized: function( event, data ) {
                that.setMinuteWidth(that.canvas.width / (24*60))
            }
          });
    },

    _draw: function() {
        var ctx = this.canvas.getContext('2d')
        ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        ctx.save();
        
        for (var i = 0; i < this.timeslots.length; i++) {
            if (i != this.selected) this._draw_timeslot(ctx, this.timeslots[i], false);
        }
        ctx.restore()
        
        ctx.save();
        if (this.selected != null) this._draw_timeslot(ctx, this.timeslots[this.selected], true);
        ctx.restore();
    },

    _on_keyup: function(that, event) {
        // Delete key
        if (event.keyCode == 46) this.removeTimeslot();
    }, 

    _on_mousemove: function(that, event) {
        this._fix_event(event);
        var i;
        var cursor = 'auto';
        var handle = -1;

        for (i = 0; i < that.timeslots.length; i++) {
            var handle = that._get_timeslot_resize_handle(that.timeslots[i], event.offsetX, event.offsetY);
            if (handle != -1) break;
        }

        if (!that.mousedown) {
            switch (handle) {
              case RIGHT: cursor='w-resize';  break;
              case LEFT: cursor='e-resize';  break;
            }
            that.element.css("cursor", cursor);
        } else {

            // Create new on drag
            if (this.selected == null) {
                return;
            };

            var minWidth = 20;
            
            if (that.dragAction == RESIZE) {
                if (that.dragDirection == RIGHT) {
                    if (this._get_x(that.timeslots[that.selected].start) + minWidth < event.offsetX)
                        that.timeslots[that.selected].end = this._get_time(event.offsetX);
                }
                if (that.dragDirection == LEFT) {
                    if (this._get_x(that.timeslots[that.selected].end) > event.offsetX + minWidth)
                        that.timeslots[that.selected].start = this._get_time(event.offsetX);
                }
            } else if (that.dragAction == MOVE) {
                that.timeslots[that.selected].moveMinutes((event.offsetX - this.dragXOffset) / this.minuteWidth);
            }
            that._draw();
        }


    },

    _on_mousedown: function(that, event) {
        this._fix_event(event);
        that.mousedown = true;

        for (i = 0; i < that.timeslots.length; i++) {
            var handle = that._get_timeslot_resize_handle(that.timeslots[i], event.offsetX, event.offsetY);
            if (handle != -1) {
                this.selected = i;
                this.dragDirection = handle;
                this.dragAction = RESIZE;
                return;
            };
        }

        // No handle selected, try to see if a Timeslot is selected
        for (i = 0; i < that.timeslots.length; i++) {
            if (that.timeslots[i].in(this._get_time(event.offsetX))) {
                this.selected = i;
                this.dragXOffset = event.offsetX - this._get_x(that.timeslots[i].start);
                this.dragAction = MOVE;
                return;
            }
        }
    },

    _on_mouseup: function(that, event) {
        this._fix_event(event);
        that.mousedown = false;
        this.dragXOffset = -1;

        that.dragDirection = -1;
        that.dragAction = -1;

        var withinTimeslot = false;
        for (var i = 0; i < this.timeslots.length; i++) {
            if (this.timeslots[i].in(this._get_time(event.offsetX))) 
                withinTimeslot = true;
        }
        if (!withinTimeslot) that.selected = null;

        that._draw();
    },

    _on_doubleclick: function(that, event) {
        this._fix_event(event);
        this.addTimeslot(event.offsetX - 100/2);
    },

    _draw_timeslot : function(ctx, timeslot, selected) {
        var x1 = this._get_x(timeslot.start);
        var x2 = this._get_x(timeslot.end);
        
        var y1 = 0;
        var y2 = this.canvas.height;
        
        var i;
        for (i = 0; i < 3; i++) {
            ctx.fillStyle = this.BORDER_COLOURS[i];
            ctx.fillRect(x1 + i, y1 + i, x2 - x1 - i * 2, y2 - y1 - i * 2);
        }

        ctx.save();
        ctx.fillStyle = 'white';
        ctx.globalCompositeOperation = 'destination-out';
        ctx.fillRect(x1 + i, y1 + i, x2 - x1 - i * 2, y2 - y1 - i * 2);
        ctx.restore();
    }, 
    
    _get_x : function(time) {
        return this.startTime.diff(time, 'minutes') * this.minuteWidth;
    },
    
    _get_time : function(x) {
        var minutes = Math.floor(x / this.minuteWidth);
        return this.startTime.clone().add(minutes, 'minutes');
    },

    _get_timeslot_resize_handle : function(timeslot, x, y) {
        var tolerance = 20;
        
        var x1 = this._get_x(timeslot.start);
        var x2 = this._get_x(timeslot.end);
        
        if (isNear(x, y, x1, tolerance, LEFT)) return LEFT;
        if (isNear(x, y, x2, tolerance, RIGHT)) return RIGHT;
        return -1;
    },
    

    gettimeslots: function() {
        return this.timeslots;
    },

    addTimeslot: function(x) {
        var default_size = 100;
        x = x || Math.floor((this.width - default_size)/2);
        
        this.selected = this.timeslots.push(new Timeslot(this._get_time(x), this._get_time(x+default_size))) - 1;
        this._draw();
    },

    removeTimeslot: function() {
        if (this.selected != null) {
            this.timeslots.splice(this.selected, 1);
            this.selected = null;
            this._draw();
        }
    },

    showRegions: function() {
        this.show_regions = true;
        this._draw();
    },

    hideRegions: function() {
        this.show_regions = false;
        this._draw();
    },
    
    setMinuteWidth : function(width) {
        this.minuteWidth = width;
        this._draw();
    },    
    
    setStartTime : function(time) {
        this.startTime = time;
    },

    _fix_event: function(event) {
        // For firefox from http://stackoverflow.com/questions/22716333/firefox-javascript-mousemove-not-the-same-as-jquery-mousemove
        if(typeof event.offsetX === "undefined" || typeof event.offsetY === "undefined") {
           var targetOffset = $(event.target).offset();
           event.offsetX = event.pageX - targetOffset.left;
           event.offsetY = event.pageY - targetOffset.top;
        }
    }

});
