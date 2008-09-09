// Level information
var currentLevel:Number = 0;				// Current level.
var currentEnemies:Number = 0;			// Current enemies.

// Basic declarations
var cellW:Number = 32;				// Height of tiles in pixels
var cellH:Number = 32; 				// Height of tiles in pixels

/**
 * Tracking object types:
 *  0 = wall
 *  1 = tank
 *  2 = bullet
 *  3 = bomb
 *  4 = explosion
 */
var objMap:ObjectMap = new ObjectMap(14, 25, 5, this.cellW, this.cellH);

// Max objects allowed
var maxTreads:Number = 100;		// Maximum number of treads on the board at once.
var maxSmokes:Number = 100;		// Maximum number of smoke on the board at once.
var maxBullets:Number = 20;		// Maximum number of bullets on the board at once.
var maxExplosions:Number = 50;// Maximum number of explosions on the board at once.
var maxBombs:Number = 20;			// Maximum number of bombs on the board at once.

// Object counters
var treadCount:Number = 0;		// Current tread index.
var smokeCount:Number = 0;		// Current smoke index.
var bulletCount:Number = 0;		// Current bullet index.
var explosionCount:Number = 0;// Current explosion index.
var bombCount:Number = 0;			// Current bomb index.
var wallCount:Number = 0;			// Number of walls.
var tankCount:Number = 0;			// Number of tanks (alive or dead).
var killCount:Number = 0;			// Number of kills.

//sounds
var bullet_shot = new Sound();
	bullet_shot.attachSound("shot.mp3");
var bullet_bounce = new Sound();
	bullet_bounce.attachSound("bullet_bounce.mp3");
var mine_drop = new Sound();
	mine_drop.attachSound("mine_drop.mp3");
var mine_explosion = new Sound();
	mine_explosion.attachSound("mine_explosion.mp3");
var bullet_explosion = new Sound();
	bullet_explosion.attachSound("bullet_explosion.wav");//used wav because its sucha bad sound to begin with
var treads = new Sound();
	treads.attachSound("treads.wav");// i needed to use wav cause compression messed up the fade out
var intro = new Sound();
	intro.attachSound("intro.mp3");
	
	
function addWall(x:Number, y:Number, type:Number) {s
	_root.wall_container.attachMovie("wall", "wall"+this.wallCount, _root.wall_container.getNextHighestDepth());
	_root.wall_container["wall"+this.wallCount]._x = x;
	_root.wall_container["wall"+this.wallCount]._y = y;
	_root.wall_container["wall"+this.wallCount].gotoAndStop(type);
	_root.wall_container["wall"+this.wallCount].idNumber = this.wallCount;
	
	// Add it to the map.
	this.objMap.addObject(this.wallCount, 0, x, y);
	
	this.wallCount++;
}

function addTank(x:Number, y:Number, type:Number) {
	_root.tank_container.attachMovie("enemy_" + type, "tank" + this.tankCount, _root.tank_container.getNextHighestDepth());
	_root.tank_container["tank" + this.tankCount]._x = x;
	_root.tank_container["tank" + this.tankCount]._y = y;
	_root.tank_container["tank" + this.tankCount].idNumber = this.tankCount;
	_root.tank_container["tank" + this.tankCount].aiType = type;
	
	// Add any variables we need.
	_root["enemy" + type + "_Create"].call(_root.tank_container["tank" + this.tankCount]);
	
	// Here are the basic movement tweens for the enemy (rotate turret)
//	_root.tank_container["tank" + this.tankCount].rotate = new Tween(_root.tank_container["tank" + this.tankCount], "currentRotation", None.easeNone, -90, -90, 10, false);

	// Add it to the map.
	this.objMap.addObject(this.tankCount, 1, x, y);
	
	_root.tankCount++;
}

function addPlayer(x:Number, y:Number) {
	_root.tank_container.attachMovie("player", "player", _root.tank_container.getNextHighestDepth());
	_root.tank_container.player._x = x;
	_root.tank_container.player._y = y;
	_root.tank_container.player.base._rotation = 90;
	
	// Add any variables we need
	_root.player_Create.call(_root.tank_container.player);
	
	// Here are the basic movement tweens for the player (rotate turret)
	_root.tank_container.player.rotate = new Tween(_root.tank_container.player, "currentRotation", None.easeNone, 90, 90, 10, false);

	// Add it to the map.
	this.objMap.addObject(-1, 1, x, y);
};

function addTread(x:Number, y:Number, r:Number) {
	if (_root.tread_container["tread" + this.treadCount] != undefined)
		_root.tread_container["tread" + this.treadCount].removeMovieClip();
	
	_root.tread_container.attachMovie("tank_tread", "tread" + this.treadCount, _root.tread_container.getNextHighestDepth());
	_root.tread_container["tread" + this.treadCount]._x = x;
	_root.tread_container["tread" + this.treadCount]._y = y;
	_root.tread_container["tread" + this.treadCount]._rotation = r;
	
	this.treadCount ++;
	if (this.treadCount > this.maxTreads)
		this.treadCount = 0;
};

function addMuzzleFlash(x:Number, y:Number) {
	_root.explosion_container.attachMovie("tank_muzzleflash", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addBullet(x:Number, y:Number, r:Number, hits:Number, owner:Number) {
	_root.bullet_container.attachMovie("bullet", "bullet" + this.bulletCount, _root.bullet_container.getNextHighestDepth());
	_root.bullet_container["bullet" + this.bulletCount]._x = x;
	_root.bullet_container["bullet" + this.bulletCount]._y = y;
	_root.bullet_container["bullet" + this.bulletCount]._rotation = r;
	_root.bullet_container["bullet" + this.bulletCount].idNumber = this.bulletCount;
	_root.bullet_container["bullet" + this.bulletCount].hitMax = hits;
	_root.bullet_container["bullet" + this.bulletCount].tankOwner = owner;
	
	//play sound
	_root.bullet_shot.start(0,0);
	
	// Assign default variables.
	_root.bullet_Create.call(_root.bullet_container["bullet" + this.bulletCount]);
	
	// Add it to the map.
	this.objMap.addObject(this.bulletCount, 2, x, y);
	
	this.bulletCount++;
	if (this.bulletCount > this.maxBullets)
		this.bulletCount = 0;
};

function addBulletSmoke(x:Number, y:Number) {
	if (_root.smoke_container["smoke" + this.smokeCount] != undefined)
		_root.smoke_container["smoke" + this.smokeCount].removeMovieClip();
		
	_root.smoke_container.attachMovie("bullet_smoke", "smoke" + this.smokeCount, _root.smoke_container.getNextHighestDepth());
	_root.smoke_container["smoke" + this.smokeCount]._x = x;
	_root.smoke_container["smoke" + this.smokeCount]._y = y;
	
	this.smokeCount ++;
	if (this.smokeCount > this.maxSmokes)
		this.smokeCount = 0;
};

function addBulletExplosion(x:Number, y:Number) {
	_root.explosion_container.attachMovie("bullet_explosion", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addBulletBounceExp(x:Number, y:Number) {
	_root.explosion_container.attachMovie("bullet_bounceExp", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addBomb(x:Number, y:Number, owner:Number) {
	_root.bomb_container.attachMovie("bomb", "bomb" + this.bombCount, _root.bomb_container.getNextHighestDepth());
	_root.bomb_container["bomb" + this.bombCount]._x = x;
	_root.bomb_container["bomb" + this.bombCount]._y = y;
	_root.bomb_container["bomb" + this.bombCount].tankOwner = owner; // assign to player
	_root.bomb_container["bomb" + this.bombCount].idNumber = this.bombCount;
	_root.bomb_container["bomb" + this.bombCount].isActivated = 0;
	
	// Add it to the map.
	this.objMap.addObject(this.bombCount, 3, x, y);
	
	this.bombCount++;
	if (this.bombCount > this.maxBombs)
		this.bombCount = 0;
};

function addBombExplosion(x:Number, y:Number) {
	if (_root.explosion_container["explosion" + this.explosionCount] != undefined)
		_root.explosion_container["explosion" + this.explosionCount].removeMovieClip();
		
	_root.explosion_container.attachMovie("bomb_explosion", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	_root.explosion_container["explosion" + this.explosionCount].idNumber = this.explosionCount;
	
	// Add it to the map.
	this.objMap.addObject(this.explosionCount, 4, x, y);
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addTankExplosion(x:Number, y:Number) {
	if (_root.explosion_container["explosion" + this.explosionCount] != undefined)
		_root.explosion_container["explosion" + this.explosionCount].removeMovieClip();
		
	_root.explosion_container.attachMovie("tank_explosion", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addWallExplosion(x:Number, y:Number) {
	if (_root.explosion_container["explosion" + this.explosionCount] != undefined)
		_root.explosion_container["explosion" + this.explosionCount].removeMovieClip();
		
	_root.explosion_container.attachMovie("wall_explosion", "explosion" + this.explosionCount, _root.explosion_container.getNextHighestDepth());
	_root.explosion_container["explosion" + this.explosionCount]._x = x;
	_root.explosion_container["explosion" + this.explosionCount]._y = y;
	
	this.explosionCount ++;
	if (this.explosionCount > this.maxExplosions)
		this.explosionCount = 0;
};

function addDeathMark(x:Number, y:Number) {
	_root.tread_container.attachMovie("tank_death", "death" + this.killCount, _root.tread_container.getNextHighestDepth());
	_root.tread_container["death" + this.killCount]._x = x;
	_root.tread_container["death" + this.killCount]._y = y;
	
	this.killCount ++;
};

function clearBoard() {
	// Remove the player
	_root.tank_container.player.removeMovieClip();
	
	// Remove the tanks
	for (x = 0; x < _root.tankCount; x++)
		_root.tank_container["tank" + x].removeMovieClip();
	
	// Remove the bullets
	for (x = 0; x < _root.maxBullets; x++)
		_root.bullet_container["bullet" + x].removeMovieClip();
	
	// Remove the smoke
	for (x = 0; x < _root.maxSmokes; x++)
		_root.bullet_container["smoke" + x].removeMovieClip();

	// Remove the bombs
	for (x = 0; x < _root.maxBombs; x++)
		_root.bomb_container["bomb" + x].removeMovieClip();
		
	// Remove the explosions
	for (x = 0; x < _root.maxExplosions; x++)
		_root.explosion_container["explosion" + x].removeMovieClip();

	// Remove the deaths
	for (x = 0; x < _root.killCount; x++)
		_root.tread_container["death" + x].removeMovieClip();
		
	// Remove the treads
	for (x = 0; x < _root.maxTreads; x++)
		_root.tread_container["tread" + x].removeMovieClip();
	
	// Remove the walls
	for (x = 0; x < _root.wallCount; x++)
		_root.wall_container["wall" + x].removeMovieClip();
	
	// Clear the grid
	this.objMap.clearAll();
	// Clear the AI Nodes
	this.node_Clear();
	
	// Reset the variables!
	treadCount = 0;
	smokeCount = 0;
	bulletCount = 0;
	explosionCount = 0;
	bombCount = 0;
	wallCount = 0;
	tankCount = 0;
	killCount = 0;
}

/**
 * This builds the walls for the level.
 */
function loadBoard(level:Number)
{
	var map:Array = this.mapData[level];
	var enemies:Array = this.enemyData[level];
	var nodes:Array = this.nodeData[level];
	var mapWidth:Number = map[0].length;
	var mapHeight:Number = map.length;
	var x:Number;
	var y:Number;
	var i:Number;
	var j:Number;
	
	this.clearBoard();
	
	for (i = 0; i < mapHeight; i++) {
		for (j = 0; j < mapWidth; j++) {
			switch (map[i][j]) {
				case 0:	// Do nothing!
					break;
				case 1:
				case 2:
				case 3:
				case 4:
					this.addWall((j * this.cellW) + (.5 * _root.cellW), (i * this.cellH) + (.5 * this.cellH), map[i][j]);
					break;
				case 5:	// Add the player
					this.addPlayer((j * this.cellW) + (.5 * _root.cellW), (i * this.cellH) + (.5 * this.cellH));
					break;
				case 6:	// Add an enemy
					this.addTank((j * this.cellW) + (.5 * this.cellW), (i * this.cellH) + (.5 * this.cellH), enemies[this.tankCount]);
					break;
				case 9:
				trace(this.nodeCount);
					this.node_Add((j * this.cellW) + (.5 * this.cellW), (i * this.cellH) + (.5 * this.cellH), nodes[this.nodeCount], this.cellW, this.cellH);
					break;
			}
		}
	}
	
	this.node_Calculate();
}

/**
 * Starts a new level.
 */
function newLevel() {
	this.currentLevel++;
	this.currentEnemies = this.enemyData[currentLevel].length;
	_root.attachMovie("mission_intro", "mission_intro", _root.getNextHighestDepth());
}

/**
 * Ends the level.
 */
function endLevel() {
	_root.pauseGame();
	_root.attachMovie("mission_complete", "mission_complete", _root.getNextHighestDepth());
	_root.mission_complete._x = 400;
	_root.mission_complete._y = 125;
}

/**
 * Ends the game.
 */
function endGame() {
	_root.pauseGame();
	if (_root.mission_failed)
		_root.mission_failed.removeMovieClip();
	_root.attachMovie("mission_failed", "mission_failed", _root.getNextHighestDepth());
	_root.mission_failed._x = 400;
	_root.mission_failed._y = 125;
}

/**
 * Pauses the game
 */
function pauseGame() {
	var x:Number;
	var listBombs:Array = _root.objMap.getList(3);;
	var listExplosions:Array = _root.objMap.getList(4);

	if (_root.isPaused == 0) {
		// Set the flag
		_root.isPaused = 1;
		
		for (x = 0; x < listBombs.length; x++) {
			_root.bomb_container["bomb" + listBombs[x]].base.stop();
		}
		
		for (x = 0; x < listExplosions.length; x++) {
			_root.explosion_container["explosion" + listExplosions[x]].stop();
		}
	} else {
		// Set the flag
		_root.isPaused = 0;
		
		for (x = 0; x < listBombs.length; x++) {
			if (_root.bomb_container["bomb" + listBombs[x]].isActivated == 1)
				_root.bomb_container["bomb" + listBombs[x]].base.play();
		}
		
		for (x = 0; x < listExplosions.length; x++) {
			_root.explosion_container["explosion" + listExplosions[x]].play();
		}
	}
}