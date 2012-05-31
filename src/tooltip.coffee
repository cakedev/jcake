class Tooltip
  constructor: (@element, @text, @direction) ->

cake.tooltip =
  tooltips: []

  defaultDirection: "bottom"
  horizontalMargin: 10
  verticalMargin: 6

  invoke: (action, params) ->
    if action?
      if cake.tooltip[action]?
        return cake.tooltip[action].call @, params
      else
        console.log "#{action} is not a valid action for tooltip"
        return @
    else
      return cake.tooltip.create.call @, params

  create: (params) ->
    text = if params.text? then params.text else ""
    direction = if params.direction? then params.direction else @.defaultDirection

    $element = $ "<div class='-cakedev-tooltip'><p></p><span class='-cakedev-arrow'></span></div>"
    $("body").append $element

    tooltip = new Tooltip $element, text, direction
    cake.tooltip.tooltips.push tooltip

    @.each ->
      $(@).on "mouseenter", ->
        cake.tooltip.setTooltip $(@), tooltip

      $(@).on "mouseout", ->
        $element.hide()

  setTooltip: ($target, tooltip) ->
    $element = tooltip.element
    $element.children("p").text tooltip.text
    fn = null

    switch tooltip.direction
      when "left" then fn = @.setToLeft
      when "right" then fn = @.setToRight
      when "top" then fn = @.setToTop
      else fn = @.setToBottom

    fn.call @, $target, $element

  setToTop: ($target, $element) ->
    $element.children(".-cakedev-arrow").addClass "-cakedev-arrow-down-black"

    top = $target.offset().top - $element.outerHeight() - @.verticalMargin
    left = $target.offset().left + parseInt($target.outerWidth() / 2, 10) - parseInt($element.outerWidth() / 2, 10)

    @.show $element, top, left

  setToRight: ($target, $element) ->
    $element.children(".-cakedev-arrow").addClass "-cakedev-arrow-left-black"

    top = $target.offset().top + parseInt($target.outerHeight() / 2, 10) - parseInt($element.outerHeight() / 2, 10)
    left = $target.offset().left + $target.outerWidth() + @.horizontalMargin

    @.show $element, top, left

  setToBottom: ($target, $element) ->
    $element.children(".-cakedev-arrow").addClass "-cakedev-arrow-up-black"

    top = $target.offset().top + $target.outerHeight() + @.verticalMargin
    left = $target.offset().left + parseInt($target.outerWidth() / 2, 10) - parseInt($element.outerWidth() / 2, 10)
    
    @.show $element, top, left

  setToLeft: ($target, $element) ->
    $element.children(".-cakedev-arrow").addClass "-cakedev-arrow-right-black"

    top = $target.offset().top + parseInt($target.outerHeight() / 2, 10) - parseInt($element.outerHeight() / 2, 10)
    left = $target.offset().left - $element.outerWidth() - @.horizontalMargin

    @.show $element, top, left

  show: ($element, top, left) ->
    $element.css("top", top + "px");
    $element.css("left", left + "px");
    $element.show()
