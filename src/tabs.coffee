jcakedev.tabs =
  invoke: (action, params) ->
    if action?
    	0
    else
    	jcakedev.tabs.create.call this, params