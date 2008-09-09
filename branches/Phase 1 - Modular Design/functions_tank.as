function tank_CheckTank(idA:Number, idB:Number) {
	var tankA:Object = _root.tank_container[(idA != -1?"tank" + idA:"player")];
	var tankB:Object = _root.tank_container[(idB != -1?"tank" + idB:"player")];
	var bounce:Number = 3; // Bounce distance.
	var hitAngle:Number;
	var slopeX:Number;
	var slopeY:Number;

	// Make sure they both hit eachother!
	if (((tankA.base.a.hitTest(tankB.base) == true) || (tankA.base.b.hitTest(tankB.base) == true) ||
			(tankA.base.c.hitTest(tankB.base) == true) ||	(tankA.base.d.hitTest(tankB.base) == true) ||
			(tankA.base.e.hitTest(tankB.base) == true) ||	(tankA.base.f.hitTest(tankB.base) == true) ||
			(tankA.base.g.hitTest(tankB.base) == true)) && ((tankB.base.a.hitTest(tankA.base) == true) ||	
			(tankB.base.b.hitTest(tankA.base) == true) || (tankB.base.c.hitTest(tankA.base) == true) ||	
			(tankB.base.d.hitTest(tankA.base) == true) || (tankB.base.e.hitTest(tankA.base) == true) ||	
			(tankB.base.f.hitTest(tankA.base) == true) || (tankB.base.g.hitTest(tankA.base) == true))) {

		// Calculate the hit angle.
		hitAngle = Math.abs(_root.toDegrees(Math.atan((tankA._x - tankB._x) / (tankB._y - tankA._y))));

		if ((tankA._x > tankB._x) && 
				(tankA._y > tankB._y))
			hitAngle = (90 - hitAngle) + 90;
		else if ((tankA._x < tankB._x) &&
						 (tankA._y >= tankB._y))
			hitAngle += 180;
		else if ((tankA._x < tankB._x) &&
						 (tankA._y < tankB._y))
			hitAngle = (90 - hitAngle) + 270;

		if (hitAngle > 180)
			hitAngle = -1 * (360 - hitAngle);

		slopeX = bounce * Math.sin(_root.toRadians(hitAngle));
		slopeY = bounce * Math.cos(_root.toRadians(hitAngle));	

		// Move the tanks
		tankA._x += slopeX;
		tankA._y -= slopeY;
		tankB._x -= slopeX;
		tankB._y += slopeY;

		// Update current locations.
		_root.objMap.movObject(idA, 1, tankA._x, tankA._y);
		_root.objMap.movObject(idB, 1, tankB._x, tankB._y);
		
		// Change the *stun* time!
		tankA.disabled = 2;
		tankB.disabled = 2;		
	}
};

function tank_CheckWall(idA:Number, idB:Number) {
	var tank:Object = _root.tank_container[(idA != -1?"tank" + idA:"player")];
	var wall:Object = _root.wall_container["wall" + idB];
	var bounce:Number = 3; // Bounce distance.
	var hitTop:Number;
	var hitSide:Number;
	var hitAngle:Number;

	if ((tank.base.a.hitTest(wall) == true) || (tank.base.b.hitTest(wall) == true) ||
			(tank.base.c.hitTest(wall) == true) || (tank.base.d.hitTest(wall) == true) ||
			(tank.base.e.hitTest(wall) == true) || (tank.base.f.hitTest(wall) == true) ||
			(tank.base.g.hitTest(wall) == true)) {

		hitTop = _root.toDegrees(Math.atan((0.5 * wall._width) / (0.5 * wall._height)));
		hitSide = _root.toDegrees(Math.atan((0.5 * wall._height) / (0.5 * wall._width)));
		hitAngle = Math.abs(_root.toDegrees(Math.atan((tank._x - wall._x) / (wall._y - tank._y))));

		if ((tank._x > wall._x) && 
				(tank._y > wall._y))
			hitAngle = (90 - hitAngle) + 90;
		else if ((tank._x < wall._x) &&
						 (tank._y >= wall._y))
			hitAngle += 180;
		else if ((tank._x < wall._x) &&
						 (tank._y < wall._y))
			hitAngle = (90 - hitAngle) + 270;

		if (hitAngle > 180)
			hitAngle = -1 * (360 - hitAngle);

		// Change this if we want to *stun* the tank when it hits a wall.
		tank.disabled = 0;
		
		if (_root.isBetween(hitTop * -1, hitTop, hitAngle)) {
			// Hits the Top
			tank._y -= bounce;
		} else if (_root.isBetween(90 - hitSide, 90 + hitSide, hitAngle)) {
			// Hits the Right
			tank._x += bounce;
		} else if (_root.isBetween(180 - hitTop, 180, hitAngle) || _root.isBetween(-180, -180 + hitTop, hitAngle)) {
			// Hits the Bottom
			tank._y += bounce;
		} else if (_root.isBetween(-90 - hitSide, -90 + hitSide, hitAngle)) {
			// Hits the Left
			tank._x -= bounce;
		}
		
		// Update the map.
		_root.objMap.movObject(idA, 1, tank._x, tank._y);
	}
};

function tank_CheckBullet(idA:Number, idB:Number) {
	var tank:Object = _root.tank_container[(idA != -1?"tank" + idA:"player")];
	var bullet:Object = _root.bullet_container["bullet" + idB];
	
	if (tank.hitTest(bullet._x, bullet._y, true) == true) {
		bullet.hitCount = bullet.hitMax;
		tank.isDestroyed = 1;
	}
};

function tank_CheckBomb(idA:Number, idB:Number) {
	var tank:Object = _root.tank_container[(idA != -1?"tank" + idA:"player")];
	var bomb:Object = _root.bomb_container["bomb" + idB];
	
	if (bomb.isActivated == 0) {
 		if (idA == bomb.tankOwner) {
			if (bomb.detection.hitTest(tank.base) == false) {
				bomb.isActivated = 1;
				bomb.base.play();
			}
		}
	} else {
		if (bomb.detection.hitTest(tank.base) == true) {
			bomb.explode = 1;
		}
	}
};