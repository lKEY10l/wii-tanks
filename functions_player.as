function player_Create() {
	this.bulletMaxHits = 2;
	this.speedVehicle = 3;
	this.disabled = 0;
	this.fireCount = 5;
	this.mineCount = 2;
	this.isFiring = 0;
	this.isMining = 0;
	this.isTread = 0;
	this.isDestroyed = 0;
	this.tread_sound_delay = 0;
};

function player_RotateTurret() {
	if (_root.gameOver != 1) 
		this.turret._rotation = _root.toDegrees(Math.atan2(_root._ymouse - this._y, _root._xmouse - this._x));
};

function player_MoveTank() {
	// Adjust current rotation to match the messed up one.
	this.base._rotation = this.currentRotation % 360;
	
	// See if we are not "buzzed" for a sec
	if (this.disabled == 0) {
		this.targetRotation = 200;

		// If they are holding both up and down, ignore it.
		if (!(_root.keys.isUp && _root.keys.isDown) && !(_root.keys.isLeft && _root.keys.isRight)) {
			if (_root.keys.isUp) {
				if (_root.keys.isLeft)
					this.targetRotation = -45 + (Math.floor(this.currentRotation / 360) * 360);
				else if (_root.keys.isRight)
					this.targetRotation = 45 + (Math.floor(this.currentRotation / 360) * 360);
				else
					this.targetRotation = 0 + (Math.floor(this.currentRotation / 360) * 360);
			} else if (_root.keys.isDown) {
				if (_root.keys.isLeft)
					this.targetRotation = -135 + (Math.floor(this.currentRotation / 360) * 360);
				else if (_root.keys.isRight)
					this.targetRotation = 135 + (Math.floor(this.currentRotation / 360) * 360);
				else
					this.targetRotation = 180 + (Math.floor(this.currentRotation / 360) * 360);
			} else if (_root.keys.isLeft) {
				this.targetRotation = -90 + (Math.floor(this.currentRotation / 360) * 360);
			} else if (_root.keys.isRight) {
				this.targetRotation = 90 + (Math.floor(this.currentRotation / 360) * 360);
			}
		}

		// Check if a key was pressed
		if (this.targetRotation != 200) {
			// Check for reverse!!
			if (Math.abs(this.targetRotation - this.currentRotation) > 150 &&
					Math.abs(this.targetRotation - this.currentRotation) < 210) {
				this.dir = -1;
				this.rotateTime = 0; // 4 increase to decrease reverse speed
			} else {
				this.dir = 1;
				// Adjust for weird rotation
				if (Math.abs(this.targetRotation - this.currentRotation) > 180) {
					if (this.currentRotation > 0)
						this.targetRotation = 360 + this.targetRotation;
					else
						this.targetRotation = this.targetRotation + 360;
				}
				
				// Calculate time to rotate (adjust the last number for speed, lower=faster)
				this.rotateTime = Math.abs(this.targetRotation - this.currentRotation)/5;
				this.rotate.continueTo(this.targetRotation, this.rotateTime);
			}
			this.oldX = (this.speedVehicle * this.dir) * Math.sin(_root.toRadians(this.base._rotation));
			this.oldY = (this.speedVehicle * this.dir) * Math.cos(_root.toRadians(this.base._rotation));
			this.stepX = this._x + (this.oldX / ((this.rotateTime / 10) + 1));
			this.stepY = this._y - (this.oldY / ((this.rotateTime / 10) + 1));
	
			this._x = this.stepX;
			this._y = this.stepY;
			
			// Update current location.
			_root.objMap.movObject(-1, 1, this._x, this._y);
			
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
			this.rotate.stop();
		}
	} else {
		this.disabled--;
	}
};

function player_CheckDeath() {
	if (this.isDestroyed == 1){
		// Attach an explosion.
		_root.addTankExplosion(this._x, this._y);
			
		// Attach a death mark
		_root.addDeathMark(this._x, this._y);
		
		// Set gameover
		_root.pauseGame();
		_root.gameOver = 1;
		
		// Remove the map reference.
		_root.objMap.delObject(-1, 1);
		
		// Remove self
		this.removeMovieClip();
	}
};

function player_FireBullet() {
	var newX:Number;
	var newY:Number;
	var listWalls:Array;
	
	if (_root.keys.isMouse && this.isFiring == 0) {
		if (this.fireCount != 0) {
			// Calculate the start points
			newX = this._x + Math.cos(_root.toRadians(this.turret._rotation)) * 30;
			newY = this._y + Math.sin(_root.toRadians(this.turret._rotation)) * 30;
			
			listWalls = _root.objMap.getOthers(-1, 1, 0, 1);
			// Check if we are firing in any walls!!!  BAD PLAYERS!
			for (x = 0; x < listWalls.length; x++) {
				if (_root.wall_container["wall" + listWalls[x]].hidden.hitTest(newX, newY, false) == true) {
					return;
				}
			}
			
			// Create the bullet.
			_root.addBullet(newX, newY, this.turret._rotation, this.bulletMaxHits, -1);
			
			// Show the muzzle flash
			_root.addMuzzleFlash(newX, newY);
			
			// Set the firing delay (between shots)
			this.isFiring = 3;
			// Fire off our ammo
			if (this.fireCount != 0)
				this.fireCount--;
		}
	}
	if (!_root.keys.isMouse) {
		if (this.isFiring != 0)
			this.isFiring --;
	}
};

function player_FireMine() {
	if (_root.keys.isSpace && this.isMining == 0) {
		if (this.mineCount != 0) {
			// Check if we are dropping mines on other mines.
			listMines = _root.objMap.getOthers(-1, 1, 3, 1);
			for (x = 0; x < listMines.length; x++) {
				if (_root.bomb_container["bomb" + listMines[x]].base.hitTest(this.base) == true)
					return;
			}
			
			// Add the bomb
			_root.addBomb(this._x, this._y, -1);
			// Play Sound
			_root.mine_drop.start(0,0);
			
			// Set the firing delay (between shots)
			this.isMining = 3;
			// Fire off our ammo
			if (this.mineCount != 0)
				this.mineCount--;
		}
	}
	if (!_root.keys.isSpace) {
		if (this.isMining != 0)
			this.isMining --;
	}
};
