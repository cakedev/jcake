jcakedev.plugins.tooltip =
  pluginManager: null  

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTooltip = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "setText"
            pm.notify "Not implemented yet"
          else
            pm.notify "'#{action}' is not a valid action for cakeTooltip"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    text = if params.text? then params.text else ""
    direction = if params.direction? then params.direction else "bottom"
    hMargin = if params.hMargin? then params.hMargin else 10
    vMargin = if params.vMargin? then params.vMargin else 6
    animate = if params.animate? then params.animate else yes
    animationSpeed = if params.animationSpeed? then params.animationSpeed else 150

    $obj.each ->
      tooltip = new Tooltip $(@), text, direction, hMargin, vMargin, animate, animationSpeed
      me.pluginManager.addComponent tooltip

class Tooltip
  constructor: (@el, @text, @direction, @hMargin, @vMargin, @animate, @animationSpeed) ->
    me = @

    @el.on "mouseenter", ->
      me.show()

    @el.on "mouseleave", ->
      me.hide()

  setText: (text) ->
    @tooltip.children("p").text text

  setDirection: (direction) ->
    @direction = direction

    $arrow = @tooltip.children "span"
    $arrow.removeClass()
    $arrow.addClass "-cakedev-arrow"

    switch direction
      when "left" then $arrow.addClass "-cakedev-arrow-right-black"
      when "right" then $arrow.addClass "-cakedev-arrow-left-black"
      when "top" then $arrow.addClass "-cakedev-arrow-down-black"
      else $arrow.addClass "-cakedev-arrow-up-black"

  show: ->
    if not @tooltip?
      @tooltip = $ "<div class='-cakedev-tooltip'><p /><span /></div>"
      $("body").append @tooltip

      @setText @text
      @setDirection @direction

    switch @direction
      when "left" then @setToLeft()
      when "right" then @setToRight()
      when "top" then @setToTop()
      else @setToBottom()

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

    @showTooltip top, left

  setToRight: ->
    top = @el.offset().top + parseInt(@el.outerHeight() / 2, 10) - parseInt(@tooltip.outerHeight() / 2, 10)
    left = @el.offset().left + @el.outerWidth() + @hMargin

    @showTooltip top, left

  setToBottom: ->
    top = @el.offset().top + @el.outerHeight() + @vMargin
    left = @el.offset().left + parseInt(@el.outerWidth() / 2, 10) - parseInt(@tooltip.outerWidth() / 2, 10)
    
    @showTooltip top, left

  setToLeft: ->
    top = @el.offset().top + parseInt(@el.outerHeight() / 2, 10) - parseInt(@tooltip.outerHeight() / 2, 10)
    left = @el.offset().left - @tooltip.outerWidth() - @hMargin

    @showTooltip top, left

  showTooltip: (top, left) ->
    @tooltip.css("top", top + "px");
    @tooltip.css("left", left + "px");

    if @animate
      @tooltip.stop().animate { opacity: 0.80 }, @animationSpeed
    else
      @tooltip.show()
