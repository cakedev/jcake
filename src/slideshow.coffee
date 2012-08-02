class Slideshow
  constructor: (@element) ->
    @slides = []
    @currentIndex = 0
    @animationSpeed = 400
    @autoNavigate = false
    @delay = 2000
    @rotate = true
    @animating = false
    @navigationMargin = 20

cake.slideshow = 
  slideshows: []

  invoke: (action, params) ->
    if action?
      if cake.slideshow[action]?
        cake.slideshow[action].call @, params
      else
        console.log "'#{action}' is not a valid action for slideshow"
        return @
    else
      return cake.slideshow.create.call @, params

  create: (params) ->
    @each ->
      $slideshow = $ @

      slideshow = new Slideshow $slideshow

      disableNavigation = false
      fixedHeight = false

      if params?
        if params.height?
          fixedHeight = true
          $slideshow.css "height", if isNaN params.height then params.height else "#{params.height}px"
        if params.disableNavigation?
          disableNavigation = params.disableNavigation
        if params.rotate?
          slideshow.rotate = params.rotate
        if params.animationSpeed?
          slideshow.animationSpeed = params.animationSpeed
        if params.autoNavigate?
          slideshow.autoNavigate = params.autoNavigate
        if params.delay?
          slideshow.delay = params.delay
        if params.navigationMargin?
          slideshow.navigationMargin = params.navigationMargin

      $slides = $slideshow.children "div"
      slideshow.slides = $slides

      cake.slideshow.slideshows.push slideshow

      $slideshow.addClass "-cakedev-slideshow" if not $slideshow.hasClass "-cakedev-slideshow"

      height = $slideshow.height()

      if not fixedHeight
        maxHeight = 0

        for el, i in $slides
          maxHeight = $slides.eq(i).height() if $slides.eq(i).height() > maxHeight

        height = maxHeight
        $slideshow.css "height", "#{height}px"

      for el, i in $slides
        $slide = $slides.eq i

        $slide.addClass "-cakedev-slideshow-slide" if not $slide.hasClass "-cakedev-slideshow-slide"

        $slide.css "height", "#{height}px"
        $slide.css "width", "100%"
        $slide.css "top", "-#{i * height}px"

      $slides.not(":eq(0)").css "margin-left", "#{$slideshow.width()}px"

      cake.slideshow.setNavigationControls slideshow if not disableNavigation
      cake.slideshow.setAutoNavigation slideshow if slideshow.autoNavigate

      true

  setNavigationControls: (slideshow) ->
    $slideshow = slideshow.element
    $slides = slideshow.slides

    width = $slideshow.width()
    height = $slideshow.height();

    $arrowleft = $ "<div class='-cakedev-slideshow-arrowleft' />"
    $arrowright = $ "<div class='-cakedev-slideshow-arrowright' />"

    $slideshow.append $arrowleft
    $slideshow.append $arrowright

    $arrowleft.css "left", "#{slideshow.navigationMargin}px"
    $arrowleft.css "top",
      "-" + (
        height * $slides.length -
        parseInt(height / 2, 10) +
        parseInt($arrowleft.height() / 2, 10)
      ) + "px"

    $arrowright.css "left", (width - $arrowright.width() - slideshow.navigationMargin) + "px"
    $arrowright.css "top",
      "-" + (
        height * $slides.length -
        parseInt(height / 2, 10) +
        parseInt($arrowright.height() / 2, 10) +
        $arrowleft.height()
      ) + "px"

    $arrowleft.on "click", ->
      slideshow.autoNavigate = false
      cake.slideshow.movePrevious.call slideshow.element

    $arrowright.on "click", ->
      slideshow.autoNavigate = false
      cake.slideshow.moveNext.call slideshow.element

    true

  setAutoNavigation: (slideshow) ->
    cake.slideshow.autoNavigate slideshow

  autoNavigate: (slideshow) ->
    setTimeout(
      ->
        if slideshow.autoNavigate
          cake.slideshow.moveNext.call(
            slideshow.element,
            -> cake.slideshow.autoNavigate slideshow
          )
      slideshow.delay
    )

    true

  moveNext: (callback, animationSpeed) ->
    slideshow = cake.slideshow.getCurrentElement.call @

    if slideshow?
      if slideshow.animating
        return;

      if slideshow.slides.length > 1
        speed = if animationSpeed? then animationSpeed else slideshow.animationSpeed

        if slideshow.currentIndex is slideshow.slides.length - 1
          if slideshow.rotate
            speed = Math.round(speed / slideshow.slides.length) + 100
            cake.slideshow.moveToFirst slideshow, speed, callback
        else
          slideshow.animating = true

          cake.slideshow.changeSlide(
            slideshow.slides.eq(slideshow.currentIndex),
            slideshow.slides.eq(slideshow.currentIndex + 1),
            speed,
            "f",
            ->
              slideshow.animating = false
              slideshow.currentIndex++

              if typeof callback == "function"
                callback()
          )
    true

  movePrevious: (callback, animationSpeed) ->
    slideshow = cake.slideshow.getCurrentElement.call @

    if slideshow?
      if slideshow.animating
        return;

      if slideshow.slides.length > 1
        speed = if animationSpeed? then animationSpeed else slideshow.animationSpeed

        if slideshow.currentIndex is 0
          if slideshow.rotate
            speed = Math.round(speed / slideshow.slides.length) + 100
            cake.slideshow.moveToLast slideshow, speed, callback
        else
          slideshow.animating = true

          cake.slideshow.changeSlide(
            slideshow.slides.eq(slideshow.currentIndex),
            slideshow.slides.eq(slideshow.currentIndex - 1),
            speed,
            "b",
            ->
              slideshow.animating = false
              slideshow.currentIndex--

              if typeof callback == "function"
                callback()
          )
    true

  moveToFirst: (slideshow, slideAnimationSpeed, callback) ->
    if slideshow.currentIndex > 0
      cake.slideshow.movePrevious.call(
        slideshow.element,
        -> cake.slideshow.moveToFirst slideshow, slideAnimationSpeed, callback
        slideAnimationSpeed
      )
    else
      if typeof callback is "function"
        callback()

    true

  moveToLast: (slideshow, slideAnimationSpeed, callback) ->
    if slideshow.currentIndex < slideshow.slides.length - 1
      cake.slideshow.moveNext.call(
        slideshow.element,
        -> cake.slideshow.moveToLast slideshow, slideAnimationSpeed, callback
        slideAnimationSpeed
      )
    else
      if typeof callback is "function"
        callback()

    true

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

    true

  getCurrentElement: ->
    currentSlideshow = null
    for slideshow in cake.slideshow.slideshows
      if slideshow.element.get(0) is @get(0)
        currentSlideshow = slideshow

    currentSlideshow
