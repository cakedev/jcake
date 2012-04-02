jcakedev =
  _init: ($) ->
    plugins =
      combo: (action, params) ->
        throw "plugin definition not found exception (combo)" if not jcakedev.combo?
        jcakedev.combo.invoke.call this, action, params

      tabs: (action, params) ->
        throw "plugin definition not found exception (tabs)" if not jcakedev.tabs?
        jcakedev.combo.invoke.call this, action, params

      slideshow: (action, params) ->
        throw "plugin definition not found exception (slideshow)" if not jcakedev.slideshow?
        jcakedev.slideshow.call this, action, params

    $.fn.jcakedev = (plugin, action, params) ->
      if this.length
        if plugin?
          if plugins[plugin]?
            plugins[plugin].call this, action, params
          else
            console.log "'#{plugin}' is not a valid plugin name"
        else
          console.log "no plugin name was specified"
    0

if jQuery?
  jcakedev._init jQuery
else
  throw "jQuery not found"
