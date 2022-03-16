<?php
	
	date_default_timezone_set('America/Los_Angeles');

	error_reporting( E_ALL );
	ini_set('display_errors', 1);

	require_once('_core/class.dmc.php');

	$genericDMC = new GenericDMC(); // optionally pass an alternate root relative path to data folder. Default is "/_resources/data/".

	if(str_replace('\\', '/', strtolower(__FILE__)) == str_replace('\\', '/', strtolower($_SERVER['SCRIPT_FILENAME'])) && isset($_GET['datasource']) && $_GET['datasource'] != ''){
		get_generic_dmc_output(array('endpoint' => true));
	}

	function get_generic_dmc_output($options){
		global $genericDMC;
		return $genericDMC->get_output($options);
	}

	class GenericDMC {

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
					break;
				case 'news':
					$templating_function = 'render_news';
					break;
				case 'events':
					$templating_function = 'render_events';
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
		
		public function render_news($resultSet){
			$output = "";
			$items = $resultSet['items'];

			$output .= '<ul class="small-block-grid-2 medium-block-grid-3 large-block-grid-4">';
			foreach($items as $i){
				//$image = $i->children('media', true)->content->attributes()->url;
				
				$output .= "	<li>";
				$output .= '		<div class="panel">';
				$output .= "			<h5>{$i->title}</h5>";
				$output .= "			<h6>" . date("F j, Y", strtotime($i->pubDate)) . "</h6>";
				//$output .= "			<p>{$i->description}</p>";
				$output .= "			<a href=\"{$i->link}\">Read Article</a>";
				$output .= "		</div>";
				$output .= "	</li>";
			}
			$output .= "</ul>";

			return $output;
		}
		
		public function render_events($resultSet){
			$output = "";
			$items = $resultSet['items'];

			$output .= '<ul class="small-block-grid-2 medium-block-grid-3 large-block-grid-4">';
			foreach($items as $i){
				//$image = $i->children('media', true)->content->attributes()->url;
				
				$output .= "	<li>";
				$output .= '		<div class="panel">';
				$output .= "			<h5>{$i->title}</h5>";
				$output .= "			<h6>" . date("F j, Y", strtotime($i->pubDate)) . "</h6>";
				//$output .= "			<p>{$i->description}</p>";
				$output .= "			<a href=\"{$i->link}\">Read Article</a>";
				$output .= "		</div>";
				$output .= "	</li>";
			}
			$output .= "</ul>";

			return $output;
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

		public function render_listing($resultSet){
			$output = "";
			$pagination = $this->render_pagination($resultSet);

			$items = $resultSet['items'];

			foreach($items as $i){
				$office = $i->BUILDINGNAME . ' ' . $i->BLDGROOM;
				$phone = $this->format_phone($i->PHONE);
				$href = $i->attributes()->href;

				if($href!=''){
					$output .= "<h2><a href=\"{$href}\">{$i->FIRST_NAME} {$i->LAST_NAME}</a></h2>";
				}else{
					$output .= "<h2>{$i->FIRST_NAME} {$i->LAST_NAME}</h2>";	
				}
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
			
			return $pagination . $output . $pagination;
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

			$result .= '<ul class="pagination pagination-lg pull-right">';
			if($previousPage > 0){
				$result .= '	<li><a href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $previousPage) . '">« <span class="sr-only">Previous</span></a></li>';
			}

			for ($i = 1; $i <= $totalPages; $i++) {
				if($i == $page){
					$result .= '	<li class="active"><a href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
				}else{
					$result .= '	<li><a href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
				}
			}

			if($nextPage <= $totalPages){
				$result .= '	<li><a href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $nextPage) . '"><span class="sr-only">Next</span> »</a></li>';	
			}

			$result .= '</ul>';

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
		
		private function remove_past_dates($resultSet){
			$result_items = array();
			$now = new DateTime('today'); // begining of the current day
			
			foreach($resultSet['items'] as $i){
				$date = new DateTime($i->pubDate);
				
				if($date > $now) $result_items[] = $i;
			}
			
			$resultSet['items'] = $result_items;
			$resultSet['meta']['total'] = count($resultSet['items']);

			return $resultSet;
		}

	}
?>