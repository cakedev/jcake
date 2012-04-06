jcakedev =
  _init: ($) ->
    plugins =
      combo: (action, params) ->
        throw "plugin definition not found exception (combo)" if not jcakedev.combo?
        jcakedev.combo.invoke.call @, action, params

      tabs: (action, params) ->
        throw "plugin definition not found exception (tabs)" if not jcakedev.tabs?
        jcakedev.tabs.invoke.call @, action, params

      slideshow: (action, params) ->
        throw "plugin definition not found exception (slideshow)" if not jcakedev.slideshow?
        jcakedev.slideshow.call @, action, params

    $.fn.jcakedev = (plugin, action, params) ->
      if @length
        if plugin? and plugins[plugin]?
            plugins[plugin].call @, action, params
        else
          throw "invalid plugin name exception"
    null

if jQuery?
  jcakedev._init jQuery
else
  throw "jQuery not found exception"
