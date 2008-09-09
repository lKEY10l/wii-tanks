function explosion_CheckTank(idA:Number, idB:Number) {
	var explosion:Object = _root.explosion_container["explosion" + idA];
	var tank:Object = _root.tank_container[(idB != -1?"tank" + idB:"player")];
	
	if (explosion.detect.hitTest(tank) == true) {
		tank.isDestroyed = 1;
	}
};

function explosion_CheckBullet(idA:Number, idB:Number) {
	var explosion:Object = _root.explosion_container["explosion" + idA];
	var bullet:Object = _root.bullet_container["bullet" + idB];
	
	if (explosion.detect.hitTest(bullet) == true) {
		bullet.hitCount = bullet.hitMax;
		
	}
};

function explosion_CheckWall(idA:Number, idB:Number) {
	var explosion:Object = _root.explosion_container["explosion" + idA];
	var wall:Object = _root.wall_container["wall" + idB];
	
	if (wall._currentframe == 3) { // Only Breakable!
		if (explosion.detect.hitTest(wall) == true) {
			// Add explosion
			_root.addWallExplosion(wall._x, wall._y);
			
			// Remove the map reference.
			_root.objMap.delObject(wall.idNumber, 0);
		
			// Remove said movie clip
			wall.removeMovieClip();
		}
	}
};
			
function explosion_CheckBomb(idA:Number, idB:Number) {
	var explosion:Object = _root.explosion_container["explosion" + idA];
	var bomb:Object = _root.bomb_container["bomb" + idB];
	
	if (explosion.detect.hitTest(bomb) == true) {
		bomb.explode = 1;
	}
};