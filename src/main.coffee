cake =
  _init: ($) ->
    $.fn.cake = (plugin, action, params) ->
      if @length
        if plugin?
          if cake[plugin]?
            cake[plugin].invoke.call @, action, params
          else
            console.log "plugin definition not found for '#{plugin}'"
        else
          console.log "plugin name not specified"
    null

if jQuery?
  cake._init jQuery
else
  throw "jQuery not found exception"
