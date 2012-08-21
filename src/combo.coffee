jcakedev.plugins.combo =
  pluginManager: null,

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeCombo = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getValue"
            return me.getValue @
          when "setValue"
            me.setValue @, args[1]
          else
            console.log "'#{action}' is not a valid action for cakeCombo"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($elements, params) ->
    me = @

    if params.options? and params.options.length
      options = params.options
      delegate = params.delegate
      defaultValue = params.defaultValue

      $elements.each ->
        combo = new Combo $(@), options, delegate
        combo.setValue defaultValue if defaultValue?

        me.pluginManager.addComponent combo
    else
      console.log "No options were defined for cakeCombo"

  getValue: ($obj) ->
    if $obj.length > 1
      values =
        for i in [0...$obj.length]
          $el = $obj.eq i

          combo = @pluginManager.getComponent $el
          continue if not combo?

          combo.getValue()
    else
      combo = @pluginManager.getComponent $obj
      if combo? then combo.getValue() else null

  setValue: ($obj, value) ->
    for i in [0...$obj.length]
      $el = $obj.eq i

      combo = @pluginManager.getComponent $el
      combo.setValue(value) if combo?

class Combo
  constructor: (@el, @options, @delegate) ->
    @selectedIndex = 0
    @el.addClass "-cakedev-combo"

    $comboElement = $ "<table class='-cakedev-combo-element' />"
    $comboElement.append(
      "<tr>" +
        "<td class='-cakedev-combo-optionText'></td>" +
        "<td class='-cakedev-combo-arrow'><span class='-cakedev-arrow -cakedev-arrow-down-black'></span></td>" +
      "</tr>"
    )

    @el.append $comboElement

    @setOptions()
    @setCurrentOption()

    me = @

    $comboElement.on "mouseenter", ->
      me.showList yes
      me.setFocus yes

    $comboElement.on "mouseleave", (event) ->
      $target = if event.toElement? then $(event.toElement) else $(event.relatedTarget)

      if (not $target.hasClass("-cakedev-combo-list-container") and not $target.closest(".-cakedev-combo-list-container").length)
        me.hideList yes
        me.setFocus no

      yes

  showList: (animate) ->
    $el = @el.children(".-cakedev-combo-list-container")
    $el.stop().show()
    if animate
      $el.animate { opacity: 1.0 }, 200
    else
      $el.css "opacity", 1.0

  hideList: (animate) ->
    $el = @el.children(".-cakedev-combo-list-container")
    if animate
      $el.stop().animate { opacity: 0 }, 200, -> $el.hide()
    else
      $el.stop().hide()
      $el.css "opacity", 0

  setOptions: ->
    me = @
    $listContainer = $ "<div class='-cakedev-combo-list-container' />"
    $list = $ "<ul />"

    for option in @options
      $list.append "<li>#{option.text}</li>"

    $listContainer.append $list

    $list.children("li").each (index) ->
      $(@).on "click", (event) ->
        if me.selectedIndex isnt index
          if typeof me.delegate is "function"
            me.delegate.call me.el, me.options[index]

          me.setValue me.options[index].value
          me.setFocus no
          me.hideList no

          true

    $listContainer.on "mouseleave", (event) ->
      $target = if event.toElement? then $(event.toElement) else $(event.relatedTarget)

      if (not $target.hasClass("-cakedev-combo-element") and not $target.closest(".-cakedev-combo-element").length)
        me.hideList yes
        me.setFocus no

      yes

    @el.append $listContainer

  setCurrentOption: ->
    @el.children("table").find(".-cakedev-combo-optionText").text @options[@selectedIndex].text

    $options = @el.children(".-cakedev-combo-list-container").children("ul").children "li"
    $options.removeClass "-cakedev-combo-selectedOption"
    $options.eq(@selectedIndex).addClass "-cakedev-combo-selectedOption"

  setFocus: (focus) ->
    if focus
      @el.children(".-cakedev-combo-element").addClass "-cakedev-combo-focused"
    else
      @el.children(".-cakedev-combo-element").removeClass "-cakedev-combo-focused"

  setValue: (value) ->
    if @getValue() isnt value
      for option, i in @options
        if option.value is value
          @selectedIndex = i
          break

      @setCurrentOption()

  getValue: ->
    @options[@selectedIndex].value
