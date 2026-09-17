function toString(obj) {
	if (typeof(obj) == "string") {
		return obj;
	} else if (obj === true) {
		return "yes";
	} else if (obj === false) {
		return "no";
	} else if (typeof(obj) == "function") {
		return '<pre>' + obj.toString() + '</pre>';
	} else if (obj == null) {
		return 'nothing';
	} else if (Array.isArray(obj)) {
		var res = "";
		var lang = false;
		obj.forEach(x => {var tmp = toString(x); res += ", "; res += tmp; });
		return "[" + res.substr(2) + "]";
	} else if (typeof(obj)=="object" && obj.has) {
		return "{"+[...obj].toString()+"}";
	} else if (typeof(obj) == "number") {
		return obj.toString();
	} else if (typeof(obj) == "object") {
		return "object";
	} else {
		return 'nothing';
	}
}

function run(uit, main) {
	SCHAAL = 7.2;
	var uitBreedte = 178;
	var context;

	function setcontext(transform) {
		if (!context) {
			var width = window.screen.width;
			var height = window.screen.height;
			SCHAAL = height/100;
			uitBreedte = width / height * 100;

			uit.innerHTML = '<canvas width="'+width+'" height="'+height+'"></canvas>'
			context = uit.children[0].getContext("2d");
			context.fillStyle = 'white';
			context.strokeStyle = 'white';
			context.font = '48px Arial';
			context.lineWidth = '4';
		}
		return transform(context);
	}
	var nu = new Date().getTime() / 1000;
	var vars = [];
	var uitvoer;
	var schermVerverst = false;
	var toetsCode = null;
	var toetsBegint = false;
	var toetsEindigt = false;
	var toetsBegin = (toetscode) => false;
	var toetsEind = (toetscode) => false;
	var muisBeweegt = false;
	var muisBeweegtNaar = null; //[0, 0];
	var muisKlikBegin = false;
	var muisKlikEind = false;
	var vroeger = nu;
	var dt = 0;
	var misschien = Math.random() < 0.5;
	var id = x => x;

	// start
	var uv = main([vars, true, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);

	vars = uv[0];
	uitvoer = uv[1];

	if (!context)
		uit.innerHTML = toString(uitvoer);


	FULLSCREEN = false;

	uit.onkeydown = (ev) =>
	{
		if (ev.key == 'f')
		{
			if (FULLSCREEN)
				document.exitFullscreen();
			else
				uit.requestFullscreen();

			FULLSCREEN = !FULLSCREEN;
		}

		var nu = new Date().getTime() / 1000;
		var toetsBegin = (keycode) => ev.keyCode == keycode;
		var toetsCode = ev.keyCode;
		var toetsBegint = true;
		var setcontext = x => x;
		var misschien = Math.random() < 0.5;
		var uv = main([vars, false, nu, x => x, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);

		vars = uv[0];

		return ev.keyCode > 96;
	};

	uit.onmousedown = (ev) => {
		var nu = new Date().getTime() / 1000;
		var muisBeweegt = true;
		var canvas = uit.children[0] || uit;
		var b = canvas.getBoundingClientRect();
		var muisX = (ev.clientX - b.left) / canvas.clientHeight * 100;
		var muisY = (ev.clientY - b.top) / canvas.clientHeight * 100;
		var muisY = 100 - muisY;
		var muisBeweegtNaar = [+muisX.toFixed(3), +muisY.toFixed(3)];
		var muisKlikBegin = true;
		var setcontext = id;
		var misschien = Math.random() < 0.5;
		var uv = main([vars, false, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);

		vars = uv[0];
	};
		
	uit.onmouseup = (ev) => {
		var nu = new Date().getTime() / 1000;
		var muisBeweegt = true;
		var canvas = uit.children[0] || uit;
		var b = canvas.getBoundingClientRect();
		var muisX = (ev.clientX - b.left) / canvas.clientHeight * 100;
		var muisY = (ev.clientY - b.top) / canvas.clientHeight * 100;
		var muisY = 100 - muisY;
		var muisBeweegtNaar = [+muisX.toFixed(3), +muisY.toFixed(3)];
		var muisKlikEind = true;
		var setcontext = id;
		var misschien = Math.random() < 0.5;
		var uv = main([vars, false, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);

		vars = uv[0];
	};

	uit.onmousemove = (ev) => {
		var nu = new Date().getTime() / 1000;
		muisBeweegt = true;
		var canvas = uit.children[0] || uit;
		var b = canvas.getBoundingClientRect();
		var muisX = (ev.clientX - b.left) / canvas.clientHeight * 100;
		var muisY = (ev.clientY - b.top) / canvas.clientHeight * 100;
		var muisY = 100 - muisY;
		var muisBeweegtNaar = [+muisX.toFixed(3), +muisY.toFixed(3)];
		var setcontext = id;
		var misschien = Math.random() < 0.5;
		var uv = main([vars, false, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);
		vars = uv[0];
		return true;
	};
		

	uit.onkeyup = (ev) => {
		var nu = new Date().getTime() / 1000;
		var toetsEind = (keycode) => ev.keyCode == keycode;
		var toetsCode = ev.keyCode;
		var toetsEindigt = true;
		var setcontext = id;
		var misschien = Math.random() < 0.5;
		var uv = main([vars, false, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien]);

		vars = uv[0];

		return ev.keyCode > 96;
	};

	var refresh = (ev) => {
		if (window.stopped)
			return;
		if (window.paused) {
			requestAnimationFrame(refresh);
			return;
		}
		var vroeger = nu;
		nu = new Date().getTime() / 1000;
		var dt = nu - vroeger;
		var schermVerverst = true;
		var misschien = Math.random() < 0.5;

		var uv = main([vars, false, nu, setcontext, uitBreedte, schermVerverst, toetsCode, toetsBegint, toetsEindigt, toetsBegin, toetsEind, muisBeweegt, muisBeweegtNaar, muisKlikBegin, muisKlikEind, misschien, dt]);
		var na = new Date().getTime() / 1000;
		muisBeweegt = false;
		vars = uv[0];
		uitvoer = uv[1];

		if (!context)
			uit.innerHTML = toString(uitvoer);

		// debug
		if (window.cache && window.naam2index && naam && !window.stopped)
			if (naam2index[naam])
				preview.innerHTML = toString(cache[naam2index[naam]]);

		if (!window.stopped)
			requestAnimationFrame(refresh);
	}
	requestAnimationFrame(refresh);
}
