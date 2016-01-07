console.log("--------- in background.js ---------------");

chrome.browserAction.onClicked.addListener(
	function(tab){
		console.log("chrome.browserAction.onClicked\n"+tab);
		push(tab);
	}
)

console.log("--------- leaving background.js ---------------");

// chrome.browserAction.onClicked
// dictate('js: body.style.width="660px";header.style.fontSize="0.6em";outputbox.style.fontSize="0.8em"')
// React when a browser action's icon is clicked.
//chrome.browserAction.onClicked.addListener(function(tab){
//  var viewTabUrl = chrome.extension.getURL('image.html');
//  var imageUrl = /* an image's URL */;
//
//  // Look through all the pages in this extension to find one we can use.
//  var views = chrome.extension.getViews();
//  for (var i = 0; i < views.length; i++) {
//    var view = views[i];
//
//    // If this view has the right URL and hasn't been used yet...
//    if (view.location.href == viewTabUrl && !view.imageAlreadySet) {
//
//      // ...call one of its functions and set a property.
//      view.setImageUrl(imageUrl);
//      view.imageAlreadySet = true;
//      break; // we're done
//    }
//  }
// });