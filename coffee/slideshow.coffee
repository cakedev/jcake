jcake.plugin(
  "cakeSlideshow"
  []
  ($el, props) ->
    props = if props? then props else {}
    
    height = props.height
    disableNavigation = if props.disableNavigation? then props.disableNavigation else no
    animationSpeed = if props.animationSpeed? then props.animationSpeed else 400
    autoNavigate = if props.autoNavigate? then props.autoNavigate else yes
    delay = if props.delay? then props.delay else 2000
    rotate = if props.rotate? then props.rotate else yes
    navigationMargin = if props.navigationMargin? then props.navigationMargin else 20

    return new Slideshow $el, height, disableNavigation, animationSpeed, autoNavigate, delay, rotate, navigationMargin
  ->
    $(".x-jcake-slideshow").each ->
      $el = $ @

      $el.cakeSlideshow
        height: $el.data "height"
        disableNavigation: $el.data "disableNavigation"
        animationSpeed: $el.data "animationSpeed"
        autoNavigate: $el.data "autoNavigate"
        delay: $el.data "delay"
        rotate: $el.data "rotate"
        navigationMargin: $el.data "navigationMargin"
)

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
