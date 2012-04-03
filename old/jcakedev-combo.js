jcakedev.combo = {
	
	combos: [],

	invoke: function(action, params) {
		if (action) {
			if (action == "create") {
				return jcakedev.combo.create.call(this, params);
			}
			else if (action == "getValue") {
				return jcakedev.combo.getValue.call(this);
			}
			else if (action == "setValue") {
				return jcakedev.combo.setValue.call(this, params);
			}
			else {
				console.log(action + " is not a valid action for combo");
			}
		}
		else {
			return jcakedev.combo.create.call(this, params);
		}
	},
			
	create: function(params) {
		var options = [];
		var delegate = null;
		var defaultValue = null;

		if (params) {
			options = params.options;
			delegate = params.delegate;
			defaultValue = params.defaultValue;
		}

		if (!options || !options.length) {
			console.log("No options were defined for the combo(s)");
			return this;
		}

		return this.each(function(){
			var $combo = $(this);

			if (!$combo.hasClass("-cakedev-custom-combo")) {
				$combo.addClass("-cakedev-custom-combo")
			}
			
			var combo = {
				element: $combo,
				options: options,
				delegate: delegate,
				selectedIndex: 0
			};
			
			var selectedOptionIndex = 0;
			var optionsList = "";
			
			for (var i = 0; i < options.length; i++) {
				if (defaultValue != null && options[i].value == defaultValue) {
					selectedOptionIndex = i;
				}
				
				optionsList +=
					"<li class='-cakedev-combo-option-" + i + "'>" +
						"<a href='#'>" + options[i].text + "</a>" +
					"</li>";
			}

			combo.selectedIndex = selectedOptionIndex;
			var selectedOption = options[selectedOptionIndex];
			
			$combo.append(
				"<table style='border-collapse: collapse;'>" +
					"<tr>" +
						"<td class='-cakedev-combo-optionText'>" + selectedOption.text + "</td>" +
						"<td class='-cakedev-combo-arrow'><div></div></td>" +
					"</tr>" +
				"</table>"
			);
			
			$combo.append(
				"<div class='-cakedev-combo-list-container'>" +
					"<ul>" +
						optionsList +
					"</ul>" +
				"</div>"
			);

			$combo.find("li a").each(function(index){
				$(this).on("click", function(event){
					event.preventDefault();

					jcakedev.combo.setValue.call($combo, combo.options[index].value);

					if (combo.delegate && typeof(combo.delegate) == "function") {
						combo.delegate(combo.options[index], $combo);
					}
					else {
						console.log("Delegate for combo is not a valid function.");
					}
				});
			});
			
			$combo.find(".-cakedev-combo-option-" + selectedOptionIndex).hide();
			
			var $list = $combo.find(".-cakedev-combo-list-container");
			$list.hide();
			
			$combo.find("table").click(function(){
				if ($list.is(":visible")) {
					$list.hide();
				}
				else {
					$list.show();
				}
			});

			jcakedev.combo.combos.push(combo);
		});
	},

	setValue: function(value) {
		var combo = jcakedev.combo.getCurrentElement.call(this);
		if (combo) {
			var i;
			var option = null;

			for (i = 0; i < combo.options.length; i++) {
				if (combo.options[i].value == value) {
					option = combo.options[i];
					break;
				}
			}

			if (option) {
				this.find(".-cakedev-combo-optionText").html(option.text);
				var $itemsParent = this.find("ul");
				$itemsParent.children("li").show();
				$itemsParent.children("li").filter(".-cakedev-combo-option-" + i).hide();

				combo.selectedIndex = i;
			}
		}

		return this;
	},

	getValue: function() {
		var combo = jcakedev.combo.getCurrentElement.call(this);
		if (combo) {
			return combo.options[combo.selectedIndex].value;
		}

		return null;
	},

	getCurrentElement: function() {
		for (var i = 0; i < jcakedev.combo.combos.length; i++) {
			var combo = jcakedev.combo.combos[i];
			if (combo.element.get(0) == this.get(0)) {
				return combo;
			}
		}

		return null;
	}

};

$(document).ready(function(){

	$(document).click(function(event){
        if (!$(event.target).closest(".-cakedev-custom-combo table").length) {
			$(".-cakedev-custom-combo .-cakedev-combo-list-container").hide();
		}
    });
    
});
