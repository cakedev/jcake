jcakedev.slideshow = {

	slideshows: [],

	invoke: function(action, params) {
		if (action) {
			if (action == "create") {
				return jcakedev.slideshow.create.call(this, params);
			}
			else {
				console.log(action + " is not a valid action for slideshow");
			}
		}
		else {
			return jcakedev.slideshow.create.call(this, params);
		}
	},

	create: function(params) {
		return this.each(function(){
			var $slideshow = $(this);

			var disableNavigation = false;
			var rotate = true;
			var animationSpeed = 400;
			var autoNavigate = false;
			var delay = 2000;

			if (params) {
				if (params.height) {
					$slideshow.css("height", isNaN(params.height) ? params.height : params.height + "px");
				}
				if (params.disableNavigation) {
					disableNavigation = true;
				}
				if (params.rotate != null && !params.rotate) {
					rotate = false;
				}
				if (params.animationSpeed) {
					animationSpeed = params.animationSpeed;
				}
				if (params.autoNavigate != null && params.autoNavigate) {
					autoNavigate = true;
				}
				if (params.delay && !isNaN(params.delay)) {
					delay = params.delay;
				}
			}

			var $slides = $slideshow.children("div");

			var slideshow = {
				element: $slideshow,
				slides: $slides,
				currentIndex: 0,
				animationSpeed: animationSpeed,
				animating: false,
				rotate: rotate,
				delay: delay,
				autoNavigate: autoNavigate
			};

			jcakedev.slideshow.slideshows.push(slideshow);

			if (!$slideshow.hasClass("-cakedev-slideshow")) {
				$slideshow.addClass("-cakedev-slideshow");
			}

			var width = $slideshow.width();
			var height = $slideshow.height();
			
			for (var i = 0; i < $slides.length; i++) {
				var $slide = $slides.eq(i);

				if (!$slide.hasClass("-cakedev-slideshow-slide")) {
					$slide.addClass("-cakedev-slideshow-slide");
				}

				$slide.css("height", height + "px");
				$slide.css("width", width + "px");
				$slide.css("top", "-" + (i * height) + "px");

				if (i > 0) {
					$slide.css("margin-left", width);
				}
			}

			if (!disableNavigation) {
				jcakedev.slideshow.setNavigationControls(slideshow, width, height);
			}
			if (autoNavigate) {
				jcakedev.slideshow.setAutoNavigation(slideshow);
			}
		});
	},

	setNavigationControls: function(slideshow, width, height) {
		var $slideshow = slideshow.element;
		var $slides = slideshow.slides;

		var $arrowleft = $("<div class='-cakedev-slideshow-arrowleft'></div>");
		var $arrowright = $("<div class='-cakedev-slideshow-arrowright'></div>");

		$slideshow.append($arrowleft);
		$slideshow.append($arrowright);

		$arrowleft.css("left", "10px");
		$arrowleft.css("top",
			"-" + (
					height * $slides.length -
					parseInt(height / 2, 10) +
					parseInt($arrowleft.height() / 2, 10)
				) +
			"px"
		);

		$arrowright.css("left", (width - $arrowright.width() - 10) + "px");
		$arrowright.css("top",
			"-" + (
					height * $slides.length -
					parseInt(height / 2, 10) +
					parseInt($arrowright.height() / 2, 10) +
					$arrowleft.height()
				) +
			"px"
		);

		$arrowleft.on("click", function(){
			slideshow.autoNavigate = false;
			jcakedev.slideshow.movePrevious.call(slideshow.element);
		});

		$arrowright.on("click", function(){
			slideshow.autoNavigate = false;
			jcakedev.slideshow.moveNext.call(slideshow.element);
		});
	},

	setAutoNavigation: function(slideshow) {
		jcakedev.slideshow.autoNavigate(slideshow);
	},

	autoNavigate: function(slideshow) {
		setTimeout(function(){
			if (slideshow.autoNavigate) {
				jcakedev.slideshow.moveNext.call(slideshow.element, function(){
					jcakedev.slideshow.autoNavigate(slideshow);
				});
			}
		}, slideshow.delay);
	},

	moveNext: function(callback, animationSpeed) {
		var slideshow = jcakedev.slideshow.getCurrentElement.call(this);

		if (slideshow) {
			if (slideshow.animating) {
				return;
			}

			if (slideshow.slides.length > 1) {
				var speed = animationSpeed != null ? animationSpeed : slideshow.animationSpeed;

				if (slideshow.currentIndex == slideshow.slides.length - 1) {
					if (slideshow.rotate) {
						speed = Math.round(speed / slideshow.slides.length) + 100;
						jcakedev.slideshow.moveToFirst(slideshow, speed, callback);
					}
				}
				else {
					slideshow.animating = true;

					jcakedev.slideshow.changeSlide(
						slideshow.slides.eq(slideshow.currentIndex),
						slideshow.slides.eq(slideshow.currentIndex + 1),
						speed,
						"f",
						function() {
							slideshow.animating = false;
							slideshow.currentIndex++;
							if (callback && typeof(callback) == "function") {
								callback();
							}
						}
					);
				}
			}
		}
	},

	movePrevious: function(callback, animationSpeed) {
		var slideshow = jcakedev.slideshow.getCurrentElement.call(this);

		if (slideshow) {
			if (slideshow.animating) {
				return;
			}

			if (slideshow.slides.length > 1) {
				var speed = animationSpeed != null ? animationSpeed : slideshow.animationSpeed;

				if (slideshow.currentIndex == 0) {
					if (slideshow.rotate) {
						speed = Math.round(speed / slideshow.slides.length) + 100;
						jcakedev.slideshow.moveToLast(slideshow, speed, callback);
					}
				}
				else {
					slideshow.animating = true;

					jcakedev.slideshow.changeSlide(
						slideshow.slides.eq(slideshow.currentIndex),
						slideshow.slides.eq(slideshow.currentIndex - 1),
						speed,
						"b",
						function() {
							slideshow.animating = false;
							slideshow.currentIndex--;
							if (callback && typeof(callback) == "function") {
								callback();
							}
						}
					);
				}
			}
		}
	},

	moveToFirst: function(slideshow, slideAnimationSpeed, callback) {
		if (slideshow.currentIndex > 0) {
			jcakedev.slideshow.movePrevious.call(slideshow.element,
				function() { jcakedev.slideshow.moveToFirst(slideshow, slideAnimationSpeed, callback); },
				slideAnimationSpeed
			);
		}
		else {
			if (callback && typeof(callback) == "function") {
				callback();
			}
		}
	},

	moveToLast: function(slideshow, slideAnimationSpeed, callback) {
		if (slideshow.currentIndex < slideshow.slides.length - 1) {
			jcakedev.slideshow.moveNext.call(slideshow.element,
				function() { jcakedev.slideshow.moveToLast(slideshow, slideAnimationSpeed, callback); },
				slideAnimationSpeed
			);
		}
		else {
			if (callback && typeof(callback) == "function") {
				callback();
			}
		}
	},

	changeSlide: function($current, $new, speed, direction, callback) {
		$current.css("z-index", 990);
		$new.css("z-index", 991);
		$new.animate({marginLeft: "0px"}, speed, "linear", function(){
			if (callback && typeof(callback) == "function") {
				callback();
			}
		});

		if (direction == "f") {
			$current.animate({ marginLeft: "-" + $current.width() + "px" }, speed, "linear");
		}
		else if (direction == "b") {
			$current.animate({ marginLeft: $current.width() + "px" }, speed, "linear");
		}
	},

	getCurrentElement: function() {
		for (var i = 0; i < jcakedev.slideshow.slideshows.length; i++) {
			var slideshow = jcakedev.slideshow.slideshows[i];
			if (slideshow.element.get(0) == this.get(0)) {
				return slideshow;
			}
		}

		return null;
	}
	
};
