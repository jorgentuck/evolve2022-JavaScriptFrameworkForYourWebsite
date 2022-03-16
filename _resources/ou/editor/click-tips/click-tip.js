//JSON object for the Click Tips
var ouClickTipObject = [
	// {
		// "id" : "the id of the element you want the click tip appear on. (required)"
		// "headingText" : "the heading of the modal when clicked (required)"
		// "bodyContent" : "the content of the modal (required), make sure to escape double quotes: <a href=\"https://google.com\">Learn more</a>"
		// "buttonTitle" : "the title when the user hovers over the button (required)"
		// "topIndent" : "how far down you want the button to appear on the element, must be a number, can be negative, default is "0" (optional)"
		// "leftIndent" : "how idented you want the button from the left side, must be a number, can be negative, default is "0" (optional)"
		// "openButtonText" : "the click tip button text for the element, default is "?" (optional)"
		// "backgroundColor" : "the background color of the click tip button, default is "#000000" (optional)"
		// "textColor" : "the text color of the click tip button, default is "#FFFFFF" (optional)"
		// "borderColor" : "the border color of the click tip button, default is "#FFFFFF" (optional)"
	// }
];

// do not edit below this line
Object.size = function(obj) {
	var size = 0;
	for (var key in obj) { if (obj.hasOwnProperty(key)) size++; }
	return size;
};

var modal = document.getElementById('ou-click-tip-modal');

document.getElementsByClassName("ou-click-tip-modal-close")[0].onclick = function() { modal.style.display = "none"; }
window.onclick = function(e) { (e.target == modal) ? modal.style.display = "none" : "";  }
document.onkeyup = function(e) { (e.keyCode == 27) ? modal.style.display = "none" : ""; };

function setAttributes(el, attrs) { for (var key in attrs) { el.setAttribute(key, attrs[key]); } }

var ouClickTipObjectSize = Object.size(ouClickTipObject);
window.onload = function() {
	for (var i = 0; i < ouClickTipObjectSize; i++){
		var current = ouClickTipObject[i];
		var currentId = document.getElementById(current.id);
		currentId.style.display = "block";
		var topIndent = current.topIndent || 0;
		var leftIndent = current.leftIndent || 0;
		currentId.style.top = currentId.nextElementSibling.offsetTop + topIndent + "px";
		currentId.style.marginLeft = leftIndent + "px";
		currentId.innerHTML = current.openButtonText || "?";
		currentId.style.backgroundColor = current.backgroundColor || "#000000";
		currentId.style.color = current.textColor || "#FFFFFF";
		currentId.style.borderColor = current.borderColor || "#FFFFFF";
		setAttributes (currentId, {"title": current.buttonTitle, "data-header": encodeURIComponent(current.headingText), "data-body": encodeURIComponent(current.bodyContent)});
		currentId.onclick = function(e) {
			// determine the header
			var header = (decodeURIComponent(e.target.getAttribute("data-header")) == "null") ? decodeURIComponent(e.target.parentElement.getAttribute("data-header")) : decodeURIComponent(e.target.getAttribute("data-header"));
			// determine the footer
			var body = (decodeURIComponent(e.target.getAttribute("data-body")) == "null") ? decodeURIComponent(e.target.parentElement.getAttribute("data-body")) : decodeURIComponent(e.target.getAttribute("data-body"));
			document.getElementById("ou-click-tip-modal-title").innerHTML = header;
			document.getElementById("ou-click-tip-paragraph").innerHTML = body;
			modal.style.display = (modal.style.display == "block") ? modal.style.display = "none" : modal.style.display = "block";
		}
	}
}