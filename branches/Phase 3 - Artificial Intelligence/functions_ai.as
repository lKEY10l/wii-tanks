this.nodes = Array();
this.nodeCount = 0;
this.DEBUG = false;

function node_Add(x:Number, y:Number, type:Number, w:Number, h:Number) {
	var xOff:Number = 0;
	var yOff:Number = 0;
	
	if (type == 2 || type == 5 || type == 8)
		xOff += (w/2) - 1;
	else if (type == 0 || type == 3 || type == 6)
		xOff -= (w/2) + 1;
	
	if (type == 6 || type == 7 || type == 8)
		yOff += (h/2) - 1;
	else if (type == 0 || type == 1 || type == 2)
		yOff -= (h/2) + 1;
	trace(xOff + " " + yOff);
	this.nodes[this.nodeCount] = new Object();
	this.nodes[this.nodeCount]._x = x + xOff;
	this.nodes[this.nodeCount]._y = y + yOff;
	this.nodes[this.nodeCount].neighbors = Array();
	
	if (this.DEBUG == true) {
		_root.cursor_container.attachMovie("node", "node" + this.nodeCount, _root.cursor_container.getNextHighestDepth());
		_root.cursor_container["node" + this.nodeCount]._x = x + xOff;
		_root.cursor_container["node" + this.nodeCount]._y = y + yOff;
		_root.cursor_container["node" + this.nodeCount].name = this.nodeCount;
	}
	
	this.nodeCount ++;
};

function node_Clear() {
	this.nodes = Array();
	this.nodeCount = 0;
}

function node_Calculate() {
	var x:Number;
	var y:Number;
	var z:Number;
	var a:Number;
	var loopAgain:Boolean;

	// Populate the node data.
	for (x = 0; x < this.nodeCount; x++) {
		for (y = x + 1; y < this.nodeCount; y++) {
			if (this.node_LineOfSight(this.nodes[x]._x, this.nodes[x]._y, this.nodes[y]._x, this.nodes[y]._y) == true) {
				this.nodes[x].neighbors[this.nodes[x].neighbors.length] = y;
				this.nodes[y].neighbors[this.nodes[y].neighbors.length] = x;
				if (this.DEBUG == true) {
					_root.tank_container.lineStyle(5,0x000000,10);
					_root.tank_container.moveTo(this.nodes[x]._x, this.nodes[x]._y);
					_root.tank_container.lineTo(this.nodes[y]._x, this.nodes[y]._y);
				}
			}
		}
		
		this.nodes[x].table = Array(this.nodeCount);
		for (y = 0; y < this.nodeCount; y++) {
			this.nodes[x].table[y] = Array(this.nodeCount);
		}
	
		this.nodes[x].lowest = Array(this.nodeCount);
		this.nodes[x].fastest = Array(this.nodeCount);
	}

	// Calculate the direct neighbor information (t = 0)
	for (x = 0; x < this.nodeCount; x++) {
		for (y = 0; y < this.nodes[x].neighbors.length; y++) {
			z = this.nodes[x].neighbors[y];
			// Note: this process is done twice, we may want to optimize this in the future.
			this.nodes[x].table[z][z] = Math.floor(_root.calcDistance(this.nodes[x]._x, this.nodes[z]._x, this.nodes[x]._y, this.nodes[z]._y));
			this.nodes[x].lowest[z] = this.nodes[x].table[z][z];
			this.nodes[x].fastest[z] = z;
		}
	}

	do {
		loopAgain = false;
		for (x = 0; x < this.nodeCount; x++) {
			for (y = 0; y < this.nodes[x].neighbors.length; y++) {
				z = this.nodes[x].neighbors[y];
				for (a = 0; a < this.nodeCount; a++) {
					if (z != x && a != x && this.nodes[z].lowest[a] != undefined && this.nodes[x].lowest[z] != undefined) {
						this.nodes[x].table[z][a] = this.nodes[z].lowest[a] + this.nodes[x].lowest[z];
						this.nodes[x].table[a][z] = this.nodes[z].lowest[a] + this.nodes[x].lowest[z];
					}
				}
			}
			for (y = 0; y < this.nodeCount; y++) {
				for (z = 0; z < this.nodeCount; z++) {
					if (this.nodes[x].table[z][y] < this.nodes[x].lowest[y] || (this.nodes[x].lowest[y] == undefined && this.nodes[x].table[z][y] != undefined)) {
						loopAgain = true;
						this.nodes[x].lowest[y] = this.nodes[x].table[z][y];
						this.nodes[x].fastest[y] = z;
					}
				}
			}
		}
	} while (loopAgain == true);
	
	for (x=0;x<this.nodeCount;x++) {
		this.node_Print(x);
	}
};

function node_LineOfSight(srcX:Number, srcY:Number, dstX:Number, dstY:Number):Boolean {
	var acc:Number = 15;
	var x:Number;
	var y:Number;
	var newX:Number;
	var newY:Number;
	var dist:Number = _root.calcDistance(srcX, dstX, srcY, dstY);
	var distX:Number = (srcX - dstX) / Math.floor(dist / acc);
	var distY:Number = (srcY - dstY) / Math.floor(dist / acc);
	var angle:Number = _root.calcAngle(srcX, dstX, srcY, dstY);
	var offX:Number = Math.sin(_root.toRadians(angle)) * 15;
	var offY:Number = Math.cos(_root.toRadians(angle)) * 15;
	
	// Check if there are walls in our way
	for (y = 0; y < Math.floor(dist / acc); y ++) {
		newX = dstX + (distX * (y+1));
		newY = dstY + (distY * (y+1));

		listWalls = _root.objMap.getAt(newX + offX, newY + offY, 0);
		for (x = 0; x < listWalls.length; x++) {
			if (_root.wall_container["wall" + listWalls[x]].hidden.hitTest(newX + offX, newY + offY, true) == true) {
				return false;
			}
		}
		
		listWalls = _root.objMap.getAt(newX - offX, newY - offY, 0);
		for (x = 0; x < listWalls.length; x++) {
			if (_root.wall_container["wall" + listWalls[x]].hidden.hitTest(newX - offX, newY - offY, true) == true) {
				return false;
			}
		}
	}
	
	return true;
};

function node_PathFind(srcX:Number, srcY:Number, dstX:Number, dstY:Number):Array {
	var x:Number;
	var y:Number;
	var srcDist:Number = undefined;
	var srcNode:Number;
	var dstDist:Number = undefined;
	var dstNode:Number;
	
	for (x = 0; x < this.nodeCount; x++) {
		if (this.node_LineOfSight(dstX, dstY, this.nodes[x]._x, this.nodes[x]._y) == true) {
			y = _root.calcDistance(dstX, this.nodes[x]._x, dstY, this.nodes[x]._y);
//			trace(x + " " + y + "  " + dstX + "," + dstY + " - " + this.nodes[x]._x + "," + this.nodes[x]._y);
			if (dstDist == undefined || y < dstDist) {
//				trace(x + ", " + y);
				dstDist = y;
				dstNode = x;
			}
		}
	}
	
	for (x = 0; x < this.nodeCount; x++) {
		if (this.node_LineOfSight(srcX, srcY, this.nodes[x]._x, this.nodes[x]._y) == true) {
			y = _root.calcDistance(srcX, this.nodes[x]._x, srcY, this.nodes[x]._y);
			if (x == dstNode || (this.nodes[x].lowest[dstNode] != undefined && (srcDist == undefined || this.nodes[x].lowest[dstNode] + y < srcDist))) {
				srcDist = y + (x == dstNode?0:this.nodes[x].lowest[dstNode]);
				srcNode = x;
			}
		}
	}
	
	y = this.nodes[srcNode].fastest[dstNode];
	trace(srcNode + " " + dstNode + " " + y);
	if ((this.node_LineOfSight(srcX, srcY, dstX, dstY) == true) || (y == undefined)) {
		return Array(dstX, dstY);
	} else if (this.node_LineOfSight(srcX, srcY, this.nodes[y]._x, this.nodes[y]._y) == true || _root.calcDistance(srcX, this.nodes[srcNode]._x, srcY, this.nodes[srcNode]._y) < 5) {
		srcNode = y;
	}

	//trace (srcNode + " " + srcDist + " " + dstNode + " " + dstDist);
	return Array(this.nodes[srcNode]._x, this.nodes[srcNode]._y);
};

function node_Print(z) {
	for (x = 0; x < this.nodeCount; x++) {
		temp = "[";
		for (y = 0; y < this.nodeCount; y++) {
			temp += "\t" + this.nodes[z].table[x][y];
		}
		temp += "\t]";
//		trace(temp);
	}
	
	temp = z + ":[";
	for (y = 0; y < this.nodeCount; y++) {
		temp += "\t" + this.nodes[z].fastest[y];
	}
	temp += "\t]";
	trace(temp);
};