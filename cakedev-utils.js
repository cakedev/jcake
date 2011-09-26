(function($){

	var cakedev = {
		
		combo: {

			combos: [],
			
			create: function(params) {
				var options = params.options;
				var delegate = params.delegate;
				var defaultValue = params.defaultValue;

				return this.each(function(){
					if (options && options.length) {
						if (!$(this).hasClass("-cakedev-custom-combo")) {
							$(this).addClass("-cakedev-custom-combo")
						}
						
						var newOption = {
							element: $(this),
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

						newOption.selectedIndex = selectedOptionIndex;
						var selectedOption = options[selectedOptionIndex];
						
						$(this).append(
							"<table style='border-collapse: collapse;'>" +
								"<tr>" +
									"<td class='-cakedev-combo-optionText'>" + selectedOption.text + "</td>" +
									"<td class='-cakedev-combo-arrow'><div></div></td>" +
								"</tr>" +
							"</table>"
						);
						
						$(this).append(
							"<div class='-cakedev-combo-list-container'>" +
								"<ul>" +
									optionsList +
								"</ul>" +
							"</div>"
						);

						$(this).find("li a").each(function(index){
							$(this).click(function(event){
								event.preventDefault();

								var $combo = $(this).closest(".-cakedev-custom-combo");
								var combo = cakedev.combo.getCurrentCombo.call($combo);

								if (combo) {							
									cakedev.combo.setValue.call(
										$combo,
										combo.options[index].value
									);

									combo.delegate(combo.options[index], $combo);
								}
							});
						});
						
						$(this).find(".-cakedev-combo-option-" + selectedOptionIndex).hide();
						
						var $list = $(this).find(".-cakedev-combo-list-container");
						$list.hide();
						
						$(this).find("table").click(function(){
							if ($list.is(":visible")) {
								$list.hide();
							}
							else {
								$list.show();
							}
						});
					}

					cakedev.combo.combos.push(newOption)
				});
			},

			setValue: function(value) {
				var combo = cakedev.combo.getCurrentCombo.call(this);
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
				var combo = cakedev.combo.getCurrentCombo.call(this);
				if (combo) {
					return combo.options[combo.selectedIndex].value;
				}

				return null;
			},

			getCurrentCombo: function() {
				for (var i = 0; i < cakedev.combo.combos.length; i++) {
					var combo = cakedev.combo.combos[i];
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

					var newTabControl = {
						element: $tabControl,
						tabs: [],
						properties: {
							direction: "top",
							bgcolor: "#3c78b5"
						}
					};
					
					if (params) {
						if (params.direction)	newTabControl.properties.direction = params.direction;
						if (params.bgcolor)		newTabControl.properties.bgcolor = params.bgcolor;
					}
					
					var tabHeaderClass = newTabControl.properties.direction == "bottom" ? "-cakedev-tabHeader-bottom" : "-cakedev-tabHeader-top";
					$tabControl.css("background-color", newTabControl.properties.bgcolor);

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

							newTabControl.tabs.push($tab);
						}
						
						if (newTabControl.properties.direction == "bottom") {
							$tabControl.append($tabHeadersContainer);
						}
						else {
							$tabControl.prepend($tabHeadersContainer);
						}
						
						$tabHeadersContainer.append("<table cellpadding='0px' cellspacing='0px'><tr>" + tabHeadersContent + "</tr></table>");

						var $tabHeaders = $tabHeadersContainer.find(".-cakedev-tabHeader");
						for (var i = 0; i < $tabHeaders.length; i++) {
							$tabHeaders.eq(i).click(function(){
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
								$currentTabControl.children(".-cakedev-tab").hide().eq(index).show();
							});
						}

						$tabHeadersContainer.find(".-cakedev-tabHeader").eq(0).addClass("-cakedev-selected-tab");
						$tabControl.children(".-cakedev-tab").not(":eq(0)").hide();
						
						cakedev.tabs.tabControls.push(newTabControl);
					}
				});
			},

			getCurrentTabControl: function() {
				for (var i = 0; i < cakedev.tabs.tabControls.length; i++) {
					var tab = cakedev.tabs.tabControls[i];
					if (tab.element.get(0) == this.get(0)) {
						return tab;
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
					return cakedev.combo.create.call(this, params);
				}
				else if (action == "getValue") {
					return cakedev.combo.getValue.call(this);
				}
				else if (action == "setValue") {
					return cakedev.combo.setValue.call(this, params);
				}
			}
		},

		tabs: function(action, params) {
			if (action) {
				if (action == "create") {
					return cakedev.tabs.create.call(this, params);
				}
			}
		}

	};

	$.fn.cakedev = function(method, action, params) {
		if (this.length) {
			if (method) {
				if (methods[method]) {
					return methods[method].call(this, action, params);
				}
				else {
					console.log("Method: '" + method + "' is not a valid method name.")
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
