jcake.plugin(
  "cakeTooltip"
  []
  ($el, props) ->
    props = if props? then props else {}
    
    text = if props.text? then props.text else ""
    direction = if props.direction? then props.direction else "bottom"
    hMargin = if props.hMargin? then props.hMargin else 10
    vMargin = if props.vMargin? then props.vMargin else 6
    animate = if props.animate? then props.animate else yes
    animationSpeed = if props.animationSpeed? then props.animationSpeed else 200

    return new Tooltip $el, text, direction, hMargin, vMargin, animate, animationSpeed
  ->
    $(".x-jcake-tooltip").each ->
      $el = $ @

      $el.cakeTooltip
        text: $el.data "text"
        direction: $el.data "direction"
        hMargin: $el.data "hMargin"
        vMargin: $el.data "vMargin"
        animate: $el.data "animate"
        animationSpeed: $el.data "animationSpeed"
)

class Tooltip
  constructor: (@el, @text, @direction, @hMargin, @vMargin, @animate, @animationSpeed) ->
    me = @

    @el.on "mouseenter", ->
      me.show()

    @el.on "mouseleave", ->
      me.hide()

  animationMargin: 25,

  setText: (text) ->
    @text = text
    @setTooltipText()

  setTooltipText: ->
    @tooltip.children("p").text @text

  setDirection: (direction) ->
    @direction = direction
    @setTooltipDirection()

  setTooltipDirection: ->
    $arrow = @tooltip.children "span"
    $arrow.removeClass().addClass "jcake-icon jcake-arrow"

    switch @direction
      when "left"
        $arrow.addClass "jcake-arrow-right-black"
        @setToLeft()
      when "right"
        $arrow.addClass "jcake-arrow-left-black"
        @setToRight()
      when "top"
        $arrow.addClass "jcake-arrow-down-black"
        @setToTop()
      else
        $arrow.addClass "jcake-arrow-up-black"
        @setToBottom()

  show: ->
    if not @tooltip?
      @tooltip = $ "<div class='jcake-tooltip'><p /><span /></div>"
      $("body").append @tooltip

    @setTooltipText()
    @setTooltipDirection()

  hide: ->
    if @animate
      me = @

      @tooltip.stop()
      @tooltip.animate { opacity: 0 }, @animationSpeed, ->
        $(@).remove()
        me.tooltip = null
    else
      @tooltip.remove()
      @tooltip = null

  setToTop: ->
    top = @el.offset().top - @tooltip.outerHeight() - @vMargin
    left = @el.offset().left + parseInt(@el.outerWidth() / 2, 10) - parseInt(@tooltip.outerWidth() / 2, 10)
    @tooltip.css "margin-top", "-#{@animationMargin}px"

    @showTooltip top, left

  setToRight: ->
    top = @el.offset().top + parseInt(@el.outerHeight() / 2, 10) - parseInt(@tooltip.outerHeight() / 2, 10)
    left = @el.offset().left + @el.outerWidth() + @hMargin
    @tooltip.css "margin-left", "#{@animationMargin}px"

    @showTooltip top, left

  setToBottom: ->
    top = @el.offset().top + @el.outerHeight() + @vMargin
    left = @el.offset().left + parseInt(@el.outerWidth() / 2, 10) - parseInt(@tooltip.outerWidth() / 2, 10)
    @tooltip.css "margin-top", "#{@animationMargin}px"
    
    @showTooltip top, left

  setToLeft: ->
    top = @el.offset().top + parseInt(@el.outerHeight() / 2, 10) - parseInt(@tooltip.outerHeight() / 2, 10)
    left = @el.offset().left - @tooltip.outerWidth() - @hMargin
    @tooltip.css "margin-left", "-#{@animationMargin}px"

    @showTooltip top, left

  showTooltip: (top, left) ->
    @tooltip.css { top: "#{top}px", left: "#{left}px" }

    visibleProperties = { opacity: 1, margin: "0px" }

    if @animate
      @tooltip.stop().animate visibleProperties, @animationSpeed
    else
      @tooltip.css(visibleProperties).show()
