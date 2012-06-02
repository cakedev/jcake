
/*
jCaKeDev 1.0
cakedevp.github.com/jcakedev
*/

(function() {
  var Combo, Slideshow, TabControl, Tooltip, cake;

  cake = {
    _init: function($) {
      $.fn.cake = function(plugin, action, params) {
        if (this.length) {
          if (plugin != null) {
            if (cake[plugin] != null) {
              return cake[plugin].invoke.call(this, action, params);
            } else {
              return console.log("plugin definition not found for '" + plugin + "'");
            }
          } else {
            return console.log("plugin name not specified");
          }
        }
      };
      return null;
    }
  };

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    cake._init(jQuery);
  } else {
    console.log("jQuery not found");
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

  cake.combo = {
    combos: [],
    invoke: function(action, params) {
      if (action != null) {
        if (cake.combo[action] != null) {
          return cake.combo[action].call(this, params);
        } else {
          console.log("'" + action + "' is not a valid action for combo");
          return this;
        }
      } else {
        return cake.combo.create.call(this, params);
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
        console.log("No options were defined for combo(s)");
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
        $combo.append("<table style='border-collapse: collapse;'>" + "<tr>" + ("<td class='-cakedev-combo-optionText'>" + selectedOption.text + "</td>") + "<td class='-cakedev-combo-arrow'><div class='-cakedev-arrow -cakedev-arrow-down-black'></div></td>" + "</tr>" + "</table>");
        $combo.append("<div class='-cakedev-combo-list-container'>" + ("<ul>" + optionsList + "</ul>") + "</div>");
        $combo.find("li").each(function(index) {
          $(this).on("click", function(event) {
            cake.combo.setValue.call($combo, combo.options[index].value);
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
        cake.combo.combos.push(combo);
        return true;
      });
    },
    setValue: function(value) {
      var $itemsParent, combo, i, index, opt, option, _len, _ref;
      combo = cake.combo.getCurrentElement.call(this);
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
      combo = cake.combo.getCurrentElement.call(this);
      if (combo != null) {
        return combo.options[combo.selectedIndex].value;
      } else {
        return null;
      }
    },
    getCurrentElement: function() {
      var combo, currentCombo, _i, _len, _ref;
      currentCombo = null;
      _ref = cake.combo.combos;
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
      this.bgcolor = null;
    }

    return TabControl;

  })();

  cake.tabs = {
    tabControls: [],
    invoke: function(action, params) {
      if (action != null) {
        if (cake.tabs[action] != null) {
          return cake.tabs[action].call(this, params);
        } else {
          console.log("'" + action + "' is not a valid action for tabs");
          return this;
        }
      } else {
        return cake.tabs.create.call(this, params);
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
        cake.tabs.tabControls.push(tabControl);
        if (params != null) {
          if (params.direction != null) tabControl.direction = params.direction;
          if (params.bgcolor != null) tabControl.bgcolor = params.bgcolor;
        }
        tabHeaderClass = tabControl.direction === "bottom" ? "-cakedev-tabHeader-bottom" : "-cakedev-tabHeader-top";
        if (tabControl.bgcolor != null) {
          $tabControl.css("background-color", tabControl.bgcolor);
        }
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
      tabControl = cake.tabs.getCurrentElement.call(this);
      if (tabControl != null) {
        return tabControl.currentTab;
      } else {
        return null;
      }
    },
    getCurrentElement: function() {
      var element, tab, _i, _len, _ref;
      element = null;
      _ref = cake.tabs.tabControls;
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

  Slideshow = (function() {

    function Slideshow(element) {
      this.element = element;
      this.slides = [];
      this.currentIndex = 0;
      this.animationSpeed = 400;
      this.autoNavigate = false;
      this.delay = 2000;
      this.rotate = true;
      this.animating = false;
    }

    return Slideshow;

  })();

  cake.slideshow = {
    slideshows: [],
    invoke: function(action, params) {
      if (action != null) {
        if (cake.slideshow[action] != null) {
          return cake.slideshow[action].call(this, params);
        } else {
          console.log("'" + action + "' is not a valid action for slideshow");
          return this;
        }
      } else {
        return cake.slideshow.create.call(this, params);
      }
    },
    create: function(params) {
      return this.each(function() {
        var $slide, $slides, $slideshow, disableNavigation, el, height, i, slideshow, width, _len;
        $slideshow = $(this);
        slideshow = new Slideshow($slideshow);
        disableNavigation = false;
        if (params != null) {
          if (params.height != null) {
            $slideshow.css("height", isNaN(params.height) ? params.height : "" + params.height + "px");
          }
          if (params.disableNavigation != null) {
            disableNavigation = params.disableNavigation;
          }
          if (params.rotate != null) slideshow.rotate = params.rotate;
          if (params.animationSpeed != null) {
            slideshow.animationSpeed = params.animationSpeed;
          }
          if (params.autoNavigate != null) {
            slideshow.autoNavigate = params.autoNavigate;
          }
          if (params.delay != null) slideshow.delay = params.delay;
        }
        $slides = $slideshow.children("div");
        slideshow.slides = $slides;
        cake.slideshow.slideshows.push(slideshow);
        if (!$slideshow.hasClass("-cakedev-slideshow")) {
          $slideshow.addClass("-cakedev-slideshow");
        }
        width = $slideshow.width();
        height = $slideshow.height();
        for (i = 0, _len = $slides.length; i < _len; i++) {
          el = $slides[i];
          $slide = $slides.eq(i);
          if (!$slide.hasClass("-cakedev-slideshow-slide")) {
            $slide.addClass("-cakedev-slideshow-slide");
          }
          $slide.css("height", "" + height + "px");
          $slide.css("width", "" + width + "px");
          $slide.css("top", "-" + (i * height) + "px");
          if (i > 0) $slide.css("margin-left", width);
        }
        if (!disableNavigation) {
          cake.slideshow.setNavigationControls(slideshow, width, height);
        }
        if (slideshow.autoNavigate) cake.slideshow.setAutoNavigation(slideshow);
        return true;
      });
    },
    setNavigationControls: function(slideshow, width, height) {
      var $arrowleft, $arrowright, $slides, $slideshow;
      $slideshow = slideshow.element;
      $slides = slideshow.slides;
      $arrowleft = $("<div class='-cakedev-slideshow-arrowleft'></div>");
      $arrowright = $("<div class='-cakedev-slideshow-arrowright'></div>");
      $slideshow.append($arrowleft);
      $slideshow.append($arrowright);
      $arrowleft.css("left", "10px");
      $arrowleft.css("top", "-" + (height * $slides.length - parseInt(height / 2, 10) + parseInt($arrowleft.height() / 2, 10)) + "px");
      $arrowright.css("left", (width - $arrowright.width() - 10) + "px");
      $arrowright.css("top", "-" + (height * $slides.length - parseInt(height / 2, 10) + parseInt($arrowright.height() / 2, 10) + $arrowleft.height()) + "px");
      $arrowleft.on("click", function() {
        slideshow.autoNavigate = false;
        return cake.slideshow.movePrevious.call(slideshow.element);
      });
      $arrowright.on("click", function() {
        slideshow.autoNavigate = false;
        return cake.slideshow.moveNext.call(slideshow.element);
      });
      return true;
    },
    setAutoNavigation: function(slideshow) {
      return cake.slideshow.autoNavigate(slideshow);
    },
    autoNavigate: function(slideshow) {
      setTimeout(function() {
        if (slideshow.autoNavigate) {
          return cake.slideshow.moveNext.call(slideshow.element, function() {
            return cake.slideshow.autoNavigate(slideshow);
          });
        }
      }, slideshow.delay);
      return true;
    },
    moveNext: function(callback, animationSpeed) {
      var slideshow, speed;
      slideshow = cake.slideshow.getCurrentElement.call(this);
      if (slideshow != null) {
        if (slideshow.animating) return;
        if (slideshow.slides.length > 1) {
          speed = animationSpeed != null ? animationSpeed : slideshow.animationSpeed;
          if (slideshow.currentIndex === slideshow.slides.length - 1) {
            if (slideshow.rotate) {
              speed = Math.round(speed / slideshow.slides.length) + 100;
              cake.slideshow.moveToFirst(slideshow, speed, callback);
            }
          } else {
            slideshow.animating = true;
            cake.slideshow.changeSlide(slideshow.slides.eq(slideshow.currentIndex), slideshow.slides.eq(slideshow.currentIndex + 1), speed, "f", function() {
              slideshow.animating = false;
              slideshow.currentIndex++;
              if (typeof callback === "function") return callback();
            });
          }
        }
      }
      return true;
    },
    movePrevious: function(callback, animationSpeed) {
      var slideshow, speed;
      slideshow = cake.slideshow.getCurrentElement.call(this);
      if (slideshow != null) {
        if (slideshow.animating) return;
        if (slideshow.slides.length > 1) {
          speed = animationSpeed != null ? animationSpeed : slideshow.animationSpeed;
          if (slideshow.currentIndex === 0) {
            if (slideshow.rotate) {
              speed = Math.round(speed / slideshow.slides.length) + 100;
              cake.slideshow.moveToLast(slideshow, speed, callback);
            }
          } else {
            slideshow.animating = true;
            cake.slideshow.changeSlide(slideshow.slides.eq(slideshow.currentIndex), slideshow.slides.eq(slideshow.currentIndex - 1), speed, "b", function() {
              slideshow.animating = false;
              slideshow.currentIndex--;
              if (typeof callback === "function") return callback();
            });
          }
        }
      }
      return true;
    },
    moveToFirst: function(slideshow, slideAnimationSpeed, callback) {
      if (slideshow.currentIndex > 0) {
        cake.slideshow.movePrevious.call(slideshow.element, function() {
          return cake.slideshow.moveToFirst(slideshow, slideAnimationSpeed, callback);
        }, slideAnimationSpeed);
      } else {
        if (typeof callback === "function") callback();
      }
      return true;
    },
    moveToLast: function(slideshow, slideAnimationSpeed, callback) {
      if (slideshow.currentIndex < slideshow.slides.length - 1) {
        cake.slideshow.moveNext.call(slideshow.element, function() {
          return cake.slideshow.moveToLast(slideshow, slideAnimationSpeed, callback);
        }, slideAnimationSpeed);
      } else {
        if (typeof callback === "function") callback();
      }
      return true;
    },
    changeSlide: function($current, $new, speed, direction, callback) {
      $current.css("z-index", 990);
      $new.css("z-index", 991);
      $new.animate({
        marginLeft: "0px"
      }, speed, "linear", function() {
        if (typeof callback === "function") return callback();
      });
      if (direction === "f") {
        $current.animate({
          marginLeft: "-" + ($current.width()) + "px"
        }, speed, "linear");
      } else if (direction === "b") {
        $current.animate({
          marginLeft: "" + ($current.width()) + "px"
        }, speed, "linear");
      }
      return true;
    },
    getCurrentElement: function() {
      var currentSlideshow, slideshow, _i, _len, _ref;
      currentSlideshow = null;
      _ref = cake.slideshow.slideshows;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        slideshow = _ref[_i];
        if (slideshow.element.get(0) === this.get(0)) currentSlideshow = slideshow;
      }
      return currentSlideshow;
    }
  };

  Tooltip = (function() {

    function Tooltip(element, text, direction) {
      this.element = element;
      this.text = text;
      this.direction = direction;
    }

    return Tooltip;

  })();

  cake.tooltip = {
    tooltips: [],
    defaultDirection: "bottom",
    horizontalMargin: 10,
    verticalMargin: 6,
    invoke: function(action, params) {
      if (action != null) {
        if (cake.tooltip[action] != null) {
          return cake.tooltip[action].call(this, params);
        } else {
          console.log("" + action + " is not a valid action for tooltip");
          return this;
        }
      } else {
        return cake.tooltip.create.call(this, params);
      }
    },
    create: function(params) {
      var $element, direction, text, tooltip;
      text = params.text != null ? params.text : "";
      direction = params.direction != null ? params.direction : this.defaultDirection;
      $element = $("<div class='-cakedev-tooltip'><p></p><span class='-cakedev-arrow'></span></div>");
      $("body").append($element);
      tooltip = new Tooltip($element, text, direction);
      cake.tooltip.tooltips.push(tooltip);
      return this.each(function() {
        $(this).on("mouseenter", function() {
          return cake.tooltip.setTooltip($(this), tooltip);
        });
        return $(this).on("mouseout", function() {
          return $element.hide();
        });
      });
    },
    setTooltip: function($target, tooltip) {
      var $element, fn;
      $element = tooltip.element;
      $element.children("p").text(tooltip.text);
      fn = null;
      switch (tooltip.direction) {
        case "left":
          fn = this.setToLeft;
          break;
        case "right":
          fn = this.setToRight;
          break;
        case "top":
          fn = this.setToTop;
          break;
        default:
          fn = this.setToBottom;
      }
      return fn.call(this, $target, $element);
    },
    setToTop: function($target, $element) {
      var left, top;
      $element.children(".-cakedev-arrow").addClass("-cakedev-arrow-down-black");
      top = $target.offset().top - $element.outerHeight() - this.verticalMargin;
      left = $target.offset().left + parseInt($target.outerWidth() / 2, 10) - parseInt($element.outerWidth() / 2, 10);
      return this.show($element, top, left);
    },
    setToRight: function($target, $element) {
      var left, top;
      $element.children(".-cakedev-arrow").addClass("-cakedev-arrow-left-black");
      top = $target.offset().top + parseInt($target.outerHeight() / 2, 10) - parseInt($element.outerHeight() / 2, 10);
      left = $target.offset().left + $target.outerWidth() + this.horizontalMargin;
      return this.show($element, top, left);
    },
    setToBottom: function($target, $element) {
      var left, top;
      $element.children(".-cakedev-arrow").addClass("-cakedev-arrow-up-black");
      top = $target.offset().top + $target.outerHeight() + this.verticalMargin;
      left = $target.offset().left + parseInt($target.outerWidth() / 2, 10) - parseInt($element.outerWidth() / 2, 10);
      return this.show($element, top, left);
    },
    setToLeft: function($target, $element) {
      var left, top;
      $element.children(".-cakedev-arrow").addClass("-cakedev-arrow-right-black");
      top = $target.offset().top + parseInt($target.outerHeight() / 2, 10) - parseInt($element.outerHeight() / 2, 10);
      left = $target.offset().left - $element.outerWidth() - this.horizontalMargin;
      return this.show($element, top, left);
    },
    show: function($element, top, left) {
      $element.css("top", top + "px");
      $element.css("left", left + "px");
      return $element.show();
    }
  };

}).call(this);
