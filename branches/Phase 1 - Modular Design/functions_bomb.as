function bomb_CheckDeath() {
	if (this.explode == 1) {
		if (this.tankOwner == -1)
			_root.tank_container.player.mineCount++;
		else
			_root.tank_container["tank" + this.tankOwner].mineCount++;
			
		_root.addBombExplosion(this._x, this._y);
		// Play Sound
			_root.mine_explosion.start(0,0);
		
		// Remove the map reference.
		_root.objMap.delObject(this.idNumber, 3);
		
		this.removeMovieClip();
	}
};