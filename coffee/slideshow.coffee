jcake.plugins.slideshow = 
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeSlideshow = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "moveNext"
            pm.notify "Not implemented yet"
          when "movePrevious"
            pm.notify "Not implemented yet"
          else
            pm.notify "'#{action}' is not a valid action for cakeSlideshow"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    height = params.height
    disableNavigation = if params.disableNavigation? then params.disableNavigation else no
    animationSpeed = if params.animationSpeed? then params.animationSpeed else 400
    autoNavigate = if params.autoNavigate? then params.autoNavigate else yes
    delay = if params.delay? then params.delay else 2000
    rotate = if params.rotate? then params.rotate else yes
    navigationMargin = if params.navigationMargin? then params.navigationMargin else 20

    me = @

    $obj.each ->
      slideshow = new Slideshow $(@), height, disableNavigation, animationSpeed, autoNavigate, delay, rotate, navigationMargin
      me.pluginManager.addComponent slideshow

class Slideshow
  constructor: (@el, @height, @disableNavigation, @animationSpeed, @autoNavigate, @delay, @rotate, @navigationMargin) ->
    @currentIndex = 0
    @animating = no

    fixedHeight = no

    if @height?
      fixedHeight = yes
      @el.css "height", if isNaN(@height) then @height else "#{@height}px"

    @slides = @el.children "div"
    @el.addClass "jcake-slideshow"
    @height = @el.height()

    if not fixedHeight
      maxHeight = 0

      for i in [0...@slides.length]
        maxHeight = @slides.eq(i).height() if @slides.eq(i).height() > maxHeight

      height = maxHeight
      @el.css "height", "#{height}px"

    for i in [0...@slides.length]
      $slide = @slides.eq i

      $slide.addClass "jcake-slideshow-slide"
      $slide.css "height", "#{height}px"

    @slides.not(":eq(0)").css "margin-left", "#{@el.width()}px"

    @setNavigationControls() if not @disableNavigation
    @setAutoNavigation() if @autoNavigate

  setNavigationControls: ->
    width = @el.width()
    height = @el.height();

    $arrowleft = $ "<div class='jcake-slideshow-arrowleft' />"
    $arrowright = $ "<div class='jcake-slideshow-arrowright' />"

    @el.append $arrowleft
    @el.append $arrowright

    $arrowleft.css "left", "#{@navigationMargin}px"
    $arrowright.css "left", (width - $arrowright.width() - @navigationMargin) + "px"

    me = @

    $arrowleft.on "click", ->
      me.autoNavigate = no
      me.movePrevious()

    $arrowright.on "click", ->
      me.autoNavigate = no
      me.moveNext()

  setAutoNavigation: ->
    @navigate()

  navigate: ->
    me = @
    setTimeout(
      ->
        if me.autoNavigate
          me.moveNext -> me.navigate()
      @delay
    )

  moveNext: (callback, animationSpeed) ->
    if not @animating
      if @slides.length > 1
        speed = if animationSpeed? then animationSpeed else @animationSpeed

        if @currentIndex is @slides.length - 1
          if @rotate
            speed = Math.round(speed / @slides.length) + 100
            @moveToFirst speed, callback
        else
          me = @
          @animating = true

          @changeSlide(
            @slides.eq(@currentIndex),
            @slides.eq(@currentIndex + 1),
            speed,
            "f",
            ->
              me.animating = false
              me.currentIndex++

              if typeof callback is "function"
                callback()
          )

  movePrevious: (callback, animationSpeed) ->
    if not @animating
      if @slides.length > 1
        speed = if animationSpeed? then animationSpeed else @animationSpeed

        if @currentIndex is 0
          if @rotate
            speed = Math.round(speed / @slides.length) + 100
            @moveToLast speed, callback
        else
          me = @
          @animating = true

          @changeSlide(
            @slides.eq(@currentIndex),
            @slides.eq(@currentIndex - 1),
            speed,
            "b",
            ->
              me.animating = false
              me.currentIndex--

              if typeof callback == "function"
                callback()
          )

  moveToFirst: (slideAnimationSpeed, callback) ->
    if @currentIndex > 0
      me = @
      @movePrevious(
        -> me.moveToFirst slideAnimationSpeed, callback
        slideAnimationSpeed
      )
    else
      if typeof callback is "function"
        callback()

  moveToLast: (slideAnimationSpeed, callback) ->
    if @currentIndex < @slides.length - 1
      me = @
      @moveNext(
        -> me.moveToLast slideAnimationSpeed, callback
        slideAnimationSpeed
      )
    else
      if typeof callback is "function"
        callback()

  changeSlide: ($current, $new, speed, direction, callback) ->
    $current.css "z-index", 990
    $new.css "z-index", 991
    $new.animate { marginLeft: "0px" }, speed, "linear", ->
      if typeof callback is "function"
        callback()

    if direction is "f"
      $current.animate { marginLeft: "-#{$current.width()}px" }, speed, "linear"
    else if direction is "b"
      $current.animate { marginLeft: "#{$current.width()}px" }, speed, "linear"
