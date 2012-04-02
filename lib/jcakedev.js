(function() {
  var jcakedev;

  jcakedev = {
    _init: function($) {
      var plugins;
      plugins = {
        combo: function(action, params) {
          if (!(jcakedev.combo != null)) {
            throw "plugin definition not found exception (combo)";
          }
          return jcakedev.combo.invoke.call(this, action, params);
        },
        tabs: function(action, params) {
          if (!(jcakedev.tabs != null)) {
            throw "plugin definition not found exception (tabs)";
          }
          return jcakedev.combo.invoke.call(this, action, params);
        },
        slideshow: function(action, params) {
          if (!(jcakedev.slideshow != null)) {
            throw "plugin definition not found exception (slideshow)";
          }
          return jcakedev.slideshow.call(this, action, params);
        }
      };
      $.fn.jcakedev = function(plugin, action, params) {
        if (this.length) {
          if (plugin != null) {
            if (plugins[plugin] != null) {
              return plugins[plugin].call(this, action, params);
            } else {
              return console.log("'" + plugin + "' is not a valid plugin name");
            }
          } else {
            return console.log("no plugin name was specified");
          }
        }
      };
      return 0;
    }
  };

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jcakedev._init(jQuery);
  } else {
    throw "jQuery not found";
  }

  jcakedev.tabs = {
    invoke: function(action, params) {
      if (action != null) {
        return 0;
      } else {
        return jcakedev.tabs.create.call(this, params);
      }
    }
  };

}).call(this);
