// Main Functions
this.onEnterFrame = function() {
	var x:Number;
	var y:Number;
	var listTanks:Array;
	var listBullets:Array;
	var listBombs:Array;
	var listExplosions:Array;
	var areaTanks:Array;
	var areaWalls:Array;
	var areaBullets:Array;
	var areaBombs:Array;
	
	// Draw the cursor
	_root.lockCursor();
	
	// Rotate the player's turret.
	_root.player_RotateTurret.call(_root.tank_container.player);

	// Lock out if we are paused
	if (_root.isPaused == 0) {
		listTanks = _root.objMap.getList(1);
		listBullets = _root.objMap.getList(2);
		listBombs = _root.objMap.getList(3);
		listExplosions = _root.objMap.getList(4);

//------------------- ROTATE TURRETS

		// Rotate the tank turrets.
		for (x = 0; x < listTanks.length; x++) {
			if (listTanks[x] != -1)
				_root["enemy" + _root.tank_container["tank" + listTanks[x]].aiType + "_RotateTurret"].call(_root.tank_container["tank" + listTanks[x]]);
		}
		
//------------------- CHECK FOR DESTROYED OBJECTS

		// Check for death on tanks.
		for (x = 0; x < listTanks.length; x++) {
			if (listTanks[x] == -1)
				_root.player_CheckDeath.call(_root.tank_container.player);
			_root["enemy" + _root.tank_container["tank" + listTanks[x]].aiType + "_CheckDeath"].call(_root.tank_container["tank" + listTanks[x]]);
		}
		
		// Check for death on bullets.
		for (x = 0; x < listBullets.length; x++) {
			_root.bullet_CheckDeath.call(_root.bullet_container["bullet" + listBullets[x]]);
		}
		
		// Check for death on bombs.
		for (x = 0; x < listBombs.length; x++) {
			_root.bomb_CheckDeath.call(_root.bomb_container["bomb" + listBombs[x]]);
		}
		
		// Get the data again as things may have died.
		listTanks = _root.objMap.getList(1);
		listBullets = _root.objMap.getList(2);
		listBombs = _root.objMap.getList(3);
		
		// Check if we are dead!
		if (_root.gameOver == 1) {
			_root.endGame();
			return;
		}
		
		// Check if all the enemies are gone!
		if (listTanks.length == 1) {
			_root.endLevel();
			return;
		}
//------------------- MOVE OBJECTS

		// Move the tanks.
		for (x = 0; x < listTanks.length; x++) {
			if (listTanks[x] == -1)
				_root.player_MoveTank.call(_root.tank_container.player);
			else
				_root["enemy" + _root.tank_container["tank" + listTanks[x]].aiType + "_MoveTank"].call(_root.tank_container["tank" + listTanks[x]]);
		}
		
		// Move the bullets.
		for (x = 0; x < listBullets.length; x++) {
			_root.bullet_Move.call(_root.bullet_container["bullet" + listBullets[x]]);
		}
		
//------------------- TANK OPERATIONS

		// For each tank "listTanks[x]"
		for (x = 0; x < listTanks.length; x++) {
			areaTanks = _root.objMap.getOthers(listTanks[x], 1, 1, 1); 	// Tanks
			areaWalls = _root.objMap.getOthers(listTanks[x], 1, 0, 1); 	// Walls
			areaBullets = _root.objMap.getOthers(listTanks[x], 1, 2, 1); // Bullets
			areaBombs = _root.objMap.getOthers(listTanks[x], 1, 3, 4); 	// Bombs

			// Check tank on tank collisions.
			for (y = 0; y < areaTanks.length; y++) {
				if (listTanks[x] < areaTanks[y]) { // Make sure we don't repeat checks.
					_root.tank_CheckTank(listTanks[x], areaTanks[y]);
				}
			}

			// Check tank on wall collisions.
			for (y = 0; y < areaWalls.length; y++) {
				_root.tank_CheckWall(listTanks[x], areaWalls[y]);
			}
			
			// Check tank on bullet collisions.
			for (y = 0; y < areaBullets.length; y++) {
				_root.tank_CheckBullet(listTanks[x], areaBullets[y]);
			}
			
			// Check tank on bomb collisions.
			for (y = 0; y < areaBombs.length; y++) {
				_root.tank_CheckBomb(listTanks[x], areaBombs[y]);
			}
		}
		
//------------------- BULLET OPERATIONS

		// For each bullet "listBullets[x]"
		for (x = 0; x < listBullets.length; x++) {
			areaBullets = _root.objMap.getOthers(listBullets[x], 2, 2, 1); // Bullets
			areaWalls = _root.objMap.getOthers(listBullets[x], 2, 0, 1); 	// Walls
			areaBombs = _root.objMap.getOthers(listBullets[x], 2, 3, 1); 	// Bombs
			
			// Check bullet on bullet collisions.
			for (y = 0; y < areaBullets.length; y++) {
				if (listBullets[x] < areaBullets[y]) { // Make sure we don't repeat checks.
					_root.bullet_CheckBullet(listBullets[x], areaBullets[y]);
				}
			}
			
			// Check bullet on wall collisions.
			for (y = 0; y < areaWalls.length; y++) {
				_root.bullet_CheckWall(listBullets[x], areaWalls[y]);
			}
			
			// Check bullet on bomb collisions.
			for (y = 0; y < areaBombs.length; y++) {
				_root.bullet_CheckBomb(listBullets[x], areaBombs[y]);
			}
		}
		
//------------------- Explosion OPERATIONS

		// For each bullet "listExplosions[x]"
		for (x = 0; x < listExplosions.length; x++) {
			areaWalls = _root.objMap.getOthers(listExplosions[x], 4, 0, 5); 	// Walls
			areaTanks = _root.objMap.getOthers(listExplosions[x], 4, 1, 5); 	// Tanks
			areaBullets = _root.objMap.getOthers(listExplosions[x], 4, 2, 5); // Bullets
			areaBombs = _root.objMap.getOthers(listExplosions[x], 4, 3, 5); 	// Bombs

			// Check tank on tank collisions.
			for (y = 0; y < areaTanks.length; y++) {
				_root.explosion_CheckTank(listExplosions[x], areaTanks[y]);
			}

			// Check explosion on bullet collisions.
			for (y = 0; y < areaBullets.length; y++) {
				_root.explosion_CheckBullet(listExplosions[x], areaBullets[y]);
			}
			
			// Check explosion on wall collisions.
			for (y = 0; y < areaWalls.length; y++) {
				_root.explosion_CheckWall(listExplosions[x], areaWalls[y]);
			}
			
			// Check explosion on bomb collisions.
			for (y = 0; y < areaBombs.length; y++) {
				_root.explosion_CheckBomb(listExplosions[x], areaBombs[y]);
			}
		}

//------------------- FIRE WEAPONS

		// Fire bullets.
		for (x = 0; x < listTanks.length; x++) {
			if (listTanks[x] == -1)
				_root.player_FireBullet.call(_root.tank_container.player);
			else
				_root["enemy" + _root.tank_container["tank" + listTanks[x]].aiType + "_FireBullet"].call(_root.tank_container["tank" + listTanks[x]]);
		}
		
		// Drop Mines.
		for (x = 0; x < listTanks.length; x++) {
			if (listTanks[x] == -1)
				_root.player_FireMine.call(_root.tank_container.player);
			else
				_root["enemy" + _root.tank_container["tank" + listTanks[x]].aiType + "_FireMine"].call(_root.tank_container["tank" + listTanks[x]]);
		}
	} else {
		// Pause all movieclips (bombs, explosions, smoke, etc.)
	}
};