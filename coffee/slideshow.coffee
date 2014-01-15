jcake.plugin(
  "cakeSlideshow"
  [ "next", "prev", "goTo" ]
  ($el, props) ->
    props = if props? then props else {}
    
    height = props.height
    speed = if props.speed? then props.speed else 400
    delay = if props.delay? then props.delay else 2000
    rotate = if props.rotate? then props.rotate else yes
    effect = if props.effect? then props.effect else "slide"
    autoNavigate = if props.autoNavigate? then props.autoNavigate else yes

    return new Slideshow($el, height, speed, delay, rotate, effect, autoNavigate)
  ->
    $(".x-jcake-slideshow").each ->
      $el = $(@)

      $el.cakeSlideshow
        height: $el.data("height")
        speed: $el.data("speed")
        delay: $el.data("delay")
        rotate: $el.data("rotate")
        effect: $el.data("effect")
        autoNavigate: $el.data("autoNavigate")
)

class Slideshow
  constructor: (@el, @height, @speed, @delay, @rotate, effect, @autoNavigate) ->
    @slides = @el.children()

    if not @slides.length
      throw new Error("Slideshow requires at least 1 slide")

    @effect = @getEffect(effect)
    @current = 0

    @el.addClass("jcake-slideshow")

    if @height?
      @el.css("height", @height)
    else
      @el.css("height", @getCurrentSlide().outerHeight())

    @slides
      .addClass("jcake-slideshow-slide")
      .hide()
      .eq(0).show()

    @setNavigationControls()
    @updateNavigation()

    @navigate() if @autoNavigate

  getEffect: (id) ->
    switch id
      when "slide" then new SlideEffect(@speed)
      when "fade" then new FadeEffect(@speed)
      else new SlideEffect(@speed)

  setNavigationControls: ->
    me = @

    addListener = ($el, index) ->
      $el.on "click", ->
        if not $(@).hasClass("jcake-slideshow-bullet-selected")
          if not @animating
            me.disableNavigation()
            me.goTo(index)

    $container = $("<div class='jcake-slideshow-navigation' />")

    for i in [0...@slides.length]
      $bullet = $("<span class='jcake-slideshow-bullet' />")
      $bullet.append("<span class='jcake-slideshow-bullet-dot' />")

      $container.append($bullet)
      addListener($bullet, i)

    @el.append($container)

  updateNavigation: ->
    @el.find(".jcake-slideshow-bullet")
      .removeClass("jcake-slideshow-bullet-selected")
      .eq(@current).addClass("jcake-slideshow-bullet-selected")

  navigate: ->
    me = @

    @navigationTimeout = setTimeout ->
        me.next ->
          me.navigate()
      , @delay

  disableNavigation: ->
    clearTimeout(@navigationTimeout)

  getCurrentSlide: ->
    return @slides.eq(@current)

  getSlide: (index) ->
    return @slides.eq(index)

  getSlidesCount: ->
    return @slides.length

  next: (doneFn) ->
    if @animating
      return @

    if not @rotate and @current is (@getSlidesCount() - 1)
      return @

    me = @

    $current = me.getCurrentSlide()

    me.current++

    if me.current >= me.getSlidesCount()
      me.current = 0

    $next = me.getCurrentSlide()

    me.animating = yes

    if $current isnt $next
      me.effect.leave($current)
      me.effect.enter $next, ->
        me.animating = no
        me.updateNavigation()
        doneFn?()

    return @

  prev: (doneFn) ->
    if @animating
      return @

    if not @rotate and @current is 0
      return @

    me = @

    $current = me.getCurrentSlide()

    me.current--

    if me.current < 0
      me.current = me.getSlidesCount() - 1

    $next = me.getCurrentSlide()

    me.animating = yes

    if $current isnt $next
      me.effect.leave($current)
      me.effect.enter $next, ->
        me.animating = no
        me.updateNavigation()
        doneFn?()

    return @

  goTo: (index, doneFn) ->
    if @animating
      return @

    if index is @current
      doneFn?()
      return @

    if index > -1 and index < @getSlidesCount()
      $current = @getCurrentSlide()
      @current = index
      $next = @getCurrentSlide()

      me = @
      me.animating = yes

      finish = ->
        me.animating = no
        me.updateNavigation()
        doneFn?()

      if index < me.current
        me.effect.return($current)
        me.effect.comeback($next, finish)
      else
        me.effect.leave($current)
        me.effect.enter($next, finish)

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
