jcake.plugin(
  "cakeTable"
  [ "setData", "setLoading", "removeLoading" ]
  ($el, props) ->
    props = if props? then props else {}

    fields = if props.fields? then props.fields else []
    fieldNames = if props.fieldNames? then props.fieldNames else {}
    data = if props.data? then props.data else []
    maxRecords = if props.maxRecords? then props.maxRecords else 20
    formats = if props.formats? then props.formats else {}
    selectable = if props.selectable? then props.selectable else no
    editable = if props.editable? then props.editable else no
    erasable = if props.erasable? then props.erasable else no
    emptyMessage = if props.emptyMessage? then props.emptyMessage else "..."
    onEdit = props.onEdit
    onErase = props.onErase

    return new Table $el, fields, fieldNames, data, maxRecords, formats, selectable, editable, erasable, emptyMessage, onEdit, onErase
)

class Table
  constructor: (@el, @fields, @fieldNames, @data, @maxRecords, @formats, @selectable, @editable, @erasable, @emptyMessage, @onEdit, @onErase) ->
    @loading = no
    @currentPage = 0
    @el.addClass "jcake-table"

    $wrapper = $ "<div class='jcake-table-wrapper' />"
    $records = $ "<table class='jcake-table-records' />"
    $pages = $ "<div class='jcake-table-pages' />"

    $wrapper.append $records
    $wrapper.append "<div class='jcake-table-loading' />"
    $wrapper.append "<div class='jcake-table-message'>#{@emptyMessage}</div>"
    @el.append $wrapper
    @el.append $pages

    @setRecords()

  # public methods

  setData: (data) ->
    @data = data
    @currentPage = 0
    @setRecords() if not @loading

  setLoading: ->
    @clearRecords()
    @el.children(".jcake-table-wrapper").children(".jcake-table-loading").show()
    @loading = yes

  removeLoading: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-loading").hide()
    @setRecords()
    @loading = no

  # end

  clearData: ->
    setData []

  showEmptyMessage: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-message").show()

  hideEmptyMessage: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-message").hide()

  getValueWithFormat: (field, value) ->
    if typeof @formats[field] is "function"
      valueWithFormat = @formats[field].call value, value
      value = valueWithFormat if valueWithFormat?
    
    if value? then value else ""

  setRecords: ->
    $records = @el.find ".jcake-table-records"
    $records.empty()

    @setHeaders()
    @hideEmptyMessage()

    if @data.length
      start = @currentPage * @maxRecords
      end = start + @maxRecords

      for i in [start...end]
        if i >= @data.length
          break

        $record = $ "<tr />";
        $record.append "<td class='jcake-table-recordActions' />"

        for field in @fields
          value = @getValueWithFormat field, @data[i][field]

          $record.append "<td>#{value}</td>"

        $records.append $record

      @setSelectable() if @selectable
      @setEditable() if @editable
      @setErasable() if @erasable

      $records.find("tr:last td").css "border", "none"
    else
      @showEmptyMessage()

    @setPages()

  setHeaders: ->
    $headers = $ "<tr />"
    $headers.append "<th />"

    for field in @fields
      fieldName = if @fieldNames[field]? then @fieldNames[field] else field
      $headers.append "<th>#{fieldName}</th>"

    @el.find(".jcake-table-records").append $headers

  setPages: ->
    me = @
    $pages = @el.children ".jcake-table-pages"
    $pages.empty()

    pagesCount = Math.ceil(@data.length / @maxRecords)

    for i in [0...pagesCount]
      $page = $ "<a class='jcake-table-page' href='#'>#{i + 1}</a>"
      $page.data "pageIndex", i

      $page.on "click", ->
        index = $(@).data "pageIndex"
        if index isnt me.currentPage
          me.setPage index
        no
      
      $pages.append $page

    $pages.children(".jcake-table-page").eq(@currentPage).addClass "jcake-table-currentPage"

    if @data.length
      @setNavigationControls()
      @setInfo()

  setNavigationControls: ->
    me = @
    $pages = @el.children ".jcake-table-pages"

    $previous = $ "<a href='#'>&laquo; Anterior</a>"
    $next = $ "<a href='#'>Siguiente &raquo;</a>"
    $beginning = $ "<a href='#'>Ir al inicio</a>"
    $end = $ "<a href='#'>Ir al final</a>"

    lastPage = Math.ceil(@data.length / @maxRecords) - 1
    lastPage = 0 if lastPage < 0

    $previous.on "click", ->
      me.setPage(me.currentPage - 1) if me.currentPage > 0
      no
    $beginning.on "click", ->
      me.setPage 0
      no
    $next.on "click", ->
      me.setPage(me.currentPage + 1) if me.currentPage < lastPage
      no
    $end.on "click", ->
      me.setPage lastPage
      no

    $pages
      .prepend($end)
      .prepend($next)
      .prepend($previous)
      .prepend($beginning)

  setInfo: ->
    beginning = @currentPage * @maxRecords
    end = beginning + @maxRecords
    end = @data.length if end > @data.length

    @el.children(".jcake-table-pages").append "<span class='jcake-table-info'>Mostrando #{beginning + 1} a #{end} de #{@data.length}</span>"

  setPage: (index) ->
    @currentPage = index
    @setRecords()

  setSelectable: ->
    no

  setEditable: ->
    $actions = @el.find(".jcake-table-records").find ".jcake-table-recordActions"
    currentIndex = @currentPage * @maxRecords

    me = @
    
    for i in [0...$actions.length]
      $action = $ "<span class='jcake-table-action jcake-edit-icon' />"
      $action.data "cakedevIndex", currentIndex
      $action.on "click", ->
        me.raiseOnEdit $(@).data("cakedevIndex")

      $actions.eq(i).append $action
      currentIndex++

  raiseOnEdit: (index) ->
    if typeof @onEdit is "function"
      @onEdit.call @el, @data[index], index

  setErasable: ->
    $actions = @el.find(".jcake-table-records").find ".jcake-table-recordActions"
    currentIndex = @currentPage * @maxRecords

    me = @
    
    for i in [0...$actions.length]
      $action = $ "<span class='jcake-table-action jcake-trash-icon' />"
      $action.data "cakedevIndex", currentIndex
      $action.on "click", ->
        me.raiseOnErase $(@).data("cakedevIndex")

      $actions.eq(i).append $action
      currentIndex++

  raiseOnErase: (index) ->
    if typeof @onErase is "function"
      @onErase.call @el, @data[index], index

  clearRecords: ->
    @el.find(".jcake-table-records").find("tr").not(":first").remove()
    @el.children(".jcake-table-pages").empty()
    @hideEmptyMessage()
