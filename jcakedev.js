(function($){

	var jcakedev = {
		
		combo: {

			combos: [],
			
			create: function(params) {
				var options = [];
				var delegate = null;
				var defaultValue = null;

				if (params) {
					options = params.options;
					delegate = params.delegate;
					defaultValue = params.defaultValue;
				}

				if (!options || !options.length) {
					console.log("No options were defined for the combo(s)");
					return this;
				}

				return this.each(function(){
					var $combo = $(this);

					if (!$combo.hasClass("-cakedev-custom-combo")) {
						$combo.addClass("-cakedev-custom-combo")
					}
					
					var combo = {
						element: $combo,
						options: options,
						delegate: delegate,
						selectedIndex: 0
					};
					
					var selectedOptionIndex = 0;
					var optionsList = "";
					
					for (var i = 0; i < options.length; i++) {
						if (defaultValue != null && options[i].value == defaultValue) {
							selectedOptionIndex = i;
						}
						
						optionsList +=
							"<li class='-cakedev-combo-option-" + i + "'>" +
								"<a href='#'>" + options[i].text + "</a>" +
							"</li>";
					}

					combo.selectedIndex = selectedOptionIndex;
					var selectedOption = options[selectedOptionIndex];
					
					$combo.append(
						"<table style='border-collapse: collapse;'>" +
							"<tr>" +
								"<td class='-cakedev-combo-optionText'>" + selectedOption.text + "</td>" +
								"<td class='-cakedev-combo-arrow'><div></div></td>" +
							"</tr>" +
						"</table>"
					);
					
					$combo.append(
						"<div class='-cakedev-combo-list-container'>" +
							"<ul>" +
								optionsList +
							"</ul>" +
						"</div>"
					);

					$combo.find("li a").each(function(index){
						$(this).on("click", function(event){
							event.preventDefault();

							jcakedev.combo.setValue.call($combo, combo.options[index].value);

							if (combo.delegate && typeof(combo.delegate) == "function") {
								combo.delegate(combo.options[index], $combo);
							}
							else {
								console.log("Delegate for combo is not a valid function.");
							}
						});
					});
					
					$combo.find(".-cakedev-combo-option-" + selectedOptionIndex).hide();
					
					var $list = $combo.find(".-cakedev-combo-list-container");
					$list.hide();
					
					$combo.find("table").click(function(){
						if ($list.is(":visible")) {
							$list.hide();
						}
						else {
							$list.show();
						}
					});

					jcakedev.combo.combos.push(combo);
				});
			},

			setValue: function(value) {
				var combo = jcakedev.combo.getCurrentElement.call(this);
				if (combo) {
					var i;
					var option = null;

					for (i = 0; i < combo.options.length; i++) {
						if (combo.options[i].value == value) {
							option = combo.options[i];
							break;
						}
					}

					if (option) {
						this.find(".-cakedev-combo-optionText").html(option.text);
						var $itemsParent = this.find("ul");
						$itemsParent.children("li").show();
						$itemsParent.children("li").filter(".-cakedev-combo-option-" + i).hide();

						combo.selectedIndex = i;
					}
				}

				return this;
			},

			getValue: function() {
				var combo = jcakedev.combo.getCurrentElement.call(this);
				if (combo) {
					return combo.options[combo.selectedIndex].value;
				}

				return null;
			},

			getCurrentElement: function() {
				for (var i = 0; i < jcakedev.combo.combos.length; i++) {
					var combo = jcakedev.combo.combos[i];
					if (combo.element.get(0) == this.get(0)) {
						return combo;
					}
				}

				return null;
			}

		},

		tabs: {
			
			tabControls: [],

			create: function(params) {
				return this.each(function(){
					var $tabControl = $(this);

					if (!$tabControl.hasClass("-cakedev-tabs")) {
						$tabControl.addClass("-cakedev-tabs");
					}

					var tabControl = {
						element: $tabControl,
						tabs: [],
						currentTab: null,
						properties: {
							direction: "top",
							bgcolor: "#3c78b5"
						}
					};

					jcakedev.tabs.tabControls.push(tabControl);
					
					if (params) {
						if (params.direction)	tabControl.properties.direction = params.direction;
						if (params.bgcolor)		tabControl.properties.bgcolor = params.bgcolor;
					}
					
					var tabHeaderClass = tabControl.properties.direction == "bottom" ? "-cakedev-tabHeader-bottom" : "-cakedev-tabHeader-top";
					$tabControl.css("background-color", tabControl.properties.bgcolor);

					var $tabHeadersContainer = $("<div class='-cakedev-tabHeaders-container'></div>");
					var $tabs = $tabControl.children("div");
					
					if ($tabs.length > 0) {
						var tabHeadersContent = "";
						
						for (var i = 0; i < $tabs.length; i++) {
							var $tab = $tabs.eq(i);

							if (!$tab.hasClass("-cakedev-tab")) {
								$tab.addClass("-cakedev-tab");
							}

							var tabTitle = $tab.attr("title") ? $tab.attr("title") : i;

							tabHeadersContent +=
								"<td>" +
									"<span class=\"-cakedev-tabHeader " + tabHeaderClass + "\">" +
										tabTitle +
									"</span>" +
								"</td>";

							tabControl.tabs.push($tab);
						}
						
						if (tabControl.properties.direction == "bottom") {
							$tabControl.append($tabHeadersContainer);
						}
						else {
							$tabControl.prepend($tabHeadersContainer);
						}
						
						$tabHeadersContainer.append("<table><tr>" + tabHeadersContent + "</tr></table>");

						var $tabHeaders = $tabHeadersContainer.find(".-cakedev-tabHeader");
						for (var i = 0; i < $tabHeaders.length; i++) {
							$tabHeaders.eq(i).on("click", function(){
								var $currentTabControl = $(this).closest(".-cakedev-tabs");
								var $headersContainer = $(this).closest(".-cakedev-tabHeaders-container");

								var selectedIndex = 0;
								var $headers = $headersContainer.find(".-cakedev-tabHeader");

								for (var index = 0; index < $headers.length; index++) {
									if ($headers.eq(index).get(0) == $(this).get(0)) {
										selectedIndex = index;
										break;
									}
								}

								$headers.removeClass("-cakedev-selected-tab").eq(index).addClass("-cakedev-selected-tab");
								$currentTabControl.children(".-cakedev-tab").hide();

								var $currentTab = $currentTabControl.children(".-cakedev-tab").eq(index);
								$currentTab.show();

								tabControl.currenTab = $currentTab;
							});
						}

						$tabHeadersContainer.find(".-cakedev-tabHeader").eq(0).addClass("-cakedev-selected-tab");
						$tabControl.children(".-cakedev-tab").not(":eq(0)").hide();
						
						tabControl.currenTab = $tabControl.children(".-cakedev-tab").eq(0);
					}
				});
			},

			getActiveTab: function() {
				var $activeTab = null;
				var tabControl = jcakedev.tabs.getCurrentElement.call(this);

				if (tabControl) {
					$activeTab = tabControl.currentTab;
				}

				return $activeTab;
			},

			getCurrentElement: function() {
				for (var i = 0; i < jcakedev.tabs.tabControls.length; i++) {
					var tab = jcakedev.tabs.tabControls[i];
					if (tab.element.get(0) == this.get(0)) {
						return tab;
					}
				}

				return null;
			}

		},

		slideshow: {
			
			slideshows: [],

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

		}

	};

	var methods = {
		
		combo: function(action, params) {
			if (action) {
				if (action == "create") {
					return jcakedev.combo.create.call(this, params);
				}
				else if (action == "getValue") {
					return jcakedev.combo.getValue.call(this);
				}
				else if (action == "setValue") {
					return jcakedev.combo.setValue.call(this, params);
				}
				else {
					console.log(action + " is not a valid action for combo");
				}
			}
			else {
				return jcakedev.combo.create.call(this, params);
			}
		},

		tabs: function(action, params) {
			if (action) {
				if (action == "create") {
					return jcakedev.tabs.create.call(this, params);
				}
				else if (action == "getActiveTab") {
					return jcakedev.tabs.getActiveTab.call(this);
				}
				else {
					console.log(action + " is not a valid action for tabs");
				}
			}
			else {
				return jcakedev.tabs.create.call(this, params);
			}
		},

		slideshow: function(action, params) {
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
		}

	};

	$.fn.jcakedev = function(method, action, params) {
		if (this.length) {
			if (method) {
				if (methods[method]) {
					return methods[method].call(this, action, params);
				}
				else {
					console.log("'" + method + "' is not a valid method name.")
				}
			}
			else {
				console.log("No method name was specified.")
			}
		}
	};

}) (jQuery);

$(document).ready(function(){

	$(document).click(function(event){
        if (!$(event.target).closest(".-cakedev-custom-combo table").length) {
			$(".-cakedev-custom-combo .-cakedev-combo-list-container").hide();
		}
    });
    
});
