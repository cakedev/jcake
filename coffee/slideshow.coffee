jcake.plugin(
  "cakeSlideshow"
  [ "next", "prev", "goTo" ]
  ($el, props) ->
    props = if props? then props else {}
    
    height = props.height
    speed = if props.speed? then props.speed else 400
    delay = if props.delay? then props.delay else 2000
    autoNavigate = if props.autoNavigate? then props.autoNavigate else yes
    rotate = if props.rotate? then props.rotate else yes
    disableNavigation = if props.disableNavigation? then props.disableNavigation else no

    return new Slideshow($el, height, speed, delay, autoNavigate, rotate, disableNavigation)
  ->
    $(".x-jcake-slideshow").each ->
      $el = $(@)

      $el.cakeSlideshow
        height: $el.data "height"
        speed: $el.data "speed"
        delay: $el.data "delay"
        autoNavigate: $el.data "autoNavigate"
        rotate: $el.data "rotate"
        disableNavigation: $el.data "disableNavigation"
)

class Slideshow
  constructor: (@el, @height, @speed, @delay, @autoNavigate, @rotate, @disableNavigation) ->
    $childrens = @el.children()

    if not $childrens.length
      throw new Error("Slideshow requires at least 1 slide")

    @slides = []

    for i in [0...$childrens.length]
      @slides.push $childrens.eq(i).addClass("jcake-slideshow-slide").hide()

    @slides[0].show()

    @effect = new SlideEffect(@speed)
    @current = 0

    @el.addClass("jcake-slideshow")

    if not @height?
      @el.css("height", @getCurrentSlide().outerHeight())

    if @autoNavigate
      @navigate()

  navigate: ->
    me = @

    setTimeout ->
        me.next().navigate()
      , @delay

  getCurrentSlide: ->
    return @slides[@current]

  getSlide: (index) ->
    return @slides[index]

  next: ->
    if not @rotate and @current is (@slides.length - 1)
      return @

    $current = @getCurrentSlide()

    @current++

    if @current >= @slides.length
      @current = 0

    $next = @getCurrentSlide()

    if $current isnt $next
      @effect.leave($current)
      @effect.enter($next)

    return @

  prev: ->
    if not @rotate and @current is 0
      return @

    $current = @getCurrentSlide()

    @current--

    if @current < 0
      @current = $slides.length - 1

    $next = getCurrentSlide()

    if $current isnt $next
      @effect.leave($current)
      @effect.enter($next)

    return @

  goTo: (index) ->
    if index is @current
      return @

    if index > -1 and index < @slides.length
      $current = @getCurrentSlide()
      $next = @getSlide(index)

      if index < @current
        @effect.return($current)
        @effect.comeback($)
      else
        @effect.leave($current)
        @effect.enter($next)

class Effect
  constructor: (@speed) ->
  comeback: ($slide, fn) ->
  enter: ($slide, fn) ->
  leave: ($slide, fn) ->
  return: ($slide, fn) ->

class SlideEffect extends Effect
  comeback: ($slide, fn) ->
    $slide
      .css("left", "100%")
      .show()
      .animate({ left: "0%" }, @speed, fn)

  enter: ($slide, fn) ->
    $slide
      .css("left", "-100%")
      .show()
      .animate({ left: "0%" }, @speed, fn)

  leave: ($slide, fn) ->
    $slide
      .css("left", "0%")
      .animate({ left: "100%" }, @speed, ->
        $slide.hide()
        fn?()
      )

  return: ($slide, fn) ->
    $slide
      .css("left", "0%")
      .animate({ left: "-100%" }, @speed, ->
        $slide.hide()
        fn?()
      )

class FadeEffect extends Effect
  comeback: ($slide, fn) ->
    @enter($slide, fn)

  enter: ($slide, fn) ->
    $slide.fadeIn(@speed, fn)

  leave: ($slide, fn) ->
    $slide.fadeOut(@speed, fn)

  return: ($slide, fn) ->
    @leave($slide, fn)
