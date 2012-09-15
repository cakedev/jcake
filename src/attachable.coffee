jcakedev.plugins.attachable =
  pluginManager: null  

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeAttach = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "setDirection"
            @pm.notify "Not implemented yet"
          else
            @pm.notify "'#{action}' is not a valid action for cakeAttach"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    direction = if params.direction? then params.direction else "top"
    margin = if params.margin? then params.margin else 0
    zIndex = if params.zIndex? then params.zIndex else "auto"

    $obj.each ->
      attachable = new Attachable $(@), direction, margin, zIndex
      me.pluginManager.addComponent attachable

class Attachable
  constructor: (@el, @direction, @margin, @zIndex) ->
    @el.css "z-index", this.zIndex

    this.top = @el.offset().top
    this.left = @el.offset().left

$(document).on "scroll", ->
  scrollTop = $(window).scrollTop()

  for cmp in jcakedev.components
    if not (cmp instanceof Attachable)
      continue

    $el = cmp.el

    if not $el.hasClass("-cakedev-attachable") and scrollTop > (cmp.top - cmp.margin)
      $el.addClass "-cakedev-attachable"
      $el.after "<div class='-cakedev-dummy' style='height: #{$el.outerHeight()}px; width: #{$el.outerWidth()}px;'></div>"
    else if $el.hasClass("-cakedev-attachable") and scrollTop <= (cmp.top - cmp.margin)
      $el.removeClass "-cakedev-attachable"
      $el.parent().children(".-cakedev-dummy").remove()

    if $el.hasClass "-cakedev-attachable"
      $el.css "top", cmp.top
      $el.css "left", cmp.left

      if cmp.direction is "top"
        $el.css "top", "#{cmp.margin}px"
      else
        $el.css "margin-bottom", "#{cmp.margin}px"
    else
      $el.css "top", "auto"
      $el.css "left", "auto"

  true
