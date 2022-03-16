$( document ).ready(function() {
	$("h2").each(function(i) {
		$(this).text(v.upperCase($(this).text()));
	})
});