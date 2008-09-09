var maxCursors:Number = 3;		// Number of floaty things between player and mouse.
var maxTrail:Number = 100;		// Maximum number of trails
var trailCount:Number = 0;		// Current trail counter

/**
 * This creates those little floating things near the cursor.
 */
for (x = 0; x < this.maxCursors; x++) {
	_root.cursor_container.attachMovie("cursor_floater","cursor_floater" + x, _root.cursor_container.getNextHighestDepth());
	_root.cursor_container["cursor_floater" + x]._x = 0;
	_root.cursor_container["cursor_floater" + x]._y = 0;
}

/**
 * Attach the custom cursor and place the floaty things.
 */
this.lockCursor = function() {
	// Attach the custom cursor
	_root.mouse._x = _root._xmouse;
	_root.mouse._y = _root._ymouse;
	
	// Only do this if not gameover
	if (_root.gameOver != 1) {
		// Place the floaty things
		var distX:Number = (_root._xmouse - _root.tank_container.player._x) / (this.maxCursors + 1);
		var distY:Number = (_root._ymouse - _root.tank_container.player._y) / (this.maxCursors + 1);
		for (x = 0; x < this.maxCursors; x++) {
			_root.cursor_container["cursor_floater" + x]._x = _root.tank_container.player._x + (distX * (x+1));
			_root.cursor_container["cursor_floater" + x]._y = _root.tank_container.player._y + (distY * (x+1));
		}
	} else {
		for (x = 0; x < this.maxCursors; x++) {
			_root.cursor_container["cursor_floater" + x]._x = -10;
			_root.cursor_container["cursor_floater" + x]._y = -10;
		}
	}
	
	// Add a trail.
	if (_root.cursor_container["trail" + this.trailCount] != undefined)
		_root.cursor_container["trail" + this.trailCount].removeMovieClip();
	_root.cursor_container.attachMovie("cursor_trail", "trail" + this.trailCount, _root.cursor_container.getNextHighestDepth());
	_root.cursor_container["trail" + this.trailCount]._x = _root._xmouse;
	_root.cursor_container["trail" + this.trailCount]._y = _root._ymouse;
	_root.cursor_container["trail" + this.trailCount].lineStyle(5, 0x00FFFF, 100);

	var old:Number = this.trailCount-1;
	if (old < 0)
		old = this.maxTrail;
	_root.cursor_container["trail" + old].lineTo(_root.cursor_container["trail" + old]._xmouse, _root.cursor_container["trail" + old]._ymouse);
	this.trailCount ++;
	if (this.trailCount > this.maxTrail)
		this.trailCount = 0;
}