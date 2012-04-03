var jcakedev = {};

(function($){

	var plugins = {
		
		combo: function(action, params) {
			if (!jcakedev.combo) {
				throw "plugin definition not found exception (combo)";
			}

			jcakedev.combo.invoke.call(this, action, params);
		},

		tabs: function(action, params) {
			if (!jcakedev.tabs) {
				throw "plugin definition not found exception (tabs)";
			}

			jcakedev.tabs.invoke.call(this, action, params);
		},

		slideshow: function(action, params) {
			if (!jcakedev.slideshow) {
				throw "plugin definition not found exception (slideshow)";
			}
			
			jcakedev.slideshow.invoke.call(this, action, params);
		}

	};

	$.fn.jcakedev = function(plugin, action, params) {
		if (this.length) {
			if (plugin) {
				if (plugins[plugin]) {
					return plugins[plugin].call(this, action, params);
				}
				else {
					console.log("'" + plugin + "' is not a valid plugin name")
				}
			}
			else {
				console.log("no plugin name was specified")
			}
		}
	};

}) (jQuery);
