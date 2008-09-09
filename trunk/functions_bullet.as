function bullet_Create() {
	this.hitCount = 0;
	this.smokeTimer = 0;
	this.speedBullet = 5;
};

function bullet_Move() {
	newX = this.speedBullet * Math.sin(_root.toRadians(this._rotation + 90));
	newY = this.speedBullet * Math.cos(_root.toRadians(this._rotation + 90));
	this._x += newX;
	this._y -= newY;
	
	// Update map!
	_root.objMap.movObject(this.idNumber, 2, this._x, this._y);
	
	if (this.smokeTimer == 0) {
		_root.addBulletSmoke(this._x, this._y);
		this.smokeTimer = 1;
	} else
		this.smokeTimer --;
};

function bullet_CheckDeath() {
	if (this.hitCount >= this.hitMax) {
		if (this.tankOwner == -1)
			_root.tank_container.player.fireCount++;
		else
			_root.tank_container["tank" + this.tankOwner].fireCount++;
			
		// Add an explosion.
		_root.addBulletExplosion(this._x, this._y);

		// Remove the map reference.
		_root.objMap.delObject(this.idNumber, 2);
		
		// Remove the movie clip.
		this.removeMovieClip();
	}
};

function bullet_CheckBullet(idA:Number, idB:Number) {
	var bulletA:Object = _root.bullet_container["bullet" + idA];
	var bulletB:Object = _root.bullet_container["bullet" + idB];
	
	if (bulletA.hitTest(bulletB) == true) {
		bulletA.hitCount = bulletA.hitMax;
		//play only one sound
		_root.bullet_explosion.start(0,0);
		bulletB.hitCount = bulletB.hitMax;
	}
};

function bullet_CheckWall(idA:Number, idB:Number) {
	var bullet:Object = _root.bullet_container["bullet" + idA];
	var wall:Object = _root.wall_container["wall" + idB];
	var hitTop:Number;
	var hitSide:Number;
	var hitAngle:Number;
	var oldRotation:Number;
	var newRotation:Number;

	if (wall._currentframe != 4) { // Check for holes
		if (wall.base.hitTest(bullet._x, bullet._y, false) == true) {
			hitTop = _root.toDegrees(Math.atan((0.5 * wall.base._width) / (0.5 * wall.base._height)));
			hitSide = _root.toDegrees(Math.atan((0.5 * wall.base._height) / (0.5 * wall.base._width)));
			hitAngle = Math.abs(_root.toDegrees(Math.atan((bullet._x - wall._x) / (wall._y - bullet._y))));

			if ((bullet._x > wall._x) && 
					(bullet._y > wall._y))
				hitAngle = (90 - hitAngle) + 90;
			else if ((bullet._x < wall._x) &&
							 (bullet._y > wall._y))
				hitAngle += 180;
			else if ((bullet._x < wall._x) &&
							 (bullet._y < wall._y))
				hitAngle = (90 - hitAngle) + 270;

			if (hitAngle > 180)
				hitAngle = -1 * (360 - hitAngle);
			oldRotation = bullet._rotation;

			if (_root.isBetween(hitTop * -1, hitTop, hitAngle)) {
				// Hits the Top
				if (bullet._rotation > 0)
					newRotation = bullet._rotation * -1;
			} else if (_root.isBetween(90 - hitSide, 90 + hitSide, hitAngle)) {
				// Hits the Right
				if (bullet._rotation < -90 || bullet._rotation > 90)
					newRotation = 90 - (bullet._rotation - 90);
			} else if (_root.isBetween(180 - hitTop, 180, hitAngle) || _root.isBetween(-180, -180 + hitTop, hitAngle)) {
				// Hits the Bottom
				if (bullet._rotation < 0)
					newRotation = bullet._rotation * -1;
			} else if (_root.isBetween(-90 - hitSide, -90 + hitSide, hitAngle)) {
				// Hits the Left
				if (bullet._rotation > -90 || bullet._rotation < 90)
					newRotation = 90 - (bullet._rotation - 90);
			}
			
			if (newRotation != oldRotation) {
				bullet.hitCount ++;
				//play sound
				if (bullet.hitCount == 1) 
					_root.bullet_bounce.start(0,0);
			
				else if (bullet.hitCount ==2) 
					_root.bullet_explosion.start(0,0);
				
				if (bullet.hitCount < bullet.hitMax) {
					bullet._rotation = newRotation;
					this.bullet_Move.call(bullet);
					
				}
			}
		}
	}
};

function bullet_CheckBomb(idA:Number, idB:Number) {
	var bullet:Object = _root.bullet_container["bullet" + idA];
	var bomb:Object = _root.bomb_container["bomb" + idB];
	
	if (bullet.hitTest(bomb.base) == true) {
		bullet.hitCount = bullet.hitMax;
		bomb.explode = 1;
	}
};