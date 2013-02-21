jcake.plugins.attachable =
  pluginManager: null  

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeAttach = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "setDirection"
            pm.notify "Not implemented yet"
          else
            pm.notify "'#{action}' is not a valid action for cakeAttach"
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

  for cmp in jcake.components
    if not (cmp instanceof Attachable)
      continue

    $el = cmp.el

    if not $el.hasClass("jcake-attachable") and scrollTop > (cmp.top - cmp.margin)
      cmp.originalWidth = $el.width "width"
      cmp.originalHeigh = $el.css "height"

      $el.css "width", $el.width()
      $el.css "height", $el.height()

      $el.addClass "jcake-attachable"
      $el.after "<div class='jcake-dummy' style='height: #{$el.outerHeight()}px; width: #{$el.outerWidth()}px;'></div>"
    else if $el.hasClass("jcake-attachable") and scrollTop <= (cmp.top - cmp.margin)
      $el.removeClass "jcake-attachable"

      $el.parent().children(".jcake-dummy").remove()
      $el.css "width", cmp.originalWidth
      $el.css "height", cmp.originalHeigh

    if $el.hasClass "jcake-attachable"
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
