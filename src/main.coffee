jcakedev =
  _init: ($) ->
    plugins =
      combo: (action, params) ->
        throw "plugin definition not found exception (combo)" if not jcakedev.combo?
        jcakedev.combo.invoke.call this, action, params

      tabs: (action, params) ->
        throw "plugin definition not found exception (tabs)" if not jcakedev.tabs?
        jcakedev.tabs.invoke.call this, action, params

      slideshow: (action, params) ->
        throw "plugin definition not found exception (slideshow)" if not jcakedev.slideshow?
        jcakedev.slideshow.call this, action, params

    $.fn.jcakedev = (plugin, action, params) ->
      if this.length
        if plugin? and plugins[plugin]?
            plugins[plugin].call this, action, params
        else
          throw "invalid plugin name exception"
    null

if jQuery?
  jcakedev._init jQuery
else
  throw "jQuery not found exception"
