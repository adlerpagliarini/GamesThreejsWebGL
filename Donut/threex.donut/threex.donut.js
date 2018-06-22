var THREEx	= THREEx	|| {}

THREEx.Donut		= {}

THREEx.Donut.baseUrl	= '../'

THREEx.Donut.loadSpaceFighter03	= function(onLoad){
	var loader	= new THREE.OBJMTLLoader();
	var baseUrl	= THREEx.Donut.baseUrl 
	var objUrl	= baseUrl + 'models/donut.obj';
	var mtlUrl	= baseUrl + 'models/donut.mtl';
	loader.load(objUrl, mtlUrl, function( object3d ){
		object3d.scale.multiplyScalar(1/10)
		// change emissive color of all object3d material - they are too dark
		object3d.traverse(function(object3d){
			if( object3d.material ){
				object3d.material.emissive.set('white')
			}
		})
		// notify the callback
		onLoad	&& onLoad(object3d)
	});		
}

//////////////////////////////////////////////////////////////////////////////////
//		comment								//
//////////////////////////////////////////////////////////////////////////////////

THREEx.Donut.Shoot	= function(){
	//CylinderGeometry(radiusTop, radiusBottom, height, radiusSegments, heightSegments, openEnded, thetaStart, thetaLength)
/*radiusTop — Radius of the cylinder at the top. Default is 20.
radiusBottom — Radius of the cylinder at the bottom. Default is 20.
height — Height of the cylinder. Default is 100.

radiusSegments — Number of segmented faces around the circumference of the cylinder. Default is 8
heightSegments — Number of rows of faces along the height of the cylinder. Default is 1.

openEnded — A Boolean indicating whether the ends of the cylinder are open or capped. Default is false, meaning capped.
thetaStart — Start angle for first segment, default = 0 (three o'clock position).
thetaLength — The central angle, often called theta, of the circular sector. The default is 2*Pi, which makes for a complete cylinder.*/
	var geometry = new THREE.CylinderGeometry( 0.015, 0.001, 0.15, 8);

	//geometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, 1 / 2, 0 ) );
	geometry.applyMatrix( new THREE.Matrix4().makeRotationZ( Math.PI / 2 ) );
	var material	= new THREE.MeshPhongMaterial({
/*		map		: THREE.ImageUtils.loadTexture(THREEx.Planets.baseURL+'images/earthmap1k.jpg'),
		bumpMap		: THREE.ImageUtils.loadTexture(THREEx.Planets.baseURL+'images/earthbump1k.jpg'),
		bumpScale	: 0.05,
		specularMap	: THREE.ImageUtils.loadTexture(THREEx.Planets.baseURL+'images/earthspec1k.jpg'),*/
		color		: color() * 0xffffff,
		specular	: new THREE.Color('black')
	})
	var mesh = new THREE.Mesh(geometry, material);

	return mesh	
	/* laiser
	
		var baseUrl	= THREEx.Donut.baseUrl;
		var url		= baseUrl + 'images/lensflare0_alpha.png';
		var texture	= THREE.ImageUtils.loadTexture(url);
		color		: 0x00ffff,
		map		: texture,
		side		: THREE.DoubleSide,
		blending	: THREE.AdditiveBlending,
		opacity		: 2,
		depthWrite	: false,
		transparent	: true,
		specular	: new THREE.Color('blue'),*/
}
function color(){
	var c = ['0xff0084','0xff0084','0x00ffea', '0x8a00ff'];//'0x8aff00'
	return c[Math.floor((Math.random() * 3) + 1)];
}


THREEx.Donut.LineLimit	= function(){
	var geometry = new THREE.CylinderGeometry( 0.015, 0.001, 2, 8);
	var material	= new THREE.MeshPhongMaterial({
		side		: THREE.DoubleSide,
		blending	: THREE.AdditiveBlending,
		opacity		: 2,
		depthWrite	: false,
		transparent	: true,
		color		: 0x0506d5,
		specular	: new THREE.Color('blue')
	})
	var mesh = new THREE.Mesh(geometry, material);

	return mesh	
}
/**
 * create a detonation effect. 
 */
THREEx.Donut.Detonation	= function(){
	var baseUrl	= THREEx.Donut.baseUrl 
	var url		= baseUrl + 'images/lensflare0_alpha.png';
	var texture	= THREE.ImageUtils.loadTexture(url);
	// do the material	
	var geometry	= new THREE.PlaneGeometry(1,1)
	var material	= new THREE.MeshBasicMaterial({
		color		: 0x00ffff,
		map		: texture,
		side		: THREE.DoubleSide,
		blending	: THREE.AdditiveBlending,
		opacity		: 2,
		depthWrite	: false,
		transparent	: true
	})
	var mesh	= new THREE.Mesh(geometry, material)
	mesh.scale.multiplyScalar(0.75)
	return mesh;
}
