(function() {
  var Combo, TabControl, jcakedev;

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

  Combo = (function() {

    function Combo(element, options, delegate) {
      this.element = element;
      this.options = options;
      this.delegate = delegate;
      this.selectedIndex = 0;
    }

    return Combo;

  })();

  jcakedev.combo = {
    combos: [],
    invoke: function(action, params) {
      if (action != null) {
        if (action === "create") {
          return jcakedev.combo.create.call(this, params);
        } else if (action === "getValue") {
          return jcakedev.combo.getValue.call(this);
        } else if (action === "setValue") {
          return jcakedev.combo.setValue.call(this, params);
        } else {
          throw "'" + action + "' is not a valid action for combo";
        }
      } else {
        return jcakedev.combo.create.call(this, params);
      }
    },
    create: function(params) {
      var defaultValue, delegate, options;
      options = [];
      delegate = null;
      defaultValue = null;
      if ((params != null) && (params.options != null) && params.options.length) {
        options = params.options;
        delegate = params.delegate;
        defaultValue = params.defaultValue;
      } else {
        throw "No options defined for combo(s) exception";
      }
      return this.each(function() {
        var $combo, $list, combo, i, option, optionsList, selectedOption, selectedOptionIndex, _len;
        $combo = $(this);
        if (!$combo.hasClass("-cakedev-custom-combo")) {
          $combo.addClass("-cakedev-custom-combo");
        }
        combo = new Combo($combo, options, delegate);
        selectedOptionIndex = 0;
        optionsList = "";
        for (i = 0, _len = options.length; i < _len; i++) {
          option = options[i];
          if ((defaultValue != null) && option.value === defaultValue) {
            selectedOptionIndex = i;
          }
          optionsList += "<li class='-cakedev-combo-option-" + i + "'>" + option.text + "</li>";
        }
        combo.selectedIndex = selectedOptionIndex;
        selectedOption = options[selectedOptionIndex];
        $combo.append("<table style='border-collapse: collapse;'>" + "<tr>" + ("<td class='-cakedev-combo-optionText'>" + selectedOption.text + "</td>") + "<td class='-cakedev-combo-arrow'><div></div></td>" + "</tr>" + "</table>");
        $combo.append("<div class='-cakedev-combo-list-container'>" + ("<ul>" + optionsList + "</ul>") + "</div>");
        $combo.find("li").each(function(index) {
          $(this).on("click", function(event) {
            jcakedev.combo.setValue.call($combo, combo.options[index].value);
            if (typeof combo.delegate === "function") {
              combo.delegate(combo.options[index], $combo);
            } else {
              console.log("Delegate is not a valid function");
            }
            return true;
          });
          return true;
        });
        $combo.find(".-cakedev-combo-option-" + selectedOptionIndex).hide();
        $list = $combo.find(".-cakedev-combo-list-container").hide();
        $combo.find("table").on("click", function() {
          if ($list.is(":visible")) {
            $list.hide();
          } else {
            $list.show();
          }
          return true;
        });
        jcakedev.combo.combos.push(combo);
        return true;
      });
    },
    setValue: function(value) {
      var $itemsParent, combo, i, index, opt, option, _len, _ref;
      combo = jcakedev.combo.getCurrentElement.call(this);
      if (combo != null) {
        index = 0;
        option = null;
        _ref = combo.options;
        for (i = 0, _len = _ref.length; i < _len; i++) {
          opt = _ref[i];
          if (opt.value === value) {
            option = opt;
            index = i;
          }
        }
        if (option != null) {
          this.find(".-cakedev-combo-optionText").html(option.text);
          $itemsParent = this.find("ul");
          $itemsParent.children("li").show();
          $itemsParent.children("li").filter(".-cakedev-combo-option-" + index).hide();
          combo.selectedIndex = index;
        }
      }
      return this;
    },
    getValue: function() {
      var combo;
      combo = jcakedev.combo.getCurrentElement.call(this);
      if (combo != null) {
        return combo.options[combo.selectedIndex].value;
      } else {
        return null;
      }
    },
    getCurrentElement: function() {
      var combo, currentCombo, _i, _len, _ref;
      currentCombo = null;
      _ref = jcakedev.combo.combos;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        combo = _ref[_i];
        if (combo.element.get(0) === this.get(0)) currentCombo = combo;
      }
      return currentCombo;
    }
  };

  $(document).ready(function() {
    $(document).on("click", function(event) {
      if (!$(event.target).closest(".-cakedev-custom-combo table").length) {
        $(".-cakedev-custom-combo .-cakedev-combo-list-container").hide();
      }
      return true;
    });
    return true;
  });

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
          tabControl.currentTab = $tabControl.children(".-cakedev-tab").eq(0);
        }
        return true;
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
