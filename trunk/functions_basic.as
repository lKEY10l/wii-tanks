/**
 * Checks if a number is between (inclusive) a Min and Max.
 */
_root.isBetween = function(Min, Max, Num) {
	if ((Num >= Min) && (Num <= Max))
		return true;
	return false
}

/**
 * Converts degrees to radians.
 */
_root.toRadians = function(Degrees) {
	return Degrees * (Math.PI / 180);
}

/**
 * Converts radians to degrees.
 */
_root.toDegrees = function(Radians) {
	return Radians * (180 / Math.PI);
}

/**
 * Converts radians to degrees.
 */
_root.calcDistance = function(x1, x2, y1, y2) {
	return Math.sqrt(Math.pow(x2 - x1,2) + Math.pow(y2 - y1,2));
}

_root.calcAngle = function(x1, x2, y1, y2) {
	var	hitAngle:Number = Math.abs(_root.toDegrees(Math.atan((x1 - x2) / (y2 - y1))));

	if ((x1 > x2) && (y1 > y2))
		hitAngle = (90 - hitAngle) + 90;
	else if ((x1 < x2) && (y1 > y2))
		hitAngle += 180;
	else if ((x1 < x2) && (y1 < y2))
		hitAngle = (90 - hitAngle) + 270;

	if (hitAngle > 180)
		hitAngle = -1 * (360 - hitAngle);
		
	return hitAngle;
}