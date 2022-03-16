<?php

date_default_timezone_set('America/Los_Angeles');

// 	error_reporting( E_ALL );
// 	ini_set('display_errors', 1);

require_once('_core/class.dmc.php');

$newsDMC = new NewsDMC(); // optionally pass an alternate root relative path to data folder. Default is "/_resources/data/".

if(str_replace('\\', '/', strtolower(__FILE__)) == str_replace('\\', '/', strtolower($_SERVER['SCRIPT_FILENAME'])) && isset($_GET['datasource']) && $_GET['datasource'] != ''){
	get_news_dmc_output(array('endpoint' => true));
}

function get_news_dmc_output($options){
	global $newsDMC;
	return $newsDMC->get_output($options);
}

class NewsDMC {

	private $dmc;

	public function __construct($data_folder = null){
		$this->dmc = new DMC($data_folder);
	}

	public function get_output($options){
		$resultSet = $this->dmc->getResultSet($options);
		$templating_function = '';

		switch($resultSet['meta']['options']['type']){
			case 'details':
			$templating_function = 'render_details';
			break;
			case 'featured':
			$templating_function = 'render_featured';
			break;
			case 'listing':
			$templating_function = 'render_listing';
			break;		
			case 'related':
			$templating_function = 'render_related';
			break;
			case 'news_feed':
			$templating_function = 'render_news_feed';
			// 			$category = isset($_GET['category']) ? $_GET['category'] : '';
			// 			if($category != ''){
			// 				$resultSet = $this->dmc->xpathFilter($resultSet, "category[text()='" . $category . "']");
			// 			}
			break;
		}

		//$resultSet = $this->dmc->xpathFilter($resultSet, "node()[name()='FIRST_NAME' or name()='LAST_NAME'][starts-with(text(), 'P')]");
		$resultSet = $this->dmc->search($resultSet);
		$resultSet = $this->dmc->distinct($resultSet);
		$resultSet = $this->dmc->sort($resultSet);
		$resultSet = $this->dmc->truncate($resultSet);
		$resultSet = $this->dmc->paginate($resultSet);
		$resultSet = $this->dmc->select($resultSet);

		//echo 'Current PHP version: ' . phpversion();
		echo $this->dmc->render($resultSet, array($this, $templating_function));
	}

	public function render_details($resultSet){
		$output = "";
		$items = $resultSet['items'];

		foreach($items as $i){
			$office = "{$i->BUILDINGNAME} {$i->BLDGROOM}";
			$phone = $this->format_phone($i->PHONE);

			$output .= "<h2>{$i->FIRST_NAME} {$i->LAST_NAME}</h2>";
			if($i->TITLE != '' || $i->DEPARTMENT != ''){
				$output .= '<p>';
				$output .= '	<strong>';

				if($i->TITLE != '') $output .= $i->TITLE;
				if($i->TITLE != '' && $i->DEPARTMENT != '') $output .= ', ';
				if($i->DEPARTMENT != '') $output .= $i->DEPARTMENT;

				$output .= '	</strong>';
				$output .= '</p>';
			}

			if($office != '') $output .= "<p>Office: {$office}</p>";
			if($phone != '') $output .= "<p>Phone: {$phone}</p>";
			if($i->EMAIL != '') $output .= "<p>E-mail: {$i->EMAIL}</p>";
		}

		return $output;
	}

	public function render_featured($resultSet){
		$output = "";
		$items = $resultSet['items'];
		$position = $resultSet['meta']['options']['position'];

		foreach($items as $i){
			$description = $this->str_trim($i->summary, 305);
			$href = $i->attributes()->href;
			if ($i->thumbnail->img->attributes()->src !='') {
				$thumbnail = $i->thumbnail->img->attributes()->src;
				$thumbnailAlt = $i->thumbnail->img->attributes()->alt;
			} else {
				$thumbnail = '/_resources/images/news-image-placeholder.jpg';
				$thumbnailAlt = 'News Placeholder';
			}

			if ($position == 1) {
				$output .= '<div class="card white">';
				$output .= '<img src="'.$thumbnail.'" class="card-img-top" alt="'.$thumbnailAlt.'"/>';
				$output .= '<div class="card-body">';
				$output .= '<h2 class="card-title">'.$i -> title.'</h2>';
				$output .= '<p class="card-text pb-1">'.$description.' <a href="'.$href.'">Read more</a></p>';
				$output .= '</div></div>';
			} 

			else {
				if ($position == 2) {
					$output .= '<div class="card card-img-side">';	
				} else  {
					$output .= '<div class="card card-img-side mt-4">';	
				}
				$output .= '<div class="row no-gutters"><div class="col-md-5">';
				$output .= '<div class="image-overlay"><div class="card-img" style="background-image: url(&apos;'.$thumbnail.'&apos;);"></div></div>';
				$output .= '</div><div class="col-md-7">';
				$output .= '<div class="card-body">';
				$output .= '<h3 class="card-title">'.$i->title.'</h3>';
				$output .= '<p class="card-text">'.$description.'<br/><a href="'.$href.'"> Read more</a></p>';
				$output .= '</div></div></div></div>';
			}
		}

		return $output;
	}


	public function render_listing($resultSet){
		$output = "";
		$pagination = $this->render_pagination($resultSet);
		$style = $resultSet['meta']['options']['style'];
		$items = $resultSet['items'];
		foreach($items as $i){
			$description = $this->str_trim($i->summary, 305);
			$url = $i->attributes()->href;

			if ($style =='narrow') {
				$imageContainer = "col-lg-4";
				$contentContainer = "col-lg-8";
			} else {
				$imageContainer = "col-md-4 col-lg-3";
				$contentContainer = "col-md-8 col-lg-9";
			}

			if ($i->thumbnail->img->attributes()->src !='') {
				$thumbnail = $i->thumbnail->img->attributes()->src;
				$thumbnailAlt = $i->thumbnail->img->attributes()->alt;
			} else {
				$thumbnail = '/_resources/images/news-image-placeholder.jpg';
				$thumbnailAlt = 'News Placeholder';
			}

			$output .= '<div class="row mb-4 news-list">
				<div class="'.$imageContainer.'">
					<img src="'.$thumbnail.'" alt="'.$thumbnailAlt.'">	
		       </div>
				<div class="'.$contentContainer.'">';
			$output .= '<h2>'.$i->title.'</h2>';
			$output .= '<div class="title-decorative">'.date("F j, Y", strtotime($i->item_date)).'';
			if ($i->author != '') {
				$output .=' | By '.$i->author.'</div>';	
			} else {
				$output .= '</div>';
			}
			$output .= '<p>'.$description.' <a href="'.$url.'">Read more</a></p>';
			$output .= '<p><a class="btn btn-default" href="'.$url.'">Read the full article</a></p>';
			$output .= '</div>';
			$output .= '</div>';
		}
		return $output . $pagination ;
	}

	public function render_news_feed($resultSet){
		$output = "";
		$items = $resultSet['items'];
		foreach($items as $i){
			$url = $i->attributes()->href;
			$description = $this->str_trim($i->summary, 90);
			if ($i->thumbnail->img->attributes()->src !='') {
				$thumbnail = $i->thumbnail->img->attributes()->src;
				$thumbnailAlt = $i->thumbnail->img->attributes()->alt;
			} else {
				$thumbnail = '/_resources/images/news-image-placeholder.jpg';
				$thumbnailAlt = 'News Placeholder';
			}
			$output .= '<div class="col-lg-6">';
			$output .= '<div class="card"><a href="'.$url.'">';
			$output .= '<div class="image-overlay"><div class="card-img-top" style="background-image: url(&apos;'.$thumbnail.'&apos;);"></div></div>';
			$output .= '<div class="card-body">';
			$output .= '<h3>'.$i->title.'</h3>';
			$output .= '<p>'.$description.'</p>';
			$output .= '</div></a></div></div>';
		}
		return $output ;
	}


	public function render_related($resultSet){
		$output = "";
		$items = $resultSet['items'];
		$count = count($items);

		if ($count > 0) {
			$output .= '<h2 class="side-nav-heading">Related Stories</h2>
					<nav class="navbar navbar-expand-lg navbar-light">
								<div class="navbar-brand d-lg-none">Navigate this section:</div>
								<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarToggler" aria-controls="navbarToggler" aria-expanded="false" aria-label="Toggle navigation">
									<span class="fas fa-chevron-down"></span>
									<span class="fas fa-chevron-up"></span>
								</button>
								<div class="navbar-collapse collapse" id="navbarToggler">
									<nav class="navbar navbar-expand-lg navbar-light">
										<ul id="side-nav-accordion" class="nav">';
			foreach($items as $i){
				$url = $i->attributes()->href;
				$output .= '<li class="nav-item"><a href="'.$url.'" class="nav-link">'.$i->title.'</a></li>';
			}
			$output .= '</ul></nav></div></nav>';
		}
		return $output;
	}


	private function render_pagination($resultSet){
		$result = '';

		if(!isset($resultSet['meta']['pagination'])) return $result;

		$totalPages = $resultSet['meta']['pagination']['page_count'];
		$page = $resultSet['meta']['pagination']['current_page'];

		$firstLinkedPage = $resultSet['meta']['pagination']['first_linked_page'];
		$lastLinkedPage = $resultSet['meta']['pagination']['last_linked_page'];

		if($totalPages < 2) return ''; // only return the pagination if there are more than 1 page.
		$previousPage = $page - 1;
		$nextPage = $page + 1;


		$query_string = $_SERVER['QUERY_STRING'];
		$result .= '<div class="row mb-5">
					<div class="col">
						<nav aria-label="Pagination">
							<ul class="pagination justify-content-center">';
		if($previousPage > 0){
			$result .= '    <li class="page-item"><a class="page-link" tabindex="-1" aria-label="Previous Page" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $previousPage) . '">Previous</a></li>';
		}

		if($firstLinkedPage > 1){
			$result .= '	<li class="page-item"><a class="page-link" tabindex="-1" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', 1) . '">1</a></li><li>...</li>';
		}


		for ($i = $firstLinkedPage; $i <= $lastLinkedPage; $i++) {
			if($i == $page){
				$result .= '	<li class="page-item active"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}else{
				$result .= '	<li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}
		}

		if($lastLinkedPage < $totalPages){
			$result .= '	<li  class="page-item">...</li><li><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $totalPages) . '">'.$totalPages.'</a></li>';
		}

		if($nextPage <= $totalPages){
			$result .= '<li class="page-item"><a class="page-link" aria-label="Next Page" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $nextPage) . '">Next</a></li>';    
		} else {
			$result .= '<li class="page-item disabled"><a class="page-link" aria-label="Next Page" href="#">Next</a></li>';    
		}
		$result .= '</ul>
						</nav>
					</div>
				</div>';
		return $result . '<br style="clear:right;" />';
	}



	private function format_phone($phone){
		$phone = preg_replace('/[\D]/', '', $phone); // remove non-digit characters

		if(strlen($phone) == 10){
			$phone = preg_replace('/^(.{3})(.{3})(.{4})$/', '($1) $2-$3', $phone);

			return $phone;
		}

		return '';
	}

	private function str_trim($txt, $limit){
		if (strlen($txt) <= $limit)
			return $txt;

		$space = strpos($txt, " ", ($limit - 5));
		return ($space > 0) ? substr($txt, 0, $space) . '...' : substr($txt, 0, $limit) . '...';
	}

}
?>