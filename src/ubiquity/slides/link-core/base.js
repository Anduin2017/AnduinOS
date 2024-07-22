/*
Additional Javascript for ubiquity-slideshow, global to all variations.
*/

/* FIXME: Replace this with a proper querystring deparam function (and update Ubiquity for new format) */
var INSTANCE_OPTIONS = {
	'locale' : 'en'
};
(function() {
	var hash = window.location.hash.split('#')[1] || '';
	var parameters = hash.split(/\?|&/);
	$.each(parameters, function(i, parameter) {
		var hash = parameter.split('=');
		var key = hash[0];
		if (hash[1] !== undefined) {
			var value = decodeURIComponent(
				hash[1].replace(/\+/g, '%20')
			);
		} else {
			var value = undefined;
		}
		
		INSTANCE_OPTIONS[key] = value;
	});
})();

var Signals = new function() {
	var handlers = {};
	
	var register = function(signalName) {
		if (! handlers[signalName]) {
			handlers[signalName] = [];
		}
	}
	
	this.fire = function(signalName, data) {
		if (! handlers[signalName]) register(signalName);
		
		$.each(handlers[signalName], function(index, callback) {
			callback(data);
		});
	}
	
	this.watch = function(signalName, handler) {
		if (! handlers[signalName]) register(signalName);
		
		var signalId = 0;
		signalId = handlers[signalName].push(handler);
		
		return signalId;
	}
	
	this.unwatch = function(signalName, handlerID) {
		if (! handlers[signalName]) register(signalName);
		
		handlers[signalName].splice(handlerID - 1, 1);
	}
}

var parse_locale_code = function(locale) {
	var data = {};
	
	var modifier = locale.split('@', 1);
	data['modifier'] = modifier[1];
	
	var codeset = modifier[0].split('.', 1);
	data['codeset'] = codeset[1];
	
	var territory = codeset[0].split('_', 1);
	data['territory'] = territory[1];
	
	data['language'] = territory[0];
	
	return data;
}

