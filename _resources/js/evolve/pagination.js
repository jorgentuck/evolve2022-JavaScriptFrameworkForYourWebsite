//  global variables
//  array for data that will be listed
let newsData = [];
//  array to build department select
let deptArr = [];
//  array to hold ajax request response
let initData = [];
//  the listing div on the page
const listingDiv = $('#listingDiv');
//  the pagination div on the page
const pager = $('#pager');
//  get feed from data-fed attribute
const feed = listingDiv.attr('data-feed');

//  run once page is ready
$(document).ready(function () {
  //  function to gather feed data and set missing image defaults
  const populateData = () => {
    //  Get JSON data
    $.getJSON(feed, (data) => {
      //  for each item returned from the ajax call
      $.each(data, (k, v) => {
        //  check if displkay is set to true
        if (v.display == 'true') {
          //  set image alt text to title if it is missing
          v.image_alt = !v.image_alt == '' ? v.image_alt : v.title;
          //  set image src to the default if it is missing
          v.image_src = !v.image_src == '' ? v.image_src : 'https://picsum.photos/286/191?random=20' + k;
          //  Save array with updated values
          initData.push(v);
          //  add missing departments to array to create select list
          if (!deptArr.includes(v.department)) {
            deptArr.push(v.department);
          }
          //  create news card
          cardCreation(v);
        }
      });
      //  calling paginateData with a 1 to set current page to 1
      paginateData(1);
    });
  };
  //  call populateData after the page loads
  populateData();
});

//  create news card html and add it to the newsData array
function cardCreation(v) {
  newsData.push(
    `<div class="col-sm-4">
          <div class="card" style="width: 18rem;">
          <img src="` +
      v.image_src +
      `" class="card-img-top" alt="` +
      v.image_alt +
      `">
          <div class="card-body">
          <h5 class="card-title">` +
      v.title +
      `</h5>
          <h6 class="card-subtitle mb-2 text-muted">Dept: ` +
      v.department +
      `</h6>
          <p class="card-text">` +
      v.summary +
      `</p>
          <a href="` +
      v.url +
      `" class="btn btn-dark">Read More</a>
          </div>
          </div>
          </div>`
  );
}

//  display items and pagination
function paginateData(currentPage) {
  //  clear out listing area
  listingDiv.empty();
  //  clear out pagination area
  pager.empty();
  //  create appendData string to hold our new html
  let appendData = new String();
  //  set default items per page
  let perPage = 3;
  //  check to see if items per page are provided and ensure it is a valid number
  if (!isNaN(listingDiv.attr('data-perPage')) && listingDiv.attr('data-perPage') > 0) {
    perPage = parseInt(listingDiv.attr('data-perPage'));
  }
  //  set number of max pages to hold all items using the items per page
  const maxPages = parseInt((newsData.length - 1) / perPage) + 1;
  //  check to see if we are trying to view a page past the max, and set back to 1 if true
  if (currentPage > maxPages) {
    currentPage = 1;
  }
  //  add html for the container
  appendData = appendData.concat(`<div class="container-fluid row">`);
  //  loop over all items to display
  for (i = 0; i < newsData.length; i++) {
    //  check to see if it will fit on the current page
    if (i >= perPage * currentPage - perPage && i < perPage * currentPage) {
      //  add html for each item on the current page
      appendData = appendData.concat(newsData[i]);
    }
  }
  //  add html for closing container
  appendData = appendData.concat(`</div>`);
  //  add the html to the listing area
  listingDiv.append(appendData);
  //  check to see if current page is the first page or not to set previous button state
  if (currentPage == 1) {
    pager.append($('<a class="btn btn-dark mx-1 disabled" tabindex="-1" aria-label="Previous Page">Previous</a>'));
  } else {
    pager.append($('<a class="btn btn-dark mx-1" aria-label="Previous Page" href="javascript:paginateData(' + (currentPage - 1) + ')">Previous</a>'));
  }
  //  for all pages between first and max (last)
  for (let i = 1; i <= maxPages; i++) {
    //  mark current page as active
    if (i == currentPage) {
      pager.append($('<a class="btn btn-dark mx-1 active" tabindex="-1" href="javascript:paginateData(' + i + ')">' + i + '</a>'));
      //  as long as there are not too many pages add link for each
    } else if (i == 1 || i == maxPages || (Math.abs(i - currentPage) < 3 && maxPages > 7) || (((currentPage <= 3 && i <= 5) || (currentPage >= maxPages - 2 && i >= maxPages - 4)) && maxPages > 7) || maxPages <= 7) {
      ellipsis = false;
      pager.append($('<a class="btn btn-dark mx-1" href="javascript:paginateData(' + i + ')">' + i + '</a>'));
      //  if there are too many pages add "..."
    } else if (!ellipsis) {
      ellipsis = true;
      pager.append($('<a class="btn btn-dark mx-1 disabled" tabindex="-1" aria-label="...">...</a>'));
    }
  }
  //  check to see if current page is the last page or not to set next button state
  if (currentPage == maxPages) {
    pager.append($('<a class="btn btn-dark mx-1 disabled" tabindex="-1" aria-label="Next Page">Next</a>'));
  } else {
    pager.append($('<a class="btn btn-dark mx-1" aria-label="Next Page" href="javascript:paginateData(' + (currentPage + 1) + ')">Next</a>'));
  }
};
