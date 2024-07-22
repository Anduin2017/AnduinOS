/*
Slideshow script for ubiquity-slideshow, global to all variations.

* Interprets parameters passed via location.hash (in #?param1=key?param2 format)
* Creates an animated slideshow inside the #slideshow element.
* Automatically loads a requested locale, based on the default slides.
* Manages slideshow controls, if requested via parameters.

Assumptions are made about the design of the html document this is inside of.
Please see slides/ubuntu/index.html for an example of this script in use.

Please include this script last, after any other scripts.


Dependencies (please load these first):
link-core/jquery.js
link-core/jquery.cycle.all.js
link-core/signals.js
*/

/* Pass parameters by creating a global SLIDESHOW_OPTIONS object, containing
   any options described at <http://jquery.malsup.com/cycle/options.html>
   
   The default callback for cycle.next also checks an extra autopause parameter,
   which will pause the slideshow when it reaches the end (but doesn't stop it)
   
   Signals: slideshow-loaded
            slideshow-started
            slide-opening
            slide-opened
            slide-closing
            slide-closed
*/

var slideshow;

var directory = {};
var extra_directory = {};

$(document).ready(function() {
	function loadExtraSlides() {
		$.ajax({
			type: 'GET',
			url: 'extra/directory.jsonp',
			dataType: 'jsonp',
			jsonpCallback: 'ubiquitySlideshowDirectoryCb',
			success: function(data, status, xhr) {
				extra_directory = $.extend(extra_directory, data);
			},
			complete: function(xhr, status) {
				slideshowReady();
			}
		});
	}
	
	$.ajax({
		type: 'GET',
		url: 'directory.jsonp',
		dataType: 'jsonp',
		jsonpCallback: 'ubiquitySlideshowDirectoryCb',
		success: function(data, status, xhr) {
			directory = $.extend(directory, data);
		},
		complete: function(xhr, status) {
			loadExtraSlides();
		}
	});
});

function slideshowReady() {
	slideshow = $('#slideshow');
	
	var slideshow_options = {
		fx:'scrollHorz',
		timeout:45000,
		speed:500,
		nowrap:false,
		autopause:true,
		manualTrump:false,
	};
	
	$.extend(slideshow_options, window.SLIDESHOW_OPTIONS);
	
	if ( 'rtl' in INSTANCE_OPTIONS )
		$(document.body).addClass('rtl');
	
	var locale = INSTANCE_OPTIONS['locale'] || 'C';
	loadSlides(locale);
	
	Signals.fire('slideshow-loaded');
	
	slideshow_options.before = function(curr, next, opts) {
		if ($(next).data('last')) {
			$('#next-slide').addClass('disabled').fadeOut(slideshow_options.speed);
		} else {
			$('#next-slide').removeClass('disabled').fadeIn(slideshow_options.speed);
		}
		
		if ($(next).data('first')) {
			$('#prev-slide').addClass('disabled').fadeOut(slideshow_options.speed);
		} else {
			$('#prev-slide').removeClass('disabled').fadeIn(slideshow_options.speed);
		}
		
		Signals.fire('slide-closing', $(curr));
		Signals.fire('slide-opening', $(next));
	}
	
	slideshow_options.after = function(curr, next, opts) {
		var index = opts.currSlide;
		/* pause at last slide if requested in options */
		if ( index == opts.slideCount - 1 && opts.autopause ) {
			slideshow.cycle('pause'); /* slides can still be advanced manually */
		}
		
		Signals.fire('slide-closed', $(curr));
		Signals.fire('slide-opened', $(next));
	}
	
	var controls = $('#controls');
	if ( 'controls' in INSTANCE_OPTIONS ) {
		var debug_controls = $('#debug-controls');
		if (debug_controls.length > 0) {
			debug_controls.show();
			controls = debug_controls;
		}
	}
	slideshow_options.prev = controls.children('#prev-slide');
	slideshow_options.next = controls.children('#next-slide');
	
	if ( 'slideNumber' in INSTANCE_OPTIONS )
		slideshow_options.startingSlide = INSTANCE_OPTIONS['slideNumber'];
	
	if (slideshow.children().length > 1) {
		slideshow.cycle(slideshow_options)
		Signals.fire('slideshow-started');
	} else {
		$('#prev-slide').addClass('disabled').hide();
		$('#next-slide').addClass('disabled').hide();
	}
};

function getTranslatedFile(locale, file_name, file_category) {
	var territory = locale.split(".",1)[0];
	var language = territory.split("_",1)[0];
	
	return tryFileLocale(locale, file_name, file_category) ||
	       tryFileLocale(territory, file_name, file_category) ||
	       tryFileLocale(language, file_name, file_category) ||
	       tryFileLocale('C', file_name, file_category);
	
	function tryFileLocale(locale, file_name, file_category) {
		if (translationFileExists(extra_directory, locale, file_name, file_category)) {
			// extra_directory can override slides from any locale, including C
			return './extra/'+locale+'/'+file_name;
		} else if (locale == 'C') {
			return './'+file_name;
		} else if (translationFileExists(directory, locale, file_name, file_category)) {
			return './l10n/'+locale+'/'+file_name;
		} else {
			return undefined;
		}
	}
	
	function translationFileExists(directory, locale, file_name, file_category) {
		return locale in directory &&
		       file_category in directory[locale] &&
		       directory[locale][file_category].indexOf(file_name) >= 0;
	}
}

function loadSlides(locale) {
	var selected_slidesets = []
	if ( 'slidesets' in INSTANCE_OPTIONS )
		selected_slidesets = INSTANCE_OPTIONS['slidesets'].split(' ');
	
	function slideIsVisible(slide) {
		var slidesets = $(slide).data('slidesets');
		var is_visible = true;
		if ( slidesets !== undefined ) {
			is_visible = false;
			$.each(slidesets.split(' '), function(index, slideset) {
				if ($.inArray(slideset, selected_slidesets) >= 0) {
					is_visible = true;
				}
			});
		}
		return is_visible;
	}
	
	function translateSlideContents(locale, contents) {
		// Warning: this assumes all images are local.
		// TODO: Only translate images selected by $(img.translatable)
		var images = $('img', contents);
		$.each(images, function(index, image) {
			var image_name = $(image).attr('src');
			var translated_image = getTranslatedFile(locale, image_name, 'media');
			$(image).attr('src', translated_image);
		});
	}
	
	slideshow.children('div').each(function(index, slide) {
		if ( slideIsVisible($(slide)) ) {
			var slide_name = $(slide).children('a').attr('href');
			var translated_slide = getTranslatedFile(locale, slide_name, 'slides');
			
			$.ajax({
				type: 'GET',
				url: translated_slide,
				cache: false,
				async: false,
				success: function(data, status, xhr) {
					$(data).appendTo(slide);
					translateSlideContents(locale, slide);
				}
			});
		} else {
			$(slide).detach();
		}
	});
	
	slideshow.children('div').first().data('first', true);
	slideshow.children('div').last().data('last', true);
}

