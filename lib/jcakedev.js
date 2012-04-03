(function() {
  var TabControl, jcakedev;

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
          return jcakedev.tabs.invoke.call(this, action, params);
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
          if ((plugin != null) && (plugins[plugin] != null)) {
            return plugins[plugin].call(this, action, params);
          } else {
            throw "invalid plugin name exception";
          }
        }
      };
      return null;
    }
  };

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    jcakedev._init(jQuery);
  } else {
    throw "jQuery not found exception";
  }

  TabControl = (function() {

    function TabControl(element) {
      this.element = element;
      this.tabs = [];
      this.currentTab = null;
      this.direction = "top";
      this.bgcolor = "#3c78b5";
    }

    return TabControl;

  })();

  jcakedev.tabs = {
    tabControls: [],
    invoke: function(action, params) {
      if (action != null) {
        if (action === "create") {
          return jcakedev.tabs.create.call(this, params);
        } else if (action === "getActiveTab") {
          return jcakedev.tabs.getActiveTab.call(this);
        } else {
          throw "'" + action + "' is not a valid action for tabs";
        }
      } else {
        return jcakedev.tabs.create.call(this, params);
      }
    },
    create: function(params) {
      return this.each(function() {
        var $tab, $tabControl, $tabHeaders, $tabHeadersContainer, $tabs, el, i, tabControl, tabHeaderClass, tabHeadersContent, tabTitle, _len, _len2;
        $tabControl = $(this);
        if (!$tabControl.hasClass("-cakedev-tabs")) {
          $tabControl.addClass("-cakedev-tabs");
        }
        tabControl = new TabControl($tabControl);
        jcakedev.tabs.tabControls.push(tabControl);
        if (params != null) {
          if (params.direction != null) tabControl.direction = params.direction;
          if (params.bgcolor != null) tabControl.bgcolor = params.bgcolor;
        }
        tabHeaderClass = tabControl.direction === "bottom" ? "-cakedev-tabHeader-bottom" : "-cakedev-tabHeader-top";
        $tabControl.css("background-color", tabControl.bgcolor);
        $tabHeadersContainer = $("<div class='-cakedev-tabHeaders-container'></div>'");
        $tabs = $tabControl.children("div");
        if ($tabs.length) {
          tabHeadersContent = "";
          for (i = 0, _len = $tabs.length; i < _len; i++) {
            el = $tabs[i];
            $tab = $tabs.eq(i);
            if (!$tab.hasClass("-cakedev-tab")) $tab.addClass("-cakedev-tab");
            tabTitle = $tab.attr("title") ? $tab.attr("title") : i;
            $tab.removeAttr("title");
            tabHeadersContent += "<td><span class='-cakedev-tabHeader " + tabHeaderClass + "'>" + tabTitle + "</span></td>";
            tabControl.tabs.push($tab);
          }
          if (tabControl.direction === "bottom") {
            $tabControl.append($tabHeadersContainer);
          } else {
            $tabControl.prepend($tabHeadersContainer);
          }
          $tabHeadersContainer.append("<table><tr>" + tabHeadersContent + "</tr></table>");
          $tabHeaders = $tabHeadersContainer.find(".-cakedev-tabHeader");
          for (i = 0, _len2 = $tabHeaders.length; i < _len2; i++) {
            el = $tabHeaders[i];
            $tabHeaders.eq(i).on("click", function() {
              var $currentTab, $currentTabControl, $headers, $headersContainer, el, index, j, _len3;
              $currentTabControl = $(this).closest(".-cakedev-tabs");
              $headersContainer = $(this).closest(".-cakedev-tabHeaders-container");
              index = 0;
              $headers = $headersContainer.find(".-cakedev-tabHeader");
              for (j = 0, _len3 = $headers.length; j < _len3; j++) {
                el = $headers[j];
                if ($headers.eq(j).get(0) === $(this).get(0)) {
                  index = j;
                  break;
                }
              }
              $headers.removeClass("-cakedev-selected-tab").eq(index).addClass("-cakedev-selected-tab");
              $currentTabControl.children(".-cakedev-tab").hide();
              $currentTab = $currentTabControl.children(".-cakedev-tab").eq(index).show();
              tabControl.currentTab = $currentTab;
              return true;
            });
          }
          $tabHeadersContainer.find(".-cakedev-tabHeader").eq(0).addClass("-cakedev-selected-tab");
          $tabControl.children(".-cakedev-tab").not(":eq(0)").hide();
          return tabControl.currentTab = $tabControl.children(".-cakedev-tab").eq(0);
        }
      });
    },
    getActiveTab: function() {
      var tabControl;
      tabControl = jcakedev.tabs.getCurrentElement.call(this);
      if (tabControl != null) {
        return tabControl.currentTab;
      } else {
        return null;
      }
    },
    getCurrentElement: function() {
      var element, tab, _i, _len, _ref;
      element = null;
      _ref = jcakedev.tabs.tabControls;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tab = _ref[_i];
        if (tab.element.get(0) === this.get(0)) {
          element = tab;
          break;
        }
      }
      return element;
    }
  };

}).call(this);
