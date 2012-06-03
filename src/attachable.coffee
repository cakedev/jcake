class Attachable
  constructor: (@element, @top, @left, @direction, @margin) ->

cake.attachable =
  attachables: []
  defaultDirection: "top"
  defaultMargin: 0

  invoke: (action, params) ->
    if action?
      if cake.attachable[action]?
        return cake.attachable[action].call @, params
      else
        console.log "#{action} is not a valid action for attachable"
        return @
    else
      return cake.attachable.create.call @, params

  create: (params) ->
    direction = cake.attachable.defaultDirection
    margin = cake.attachable.defaultMargin

    if params?
      direction = params.direction or direction
      margin = params.margin or margin

    @.each ->
      $el = $(@)
      $el.css "z-index", if params? and params.zIndex? then params.zIndex else $el.css "z-index"
      attachable = new Attachable $el, $el.offset().top, $el.offset().left, direction, margin
      cake.attachable.attachables.push attachable

$(document).on "scroll", ->
  scrollTop = $(window).scrollTop()

  for attachable in cake.attachable.attachables
    $el = attachable.element

    if not $el.hasClass("-cakedev-attachable") and scrollTop > (attachable.top - attachable.margin)
      $el.addClass "-cakedev-attachable"
      $el.after "<div class='-cakedev-dummy' style='height: #{$el.outerHeight()}px; width: #{$el.outerWidth()}px;'></div>"
    else if $el.hasClass("-cakedev-attachable") and scrollTop <= (attachable.top - attachable.margin)
      $el.removeClass "-cakedev-attachable"
      $el.parent().children(".-cakedev-dummy").remove()

    if $el.hasClass "-cakedev-attachable"
      $el.css "top", attachable.top
      $el.css "left", attachable.left

      if attachable.direction is "top"
        $el.css "top", "#{attachable.margin}px"
      else
        $el.css "margin-bottom", "#{attachable.margin}px"
    else
      $el.css "top", "auto"
      $el.css "left", "auto"

  true
