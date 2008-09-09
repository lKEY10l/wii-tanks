class ObjectMap {
	/**
	 * mapArray contains:
	 *  [t] = each type
	 *  [t][x] = each column (x) on the grid
	 *  [t][x][y] = each cell (x,y) on the grid
	 *  [t][x][y][z] = an item at grid (x,y)
	 *
	 * nameArray contains:
	 *  [0] = name
	 *  [1] = type
	 *  [2] = x pos in mapArray
	 *  [3] = y pos in mapArray
	 *  [4] = z pos in mapArray
	 */
	private var mapArray:Array;
	private var nameArray:Array;
	private var xSize:Number;
	private var ySize:Number;
	private var rowCount:Number;
	private var colCount:Number;
	private var typCount:Number;
	
	/**
	 * Creates the object and initializes the arrays.
	 * xPixels and yPixels stand for the width and height of a grid cell.
	 */
	public function ObjectMap(rows:Number, cols:Number, types:Number, xPixels:Number, yPixels:Number) {
		this.xSize = xPixels;
		this.ySize = yPixels;
		this.rowCount = rows;
		this.colCount = cols;
		this.typCount = types;
		
		this.clearAll();
	}

	/**
	 * Adds an object to a specific grid cell.
	 */
	public function addObject(name:Number, type:Number, xLoc:Number, yLoc:Number):Void {
		var x:Number = Math.floor(xLoc / this.xSize);
		var y:Number = Math.floor(yLoc / this.ySize);
		var z:Number = this.mapArray[type][x][y].length;
		
		this.nameArray[type][this.nameArray[type].length] = new Array(name, x, y, z);
		this.mapArray[type][x][y][z] = name;
	}
	
	/**
	 * Removes an object from a grid cell.
	 */
	public function delObject(name:Number, type:Number):Void {
		var n:Number = this.findName(name, type);

		this.mapArray[type][this.nameArray[type][n][1]][this.nameArray[type][n][2]].splice(this.nameArray[type][n][3], 1);
		this.nameArray[type].splice(n,1);
	}
	
	/**
	 * Moves an object to a new grid cell.
	 */
	public function movObject(name:Number, type:Number, xLoc:Number, yLoc:Number):Void {
		var x:Number = Math.floor(xLoc / this.xSize);
		var y:Number = Math.floor(yLoc / this.ySize);
		var z:Number;
		var n:Number = this.findName(name, type);
		
		this.mapArray[type][this.nameArray[type][n][1]][this.nameArray[type][n][2]].splice(this.nameArray[type][n][3], 1);
		z = this.mapArray[type][x][y].length;
		this.mapArray[type][x][y][z] = name;
		this.nameArray[type][n][1] = x;
		this.nameArray[type][n][2] = y;
		this.nameArray[type][n][3] = z;
	}
	
	/**
	 * Gets the adjacent objects of a specific type around a current object.
	 * See picture below, gets names of all items in the 9 cells around 
	 *  (including the current cell).
	 * [ ][ ][ ]
	 * [ ][x][ ]
	 * [ ][ ][ ]
	 */
	public function getOthers(name:Number, type:Number, target:Number, size:Number):Array {
		var x:Number;
		var y:Number;
		var z:Number;
		var n:Number = this.findName(name, type);
		var currX:Number = this.nameArray[type][n][1];
		var currY:Number = this.nameArray[type][n][2];
		var names:Array = new Array();
	
		for (x = currX - size; x <= currX + size; x++) {
			if (x >= 0 && x < this.colCount) {
				for (y = currY - size; y <= currY + size; y++) {
					if (y >= 0 && y < this.rowCount) {
						for (z = 0; z < this.mapArray[target][x][y].length; z++) {
							if (!(type == target && this.mapArray[target][x][y][z] == name)) {
								names[names.length] = this.mapArray[target][x][y][z];
							}
						}
					}
				}
			}
		}
		
		return names;
	}
	
	/**
	 * Gets a list of all the items of a certain type.
	 */
	public function getList(type:Number):Array {
		var x:Number;
		var names:Array = new Array();

		for (x = 0; x < this.nameArray[type].length; x++) {
			names[x] = this.nameArray[type][x][0];
		}

		return names;
	}
	
	/**
	 * Gets a list of all the objects at a certain point and a certain type.
	 */
	public function getAt(xLoc:Number, yLoc:Number, type:Number):Array {
		var x:Number = Math.floor(xLoc / this.xSize);
		var y:Number = Math.floor(yLoc / this.ySize);
		var z:Number;
		var names:Array = new Array();

		for (z = 0; z < this.mapArray[type][x][y].length; z++) {
			names[z] = this.mapArray[type][x][y][z];
		}

		return names;
	}

	/**
	 * Clears the board.
	 */
	public function clearAll():Void {
		var x:Number;
		var y:Number;
		var t:Number;

		this.nameArray = new Array(this.typCount);
		this.mapArray = new Array(this.typCount);

		for (t = 0; t < this.typCount; t++) {
			this.nameArray[t] = new Array();
			this.mapArray[t] = new Array(this.colCount);
			for (x = 0; x < this.colCount; x++) {
				this.mapArray[t][x] = new Array(this.rowCount);
				for (y = 0; y < this.rowCount; y++) {
					this.mapArray[t][x][y] = new Array();
				}
			}
		}
	}
	
	/**
	 * Private function to find the index of a 
	 * specific item in the nameArray.
	 */
	private function findName(name:Number, type:Number):Number {
		var x:Number;
		
		for (x = 0; x < this.nameArray[type].length; x++) {
			if (this.nameArray[type][x][0] == name) {
				return x;
			}
		}
		
		trace("help?");
	}
}