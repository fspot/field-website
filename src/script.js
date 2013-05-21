$(function() {

	var initialMiddle = window.location.hash.substring(1) || "accueil";
	var currentMiddle = $("#middle-" + initialMiddle);
	$("a[data-middle='" + initialMiddle + "']").addClass('selected');
	currentMiddle.slideToggle();

	function switchTo(newMiddle) {
		currentMiddle.slideToggle(200, function() {
			$("#middle-" + newMiddle).slideToggle(200, function() {
				currentMiddle = $("#middle-" + newMiddle);
				window.location.hash = newMiddle;
				switching = false;
			});
		});
	}

	var switching = false;
	$('nav li a').on('click', function() {
		if (switching)
			return false;

		switching = true;
		$('.selected').removeClass('selected');
		$(this).addClass('selected');
		switchTo($(this).data("middle"));
		return false;
	});

	$('#middle-accueil a').on('click', function() {
		var navlink = $("nav a[data-middle='" + $(this)[0].dataset.middle + "']");
		navlink.click();
	});

});
