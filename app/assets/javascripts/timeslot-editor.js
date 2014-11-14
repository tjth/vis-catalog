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

function Selection(x1, y1, x2, y2, maxX, maxY) {
  this.x1 = x1;
  this.y1 = y1;
  this.x2 = x2;
  this.y2 = y2;
  this.BORDER_COLOURS = ["#999999", "#ebebeb", "#999999"];

  this.maxX = maxX;
  this.maxY = maxY;
}

Selection.prototype.drawBorder = function(ctx, x1, y1, x2, y2) {
    var i;
    for (i = 0; i < 3; i++) {
        ctx.fillStyle = this.BORDER_COLOURS[i];
        ctx.fillRect(x1 + i, y1 + i,
                     x2 - x1 - i * 2, y2 - y1 - i * 2);
    }

    ctx.save();
    ctx.fillStyle = 'white';
    ctx.globalCompositeOperation = 'destination-out';
    ctx.fillRect(x1 + i, y1 + i,
                 x2 - x1 - i * 2, y2 - y1 - i * 2);
    ctx.restore();
}

Selection.prototype.drawOutline = function(ctx, draw_handles) {
  var squareSize = 8;

  this.drawBorder(ctx, this.x1, this.y1, this.x2, this.y2);
}

Selection.prototype.move = function(x) {
    width = this.x2 - this.x1;
    this.x1 = x; this.x2 = x + width;
}


Selection.prototype.containsPoint = function(x, y) {
    return (x >= this.x1 && x <= this.x2 &&
            y >= this.y1 && y<= this.y2);
}

Selection.prototype.drawArea = function(ctx) {
  ctx.fillRect(this.x1, this.y1, this.x2 - this.x1, this.y2 - this.y1);
}

Selection.prototype.getResizeHandle = function(x, y) {
    var tolerance = 20;
    if (isNear(x, y, this.x1, (this.y1 + this.y2)/2, tolerance, LEFT) && y < this.y2) return LEFT;
    if (isNear(x, y, this.x2, (this.y1 + this.y2)/2, tolerance, RIGHT) && y < this.y2) return RIGHT;
    return -1;
}



$.widget("widgets.timesloteditor", {

    options: {},

    selections : [],
    canvas : null,

    mousedown : false,
    dragXOffset : -1,
    dragYOffset : -1,
    dragDirection : -1,
    selected : null,
    show_regions : true,

    _create: function() {
        var that = this

        this.height = 0;

        this.element.addClass("timeslot-editor");
        this.canvas = $("<canvas></canvas>")
          .fillingCanvas()
          .mousemove(function(event) { that._on_mousemove(that, event); })
          .mousedown(function(event) { that._on_mousedown(that, event); })
          .mouseup(function(event) { that._on_mouseup(that, event); })
          .mouseover(function(event) { that._on_mouseover(that, event); })
          .dblclick(function(event) { that._on_doubleclick(that, event); })
          .attr("tabindex", "0")
          .keydown(function(event) { that._on_keyup(that, event); }) 
          .bind('selectstart', function(e) { e.preventDefault(); return false; })
          .appendTo(this.element).get(0);
        this._draw();
    },

    _draw: function() {
        var ctx = this.canvas.getContext('2d')
        ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        ctx.save();
        for (var i = 0; i < this.selections.length; i++) {
            if (i != this.selected) this.selections[i].drawOutline(ctx, false);
        }
        ctx.restore()
        
        ctx.save();
        if (this.selected != null) this.selections[this.selected].drawOutline(ctx, true);
        ctx.restore();
    },

    _on_keyup: function(that, event) {
        // Delete key
        if (event.keyCode == 46) this.removeSelection();
    }, 

    _on_mousemove: function(that, event) {
        this._fix_event(event);
        var i;
        var cursor = 'auto';
        var handle = -1;

        for (i = 0; i < that.selections.length; i++) {
            var handle = that.selections[i].getResizeHandle(event.offsetX, event.offsetY);
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

            if (that.dragAction == RESIZE) {
                if (that.dragDirection == RIGHT) {
                    that.selections[that.selected].x2 = event.offsetX;
                }
                if (that.dragDirection == LEFT) {
                    that.selections[that.selected].x1 = event.offsetX;
                }
            } else if (that.dragAction == MOVE) {
                that.selections[that.selected].move(event.offsetX - this.dragXOffset);
            }
            that._draw();
        }


    },

    _on_mousedown: function(that, event) {
        this._fix_event(event);
        that.mousedown = true;

        for (i = 0; i < that.selections.length; i++) {
            var handle = that.selections[i].getResizeHandle(event.offsetX, event.offsetY);
            if (handle != -1) {
                this.selected = i;
                this.dragDirection = handle;
                this.dragAction = RESIZE;
                return;
            };
        }

        // No handle selected, try to see if a selection is selected
        for (i = 0; i < that.selections.length; i++) {
            if (that.selections[i].containsPoint(event.offsetX, event.offsetY)) {
                this.selected = i;
                this.dragXOffset = event.offsetX - that.selections[i].x1,
                this.dragYOffset = event.offsetY - that.selections[i].y1,
                this.dragAction = MOVE;
                return;
            }
        }
    },

    _on_mouseup: function(that, event) {
        this._fix_event(event);
        that.mousedown = false;
        this.dragXOffset = this.dragYOffset = -1;

        that.dragDirection = -1;
        that.dragAction = -1;

        var withinSelection = false;
        for (var i = 0; i < this.selections.length; i++) {
            if (this.selections[i].containsPoint(event.offsetX, event.offsetY)) 
                withinSelection = true;
        }
        if (!withinSelection) that.selected = null;

        that._draw();
    },

    _on_doubleclick: function(that, event) {
        this._fix_event(event);
        console.log("yeah")
        this.addSelection(event.offsetX - 100/2, event.offsetY - 100/2);
    },

    getSelections: function() {
        return this.selections;
    },

    addSelection: function(x) {
        var default_size = 100;
        x = x || Math.floor((
            this.width - default_size)/2);
        
        console.log(this.canvas.height)
        
        this.selected = this.selections.push(
            new Selection(x, 0, x+default_size, this.canvas.height)) - 1;
        this._draw();
    },

    removeSelection: function() {
        if (this.selected != null) {
            this.selections.splice(this.selected, 1);
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

    _fix_event: function(event) {
        // For firefox from http://stackoverflow.com/questions/22716333/firefox-javascript-mousemove-not-the-same-as-jquery-mousemove
        if(typeof event.offsetX === "undefined" || 
           typeof event.offsetY === "undefined") {
           var targetOffset = $(event.target).offset();
           event.offsetX = event.pageX - targetOffset.left;
           event.offsetY = event.pageY - targetOffset.top;
        }
    }

});
