jcakedev =
  _init: ($) ->
    $.fn.jcakedev = (plugin, action, params) ->
      if @length
        if plugin?
          if jcakedev[plugin]?
            jcakedev[plugin].invoke.call @, action, params
          else
            console.log "plugin definition not found for '#{plugin}'"
        else
          console.log "plugin name not specified"
    null

if jQuery?
  jcakedev._init jQuery
else
  throw "jQuery not found exception"
