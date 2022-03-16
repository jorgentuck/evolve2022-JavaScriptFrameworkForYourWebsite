

//Adds auto focus to search when opened
$('#siteSearch').on("shown.bs.modal", function() {
     $("body").addClass("modal-open-search");
    $('#siteSearch .form-text').focus();
  });
 $('#siteSearch').on("hide.bs.modal", function() {
    $("body").removeClass("modal-open-search");
  }); 

$('#site-navigation').on("shown.bs.modal", function() {
     $("body").addClass("modal-open-menu-mobile");
  });
 $('#site-navigation').on("hide.bs.modal", function() {
    $("body").removeClass("modal-open-menu-mobile");
  }); 

//Sub-menu Item options
$( document ).ready( function () {
    $( '.dropdown-menu a.dropdown-toggle' ).on( 'click', function (event) {
        event.preventDefault(); 
		event.stopPropagation(); 
        var $el = $( this );
        var $parent = $( this ).offsetParent( ".dropdown-menu" );
        if ( !$( this ).next().hasClass( 'show' ) ) {
            $( this ).parents( '.dropdown-menu' ).first().find( '.show' ).removeClass( "show" );
        }
        var $subMenu = $( this ).next( ".dropdown-menu" );
        $subMenu.toggleClass( 'show' );
        
        $( this ).parent( "li" ).toggleClass( 'show' );

        $( this ).parents( 'li.nav-item.dropdown.show' ).on( 'hidden.bs.dropdown', function (event) {
event.preventDefault(); 
event.stopPropagation(); 
            $( '.dropdown-menu .show' ).removeClass( "show" );
        } );
        return false;
    } );
} );

//Adds open class to top nav items on hover for background color
$('.dropdown').hover(
       function(){ $(this).addClass('open') },
       function(){ $(this).removeClass('open') }
);
$('.dropdown').click(
       function(){ $(this).addClass('open') },
       function(){ $(this).removeClass('open') }
);
$('.menuClose').click(
    function(){ $('.modal').modal('hide') }
);
$('.close').click(
    function(){ $('.modal').modal('hide') }
);

jQuery(document).ready(function($) {
  var alterClass = function() {
    var ww = document.body.clientWidth;
    if (ww >= 1200) {
      $('.modal').modal('hide');
    } 
  };
  $(window).resize(function(){
    alterClass();
  });
  //Fire it when the page first loads:
  alterClass();
});

// Sticky Header
$(window).on("scroll load", function() {
	if ($(this).scrollTop() > 100){  
		$('.sticky-wrapper').addClass("sticky-header-show");
	}
	else{
		$('.sticky-wrapper').removeClass("sticky-header-show");
	}
});

$('.emergency-alert').on('closed.bs.alert', function () {
  $("body").removeClass("alert-visible");
})

if ($('.emergency-alert').length > 0) {
   $("body").addClass("alert-visible");
}

//Scroll to top button
jQuery(document).ready(function($){
	// browser window scroll (in pixels) after which the "back to top" link is shown
	var offset = 300,
		//browser window scroll (in pixels) after which the "back to top" link opacity is reduced
		offset_opacity = 1200,
		//duration of the top scrolling animation (in ms)
		scroll_top_duration = 700,
		//grab the "back to top" link
		$back_to_top = $('.cd-top');

	//hide or show the "back to top" link
	$(window).scroll(function(){
		( $(this).scrollTop() > offset ) ? $back_to_top.addClass('cd-is-visible') : $back_to_top.removeClass('cd-is-visible cd-fade-out');
		if( $(this).scrollTop() > offset_opacity ) { 
			$back_to_top.addClass('cd-fade-out');
		}
	});

	//smooth scroll to top
	$back_to_top.on('click', function(event){
		event.preventDefault();
		$('body,html').animate({
			scrollTop: 0 ,
}, scroll_top_duration
		);
	});

});

$(document).ready(function() {	
// Select all links with hashes
$('a[href*="#"]')
  // Remove links that don't actually link to anything
  .not('[href="#"]')
  .not('[href="#0"]')
  .not('[data-toggle]')
  .click(function(event) {
    // On-page links
    if (
      location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') 
      && 
      location.hostname === this.hostname
    ) {
      // Figure out element to scroll to
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
      // Does a scroll target exist?
      if (target.length) {
        // Only prevent default if animation is actually gonna happen
        event.preventDefault();
        $('html, body').animate({
          scrollTop: target.offset().top
        }, 1000, function() {
          // Callback after animation
          // Must change focus!
          var $target = $(target);
          $target.focus();
          if ($target.is(":focus")) { // Checking if the target was focused
            return false;
          } else {
            $target.attr('tabindex','-1'); // Adding tabindex for elements not focusable
            $target.focus(); // Set focus again
          }
        });
      }
    }
  });

  });

/*
 * Bootstrap Cookie Alert 
 */
(function () {
    "use strict";

    var cookieAlert = document.querySelector(".cookiealert");
    var acceptCookies = document.querySelector(".acceptcookies");

    if (!cookieAlert) {
       return;
    }

    cookieAlert.offsetHeight; // Force browser to trigger reflow (https://stackoverflow.com/a/39451131)

    // Show the alert if we cant find the "acceptCookies" cookie
    if (!getCookie("acceptCookies")) {
        cookieAlert.classList.add("show");
    }

    // When clicking on the agree button, create a 1 year
    // cookie to remember user's choice and close the banner
    acceptCookies.addEventListener("click", function () {
        setCookie("acceptCookies", true, 365);
        cookieAlert.classList.remove("show");
    });

    // Cookie functions from w3schools
    function setCookie(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }

    function getCookie(cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) === ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) === 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
})();





//Home Hero Slider
if (document.querySelector('.hero-slider') !== null) {
$(document).ready(function(){	
$(".hero-slider").slick({
        dots: false,
        infinite: true,
        fade: true,
        slidesToShow: 1,
        slidesToScroll: 1,
		accessibility: true,
		autoplay: true,
        appendArrows: '.slide-controllers',
		focusOnSelect: true,
		pauseOnHover: false,
		speed:900,
		autoplaySpeed: 7000
      });
    
 if ($('.slick-slide').hasClass('slick-active')) {
    $('.carousel-caption').addClass('animated');
  } else {
    $('.carousel-caption').removeClass('animated');
  }
  $(".hero-slider").on("beforeChange", function() {
    $('.carousel-caption').removeClass('animated').hide();
    setTimeout(() => {    
      $('.carousel-caption').addClass('animated').show();
    }, 1000);
})
    
    var xpaused = false;

$(".pause-play").on("click", function() {
if( xpaused ) {
$(".hero-slider").slick("play");
  } else {
$(".hero-slider").slick("pause");
  }
  xpaused = !xpaused;
  $(this).toggleClass( "paused" );
});
});
}

$(document).ready(function () {
	var playing = true;
	$('.play-pause').click(function () {
	if (playing == false) {
	document.getElementById('myVideo').play();
	playing = true;
	$(this).html("<span class='fa fa-pause'></span>");
} else {
	document.getElementById('myVideo').pause();
	playing = false;
	$(this).html("<span class='fa fa-play'></span>");
	}
	});
});

//Gallery Slider
if (document.querySelector('.gallery-slider') !== null) {
$(document).ready(function(){	
$(".gallery-slider").slick({
        dots: true,
        infinite: true,
        slidesToShow: 1,
        slidesToScroll: 1,
		accessibility: true,
		autoplay: false,
		focusOnSelect: true,
		pauseOnHover: false
      });
});
}

if (document.querySelector('.gallery-slider') !== null) {
$(document).ready(function(){
      $('.gallery-slider').slickLightbox({
        itemSelector: '.slide > a',
          caption: 'caption'
      });
    });
}

if (document.querySelector('.testimonial-slider') !== null) {
$(document).ready(function(){	
$(".testimonial-slider").slick({
        dots: false,
        infinite: true,
        slidesToShow: 1,
        slidesToScroll: 1,
		accessibility: true,
		autoplay: false,
		focusOnSelect: true,
		pauseOnHover: false,
		speed:900,
		autoplaySpeed: 10000
      });
    });
}