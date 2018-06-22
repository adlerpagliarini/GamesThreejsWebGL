<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default-follow-touch.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <meta property="og:title" content="Donuts Game - Você consegue bater esse recorde?" />
    <meta property="og:type" content="website" />
    <meta property="og:description" content="Compartilhe sua vitória e desafie seus amigos." />
    <meta property="og:url" content="http://www.tagcode.com.br/donut" />
    <meta property="og:image" content="http://www.tagcode.com.br/Donut/primitivas/donut-shooter-facebook.jpg" />
    <title>Donut Shooter - play this game and show how fast you are!</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type="text/javascript" src='vendor/three.js/build/three.js'></script>
    <script type="text/javascript" src="vendor/require.js"></script>
    <script type="text/javascript" src="vendor/three.js/examples/js/Detector.js"></script>
    <script type="text/javascript" src="vendor/threex.windowresize.js"></script>
    <script type="text/javascript" src="jquery/jquery1.11.2.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function (e) {
            $("#btn").click(function () {
                startGame();
                $("body").css("overflow", "hidden");
                $(".pageStart").fadeOut();
            });
        });
        function startGame() {
            require(['threex.donut/package.require.js'
	, 'vendor/three.js/examples/js/loaders/OBJMTLLoader.js'
	, 'vendor/three.js/examples/js/loaders/MTLLoader.js'
	, 'threex.keyboardstate/package.require.js'
	, 'threex.planets/package.require.js'
	, 'webaudiox/build/webaudiox.js'
	], function () {
	    // detect WebGL
	    if (!Detector.webgl) {
	        Detector.addGetWebGLMessage();
	        throw 'WebGL Not Available'
	    }
	    // setup webgl renderer full page
	    var renderer = new THREE.WebGLRenderer();
	    renderer.setSize(window.innerWidth, window.innerHeight);
	    document.getElementById("gameCanvas").appendChild(renderer.domElement);

	    // setup a scene and camera
	    var scene = new THREE.Scene();
	    //var camera	= new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.01, 1000);
	    var camera = new THREE.PerspectiveCamera(45, 1366 / 657, 0.01, 1000);
	    camera.position.z = 3;

	    // declare the rendering loop
	    var onRenderFcts = [];
	    var onRenderFctsShoot = [];
	    var onRenderFctsSpace = [];

	    // handle window resize events
	    var winResize = new THREEx.WindowResize(renderer, camera)

	    //////////////////////////////////////////////////////////////////////////////////
	    //		default 3 points lightning					//
	    //////////////////////////////////////////////////////////////////////////////////

	    var ambientLight = new THREE.AmbientLight(0x020202)
	    scene.add(ambientLight)
	    var frontLight = new THREE.DirectionalLight('white', 0.90)
	    frontLight.position.set(-0.4, 0.5, 0.5)
	    scene.add(frontLight)
	    var backLight = new THREE.DirectionalLight('white', 0.75)
	    backLight.position.set(-0.5, -0.5, -2)
	    scene.add(backLight)

	    //////////////////////////////////////////////////////////////////////////////////
	    //		add star sphere							//
	    //////////////////////////////////////////////////////////////////////////////////
	    var geometry = new THREE.SphereGeometry(90, 32, 32)
	    var url = 'primitivas/fundo.jpg';
	    var material = new THREE.MeshBasicMaterial({
	        map: THREE.ImageUtils.loadTexture(url),
	        side: THREE.BackSide
	    })
	    var starSphere = new THREE.Mesh(geometry, material)
	    scene.add(starSphere)


	    //////////////////////////////////////////////////////////////////////////////////
	    //		add a moon							//
	    //////////////////////////////////////////////////////////////////////////////////
	    var mouseActive;
	    var destroyWhenFire = 0.11;
	    var destroyWhenSpace = 0.2;
	    var destroyWhenShoot = 2.6;
	    var loseWhen = -2.6;
	    var qtdMoon = 1;
	    var dificult = 1;
	    var score = 0;
	    var moonMesh = new Array();
	    //var moonMeshTwo =  new Array(qtdMoon);
	    function newMoon() {
	        if (qtdMoon < 10 || dificult > 10) {
	            moonMesh[qtdMoon] = THREEx.Planets.createEarth();
	            scene.add(moonMesh[qtdMoon]);
	            resetMoon(qtdMoon);
	            qtdMoon++;
	        } else {
	            dificult++;
	        }
	        if (dificult > 10) {
	            dificult = 1;
	        }
	    }
	    for (l = 0; l < qtdMoon; l++) {
	        moonMesh[l] = THREEx.Planets.createEarth();
	        moonMesh[l].position.x = 7;
	        scene.add(moonMesh[l]);
	        resetMoon[l];
	    }
	    function resetMoon(l) {
	        moonMesh[l].position.x = 6
	        moonMesh[l].position.x += 5 * (Math.random() - 0.5)
	        moonMesh[l].position.y = 2 * (Math.random() - 0.5)
	    }

	    onRenderFcts.push(function (delta, now) {
	        for (l = 0; l < qtdMoon; l++) {
	            // move the moon to the left
	            moonMesh[l].position.x += -1 * delta;
	            moonMesh[l].rotation.y += 4 / 8 * delta;
	            moonMesh[l].rotation.x += 1 / 8 * delta;
	            // make it warp
	            if (moonMesh[l].position.x < loseWhen) {
	                youLose();
	                resetMoon(l);
	            }
	        }
	    })

	    onRenderFcts.push(function (delta, now) {
	        for (l = 0; l < qtdMoon; l++) {
	            // only if the spaceship is loaded
	            if (spaceship === null) return
	            // compute distance between spaceship and the moon
	            var distance = moonMesh[l].position.distanceTo(spaceship.position)
	            if (distance < destroyWhenSpace) {
	                resetMoon(l)
	                playExplosionSound()
	                youLose();
	            }
	        }
	    })
	    //LOSE//
	    function youLose() {
	        $(function () {
	            /*reset*/
	            onRenderFcts = [];
	            onRenderFctsShoot = [];
	            onRenderFctsSpace = [];
	            renderer = null;
	            $("canvas").remove();
	            $(".pageLose").fadeIn();
	            var metaV = "Donuts Game - Você consegue bater esse recorde? " + document.getElementById("scoreAspx").value;
	            $('meta[property=og\\:title]').attr('content', metaV);
	            $("body").css("overflow", "auto");
	            /* .NET*/
	            CallMe();
	            /* .NET*/
	            /*reset*/
	        });
	    }
	    /* .NET*/
	    function CallMe() {
	        // call server side method
	        PageMethods.carregarRank(CallSuccess, CallFailed);
	    }

	    // set the destination textbox value with the ContactName
	    function CallSuccess(res) {
	        if (res != "") {
	            $("#rankASPX").append(res);
	        }
	        contentLoadTriggered = false;
	    }

	    // alert message on some failure
	    function CallFailed(res) {
	        alert(res.get_message());
	        contentLoadTriggered = false;
	    }
	    /* .NET*/

	    //////////////////////////////////////////////////////////////////////////////////
	    //		explosion sound							//
	    //////////////////////////////////////////////////////////////////////////////////
	    var context = new AudioContext()
	    var lineOut = new WebAudiox.LineOut(context)
	    lineOut.volume = 0.2

	    var soundBuffer;
	    // load the sound
	    var soundUrl = 'sons/explosao.mp3'
	    WebAudiox.loadBuffer(context, soundUrl, function (buffer) {
	        soundBuffer = buffer
	    })

	    // setup a play function
	    function playExplosionSound() {
	        if (!soundBuffer) return
	        var source = context.createBufferSource()
	        source.buffer = soundBuffer
	        source.connect(lineOut.destination)
	        source.start(0)
	        return source
	    }


	    //////////////////////////////////////////////////////////////////////////////////
	    //		add an object and make it move					//
	    //////////////////////////////////////////////////////////////////////////////////

	    var spaceship = null;
	    THREEx.Donut.loadSpaceFighter03(function (object3d) {
	        scene.add(object3d)
	        spaceship = object3d
	        spaceship.rotateY(Math.PI / 2)
	        spaceship.rotateX(0.2)
	        spaceship.rotateZ(0.4)
	        spaceship.position.x = -1
	    })
	    onRenderFcts.push(function (delta, now) {
	        if (spaceship === null) return
	        spaceship.rotateY(-2 * delta);
	    });
	    /*adler*/
	    /*limitShoot*/
	    var limitShoot = new THREEx.Donut.LineLimit();
	    limitShoot.position.x = destroyWhenShoot;
	    scene.add(limitShoot)
	    /*limitShoot*/
	    var shoot = [];
	    var qtdShoot = 0; //conta a quantidade de tiros
	    //var detonation	= new THREEx.Donut.Detonation();
	    function resetShoot(value) {
	        scene.remove(shoot[value]);
	        shoot.splice(value, 1);
	        qtdShoot--;
	    }

	    onRenderFctsShoot.push(function (delta, now) {
	        for (l = 0; l < qtdShoot; l++) {
	            shoot[l].position.x += 4 * delta;
	            for (li = 0; li < qtdMoon; li++) {
	                var distance = moonMesh[li].position.distanceTo(shoot[l].position)
	                if (distance < destroyWhenFire) {
	                    score++;
	                    document.getElementById("scoreAspx").value = score
	                    document.getElementById("score").innerHTML = score;
	                    resetMoon(li)
	                    resetShoot(l)
	                    //detonation.position =  shoot[l].position;
	                    //scene.add(detonation);
	                    playExplosionSound()
	                    newMoon();
	                    break;
	                }
	            }
	            if (shoot[l].position.x > destroyWhenShoot) {
	                resetShoot(l);
	                break;
	            }
	        }
	    })

	    function drawShoot() {
	        shoot[qtdShoot] = new THREEx.Donut.Shoot();
	        shoot[qtdShoot].position.x = spaceship.position.x + 0.3;
	        shoot[qtdShoot].position.y = spaceship.position.y - 0.1;
	        shoot[qtdShoot].position.z = spaceship.position.z;
	        scene.add(shoot[qtdShoot]);
	        qtdShoot++;
	    }
	    /*adler*/

	    //////////////////////////////////////////////////////////////////////////////////
	    //		controls by keyboard						//
	    //////////////////////////////////////////////////////////////////////////////////

	    // create keyboard instance
	    var keyboard = new THREEx.KeyboardState();
	    // only on keydown + no repeat
	    var wasPressed = {};
	    keyboard.domElement.addEventListener('keydown', function (event) {
	        if ((keyboard.eventMatches(event, 'space') && !wasPressed['space']) || (keyboard.eventMatches(event, 'w') && !wasPressed['w'])) {
	            wasPressed['space'] = true;
	            wasPressed['w'] = false;
	            drawShoot();
	        }
	    })
	    // listen on keyup to maintain ```wasPressed``` array
	    keyboard.domElement.addEventListener('keyup', function (event) {
	        if (keyboard.eventMatches(event, 'space')) {
	            wasPressed['space'] = false;
	        }
	    })
	    keyboard.domElement.addEventListener('keyup', function (event) {
	        if (keyboard.eventMatches(event, 'w')) {
	            wasPressed['w'] = false;
	        }
	    })

	    // add function in rendering loop
	    onRenderFcts.push(function (delta, now) {
	        // only if the spaceship is loaded
	        if (spaceship === null) return;

	        // set the speed
	        var speed = 2;
	        if (keyboard.pressed('ctrl') || keyboard.pressed('q')) {
	            speed = 1;
	        } else {
	            speed = 2;
	        }
	        // only if donut is loaded
	        if (keyboard.pressed('down')) {
	            if (spaceship.position.y > -1.1) spaceship.position.y -= speed * delta;
	        } else if (keyboard.pressed('up')) {
	            if (spaceship.position.y < 1.3) spaceship.position.y += speed * delta;
	        }
	        /*adler*/
	        if (keyboard.pressed('left')) {
	            if (spaceship.position.x > -2.6) spaceship.position.x -= (speed) * delta;
	        } else if (keyboard.pressed('right')) {
	            if (spaceship.position.x < 2) spaceship.position.x += (speed) * delta;
	        }
	        if (keyboard.pressed('m')) {
	            mouseActive = true;
	        } else {
	            mouseActive = false;
	        }
	        /*adler*/
	    })


	    //////////////////////////////////////////////////////////////////////////////////
	    // TouchEvents
	    //////////////////////////////////////////////////////////////////////////////////
	    var el = document.getElementsByTagName("canvas")[0];
	    //el.addEventListener("touchstart", handleStart, false);
	    //el.addEventListener("touchend", handleEnd, false);
	    //el.addEventListener("touchcancel", handleCancel, false);
	    //el.addEventListener("touchleave", handleEnd, false);
	    //el.addEventListener("touchmove", handleMove, false);
	    el.addEventListener("touchend", handleClick, false);
	    //el.addEventListener("touchmove", handleMove, false);

	    var touchPress = false;



	    function handleClick(evt) {
	        //handle tap or click.
	        var touchobj = evt.changedTouches[0] // reference first touch point (ie: first finger)
	        startx = parseInt(touchobj.clientX) // get x position of touch point relative to left edge of browser
	        if ((window.innerWidth / 2) < startx) {
	            drawShoot();
	        }
	        evt.preventDefault();
	        return false;
	    }

	    var touch = { x: null, y: null }
	    var touchAux = { x: null, y: null }
	    document.addEventListener('touchstart', function (e) {
	        touchobj = e.changedTouches[0] // reference first touch point for this event
	        touchAux.x = touchobj.clientX // calculate dist traveled by touch point
	        touchAux.y = touchobj.clientY // calculate dist traveled by touch point
	        e.preventDefault(); // prevent default click behavior
	    }, false)
	    document.addEventListener('touchmove', function (e) {
	        touchobj = e.changedTouches[0] // reference first touch point for this event
	        touch.x = touchobj.clientX // calculate dist traveled by touch point
	        touch.y = touchobj.clientY // calculate dist traveled by touch point
	        e.preventDefault(); // prevent default click behavior
	    }, false)
	    document.addEventListener('touchend', function (e) {
	        touchobj = e.changedTouches[0] // reference first touch point for this event
	        touch.x = null // calculate dist traveled by touch point
	        touch.y = null // calculate dist traveled by touch point
	        e.preventDefault(); // prevent default click behavior
	    }, false)

	    onRenderFcts.push(function (delta, now) {
	        var speed = 2;
	        if (spaceship == null) return;
	        if (touch.x != null && touch.y != null) {
	            
                
                if (touch.x < touchAux.x) {
	                if (spaceship.position.x > -2.6) {
	                    spaceship.position.x -= speed * delta;
	                    touchAux.x = touch.x;
	                }
	            }
	            if (touch.x > touchAux.x) {
	                if (spaceship.position.x < 2) {
	                    spaceship.position.x += speed * delta;
	                    touchAux.x = touch.x;
	                }
	            }
                
	            if (touch.y > touchAux.y) {
	                if (spaceship.position.y > -1.1) {
	                    spaceship.position.y -= speed * delta;
	                    touchAux.y = touch.y;
	                }
	            }

	            if (touch.y < touchAux.y) {
	                if (spaceship.position.y < 1.3) {
	                    spaceship.position.y += speed * delta;
	                    touchAux.y = touch.y;
	                }
	            }

	        }
	        //spaceship.position.y += (touch.y * 1 - spaceship.position.y) * delta;
	    })







	    /* do object drag
	    //isso não usar só vou deixar aqui pq achei daora
	    #scoreTeste
	    {
	    left:20px; top:20px;
	    position:absolute;
	    z-index:9;
	    width:40px;
	    height:40px;
	    background-color:Black;
	    }
	    <div id="scoreTeste"></div>
	    */
	    /*var box2 = document.getElementById('scoreTeste');
	    box2.addEventListener('touchstart', function (e) {
	    touchobj = e.changedTouches[0] // reference first touch point
	    boxleft = parseInt(box2.style.left) // get left position of box

	    //se eu quiser sempre iniciar do começo
	        
	    startx = parseInt(touchobj.clientX) // get x coord of touch point
	    starty = parseInt(touchobj.clientY) // get x coord of touch point se eu quiser sempre iniciar do começo

	    e.preventDefault() // prevent default click behavior
	    }, false)

	    box2.addEventListener('touchmove', function (e) {
	    touchobj = e.changedTouches[0] // reference first touch point for this event
	    var distx = parseInt(touchobj.clientX) // calculate dist traveled by touch point
	    var disty = parseInt(touchobj.clientY) // calculate dist traveled by touch point
	    // move box according to starting pos plus dist
	    // with lower limit 0 and upper limit 380 so it doesn't move outside track:
	    $("#scoreTeste").css("left", distx);
	    $("#scoreTeste").css("top", disty);
	    e.preventDefault()
	    }, false)*/
	    /*ate aqui achei daora*/


	    //////////////////////////////////////////////////////////////////////////////////
	    //		Camera Controls							//
	    //////////////////////////////////////////////////////////////////////////////////
	    /*var mouse	= {x : 0, y : 0}
	    document.addEventListener('mousemove', function(event){
	    mouse.x	= (event.clientX / window.innerWidth ) - 0.5
	    mouse.y	= (event.clientY / window.innerHeight) - 0.5
	    }, false)
	    onRenderFcts.push(function(delta, now){
	    camera.position.x += (mouse.x*5 - camera.position.x) * (delta*3)
	    camera.position.y += (mouse.y*5 - camera.position.y) * (delta*3)
	    camera.lookAt( scene.position )
	    })*/
	    var mouse = { x: 0, y: 0 }
	    document.addEventListener('mousemove', function (event) {
	        mouse.x = (event.clientX / window.innerWidth) - 0.5
	        //mouse.y	= (event.clientY / window.innerHeight) - 0.5
	    }, false)
	    onRenderFcts.push(function (delta, now) {
	        if (mouseActive) {
	            camera.position.x += (mouse.x * 5 - camera.position.x) * (delta * 3)
	            //camera.position.y += (mouse.y*5 - camera.position.y) * (delta*3)
	            camera.lookAt(scene.position)
	        }
	    })

	    //////////////////////////////////////////////////////////////////////////////////
	    //		render the scene						//
	    //////////////////////////////////////////////////////////////////////////////////
	    onRenderFcts.push(function () {
	        if (renderer == null) return;
	        renderer.render(scene, camera);
	    })

	    //////////////////////////////////////////////////////////////////////////////////
	    //		Rendering Loop runner						//
	    //////////////////////////////////////////////////////////////////////////////////
	    var lastTimeMsec = null
	    requestAnimationFrame(function animate(nowMsec) {
	        // keep looping
	        requestAnimationFrame(animate);
	        // measure time
	        lastTimeMsec = lastTimeMsec || nowMsec - 1000 / 60
	        var deltaMsec = Math.min(200, nowMsec - lastTimeMsec)
	        lastTimeMsec = nowMsec
	        // call each update function
	        onRenderFcts.forEach(function (onRenderFct) {
	            onRenderFct(deltaMsec / 1000, nowMsec / 1000)
	        })
	        onRenderFctsShoot.forEach(function (onRenderFct) {
	            onRenderFct(deltaMsec / 1000, nowMsec / 1000) //só preciso chamar o método, sinistro, não precisa dar push
	        })
	    })
	})

        }
    </script>
    <style>
        *
        {
            margin: 0;
            padding: 0;
        }
        html, body, form
        {
            width: 100%;
            height: 100%;
        }
        #score
        {
            position: absolute;
            display: table;
            z-index: 999999;
            font-size: 42px;
            color: #000;
            font-family: Tahoma, Geneva, sans-serif;
            top: 25px;
            right: 50px;
        }
        
        .pageStart, .pageLose
        {
            width: 100%;
            height: 100%;
            display: table;
            background: -webkit-radial-gradient(#f8eeca, #f8e179, #c59d1a); /* Safari 5.1 to 6.0 */
            background: -o-radial-gradient(#f8eeca, #f8e179, #c59d1a); /* For Opera 11.6 to 12.0 */
            background: -moz-radial-gradient(#f8eeca, #f8e179, #c59d1a); /* For Firefox 3.6 to 15 */
            background: radial-gradient(#f8eeca, #f8e179, #c59d1a); /* Standard syntax (must be last) */
        }
        .pageStart #btn
        {
            margin: 50px auto 0 auto;
            display: table;
            width: 220px;
            cursor: pointer;
        }
        .pageStart .control
        {
            display: table;
            margin: 50px auto 0 auto;
            font-size: 22px;
            color: #000;
            font-family: Arial;
            text-align: left;
            width: 880px;
        }
        
        .pageStart .logo, .pageLose .logo
        {
            display: table;
            margin: 60px auto 0 auto;
        }
        
        .pageLose .logo
        {
            display: table;
            margin: 160px auto 0 auto;
        }
        .pageLose
        {
            position: absolute;
            display: none;
        }
        .pageLose .btns
        {
            margin: 40px auto 0 auto;
            width: 480px;
        }
        .pageLose .btns a
        {
            float: left;
        }
        .pageLose .btns a #btn
        {
            margin: 0;
            display: table;
            width: 220px;
            float: left;
            cursor: pointer;
        }
        .pageLose .btns *
        {
            display: table;
        }
        .pageLose .btns a:nth-child(2)
        {
            float: right;
        }
        canvas
        {
            display: table;
            margin: auto;
        }
        .rank
        {
            position: absolute;
            top: 100px;
            left: 150px;
            width: 450px;
            font-family: Arial;
        }
        .rank .saveRank
        {
            width: 350px;
        }
        .rank ul
        {
            width: 250px;
            height: 160px;
            overflow-y: auto;
            list-style: none;
            background: rgba(255,255,255,0.8);
            padding: 20px;
            border-radius: 15px;
            margin: 0 0 20px 0;
        }
        .rank ul li
        {
            padding: 5px 5%;
            width: 90%;
            display: inline-table;
            vertical-align: middle;
            border-bottom: 1px solid rgba(0,0,0,0.5);
        }
        .rank ul li .name
        {
            font-size: 14px;
            float: left;
            width: 140px;
        }
        .rank ul li .score
        {
            font-family: Tahoma;
            font-size: 16px;
            font-weight: bold;
            float: right;
            width: 80px;
            text-align: right;
        }
        .rank .saveRank
        {
            width: 100%;
            height: auto;
            display: table;
        }
        .rank .saveRank .span
        {
            font-size: 16px;
            padding: 5px 10px;
            color: #000;
        }
        .rank .saveRank .input
        {
            width: 250px;
            height: 30px;
            padding: 10px;
            background: rgba(255,255,255,0.8);
            border: 1px solid #fff;
        }
        .rank .saveRank a
        {
            background-color: #004ea6;
            padding: 15px;
            font-size: 14px;
            font-weight: bold;
            color: #fff;
            text-decoration: none;
        }
        .clear
        {
            clear: both;
        }
        .fb-like
        {
            margin: 0 0 20px 0;
        }
    </style>
    <script>
        (function (i, s, o, g, r, a, m) {
            i['GoogleAnalyticsObject'] = r; i[r] = i[r] || function () {
                (i[r].q = i[r].q || []).push(arguments)
            }, i[r].l = 1 * new Date(); a = s.createElement(o),
  m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)
        })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

        ga('create', 'UA-39995497-4', 'auto');
        ga('send', 'pageview');

    </script>
</head>
<body style='margin: 0px; background-color: #bbbbbb;'>
    <form id="form1" runat="server">
    <div id="fb-root">
    </div>
    <script>        (function (d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) return;
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/pt_BR/sdk.js#xfbml=1&version=v2.3&appId=1521078814823785";
            fjs.parentNode.insertBefore(js, fjs);
        } (document, 'script', 'facebook-jssdk'));</script>
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">
    </asp:ScriptManager>
    <input type="hidden" name="score" id="scoreAspx" value="0" />
    <div class="pageStart">
        <div class="control">
            CONTROLS:
            <br />
            space, w = shoot;<br />
            arrows = move;<br />
            q, ctrl + arrows = move slow;<br />
            press m + mouse to move camera;
        </div>
        <div class="logo">
            <img src="primitivas/donut-game-logo.png" />
        </div>
        <img id="btn" src="primitivas/start-button.png">
    </div>
    <div class="pageLose">
        <asp:UpdatePanel ID="updateLose" runat="server">
            <ContentTemplate>
                <div class="rank">
                    <ul id="rankASPX">
                        <asp:Repeater ID="rptList" runat="server">
                            <ItemTemplate>
                                <li>
                                    <p class="name">
                                        <%#DataBinder.Eval(Container.DataItem,"Nome") %></p>
                                    <p class="score">
                                        <%#DataBinder.Eval(Container.DataItem,"Score") %>
                                        pts</p>
                                </li>
                            </ItemTemplate>
                        </asp:Repeater>
                    </ul>
                    <div class="saveRank">
                        <asp:Panel ID="pnlSaveRank" runat="server">
                            <div class="span">
                                Put your nick to save the score:</div>
                            <asp:TextBox ID="txtNome" CssClass="input" runat="server"></asp:TextBox>
                            <asp:LinkButton ID="btnSalvar" runat="server" OnClick="btnSalvar_Click">Salvar</asp:LinkButton>
                        </asp:Panel>
                    </div>
                </div>
                <div class="logo">
                    <img src="primitivas/donut-game-logo.png" />
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
        <div class="btns">
            <div class="fb-like" data-href="https://www.facebook.com/donutshooter" data-width="280px"
                data-layout="standard" data-action="like" data-show-faces="true" data-share="true">
            </div>
            <div class="clear">
            </div>
            <a href="javascript: void(0);" style="margin-right: 20px;" onclick="window.open('http://www.facebook.com/sharer.php?u=http://www.tagcode.com.br/donut/','Sweet Donut', 'toolbar=0, status=0, width=650, height=450');">
                <img id="btn" src="primitivas/share-button.png" title="share Facebook"></a>
            <a href="default.aspx">
                <img id="btn" src="primitivas/again-button.png" title="play again"></a>
        </div>
    </div>
    <div id="score">
        0
    </div>
    <div id="gameCanvas">
    </div>
    </form>
</body>
</html>
