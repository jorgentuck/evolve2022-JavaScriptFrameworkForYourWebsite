$(function(){
	// alert dismissal [START]
	$('#close-alert').on('click', function(e){
		var name = $(this).data('dismissal-cookie-name');
		var hours = $(this).data('dismissal-cookie-lifespan');
		
		if(!isValidPositiveNumber(hours)){
			hours = 1;
		}
		
		createCookie(name, '1', hours);
	});
	
	if($('#close-alert').length){
		var name = $('#close-alert').data('dismissal-cookie-name');
		if(readCookie(name) != '1'){
			$('#alert-notification').show();
		}
	}
	// alert dismissal [END]
	
	// common functions [START]
	function isValidPositiveNumber(str){
		var regex = /^(0|0\.\d+|[1-9]\d*|[1-9]\d*\.\d+)$/;
		
		return regex.test(str);
	}
	
	function createCookie(name,value,hours) {
		if (hours) {
			var date = new Date();
			date.setTime(date.getTime()+(hours*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		document.cookie = name+"="+value+expires+"; path=/";
	}
	function readCookie(name) {
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	}
	function eraseCookie(name) {
		createCookie(name,"",-1);
	}
	// common functions [END]
});