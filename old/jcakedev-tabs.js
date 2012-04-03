jcakedev.tabs = {

	tabControls: [],

	invoke: function(action, params) {
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
	
};
