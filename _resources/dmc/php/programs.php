<?php

date_default_timezone_set('America/Los_Angeles');

error_reporting( E_ALL );
ini_set('display_errors', 1);

require_once('_core/class.dmc.php');

$programsDMC = new ProgramsDMC(); // optionally pass an alternate root relative path to data folder. Default is "/_resources/data/".

if(str_replace('\\', '/', strtolower(__FILE__)) == str_replace('\\', '/', strtolower($_SERVER['SCRIPT_FILENAME'])) && isset($_GET['datasource']) && $_GET['datasource'] != ''){
	get_programs_dmc_output(array('endpoint' => true));
}

function get_programs_dmc_output($options){
	global $programsDMC;
	return $programsDMC->get_output($options);
}

class ProgramsDMC {

	private $dmc;

	public function __construct($data_folder = null){
		$this->dmc = new DMC($data_folder);
	}

	public function get_output($options){
		$resultSet = $this->dmc->getResultSet($options);
		$templating_function = '';

		switch($resultSet['meta']['options']['type']){
			case 'listing':
			$templating_function = 'render_listing';

			$pathway = isset($_GET['pathway']) ? $_GET['pathway'] : '';
			$degreetype = isset($_GET['degreetype']) ? $_GET['degreetype'] : '';
			$startswith = isset($_GET['startswith']) ? $_GET['startswith'] : '';

			// custom filtering
			if($pathway != ''){
				$resultSet = $this->dmc->xpathFilter($resultSet, "pathway[text()='" . $pathway . "']");
			}
			if($degreetype != ''){
				$resultSet = $this->dmc->xpathFilter($resultSet, "degree-type[text()='" . $degreetype . "']");
			}
			if($startswith != ''){
				$resultSet = $this->dmc->xpathFilter($resultSet, "title[starts-with(text(), '" . $startswith . "')]");
			}


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

	public function render_listing($resultSet){
		$output = "";
		$filterForm = $this->render_filter_form($resultSet);
		$pagination = $this->render_pagination($resultSet);

		$items = $resultSet['items'];

		$output .= '<div class="container">';

		foreach($items as $i){
			$href = $i->attributes()->href;				
			$image_src = $i->image->img->attributes()->src;
			$image_alt = $i->image->img->attributes()->alt;
			if($image_src == '') $image_src = '/_resources/images/placeholder.png';
			if($image_alt == '') $image_alt = $i->title;
			$output .= '<div class="card">';
			$output .= '<div class="row">';

			$output .= '		<div class="col-4">';
			$output .= '		<img class="card-img" src="'.$image_src.'" alt="'.$image_alt.'">';
			$output .= '	</div>';
			$output .= '		<div class="col-8">';
			$output .= '		<div class="card-body">';


			$output .= '			<h2 class="card-title" ><a href="'.$href.'">'.$i->title.'</a></h2>';

			if($i->{'department'} != ''){						
				$output .= '			<h3>'.$i->{'department'}.'</h3>';
			}
			if($i->{'programType'} != ''){						
				$output .= '			<h4>'.$i->{'programType'}.'</h4>';
			}

			if($i->{'location'} != ''){						
				$output .= '			<h5>'.$i->{'location'}.'</h5>';
			}




			$output .= '		</div>';
			$output .= '	</div>';
			$output .= '	</div>';
			$output .= '</div>';
		}

		if(count($items) == 0) $output .= '<p class="no-results">No entries found with the specified filter. <strong><a href="?">Click here</a></strong> to browse all programs.</p>';

		$output .= '</div>';

		return '<div class="ou-program-finder">' . $filterForm . $output . $pagination . '</div>';
	}

	private function render_filter_form($resultSet){
		$search_phrase = isset($_GET['search_phrase']) ? $_GET['search_phrase'] : '';
		$pathway = isset($_GET['pathway']) ? $_GET['pathway'] : '';
		$degreetype = isset($_GET['degreetype']) ? $_GET['degreetype'] : '';
		$startswith = isset($_GET['startswith']) ? $_GET['startswith'] : '';

		$pathways = $this->get_pathways($resultSet);
		$degreetypes = $this->get_degreetypes($resultSet);
		$title_letters = $this->get_title_letters($resultSet);

		$result = '';

		$result .= '<form>';
		$result .= '	<div class="row">';
		$result .= '	<div class="col-12">';
		$result .= '		<label for="search_phrase">';
		$result .= '				Search';
		$result .= '			</label> <input name="search_phrase" id="search_phrase" type="search" placeholder="Program Name" value="'.$search_phrase.'"> <input value="Search" type="submit">';
		$result .= '	</div>';
		$result .= '	</div>';

		$result .= '<input name="startswith" type="hidden" value="'.$startswith.'">';
		$result .= '</form>';

		$query_string = $_SERVER['QUERY_STRING'];

		$result .= '<ul class="startswith">';
		$result .= '	<li><a href="?" data-filter="all"><span class="glyphicon glyphicon-refresh"></span>All</a></li>';
		foreach ($title_letters as $i){
			if($startswith == $i){
				$class = 'active';
			}else{
				$class = '';
			}
			$result .= '<li><a href="?'.$this->dmc->updateQuerystringParameter($query_string, 'startswith', $i).'" data-filter="'.$i.'" class="'.$class.'">'.$i.'</a></li>';
		}
		$result .= '</ul>';

		return $result;
	}

	private function get_pathways($resultSet){
		$options = array();
		$options['datasource'] = $resultSet['meta']['options']['datasource'];
		$options['xpath'] =  'distinct-lists/pathways/pathway';

		$result = $this->dmc->getResultSet($options);

		return $result['items'];
	}

	private function get_degreetypes($resultSet){
		$options = array();
		$options['datasource'] = $resultSet['meta']['options']['datasource'];
		$options['xpath'] =  'distinct-lists/degree-types/degree-type';

		$result = $this->dmc->getResultSet($options);

		return $result['items'];
	}

	private function get_title_letters($resultSet){
		$options = array();
		$options['datasource'] = $resultSet['meta']['options']['datasource'];
		$options['xpath'] =  'distinct-lists/title-letters/letter';

		$result = $this->dmc->getResultSet($options);

		return $result['items'];
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
		$result.= '<nav arial-label="...">';
		$result .= '<ul class="pagination">';
		if($previousPage > 0){
			$result .= '	<li class="page-item disabled">
			<a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $previousPage) . '">« <span class="sr-only">Previous</span></a></li>';
		}

		for ($i = 1; $i <= $totalPages; $i++) {
			if($i == $page){
				$result .= '<li class="page-item active"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . 
					'<span class="sr-only">(current) </a></li>';
			}else{
				$result .= '	<li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $i) . '">' . $i . '</a></li>';
			}
		}

		if($nextPage <= $totalPages){
			$result .= '	<li class="page-item"><a class="page-link" href="?' . $this->dmc->updateQuerystringParameter($query_string, 'page', $nextPage) . '"><span class="sr-only">Next</span> »</a></li>';	
		}

		$result .= '</ul>';
		$result .= '</nav>';

		return $result . '<br style="clear:right;" />';

	}

}
?>