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
            console.log "Under development..."
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
        combo = new Combo me.pluginManager.newID(), $(@), options, delegate
        combo.setValue defaultValue if defaultValue?

        me.pluginManager.addElement combo
    else
      console.log "No options were defined for combo(s)"
      $elements

  getValue: ($element) ->
    combo = @pluginManager.getElement $element.data "jcakedevId"

    if combo?
      combo.getValue()
    else
      null

class Combo
  constructor: (@id, @element, @options, @delegate) ->
    @element.data "jcakedevId", @id
    @selectedIndex = 0

    @element.addClass "-cakedev-combo"

    $comboElement = $ "<table class='-cakedev-combo-element' />"
    $comboElement.append(
      "<tr>" +
        "<td class='-cakedev-combo-optionText'></td>" +
        "<td class='-cakedev-combo-arrow'><span class='-cakedev-arrow -cakedev-arrow-down-black'></span></td>" +
      "</tr>"
    )

    @element.append $comboElement

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
    $el = @element.children(".-cakedev-combo-list-container")
    $el.stop().show()
    if animate
      $el.stop().animate { opacity: 1.0 }, 100
    else
      $el.css "opacity", 1.0

  hideList: (animate) ->
    $el = @element.children(".-cakedev-combo-list-container")
    if animate
      $el.stop().animate { opacity: 0 }, 100, -> $el.hide()
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
            me.delegate.call me.element, me.options[index]

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

    @element.append $listContainer

  setCurrentOption: ->
    @element.children("table").find(".-cakedev-combo-optionText").text @options[@selectedIndex].text

    $options = @element.children(".-cakedev-combo-list-container").children("ul").children "li"
    $options.removeClass "-cakedev-combo-selectedOption"
    $options.eq(@selectedIndex).addClass "-cakedev-combo-selectedOption"

  setFocus: (focus) ->
    if focus
      @element.children(".-cakedev-combo-element").addClass "-cakedev-combo-focused"
    else
      @element.children(".-cakedev-combo-element").removeClass "-cakedev-combo-focused"

  setValue: (value) ->
    if @getValue() isnt value
      for option, i in @options
        if option.value is value
          @selectedIndex = i
          break

      @setCurrentOption()

  getValue: ->
    @options[@selectedIndex].value
