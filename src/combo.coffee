class Combo
  constructor: (@element, @options, @delegate) ->
    @selectedIndex = 0

jcakedev.combo =
  combos: []

  invoke: (action, params) ->
    if action?
      if action is "create"
        jcakedev.combo.create.call @, params
      else if action is "getValue"
        jcakedev.combo.getValue.call @
      else if action is "setValue"
        return jcakedev.combo.setValue.call @, params
      else
        throw "'#{action}' is not a valid action for combo"
    else
      jcakedev.combo.create.call @, params

  create: (params) ->
    options = []
    delegate = null
    defaultValue = null

    if params? and params.options? and params.options.length
      options = params.options
      delegate = params.delegate
      defaultValue = params.defaultValue
    else
      throw "No options defined for combo(s) exception"      

    @each ->
      $combo = $ @
      $combo.addClass "-cakedev-custom-combo" if not $combo.hasClass "-cakedev-custom-combo"

      combo = new Combo $combo, options, delegate

      selectedOptionIndex = 0
      optionsList = ""

      for option, i in options
        if defaultValue? and option.value is defaultValue
          selectedOptionIndex = i

        optionsList += "<li class='-cakedev-combo-option-#{i}'>#{option.text}</li>"

      combo.selectedIndex = selectedOptionIndex
      selectedOption = options[selectedOptionIndex]

      $combo.append(
        "<table style='border-collapse: collapse;'>" +
          "<tr>" +
            "<td class='-cakedev-combo-optionText'>#{selectedOption.text}</td>" +
            "<td class='-cakedev-combo-arrow'><div></div></td>" +
          "</tr>" +
        "</table>"
      )

      $combo.append(
        "<div class='-cakedev-combo-list-container'>" +
          "<ul>#{optionsList}</ul>" +
        "</div>"
      )

      $combo.find("li").each (index) ->
        $(@).on "click", (event) ->
          jcakedev.combo.setValue.call $combo, combo.options[index].value

          if typeof combo.delegate is "function"
            combo.delegate combo.options[index], $combo
          else
            console.log "Delegate is not a valid function"

          true
        true

      $combo.find(".-cakedev-combo-option-#{selectedOptionIndex}").hide()
      $list = $combo.find(".-cakedev-combo-list-container").hide()

      $combo.find("table").on "click", ->
        if $list.is ":visible"
          $list.hide()
        else
          $list.show()

        true

      jcakedev.combo.combos.push combo
      true

  setValue: (value) ->
    combo = jcakedev.combo.getCurrentElement.call @
    if combo?
      index = 0
      option = null

      for opt, i in combo.options
        if opt.value is value
          option = opt
          index = i

      if option?
        @find(".-cakedev-combo-optionText").html option.text
        $itemsParent = @find "ul"
        $itemsParent.children("li").show()
        $itemsParent.children("li").filter(".-cakedev-combo-option-#{index}").hide()

        combo.selectedIndex = index

    @

  getValue: ->
    combo = jcakedev.combo.getCurrentElement.call @
    if combo?
      combo.options[combo.selectedIndex].value
    else
      null

  getCurrentElement: ->
    currentCombo = null
    for combo in jcakedev.combo.combos
      if combo.element.get(0) is @get(0)
        currentCombo = combo

    currentCombo

$(document).ready ->
  $(document).on "click", (event) ->
    if not $(event.target).closest(".-cakedev-custom-combo table").length
      $(".-cakedev-custom-combo .-cakedev-combo-list-container").hide()
    true
  true
