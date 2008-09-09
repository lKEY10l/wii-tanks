function enemy2_Create() {
	// Speed of vehicle!
	this.speedVehicle = 3;
	// Maximum hits per bullet.
	this.bulletMaxHits = 2;
	// Number of bullets on the board at once.
	this.fireCount = 1;
	// Is the tank is firing or dropping bombs?
	this.isFiring = 0;
	this.isMining = 0;
	this.isTread = 0;
	// Is the tank destroyed?
	this.isDestroyed = 0;
	this.disabled = 0;
	this.currentRotation = 0;
};

function enemy2_RotateTurret() {
	this.turret._rotation = _root.toDegrees(Math.atan2(_root.tank_container["player"]._y - this._y, _root.tank_container["player"]._x - this._x));
};

function enemy2_MoveTank() {
	if (this.disabled == 0) {
		var Target:Array = node_PathFind(this._x, this._y, _root.tank_container["player"]._x, _root.tank_container["player"]._y);
	
		this.base._rotation = this.currentRotation % 360;
		this.targetRotation = _root.calcAngle(Target[0], this._x, Target[1], this._y);
	//	trace(this.targetRotation);
		if (Math.abs(this.targetRotation - this.currentRotation) > 180) {
			if (this.currentRotation > 0)
				this.targetRotation = 360 + this.targetRotation;
			else
				this.targetRotation = this.targetRotation + 360;
		}
		
		// Calculate time to rotate (adjust the last number for speed, lower=faster)
		this.rotateTime = Math.abs(this.targetRotation - this.currentRotation)/5;
		this.currentRotation += (this.targetRotation - this.currentRotation)/10;
		this.base._rotation = this.currentRotation % 360;
	//	this.rotate.continueTo(this.targetRotation, this.rotateTime);
	
		this.oldX = this.speedVehicle * Math.sin(_root.toRadians(this.base._rotation));
		this.oldY = this.speedVehicle * Math.cos(_root.toRadians(this.base._rotation));
		this.stepX = this._x + (this.oldX / ((this.rotateTime / 10) + 1));
		this.stepY = this._y - (this.oldY / ((this.rotateTime / 10) + 1));
	
		this._x = this.stepX;
		this._y = this.stepY;
		
		// Update current location.
		_root.objMap.movObject(this.idNumber, 1, this._x, this._y);
		
		/** 
		 * Draw the treads behind the tank!
		 */
		if (this.isTread == 0) {
			_root.addTread(this._x, this._y, this.base._rotation);
			this.isTread = 2;// originally 5
			this.tread_sound_delay ++;
				if (this.tread_sound_delay == 2) {
					_root.treads.start(0,0);
					this.tread_sound_delay = 0; //reset back to 0
			}
		} else
			this.isTread --;
	} else {
		this.disabled--;
	}
};

function enemy2_CheckDeath() {
	if (this.isDestroyed == 1){
		// Attach an explosion.
		_root.addTankExplosion(this._x, this._y);
			
		// Attach a death mark
		_root.addDeathMark(this._x, this._y);
		
		// Set the score
		_root.score++;
		
		// Remove the map reference.
		_root.objMap.delObject(this.idNumber, 1);
		
		// Remove self
		this.removeMovieClip();
	}
};

function enemy2_FireBullet() {
	var x:Number;
	var y:Number;
	var newX:Number;
	var newY:Number;
	var rot1:Number;
	var rot2:Number;
	var listWalls:Array;
	
	// If we are in the line of sight, fire.
	rot1 = Math.floor(_root.toDegrees(Math.atan2(_root.tank_container.player._y - this._y, _root.tank_container.player._x - this._x)));
	rot2 = Math.floor(this.turret._rotation);
	if (_root.isBetween(rot1 - 2, rot1 + 2, rot2) == true) {
		// Check distance to player
		var dist:Number = _root.calcDistance(_root.tank_container.player._x, this._x, _root.tank_container.player._y, this._y);
		var distX:Number = (_root.tank_container.player._x - this._x) / Math.floor(dist / 30);
		var distY:Number = (_root.tank_container.player._y - this._y) / Math.floor(dist / 30);
		var goFire:Boolean = true;
		
		// Check if there are walls in our way
		for (y = 0; y < Math.floor(dist / 30); y ++) {
			newX = this._x + (distX * (y+1));
			newY = this._y + (distY * (y+1));
			listWalls = _root.objMap.getAt(newX, newY, 0);
			for (x = 0; x < listWalls.length; x++) {
				if (_root.wall_container["wall" + listWalls[x]]._currentframe != 4) { // Ignore holes
					if (_root.wall_container["wall" + listWalls[x]].hidden.hitTest(newX, newY, false) == true) {
						goFire = false;
					}
				}
			}
		}
			
		if ((goFire == true) && (this.fireCount != 0)) {
			// Calculate the start points
			newX = this._x + Math.cos(_root.toRadians(this.turret._rotation)) * 30;
			newY = this._y + Math.sin(_root.toRadians(this.turret._rotation)) * 30;
			
			listWalls = _root.objMap.getOthers(-1, 1, 0, 1);
			// Check if we are firing in any walls!!!  BAD AI!!
			for (x = 0; x < listWalls.length; x++) {
				if (_root.wall_container["wall" + listWalls[x]].hidden.hitTest(newX, newY, false) == true) {
					return;
				}
			}
			
			// Create the bullet.
			_root.addBullet(newX, newY, this.turret._rotation, this.bulletMaxHits, this.idNumber);
			
			// Show the muzzle flash
			_root.addMuzzleFlash(newX, newY);
			
			// Set the firing delay (between shots)
			this.isFiring = 0;
			// Fire off our ammo
			if (this.fireCount != 0)
				this.fireCount--;
		}
	}
};