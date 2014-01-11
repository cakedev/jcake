jcake.plugin(
  "cakeSlideshow"
  [ "next", "prev", "goTo" ]
  ($el, props) ->
    props = if props? then props else {}
    
    height = props.height
    disableNavigation = if props.disableNavigation? then props.disableNavigation else no
    animationSpeed = if props.animationSpeed? then props.animationSpeed else 400
    autoNavigate = if props.autoNavigate? then props.autoNavigate else yes
    delay = if props.delay? then props.delay else 2000
    rotate = if props.rotate? then props.rotate else yes

    return new Slideshow($el, height, disableNavigation, animationSpeed, autoNavigate, delay, rotate)
  ->
    $(".x-jcake-slideshow").each ->
      $el = $(@)

      $el.cakeSlideshow
        height: $el.data "height"
        disableNavigation: $el.data "disableNavigation"
        animationSpeed: $el.data "animationSpeed"
        autoNavigate: $el.data "autoNavigate"
        delay: $el.data "delay"
        rotate: $el.data "rotate"
)

class Slideshow
  constructor: (@el, @height, @disableNavigation, @animationSpeed, @autoNavigate, @delay, @rotate) ->
    $children = @el.children()

    if not $children.length
      throw new Error("Slideshow requires at least 1 slide")

    @slides = []

    for i in [0..$children.length]
      @slides.push $children.eq(i).addClass("jcake-slideshow-slide")

    @effect = new SlideEffect(@animationSpeed)
    @current = 0

    @el.addClass("jcake-slideshow")

    @goTo 0

  getCurrentSlide: ->
    return $slides[@current]

  next: ->
    $currentSlide = @getCurrentSlide()

    @current++

    if @current >= @slides.left
      @current = 0

    $next = getCurrentSlide()

    if $current isnt $next
      @effect.leave $current
      @effect.enter $next

    return @

  prev: ->
    $currentSlide = @getCurrentSlide()

    @current--

    if @current < 0
      @current = $slides.length - 1

    $next = getCurrentSlide()

    if $current isnt $next
      @effect.leave $current
      @effect.enter $next

    return @

  goTo: (index) ->
    if index is @current
      return @

class SlideEffect
  constructor: (@speed) ->

  comeback: ($slide, fn) ->
    $slide
      .css("left", "100%")
      .animate({ left: "0%" }, @speed, fn)

  enter: ($slide, fn) ->
    $slide
      .css("left", "-100%")
      .animate({ left: "0%" }, @speed, fn)

  leave: ($slide, fn) ->
    $slide
      .css("left", "0%")
      .animate({ left: "100%" }, @speed, fn)

  return: ($slide, fn) ->
    $slide
      .css("left", "0%")
      .animate({ left: "-100%" }, @speed, fn)
