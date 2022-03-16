<?php

date_default_timezone_set('America/Los_Angeles');

// 	error_reporting( E_ALL );
// 	ini_set('display_errors', 1);

require_once('_core/class.dmc.php');

$eventsDMC = new EventsDMC(); // optionally pass an alternate root relative path to data folder. Default is "/_resources/data/".

if(str_replace('\\', '/', strtolower(__FILE__)) == str_replace('\\', '/', strtolower($_SERVER['SCRIPT_FILENAME'])) && isset($_GET['datasource']) && $_GET['datasource'] != ''){
	get_events_dmc_output(array('endpoint' => true));
}

function get_events_dmc_output($options){
	global $eventsDMC;
	return $eventsDMC->get_output($options);
}

class EventsDMC {

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
			case 'listing':
			$templating_function = 'render_listing';
			$resultSet = $this->remove_past_dates($resultSet);
			break;
			case 'event_items':
			$templating_function = 'render_event_items';
			$resultSet = $this->remove_past_dates($resultSet);
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




	public function render_event_items($resultSet){
		$output = "";
		$items = $resultSet['items'];
		$title = $resultSet['meta']['options']['title'];

		foreach ($items as $i) {
			$description = $this->str_trim($i->summary, 90);
			
			$url = $i->attributes()->href;
			$month = date("M", strtotime($i->item_date));
			$year = date("Y", strtotime($i->item_date));
			$day = date("j", strtotime($i->item_date));
			$startTime = date("g:i a", strtotime($i->item_date));

			$startTime = ltrim($startTime, '0');


			$output .=  '	<div class="event-item">';
			$output .=  '	<div class="event-date">';
			$output .=  '		<div class="event-date-bg"><span class="event-month">'.$month.'</span> <span class="event-day">'.$day.'</span> <span class="year">'.$year.'</span></div>';
			$output .=  '		</div>';
			$output .=  '		<div class="event-text">';
			$output .=  '	<div class="event-item-time-location"><span class="time">'.$startTime.'</span> <span class="location">'.$i->location.'</span></div>';
			$output .=  '<div class="event-item-header">';
			$output .=  '<h3><a href="'.$url.'" class="event-title">'.$i->title.'</a></h3>';
			$output .=  '</div>';
			$output .=  '<div class="event-item-copy">';
			$output .=  '<p>'.$description.'</p>';
			$output .=  '</div></div></div>';
		}

		return $output;
	}




	public function render_details($resultSet){
		$output = "";
		$items = $resultSet['items'];

		foreach($items as $i){
			$office = "{$i->building} {$i->room_number}";
			$phone = $this->format_phone($i->phone);
			$output .= "<h2>{$i->first_name} {$i->LAST_NAME}</h2>";
			if($i->title != '' || $i->department != ''){
				$output .= '<p>';
				$output .= '	<strong>';

				if($i->title != '') $output .= $i->title;
				if($i->title != '' && $i->department != '') $output .= ', ';
				if($i->department != '') $output .= $i->department;

				$output .= '	</strong>';
				$output .= '</p>';
			}

			if($office != '') $output .= "<p>Office: {$office}</p>";
			if($phone != '') $output .= "<p>Phone: {$phone}</p>";
			if($i->email != '') $output .= "<p>E-mail: {$i->email}</p>";
		}

		return $output;
	}


	//CARD VERSION 1

	public function render_listing($resultSet){
		$output = "";
		$pagination = $this->render_pagination($resultSet);
		$style = $resultSet['meta']['options']['style'];
		$items = $resultSet['items'];
		foreach($items as $i){
			$description = $this->str_trim($i->summary, 280);
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
			$output .= '<div class="title-decorative">'.date("F j, Y", strtotime($i->item_date)).' | '.date("g:i a", strtotime($i->item_date)). ' | '.$i->location;
			$output .= '</div>';
			$output .= '<p>'.$description.' <a href="'.$url.'">Read more</a></p>';
			$output .= '<p><a class="btn btn-default" href="'.$url.'">View Event</a></p>';
			$output .= '</div>';
			$output .= '</div>';
		}
		return $output . $pagination ;
	}





	private function render_filter_form($resultSet){
		$items_per_page_options = array(
			"5"=>"5",
			"10"=>"10",
			"20"=>"20",
			"30"=>"30",
			"40"=>"40",
			"50"=>"50",
			"100"=>"100",
			"200"=>"200",
			""=>"All"
		);


		$result = '';
		$result .= '<form>';
		$result .= '<div class="large-12 columns">';
		$result .= '	<div class="row collapse">';
		$result .= '		<div class="small-4 columns">';
		$result .= '			<label>Items per Page';
		$result .= '				<select name="items_per_page">';
		foreach ($items_per_page_options as $key => $val){ 
			$result .= '<option value="'.$key.'"';
			if($key == $resultSet['meta']['options']['items_per_page']) $result .= ' selected';
			$result .= '>'.$val.'</option>';

		}
		$result .= '				</select>';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '		<div class="small-6 columns">';
		$result .= '			<label>Search Phrase';
		$result .= '				<input type="text" name="search_phrase" value="'.$resultSet['meta']['options']['search_phrase'].'">';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '		<div class="small-2 columns">';
		$result .= '			<label>&nbsp;';
		$result .= '				<input type="submit" class="button postfix" value="search" />';
		$result .= '			</label>';
		$result .= '		</div>';
		$result .= '	</div>';
		$result .= '</div>';
		$result .= $this->build_hidden_inputs($resultSet);
		$result .= '</form>';
		return $result . '<br style="clear:right;" />';

	}

	private function remove_past_dates($resultSet){
		$result_items = array();
		$now = new DateTime('today'); // begining of the current day

		foreach($resultSet['items'] as $i){
			$date = new DateTime($i->item_date);

			if($date >= $now) $result_items[] = $i;
		}

		$resultSet['items'] = $result_items;
		$resultSet['meta']['total'] = count($resultSet['items']);

		return $resultSet;
	}

	private function build_hidden_inputs($resultSet){
		$result = '';

		$result .= '<input type="hidden" name="sort" value="'.$resultSet['meta']['options']['sort'].'" />';
		$result .= '<input type="hidden" name="page" value="1" />';

		return $result;
	}

	private function render_pagination($resultSet){
		$result = '';

		if(!isset($resultSet['meta']['pagination'])) return $result;

		$totalPages = $resultSet['meta']['pagination']['page_count'];
		$page = $resultSet['meta']['pagination']['current_page'];
		if($totalPages < 2) return ''; // only return the pagination if there are more than 1 page.
		$previousPage = $page - 1;
		$nextPage = $page + 1;

		$query_string = $_SERVER['QUERY_STRING'];
		$result .= '<nav aria-label="Page navigation"><ul class="pagination pull-right">';
		if($previousPage > 0){
			$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $previousPage) . '">« <span class="sr-only">Previous</span></a></li>';
		}
		for ($i = 1; $i <= $totalPages; $i++) {
			if($i == $page){
				$result .= '    <li class="page-item active"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}else{
				$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}
		}
		if($nextPage <= $totalPages){
			$result .= '    <li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $nextPage) . '"><span class="sr-only">Next</span> »</a></li>';    
		}
		$result .= '</ul></nav>';
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